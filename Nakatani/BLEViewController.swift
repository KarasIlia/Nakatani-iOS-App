//
//  BLEViewController.swift
//  SceneKitTest
//
//  Created by Илья Карась on 17.10.2020.
//  Copyright © 2020 Илья Карась. All rights reserved.
//

import UIKit
import CoreBluetooth

class ParticlePeripheral {

    /// MARK: - Device, services and characteristics Identifiers
    public static let deviceUUID = UUID(uuidString: "324F49FB-4D86-FD33-D254-EFA06E241A64")
    public static let resistanceServiceUUID = CBUUID(string: "FFE0")
    public static let resistanceCharacteristicUUID = CBUUID(string: "FFE1")
}

enum PeripheralSignals: String {
  case batteryLevel
  case startADC
  case stopADC
  case version
}

class BLEViewController: UIViewController {
  
  @IBOutlet weak var logTextView: UITextView!
  @IBOutlet weak var valueLabel: UILabel!
  
  private var manager: CBCentralManager!
  private var connectedPeripheral: CBPeripheral!
  private var characteristic: CBCharacteristic?
  
  private var logStringDate: String {
    get {
      let dateFormatter = DateFormatter()
      dateFormatter.dateFormat = "HH:mm:ss"
      return dateFormatter.string(from: Date())
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    manager = CBCentralManager(delegate: self, queue: nil)
    logTextView.isEditable = false
  }
}

// MARK: - CBCentralManagerDelegate
extension BLEViewController: CBCentralManagerDelegate {
  
  func centralManagerDidUpdateState(_ central: CBCentralManager) {
    print("Central state update")
    logTextView.text += "\(logStringDate) Central state update\n"
    if central.state == .poweredOn {
      print("Scanning for peripherals")
      logTextView.text += "\(logStringDate) Scanning for peripherals\n"

      manager.scanForPeripherals(withServices: [ParticlePeripheral.resistanceServiceUUID])
    } else {
      print("Central is not powered on")
      logTextView.text += "\(logStringDate) Central is not powered on\n"

    }
  }
  
  func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
    if peripheral == connectedPeripheral {
      print("Connected to the Nakatani Device")
      logTextView.text += "\(logStringDate) Connected to the Nakatani Device\n"

      // Stop scanning coz peripheral was connected
      manager.stopScan()
      
      // Discover peripheral's services
      connectedPeripheral.discoverServices(nil)
    }
  }
  
  func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
    if let error = error {
      print("Connection error: \(error.localizedDescription)")
      return
    }
    self.connectedPeripheral = nil
    manager.scanForPeripherals(withServices: [ParticlePeripheral.resistanceServiceUUID])
  }
  
  func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
    print("Discovered peripheral: \(peripheral.name ?? "without name")")
    logTextView.text += "\(logStringDate) Discovered peripheral: \(peripheral.name ?? "without name")\n"

    if peripheral.identifier == ParticlePeripheral.deviceUUID {
      // Save strong reference to the peripheral and set delegate
      connectedPeripheral = peripheral
      connectedPeripheral.delegate = self
      
      // Connect to the found peripheral
      manager.connect(connectedPeripheral, options: nil)
    }
  }
  
  private func writeValue(for signal: PeripheralSignals) {
    guard let characteristic = self.characteristic else { return }
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
    
    if characteristic.properties.contains(.writeWithoutResponse) && connectedPeripheral != nil {
      connectedPeripheral.writeValue(Data(bytesArray), for: characteristic, type: .withoutResponse)
    }
  }
  
  @IBAction func clearLogs() {
    logTextView.text = nil
  }
  
  @IBAction func startADC() {
    writeValue(for: .startADC)
  }
  
  @IBAction func stopADC() {
    writeValue(for: .stopADC)
  }
  
  @IBAction func getBatteryLevel() {
    writeValue(for: .batteryLevel)
  }
}

// MARK: - CBPeripheralDelegate
extension BLEViewController: CBPeripheralDelegate {
  
  func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
    guard let services = peripheral.services else { return }
    
    for service in services {
      // Discover service's characteristics
      print("Discovered service UUID: \(service.uuid.uuidString) for peripheral: \(peripheral.name!)")
      logTextView.text += "\(logStringDate) Discovered service UUID: \(service.uuid.uuidString) for peripheral: \(peripheral.name!)\n"

      peripheral.discoverCharacteristics(nil, for: service)
    }
  }
  
  func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
    for characteristic in service.characteristics! {
      print("Discovered characteristic UUID: \(characteristic.uuid.uuidString) for service: \(service.uuid.uuidString)")
      logTextView.text += "\(logStringDate) Discovered characteristic UUID: \(characteristic.uuid.uuidString) for service: \(service.uuid.uuidString)\n"

      if (characteristic.uuid == ParticlePeripheral.resistanceCharacteristicUUID) {
        // Subscribe to notifications of resistance characteristic
        print("Subscribed to notifications of characteristic:", characteristic.uuid.uuidString)
        logTextView.text += "\(logStringDate) Subscribed to notifications of characteristic: \(characteristic.uuid.uuidString)\n"
        
        // Save characteristic
        self.characteristic = characteristic
        
        peripheral.setNotifyValue(true, for: characteristic)
        writeValue(for: .stopADC)
      }
    }
  }
  
  // Get value of characteristic
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
        valueLabel.text = "Заряд батареи: \(value)%"
        logTextView.text += "\(logStringDate) Battery level received\n"
        print("Battery packet")
      // Start ADC
      case "#R":
        print("Start ADC packet")
        logTextView.text += "\(logStringDate) Start measuring resistance\n"
      // Stop ADC
      case "#S":
        valueLabel.text = ""
        print("Stop ADC packet")
        logTextView.text += "\(logStringDate) End of resistance measurement\n"
      // ADC data
      case "#M":
        valueLabel.text = "Сопротивление: \(value) Ом"
        print("ADC data packet")
      default:
        break
      }
    }
  }
}
