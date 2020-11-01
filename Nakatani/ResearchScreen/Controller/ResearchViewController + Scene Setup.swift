//
//  ResearchViewController + Scene Setup.swift
//  Nakatani
//
//  Created by Илья Карась on 01.11.2020.
//  Copyright © 2020 Илья Карась. All rights reserved.
//

import Foundation
import SceneKit

extension ResearchViewController {
  
  func addHand() {
    let handScene = SCNScene(named: "art.scnassets/hand.scn")
    guard let handNode = handScene?.rootNode.childNode(withName: "Hand", recursively: false) else { return }
    sceneView.scene?.rootNode.addChildNode(handNode)
  }
  
  func setupPoints() {
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

  func setupScene() {
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
  
  func setupCamera() {
    cameraNode = SCNNode()
    cameraNode.camera = SCNCamera()
    cameraNode.position = SCNVector3(x: 0, y: 0, z: 6)
    scnScene.rootNode.addChildNode(cameraNode)
  }
}
