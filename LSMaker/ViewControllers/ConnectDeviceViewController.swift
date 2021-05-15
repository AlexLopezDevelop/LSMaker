//
//  ConnectDeviceViewController.swift
//  LSMaker
//
//  Created by Alex Lopez on 11/10/2020.
//  Copyright © 2020 Alex Lopez. All rights reserved.
//

import UIKit
import CoreBluetooth

class ConnectDeviceViewController: UIViewController {
    
    var peripherals:[CBPeripheral] = []
    var manager:CBCentralManager? = nil
    var parentView:MainViewController? = nil
    var filteredData = [CBPeripheral]()
    var filtered = false
    
    let searchController = UISearchController()
    
    @IBOutlet weak var deviceFilter: UITextField!
    @IBOutlet weak var devicesTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configuration()
        scanBLEDevices()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        scanBLEDevices()
    }
    
    func configuration() {
        deviceFilter.delegate = self
    }

    @IBAction func buttonClose(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func deviceScannerButton(_ sender: Any) {
        scanBLEDevices()
    }
    
    @IBAction func recentDevicesButton(_ sender: Any) {
        
    }
    
    func connectionSucessMessage (deviceName: String){
        let alert = UIAlertController(title: "Conectado correctamente", message: "Se ha conectado correctamente a \(deviceName)", preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "Vale", style: .default, handler: nil))

        self.present(alert, animated: true)
    }
}

extension  ConnectDeviceViewController: CBCentralManagerDelegate {
    // MARK: BLE Scanning
    func scanBLEDevices() {
        //manager?.scanForPeripherals(withServices: [CBUUID.init(string: parentView!.BLEService)], options: nil)

        //if you pass nil in the first parameter, then scanForPeriperals will look for any devices.
        manager?.scanForPeripherals(withServices: nil, options: nil)

        //stop scanning after 3 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            self.stopScanForBLEDevices()
        }
    }

    func stopScanForBLEDevices() {
        manager?.stopScan()
    }

    // MARK: - CBCentralManagerDelegate Methods
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        if(!peripherals.contains(peripheral)) {
            if peripheral.name != nil {
                peripherals.append(peripheral)
            }
        }

        self.devicesTableView.reloadData()
    }

    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        print(central.state)
    }

    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {

        //pass reference to connected peripheral to parent view
        parentView?.mainPeripheral = peripheral
        peripheral.delegate = parentView
        peripheral.discoverServices(nil)

        //set the manager's delegate view to parent so it can call relevant disconnect methods
        manager?.delegate = parentView
        //parentView?.customiseNavigationBar()

        if let navController = self.navigationController {
            navController.popViewController(animated: true)
        }

        connectionSucessMessage(deviceName: peripheral.name!)
    }

    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print(error!)
    }
}

extension ConnectDeviceViewController: UITableViewDelegate, UITableViewDataSource {
    // MARK: - Table view data source

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if !filteredData.isEmpty {
            return filteredData.count
        }

        return filtered ? 0 : peripherals.count
    }


    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "scanTableCell", for: indexPath) as! TableViewCellDevice
        let peripheral:CBPeripheral

        if !filteredData.isEmpty {
            peripheral = filteredData[indexPath.row]
        } else {
            peripheral = peripherals[indexPath.row]
        }

        cell.deviceName.text = peripheral.name
        cell.serialNumber.text = peripheral.identifier.uuidString
        //cell.rssiNumber.text = peripheral.ew

        // Remove cell highlight/selection color
        cell.selectionStyle = .none

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        let peripheral = peripherals[indexPath.row]

        let deviceName = peripheral.name!

        // alert
        let alert = UIAlertController(title: "Conectar dispositivo", message: "¿Quieres conectarte al dispositivo \(deviceName)?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Si", style: .default, handler: {(alert: UIAlertAction!) in
            self.manager?.connect(peripheral, options: nil)
        }))
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
        self.present(alert, animated: true)

    }
}

extension ConnectDeviceViewController: UITextFieldDelegate {
    
    func filterText(_ query: String?) {
        filteredData.removeAll()
        
        for peripheral in peripherals {
            if let peripheralName = peripheral.name {
                if peripheralName.lowercased().starts(with: query?.lowercased() ?? "") {
                    filteredData.append(peripheral)
                }
            }
        }
        
        
        devicesTableView.reloadData()
        filtered = true
    }
    
    // MARK: - TextField functions
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        deviceFilter.resignFirstResponder()
        filterText(deviceFilter.text)

        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {

        if let text = textField.text {
            filterText(text+string)
        }

        return true
    }
    
    // MARK: - TextField functions
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
}
