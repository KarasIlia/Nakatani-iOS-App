//
//  ViewController.swift
//  SceneKitTest
//
//  Created by Илья Карась on 22.05.2020.
//  Copyright © 2020 Илья Карась. All rights reserved.
//

import UIKit
import SceneKit

class ViewController: UIViewController {

  @IBOutlet weak var sceneView: SCNView!
  @IBOutlet weak var rotateHandButton: UIButton!
  @IBOutlet weak var connectionIndicator: UIView!
  @IBOutlet weak var resistanceView: UIView!
  @IBOutlet weak var resistanceLabel: UILabel!
  @IBOutlet weak var startButton: UIButton!
  @IBOutlet weak var stopButton: UIButton!

  var scnScene = SCNScene()
  var cameraNode: SCNNode!
  
  var handNode: SCNNode!
  
  var nodePointOneOne: SCNNode!
  var nodePointOneTwo: SCNNode!
  var nodePointOneThree: SCNNode!
  
  var nodePointTwoOne: SCNNode!
  var nodePointTwoTwo: SCNNode!
  var nodePointTwoThree: SCNNode!
  
  var resistanceValues: [UInt32] = []
  
  override func viewDidLoad() {
    super.viewDidLoad()
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
  
  private func setupConnectionIndicator() {
    connectionIndicator.layer.cornerRadius = 10
    connectionIndicator.layer.shadowColor = UIColor.black.cgColor
    connectionIndicator.layer.shadowRadius = 5
    connectionIndicator.layer.shadowOpacity = 0.4
    connectionIndicator.layer.shadowOffset = CGSize(width: 1, height: 1)
  }
  
  private func setupActionButtons() {
    startButton.layer.cornerRadius = 10
    startButton.layer.shadowColor = UIColor.systemBlue.cgColor
    startButton.layer.shadowRadius = 5
    startButton.layer.shadowOpacity = 0.5
    startButton.layer.shadowOffset = CGSize(width: 1, height: 1)

    stopButton.layer.cornerRadius = 10
    stopButton.layer.shadowColor = UIColor.systemRed.cgColor
    stopButton.layer.shadowRadius = 5
    stopButton.layer.shadowOpacity = 0.5
    stopButton.layer.shadowOffset = CGSize(width: 1, height: 1)
  }
  
  private func setupResistanceView() {
    resistanceView.layer.cornerRadius = 20
    resistanceView.layer.shadowRadius = 5
    resistanceView.layer.shadowOpacity = 0.2
    resistanceView.layer.shadowColor = UIColor.black.cgColor
    resistanceView.layer.shadowOffset = CGSize(width: 1, height: 1)
  }
  
  private func setupPoints() {
    
    // Задаем геометрию для точек измерения
    let inactivePointGeometry = SCNSphere(radius: 0.04)
    inactivePointGeometry.firstMaterial?.diffuse.contents = UIColor.red
    // Убираем тени с точки
    inactivePointGeometry.firstMaterial?.lightingModel = SCNMaterial.LightingModel.constant;

    let activePointGeometry = SCNSphere(radius: 0.04)
    activePointGeometry.firstMaterial?.diffuse.contents = UIColor.systemGreen
    activePointGeometry.firstMaterial?.lightingModel = SCNMaterial.LightingModel.constant;
    
    // Получаем ноду руки из сцены по её имени "Hand"
    guard let handNode = sceneView.scene?.rootNode.childNode(withName: "Hand", recursively: false) else { return }

    // Добавляем  точки
    nodePointOneOne = SCNNode(geometry: activePointGeometry)
    nodePointOneOne.name = "Point 1-1"
    nodePointOneOne.position = SCNVector3(-0.55, -1.63, 0.21)
    handNode.addChildNode(nodePointOneOne)
    
    nodePointOneTwo = SCNNode(geometry: inactivePointGeometry)
    nodePointOneTwo.name = "Point 1-2"
    nodePointOneTwo.position = SCNVector3(-0.1, -1.6, 0.18)
    handNode.addChildNode(nodePointOneTwo)
    
    nodePointOneThree = SCNNode(geometry: inactivePointGeometry)
    nodePointOneThree.name = "Point 1-2"
    nodePointOneThree.position = SCNVector3(0.35, -1.63, 0.18)
    handNode.addChildNode(nodePointOneThree)
    
    nodePointTwoOne = SCNNode(geometry: inactivePointGeometry)
    nodePointTwoOne.name = "Point 2-1"
    nodePointTwoOne.position = SCNVector3(-0.55, -1.6, -0.34)
    handNode.addChildNode(nodePointTwoOne)
    
    nodePointTwoTwo = SCNNode(geometry: inactivePointGeometry)
    nodePointTwoTwo.name = "Point 2-2"
    nodePointTwoTwo.position = SCNVector3(-0.1, -1.6, -0.4)
    handNode.addChildNode(nodePointTwoTwo)
    
    nodePointTwoThree = SCNNode(geometry: inactivePointGeometry)
    nodePointTwoThree.name = "Point 3-2"
    nodePointTwoThree.position = SCNVector3(0.35, -1.6, -0.3)
    handNode.addChildNode(nodePointTwoThree)
  }

  private func setupScene() {
    sceneView.scene = scnScene
    sceneView.showsStatistics = false
    sceneView.allowsCameraControl = false
    sceneView.autoenablesDefaultLighting = true
    
    let leftSwipesGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(handleGesture(gesture:)))
    leftSwipesGestureRecognizer.direction = .left
    sceneView.addGestureRecognizer(leftSwipesGestureRecognizer)
    
    let rightSwipesGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(handleGesture(gesture:)))
    rightSwipesGestureRecognizer.direction = .right
    sceneView.addGestureRecognizer(rightSwipesGestureRecognizer)

  }
  
  private func setupCamera() {
    cameraNode = SCNNode()
    cameraNode.camera = SCNCamera()
    cameraNode.position = SCNVector3(x: 0, y: 0, z: 6)
    scnScene.rootNode.addChildNode(cameraNode)
  }
  
  override var shouldAutorotate: Bool {
    return true
  }

  override var prefersStatusBarHidden: Bool {
    return true
  }

  private func addHand() {
    let handScene = SCNScene(named: "art.scnassets/hand.scn")
    guard let handNode = handScene?.rootNode.childNode(withName: "Hand", recursively: false) else { return }
    sceneView.scene?.rootNode.addChildNode(handNode)
  }
  
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
  }
  
  @IBAction func stopADC() {
    sendRequest(for: .stopADC)
    resistanceValues = []
  }
}


// BlueTooth Extension
extension ViewController {
  
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
      // Set image based on connection status
      if let value = userInfo["value"] {
        resistanceValues.append(value)
        resistanceLabel.text = "\(value) Ом"
      }
    });
  }
  
  func sendRequest(for signal: PeripheralSignals) {
    // Send position to BLE device (if service exists and is connected)
    if let bleService = btDiscoverySharedInstance.bleService {
      bleService.sendDataRequest(for: signal)
    }
  }
}


