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

  // MARK: - Properties
  var scnScene = SCNScene()
  var cameraNode: SCNNode!
  
  var handNode: SCNNode!
  
  var nodePointOneOne: SCNNode!
  var nodePointOneTwo: SCNNode!
  var nodePointOneThree: SCNNode!
  
  var nodePointTwoOne: SCNNode!
  var nodePointTwoTwo: SCNNode!
  var nodePointTwoThree: SCNNode!
  
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
  
  // MARK: - Life cycle
  override func viewDidLoad() {
    super.viewDidLoad()
    researchProcessManager = ResearchProcessManager(researchObject: .leftHand)
    researchProcessManager.delegate = self
    
    setupScene()
    setupCamera()
    addHand()
    setupPoints()
    setupResistanceView()
    setupActionButtons()
    setupConnectionIndicator()
    
    // Watch Bluetooth connection
    NotificationCenter.default.addObserver(self, selector: #selector(self.connectionChanged(_:)), name: NSNotification.Name(rawValue: BLEServiceChangedStatusNotification), object: nil)
    
    // Watch for resistance packets
    NotificationCenter.default.addObserver(self, selector: #selector(self.resistanceObtained(_:)), name: NSNotification.Name(rawValue: BLEServiceObtainedResistanceNotification), object: nil)
    
    // Start the Bluetooth discovery process
    _ = btDiscoverySharedInstance
  }
  
  override var shouldAutorotate: Bool {
    return true
  }

  override var prefersStatusBarHidden: Bool {
    return true
  }
  
  // MARK: - @IBAction & @objc functions
  
  @objc func handleGesture(gesture: UISwipeGestureRecognizer) -> Void {
    let hand = sceneView.scene?.rootNode.childNode(withName: "Hand", recursively: true)!

    if gesture.direction == .right {
      hand?.runAction(SCNAction.rotateBy(x: 0, y: .pi, z: 0, duration: 0.5))
    }
    else if gesture.direction == .left {
      hand?.runAction(SCNAction.rotateBy(x: 0, y: -.pi, z: 0, duration: 0.5))
    }
  }
  
  @IBAction func startADC() {
    sendRequest(for: .startADC)
    nodePointOneOne.runAction(activePointAnimation)
  }
  
  @IBAction func stopADC() {
    sendRequest(for: .stopADC)
    resistanceValues = []
    nodePointOneOne.removeAllActions()
  }
}

// MARK: - ResultHandlerDelegate
extension ResearchViewController: ResultHandlerDelegate {
  func researchProcessManager(didComplete research: ResearchProcessManager, result: [UInt32]) {
    // TODO: Send result to server or save to the CoreData
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
        if value > 0 {
          resistanceValues.append(value)
        }
      }
      
      DispatchQueue.global(qos: .userInitiated).async {
        if
          let max = resistanceValues.max(),
          max < 90_000,
          let min = resistanceValues.min(),
          max - min < 5000,
          let average = resistanceValues.average()
        {
          stopADC()
          print(#line, #function, average)
        }
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
