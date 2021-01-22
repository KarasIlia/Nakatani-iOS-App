//
//  ResearchViewController.swift
//  SceneKitTest
//
//  Created by Илья Карась on 22.05.2020.
//  Copyright © 2020 Илья Карась. All rights reserved.
//

import UIKit
import SceneKit

class ResearchViewController: UIViewController {

  // MARK: - @IBOutlets
  @IBOutlet weak var sceneView: SCNView!
  @IBOutlet weak var connectionIndicator: UIView!
  @IBOutlet weak var resistanceView: UIView!
  @IBOutlet weak var resistanceLabel: UILabel!
  @IBOutlet weak var startButton: UIButton!
  @IBOutlet weak var stopButton: UIButton!
  @IBOutlet weak var researchStateLabel: UILabel!

  // MARK: - Properties
  var scnScene = SCNScene()
  var cameraNode: SCNNode!
  var handNode: SCNNode!
   
  var actToGreen: SCNAction = {
    SCNAction.customAction(duration: 0.7, action: { (node, elapsedTime) in
      node.geometry?.firstMaterial?.diffuse.contents = UIColor.systemGreen
    })
  }()

  var actToRed: SCNAction = {
    SCNAction.customAction(duration: 0.7, action: { (node, elapsedTime) in
      node.geometry?.firstMaterial?.diffuse.contents = UIColor.red
    })
  }()
  
  var activePointAnimation: SCNAction = {
    let duration: TimeInterval = 0.7
    
    let actToGreen = SCNAction.customAction(duration: duration, action: { (node, elapsedTime) in
      node.geometry?.firstMaterial?.diffuse.contents = UIColor.systemGreen
    })

    let actToRed = SCNAction.customAction(duration: duration, action: { (node, elapsedTime) in
      node.geometry?.firstMaterial?.diffuse.contents = UIColor.red
    })

    let act = SCNAction.repeatForever(SCNAction.sequence([actToGreen, actToRed]))
    return act
  }()
  
  var resistanceValues: [UInt32] = [] {
    didSet {
      if resistanceValues.count > 20 {
        resistanceValues.removeFirst()
      }
    }
  }
  
  var researchProcessManager: ResearchProcessManager!
  
  deinit {
    print("ResearchViewController deinit")
  }
  
  // MARK: - Life cycle
  override func viewDidLoad() {
    super.viewDidLoad()
    researchProcessManager = ResearchProcessManager(researchObject: .leftHand)
    researchProcessManager.delegate = self
    
    setupScene()
    setupCamera()
    addHand()
    setupPoints(using: researchProcessManager.doublyLinkedPoints.getNodes())
    setupResistanceView()
    setupActionButtons()
    setupConnectionIndicator()
    
    // Watch Bluetooth connection
    NotificationCenter.default.addObserver(self, selector: #selector(self.connectionChanged(_:)), name: NSNotification.Name(rawValue: BLEServiceChangedStatusNotification), object: nil)
    
    // Watch for resistance packets
    NotificationCenter.default.addObserver(self, selector: #selector(self.resistanceObtained(_:)), name: NSNotification.Name(rawValue: BLEServiceObtainedResistanceNotification), object: nil)
    NotificationCenter.default.addObserver(researchProcessManager!, selector: #selector(researchProcessManager.resistanceObtained(_:)), name: NSNotification.Name(rawValue: BLEServiceObtainedResistanceNotification), object: nil)
    
    // Start the Bluetooth discovery process
    _ = btDiscoverySharedInstance
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    researchProcessManager.start()
  }
  
  override var shouldAutorotate: Bool {
    return true
  }

  override var prefersStatusBarHidden: Bool {
    return true
  }
  
  func rotateHand(_ direction: UISwipeGestureRecognizer.Direction) {
    let hand = sceneView.scene?.rootNode.childNode(withName: "Hand", recursively: true)!

    if direction == .right {
      hand?.runAction(SCNAction.rotateBy(x: 0, y: .pi, z: 0, duration: 0.5))
    }
    else if direction == .left {
      hand?.runAction(SCNAction.rotateBy(x: 0, y: -.pi, z: 0, duration: 0.5))
    }
  }
  
  // MARK: - @IBAction & @objc functions
  
  @objc func handleGesture(gesture: UISwipeGestureRecognizer) {
//    rotateHand(gesture.direction)
  }
  
  @IBAction func startADC() {
    sendRequest(for: .startADC)
  }
  
  @IBAction func stopADC() {
    sendRequest(for: .stopADC)
    resistanceValues = []
  }
}

// MARK: - ResultHandlerDelegate
extension ResearchViewController: ResultHandlerDelegate {
  
  func researchProcessManager(researchStartedFor node: NodePoint) {
    DispatchQueue.main.async {
      self.researchStateLabel.text = "Проводится измерение..."
    }
  }
  
  func researchProcessManager(didCompleteWithResult: DoubleLinkedNodeList) {
    print("Research completed")
    rotateHand(.left)
    DispatchQueue.main.async {
      self.researchStateLabel.text = "Исследование завершено. Сохранение результатов..."
    }
    // TODO: Form JSON and send the result to the server or save to the CoreData
  }
  
  func researchProcessManager(activeNodeChangedTo node: NodePoint) {
    print("Active node changed to \(node.sceneNode.name!)")
    if node.sceneNode.name == "Point 4" {
      rotateHand(.right)
    }
    node.sceneNode.runAction(activePointAnimation)
    DispatchQueue.main.async {
      self.researchStateLabel.text = "Измерение в точке завершено. Приложите ручку к следующей точке."
    }
  }
  
  func researchProcessManager(didCompleteResearchFor node: NodePoint) {
    print("Value for node \(node.sceneNode.name!) was calculated")
    node.sceneNode.removeAllActions()
    node.sceneNode.runAction(actToGreen)
  }
}

// MARK: - Bluetooth Extension
extension ResearchViewController {
  
  @objc func connectionChanged(_ notification: Notification) {
    // Connection status changed. Indicate on GUI.
    let userInfo = (notification as NSNotification).userInfo as! [String: Bool]
    
    DispatchQueue.main.async(execute: { [self] in
      // Set image based on connection status
      if let isConnected: Bool = userInfo["isConnected"] {
        if isConnected {
          connectionIndicator.backgroundColor = .systemBlue
        } else {
          connectionIndicator.backgroundColor = .systemRed
        }
      }
    });
  }
  
  @objc func resistanceObtained(_ notification: Notification) {
    // Resistance value obtained. Indicate on GUI.
    let userInfo = (notification as NSNotification).userInfo as! [String: UInt32]
    
    DispatchQueue.main.async(execute: { [self] in
      if let value = userInfo["value"] {
        resistanceLabel.text = "\(value) Ом"
      }
    });
  }
  
  private func sendRequest(for signal: PeripheralSignals) {
    // Send position to BLE device (if service exists and is connected)
    if let bleService = btDiscoverySharedInstance.bleService {
      bleService.sendDataRequest(for: signal)
    }
  }
}
