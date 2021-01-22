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

enum ResearchState {
  case researchStarted
  case pointCalculating
  case pointCalculatingCompleted
  case researchCompleted
}

protocol ResultHandlerDelegate: AnyObject {
  func researchProcessManager(didCompleteWithResult: DoubleLinkedNodeList)
  func researchProcessManager(activeNodeChangedTo node: NodePoint)
  func researchProcessManager(didCompleteResearchFor node: NodePoint)
  func researchProcessManager(researchStartedFor node: NodePoint)
}

final class ResearchProcessManager: NSObject {
  weak var delegate: ResultHandlerDelegate?
  var currentPoint: NodePoint!
  var doublyLinkedPoints: DoubleLinkedNodeList!
  var researchObject: ResearchObject
  var currentResistanceValues: [UInt32] = [] {
    didSet {
      if currentResistanceValues.count > 20 {
        currentResistanceValues.removeFirst()
      }
    }
  }
  
  var previousState: ResearchState? = nil
  var currentState: ResearchState = .researchStarted {
    didSet {
      if let previousState = previousState, previousState == .pointCalculatingCompleted && currentState == .pointCalculating {
        delegate?.researchProcessManager(researchStartedFor: currentPoint)
      }
      previousState = oldValue
    }
  }

  /// A trigger that is needed to indicate that the user has removed
  /// the pen from the skin and we can go to the next point
  var isValueCalculated: Bool = false {
    didSet {
      if isValueCalculated {
        currentState = .pointCalculatingCompleted
      }
    }
  }
  var isResearchCompleted: Bool = false
  
  init(researchObject: ResearchObject) {
    self.researchObject = researchObject
    
    switch self.researchObject {
    case .leftHand:
      self.doublyLinkedPoints = DoubleLinkedNodeList.leftHandPoints
      self.currentPoint = doublyLinkedPoints.head
    case .rightHand:
      break
    case .leftFoot:
      break
    case .rightFoot:
      break
    }
  }
  
  func start() {
    self.sendRequest(for: .startADC)
  }
  
  private func researchCompleted() {
    currentPoint = nil
    isResearchCompleted = true
    sendRequest(for: .stopADC)
    delegate?.researchProcessManager(didCompleteWithResult: self.doublyLinkedPoints)
  }
    
  private func nodeValueCalculated(value: UInt32) {
    currentPoint.value = value
    delegate?.researchProcessManager(didCompleteResearchFor: currentPoint)
  }
  
  private func toTheNextPoint() {
    if let nextPoint = currentPoint.next {
      currentPoint = nextPoint
      delegate?.researchProcessManager(activeNodeChangedTo: currentPoint)
    } else {
      researchCompleted()
    }
  }
}

// MARK: - Bluetooth Extension

extension ResearchProcessManager {
  
  @objc func resistanceObtained(_ notification: Notification) {
    let userInfo = (notification as NSNotification).userInfo as! [String: UInt32]
    DispatchQueue.main.async(execute: { [self] in
      guard let value = userInfo["value"] else { return }
      if isResearchCompleted {
        return
      } else if value > 0 && !isValueCalculated {
        currentState = .pointCalculating
        currentResistanceValues.append(value)
      } else if value == 0 && isValueCalculated {
        currentResistanceValues = []
        // The user pulled the pen away from the skin and now we can calculate next point resistance.
        isValueCalculated = false
        return
      }
      
      guard !isValueCalculated else { return }
      
      DispatchQueue.global(qos: .userInitiated).async {
        if
          let max = currentResistanceValues.max(),
          max < 90_000,
          let min = currentResistanceValues.min(),
          max - min < 5000,
          let average = currentResistanceValues.average()
        {
          isValueCalculated = true
          nodeValueCalculated(value: average)
          toTheNextPoint()
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
