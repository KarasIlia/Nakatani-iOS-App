//
//  SetupResearchSettingsViewController.swift
//  Nakatani
//
//  Created by Илья Карась on 09.11.2020.
//  Copyright © 2020 Илья Карась. All rights reserved.
//

import UIKit

class SetupResearchSettingsViewController: UIViewController {
  
  @IBOutlet weak var startResearchButton: UIButton!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupStartButton()
  }
  
  private func setupStartButton() {
    startResearchButton.layer.cornerRadius = 30
    startResearchButton.layer.borderWidth = 2
    startResearchButton.layer.borderColor = UIColor.systemGreen.cgColor
    
    startResearchButton.layer.shadowColor = UIColor.systemGreen.cgColor
    startResearchButton.layer.shadowRadius = 5
    startResearchButton.layer.shadowOpacity = 0.5
    startResearchButton.layer.shadowOffset = CGSize(width: 1, height: 1)
  }
  
}
