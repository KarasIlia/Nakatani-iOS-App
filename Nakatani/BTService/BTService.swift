//
//  BTService.swift
//  SceneKitTest
//
//  Created by Илья Карась on 23.10.2020.
//  Copyright © 2020 Илья Карась. All rights reserved.
//

import Foundation
import CoreBluetooth

/* Services & Characteristics UUIDs */
let BLEServiceUUID = CBUUID(string: "FFE0")
let CharUUID = CBUUID(string: "FFE1")
let BLEServiceChangedStatusNotification = "kBLEServiceChangedStatusNotification"
let BLEServiceObtainedResistanceNotification = "kBLEServiceObtainedResistanceNotification"

let batteryLevelRequest: [UInt8] = [0x23, 0x42]
let startADCRequest = [0x23, 0x52]
let stopADCRequest = [0x23, 0x53]
let versionRequest = [0x23, 0x56]

class BTService: NSObject, CBPeripheralDelegate {
  var peripheral: CBPeripheral?
  var resistanceCharacteristic: CBCharacteristic?
  
  init(initWithPeripheral peripheral: CBPeripheral) {
    super.init()
    
    self.peripheral = peripheral
    self.peripheral?.delegate = self
  }
  
  deinit {
    self.reset()
  }
  
  func startDiscoveringServices() {
    self.peripheral?.discoverServices([BLEServiceUUID])
  }
  
  func reset() {
    if peripheral != nil {
      peripheral = nil
    }
    
    // Deallocating therefore send notification
    self.sendBTServiceNotificationWithIsBluetoothConnected(false)
  }
  
  // Mark: - CBPeripheralDelegate
  
  func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
    let uuidsForBTService: [CBUUID] = [CharUUID]
    
    if (peripheral != self.peripheral) {
      // Wrong Peripheral
      return
    }
    
    if (error != nil) {
      return
    }
    
    if ((peripheral.services == nil) || (peripheral.services!.count == 0)) {
      // No Services
      return
    }
    
    for service in peripheral.services! {
      if service.uuid == BLEServiceUUID {
        peripheral.discoverCharacteristics(uuidsForBTService, for: service)
      }
    }
  }
  
  func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
    if (peripheral != self.peripheral) {
      // Wrong Peripheral
      return
    }
    
    if (error != nil) {
      return
    }
    
    if let characteristics = service.characteristics {
      for characteristic in characteristics {
        if characteristic.uuid == CharUUID {
          resistanceCharacteristic = (characteristic)
          peripheral.setNotifyValue(true, for: characteristic)
          
          // Send notification that Bluetooth is connected and all required characteristics are discovered
          self.sendBTServiceNotificationWithIsBluetoothConnected(true)
        }
      }
    }
  }
  
  func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
    if let error = error {
      print(#function, error.localizedDescription)
      return
    }

    if
      characteristic.uuid == ParticlePeripheral.resistanceCharacteristicUUID,
      let newValue = characteristic.value,
      let string = String(bytes: newValue, encoding: .ascii)
    {
      let prefix = String(string[...1])
      let valueData = newValue.subdata(in: 2..<6)
      let value = valueData.withUnsafeBytes { $0.load(as: UInt32.self) }

      print(value)

      switch prefix {
      case "#B":
        print("Battery packet")
      // Start ADC
      case "#R":
        print("Start ADC packet")
      // Stop ADC
      case "#S":
        print("Stop ADC packet")
      // ADC data
      case "#M":
        let resistanceDetails = ["value": value]
        NotificationCenter.default.post(name: Notification.Name(rawValue: BLEServiceObtainedResistanceNotification), object: self, userInfo: resistanceDetails)
        print("ADC data packet")
      default:
        break
      }
    }
  }
  
  // Mark: - Private
  
  func sendDataRequest(for signal: PeripheralSignals) {
    
    // See if characteristic has been discovered before writing to it
    if let resistanceCharacteristic = resistanceCharacteristic {
      var bytesArray: [UInt8] = []
      
      switch signal {
      case .batteryLevel:
        bytesArray = [0x23, 0x42]
      case .startADC:
        bytesArray = [0x23, 0x52]
      case .stopADC:
        bytesArray = [0x23, 0x53]
      case .version:
        bytesArray = [0x23, 0x56]
      }

      self.peripheral?.writeValue(Data(bytesArray), for: resistanceCharacteristic, type: .withoutResponse)
    }
  }
  
  func sendBTServiceNotificationWithIsBluetoothConnected(_ isBluetoothConnected: Bool) {
    let connectionDetails = ["isConnected": isBluetoothConnected]
    NotificationCenter.default.post(name: Notification.Name(rawValue: BLEServiceChangedStatusNotification), object: self, userInfo: connectionDetails)
  }
  
}
