//
//  DoubleLinkedNodeList.swift
//  Nakatani
//
//  Created by Илья Карась on 01.11.2020.
//  Copyright © 2020 Илья Карась. All rights reserved.
//

import Foundation
import SceneKit

class NodePoint: Equatable {
  var value: UInt32? = nil
  var next: NodePoint? = nil
  var prev: NodePoint? = nil
  var sceneNode: SCNNode
  
  init(name: String, sceneNode: SCNNode) {
    sceneNode.name = name
    self.sceneNode = sceneNode
  }
  
  static func == (lhs: NodePoint, rhs: NodePoint) -> Bool { lhs.sceneNode.name == rhs.sceneNode.name }
}

class DoubleLinkedNodeList {
  var head: NodePoint? = nil
  var tail: NodePoint? = nil
  var size: Int = 0
  
  // Add node to the end of the list
  func append(name: String, sceneNode: SCNNode) {
    let newNode = NodePoint(name: name, sceneNode: sceneNode)
    
    guard self.head != nil else {
      self.head = newNode
      self.tail = newNode
      self.size += 1
      return
    }
    
    self.tail?.next = newNode
    newNode.prev = self.tail
    self.tail = newNode
    
    self.size += 1
  }
  
  // Add node to the start of the list
  func prepend(name: String, sceneNode: SCNNode) {
    let newNode = NodePoint(name: name, sceneNode: sceneNode)
    
    guard self.head != nil else {
      self.head = newNode
      self.tail = newNode
      self.size += 1
      return
    }
    
    self.head?.prev = newNode
    newNode.next = self.head
    self.head = newNode
    
    self.size += 1
  }
  
  func items() -> [NodePoint?] {
    guard self.head != nil else {
      return []
    }
    
    var allItems = [NodePoint]()
    var curr = self.head
    
    while let current = curr {
      allItems.append(current)
      curr = curr?.next
    }
    
    return allItems
  }
  
  func getNodes() -> [SCNNode?] {
    guard self.head != nil else {
      return []
    }
    
    var allNodes = [SCNNode]()
    var curr = self.head
    
    while let current = curr {
      allNodes.append(current.sceneNode)
      curr = curr?.next
    }
    
    return allNodes
  }
  
  /// Function parse double linked list and returns calculated values
  /// - Returns: [Point Name: Point Value]
  func getResultDictionary() -> [String: UInt32] {
    guard self.head != nil else {
      return [:]
    }
    
    var calculatedValues: [String: UInt32] = [:]
    var curr = self.head
    
    while let current = curr {
      calculatedValues[current.sceneNode.name!] = current.value
      curr = curr?.next
    }
    
    return calculatedValues
  }
  
  
  static let leftHandPoints: DoubleLinkedNodeList = {
    let doubleLinked = DoubleLinkedNodeList()
    let nodes = prepareNodes()
    
    nodes.enumerated().forEach { (index, node) in
      doubleLinked.append(name: "Point \(index + 1)", sceneNode: node)
    }
    
    return doubleLinked
  }()
  
  static func prepareNodes() -> [SCNNode] {
    // Задаем геометрию для точек измерения
    let pointGeometry = SCNSphere(radius: 0.04)
    pointGeometry.firstMaterial?.diffuse.contents = UIColor.red
    // Убираем тени с точки
    pointGeometry.firstMaterial?.lightingModel = SCNMaterial.LightingModel.constant
    
    // Добавляем  точки
    let pointOneNode = SCNNode(geometry: pointGeometry.copy() as? SCNGeometry)
    pointOneNode.geometry?.firstMaterial = pointGeometry.firstMaterial?.copy() as? SCNMaterial
    pointOneNode.geometry?.firstMaterial?.diffuse.contents = UIColor.red
    pointOneNode.position = SCNVector3(-0.55, -1.63, 0.21)
    
    let pointTwoNode = SCNNode(geometry: pointGeometry.copy() as? SCNGeometry)
    pointTwoNode.geometry?.firstMaterial = pointGeometry.firstMaterial?.copy() as? SCNMaterial
    pointTwoNode.geometry?.firstMaterial?.diffuse.contents = UIColor.red

    pointTwoNode.position = SCNVector3(-0.1, -1.6, 0.18)
    
    let pointThreeNode = SCNNode(geometry: pointGeometry.copy() as? SCNGeometry)
    pointThreeNode.geometry?.firstMaterial = pointGeometry.firstMaterial?.copy() as? SCNMaterial
    pointThreeNode.geometry?.firstMaterial?.diffuse.contents = UIColor.red

    pointThreeNode.position = SCNVector3(0.35, -1.63, 0.18)
    
    let pointFourNode = SCNNode(geometry: pointGeometry.copy() as? SCNGeometry)
    pointFourNode.geometry?.firstMaterial = pointGeometry.firstMaterial?.copy() as? SCNMaterial
    pointFourNode.geometry?.firstMaterial?.diffuse.contents = UIColor.red

    pointFourNode.position = SCNVector3(-0.55, -1.6, -0.34)
    
    let pointFiveNode = SCNNode(geometry: pointGeometry.copy() as? SCNGeometry)
    pointFiveNode.geometry?.firstMaterial = pointGeometry.firstMaterial?.copy() as? SCNMaterial
    pointFiveNode.geometry?.firstMaterial?.diffuse.contents = UIColor.red

    pointFiveNode.position = SCNVector3(-0.1, -1.6, -0.4)
    
    let pointSixNode = SCNNode(geometry: pointGeometry.copy() as? SCNGeometry)
    pointSixNode.geometry?.firstMaterial = pointGeometry.firstMaterial?.copy() as? SCNMaterial
    pointSixNode.geometry?.firstMaterial?.diffuse.contents = UIColor.red

    pointSixNode.position = SCNVector3(0.35, -1.6, -0.3)
    
    return [pointOneNode, pointTwoNode, pointThreeNode, pointFourNode, pointFiveNode, pointSixNode]
  }
}
