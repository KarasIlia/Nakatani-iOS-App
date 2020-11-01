//
//  DoublyLinkedPointsList + Point.swift
//  Nakatani
//
//  Created by Илья Карась on 01.11.2020.
//  Copyright © 2020 Илья Карась. All rights reserved.
//

import Foundation

class Point: Equatable {
  var value: UInt32? = nil
  var next: Point? = nil
  var prev: Point? = nil
  var name: String
  
  init(name: String) {
    self.name = name
  }
  
  static func == (lhs: Point, rhs: Point) -> Bool {
    return lhs.name == rhs.name
  }
}

class DoublyLinkedPointList {
  var head: Point? = nil
  var tail: Point? = nil
  var size: Int = 0
  
  func append(name: String) {
    // 1
    let newNode = Point(name: name)
    
    // 2
    guard self.head != nil else {
      // 3
      self.head = newNode
      self.tail = newNode
      self.size += 1
      return
    }
    
    // 4
    self.tail?.next = newNode
    newNode.prev = self.tail
    self.tail = newNode
    
    // 5
    self.size += 1
  }
  
  func prepend(name: String) {
    // 1
    let newNode = Point(name: name)
    
    // 2
    guard self.head != nil else {
      // 3
      self.head = newNode
      self.tail = newNode
      self.size += 1
      return
    }
    
    // 4
    self.head?.prev = newNode
    newNode.next = self.head
    self.head = newNode
    
    // 5
    self.size += 1
  }
  
  func items() -> [Point?] {
      // 1
      guard self.head != nil else {
          return []
      }
      
      // 2
      var allItems = [Point]()
      var curr = self.head
      
      // 3
      while let current = curr {
          allItems.append(current)
          curr = curr?.next
      }
      
      // 4
      return allItems
  }
  
  static let leftHandPoints: DoublyLinkedPointList = {
    let doubleLinked = DoublyLinkedPointList()
    doubleLinked.append(name: "Point 1-1")
    doubleLinked.append(name: "Point 1-2")
    doubleLinked.append(name: "Point 1-3")
    
    doubleLinked.append(name: "Point 2-1")
    doubleLinked.append(name: "Point 2-2")
    doubleLinked.append(name: "Point 2-3")
    return doubleLinked
  }()
}
