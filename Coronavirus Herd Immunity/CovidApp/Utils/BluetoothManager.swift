//
//  BluetoothManager.swift
//  Coronavirus Herd Immunity
//
//  Created by Antonio Romano on 27/02/2020.
//  Copyright © 2020 Coronavirus-Herd-Immunity. All rights reserved.
//

import CoreBluetooth
import Foundation

// https://developer.apple.com/documentation/corelocation/turning_an_ios_device_into_an_ibeacon_device
class BluetoothManager: NSObject, CBCentralManagerDelegate, CBPeripheralDelegate{
    
    enum PermissionStatus {
        case allowed, denied, notDetermined, notAvailable
    }
    
    enum Status{
        case on, off, unauthorized, resetting, notAvailable
    }
    
    static let shared = BluetoothManager()
    private var centralManager: CBCentralManager?
    private var ibeacons : [IBeaconDto]
    
    private override init(){
        self.ibeacons = [IBeaconDto]()
        
        super.init()
        
        if self.getPermissionStatus() == .allowed{
            print("GONNA ASK BLUETOOTH CENTRAL MANAGER")
            self.centralManager = CBCentralManager(delegate: self, queue: nil)
        }
    }
    
    // check if permission is allowed and bluetooth is on
    func isBluetoothUsable() -> Bool{
        return self.getPermissionStatus() == .allowed && (self.getBluetoothStatus() == .on || self.getBluetoothStatus() == .notAvailable)
    }
    
    func getPermissionStatus() -> PermissionStatus{
        if #available(iOS 13.1, *) {
            switch CBCentralManager.authorization {
            case .allowedAlways:
                return .allowed
            case .denied:
                return .denied
            case .restricted:
                return .notAvailable
            case .notDetermined:
                return .notDetermined
            }
        } else {
            //TODO Fallback on earlier versions
            return .allowed
        }
    }
    
    func askUserPermission(){
        print("ASKING USER PERMISSION")
        self.centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    func getBluetoothStatus() -> Status{
        if let manager = self.centralManager{
            switch(manager.state){
            case .poweredOff:
                return .off
            case .poweredOn:
                return .on
            case .resetting:
                return .resetting
            case .unauthorized:
                return .unauthorized
            default:
                return .notAvailable
            }
        }
        return .notAvailable
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        print("update bluetooth status")
        switch central.state {
            case .poweredOff:
                print("poweredOff")
                NotificationCenter.default.post(name: NSNotification.Name(Constants.Notification.bluetoothChangeStatus), object: Status.off)
                break
            case .poweredOn:
                print("poweredOn")
                NotificationCenter.default.post(name: NSNotification.Name(Constants.Notification.bluetoothChangeStatus), object: Status.on)
                break
            case .resetting:
                print("resetting")
                NotificationCenter.default.post(name: NSNotification.Name(Constants.Notification.bluetoothChangeStatus), object: Status.resetting)
                break
            case .unauthorized:
                print("unauthorized")
                NotificationCenter.default.post(name: NSNotification.Name(Constants.Notification.bluetoothChangeStatus), object: Status.unauthorized)
                break
            case .unknown:
                print("unknown")
                NotificationCenter.default.post(name: NSNotification.Name(Constants.Notification.bluetoothChangeStatus), object: Status.notAvailable)
                break
            case .unsupported:
                print("unsupported")
                NotificationCenter.default.post(name: NSNotification.Name(Constants.Notification.bluetoothChangeStatus), object: Status.notAvailable)
                break
        }
    }
    
    /* scan bluetooth devices */
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        
        // RSSI value in dBm; 127 is not available
        print("BLUETOOTH NAME", peripheral.name ?? "<NO-NAME>", peripheral.identifier, RSSI)

        if Constants.Setup.minRSSIPower <= RSSI.doubleValue && RSSI.doubleValue <= Constants.Setup.maxRSSIPower{
            
            
        }
    
    }
    
}
