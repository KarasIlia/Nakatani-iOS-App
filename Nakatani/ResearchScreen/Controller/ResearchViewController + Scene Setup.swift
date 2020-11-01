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
  
  func setupPoints(using nodes: [SCNNode?]) {
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
    
    nodes.forEach { (node) in
      if let node = node {
        handNode.addChildNode(node)
      }
    }
    nodes[0]?.runAction(activePointAnimation)
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
