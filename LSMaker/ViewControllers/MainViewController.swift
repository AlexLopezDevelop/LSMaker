//
//  MainViewController.swift
//  LSMaker
//
//  Created by Alex Lopez on 04/08/2020.
//  Copyright © 2020 Alex Lopez. All rights reserved.
//

import UIKit
import CoreBluetooth

var drivingDataManager: DrivingDataManager = DrivingDataManager.init()

class MainViewController: UIViewController {
    var manager: CBCentralManager? = nil
    var mainPeripheral: CBPeripheral? = nil
    var mainCharacteristic: CBCharacteristic? = nil
    var lsmakerBluetooth: BluetoothService = BluetoothService()

    let rxServiceUUID = UUID(uuidString: "6e400001-b5a3-f393-e0a9-e50e24dcca9e")
    let rxCharUUID = UUID(uuidString: "6e400002-b5a3-f393-e0a9-e50e24dcca9e")
    let txCharUUID = UUID(uuidString: "6e400001-b5a3-f393-e0a9-e50e24dcca9e")

    @IBOutlet weak var deviceStatusLabel: UILabel!
    @IBOutlet weak var deviceNameLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        manager = CBCentralManager(delegate: self, queue: nil)
        deviceNameLabel.text = drivingDataManager.name
        //deviceStatusLabel.text = drivingDataManager.status
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if (segue.identifier == "scan-segue") {
            let scanController: ConnectDeviceViewController = segue.destination as! ConnectDeviceViewController

            //set the manager's delegate to the scan view so it can call relevant connection methods
            manager?.delegate = scanController
            scanController.manager = manager
            scanController.parentView = self
        }

    }

    // MARK: Button Methods
    @objc func scanButtonPressed() {
        performSegue(withIdentifier: "scan-segue", sender: nil)
    }
}

extension MainViewController: CBCentralManagerDelegate, CBPeripheralDelegate {
    // MARK: - CBCentralManagerDelegate Methods
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        mainPeripheral = nil
        //customiseNavigationBar()
        print("Disconnected" + peripheral.name!)
    }

    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        print(central.state)
    }

    // MARK: CBPeripheralDelegate Methods
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        for service in peripheral.services! {
            print("Service found with UUID: " + service.uuid.uuidString)

            //device information service
            if (service.uuid.uuidString == rxServiceUUID?.uuidString) {
                peripheral.discoverCharacteristics(nil, for: service)
            }
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if (service.uuid.uuidString == rxServiceUUID?.uuidString) {
            if let characteristic = service.characteristics?.first(where: { (c) -> Bool in
                c.uuid.uuidString == rxCharUUID?.uuidString
            }) {

                lsmakerBluetooth.initialize(peripheral: peripheral, characteristic: characteristic)

                drivingDataManager.name = peripheral.name ?? "none"
                drivingDataManager.status = true
                deviceNameLabel.text = drivingDataManager.name
                if drivingDataManager.status {
                    deviceStatusLabel.text = "Conectado"
                    deviceStatusLabel.textColor = UIColor.green
                }

                let queue = DispatchQueue(label: "lsmaker.control.thread")

                queue.async { [self] in
                    while drivingDataManager.status {
                        print("speed: " + String(drivingDataManager.turn))
                        lsmakerBluetooth.move(
                                speed: drivingDataManager.speed,
                                acceleration: drivingDataManager.acceleration,
                                turn: drivingDataManager.turn)
                        usleep(2000)
                    }
                }
            }
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if (characteristic.uuid.uuidString == "2A00") {
            //value for device name recieved
            let deviceName = characteristic.value
            print(deviceName ?? "No Device Name")
        }
    }
}

