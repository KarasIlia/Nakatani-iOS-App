//
//  ResearchViewController + UI Elements Setup.swift
//  Nakatani
//
//  Created by Илья Карась on 01.11.2020.
//  Copyright © 2020 Илья Карась. All rights reserved.
//

import UIKit

// MARK: - UI setup methods
extension ResearchViewController {
  
  func setupConnectionIndicator() {
    connectionIndicator.layer.cornerRadius = 10
    connectionIndicator.layer.shadowColor = UIColor.black.cgColor
    connectionIndicator.layer.shadowRadius = 5
    connectionIndicator.layer.shadowOpacity = 0.4
    connectionIndicator.layer.shadowOffset = CGSize(width: 1, height: 1)
  }
  
  func setupActionButtons() {
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
  
  func setupResistanceView() {
    resistanceView.layer.cornerRadius = 20
    resistanceView.layer.shadowRadius = 5
    resistanceView.layer.shadowOpacity = 0.2
    resistanceView.layer.shadowColor = UIColor.black.cgColor
    resistanceView.layer.shadowOffset = CGSize(width: 1, height: 1)
  }
}
