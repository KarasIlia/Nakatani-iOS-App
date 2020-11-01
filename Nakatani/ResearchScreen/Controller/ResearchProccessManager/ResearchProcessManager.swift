//
//  ResearchProcessManager.swift
//  Nakatani
//
//  Created by Илья Карась on 30.10.2020.
//  Copyright © 2020 Илья Карась. All rights reserved.
//

import Foundation

enum ResearchObject {
  case leftHand
  case rightHand
  case leftFoot
  case rightFoot
}

class ResearchProcessManager: NSObject {
  var currentPoint: Point!
  var doublyLinkedPoints: DoublyLinkedPointList!
  
  var researchObject: ResearchObject
  
  weak var delegate: ResultHandlerDelegate?
  
  init(researchObject: ResearchObject) {
    self.researchObject = researchObject
    
    switch self.researchObject {
    case .leftHand:
      self.doublyLinkedPoints = DoublyLinkedPointList.leftHandPoints
      self.currentPoint = doublyLinkedPoints.head
    case .rightHand:
      break
    case .leftFoot:
      break
    case .rightFoot:
      break
    }
  }
  
  private func researchCompleted() {
    delegate?.researchProcessManager(didComplete: self, result: [])
  }
  
  func toTheNextPoint() {
    currentPoint = currentPoint.next
  }
}

protocol ResultHandlerDelegate: AnyObject {
  func researchProcessManager(didComplete research: ResearchProcessManager, result: [UInt32])
}
