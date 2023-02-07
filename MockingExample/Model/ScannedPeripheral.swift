//
//  ScannedPeripheral.swift
//  MockingExample
//
//  Created by Aleksander Nowakowski on 07/02/2023.
//

import Foundation
import CoreBluetooth

class ScannedPeripheral: Identifiable {
    let peripheral: CBPeripheral
    let id: UUID
    
    private(set) var name: String? = nil
    private(set) var rssi: NSNumber = -128
    private(set) var isConnectable: Bool = false
    
    var rssiValue: Double {
        return rssi.doubleValue / 138 + 0.9
    }
    
    init(_ peripheral: CBPeripheral) {
        self.peripheral = peripheral
        self.name = peripheral.name
        self.id = peripheral.identifier
    }
    
    func update(advertisementData: [String : Any], rssi: NSNumber) {
        self.isConnectable = advertisementData[CBAdvertisementDataIsConnectable] as? Bool ?? false
        self.name = advertisementData[CBAdvertisementDataLocalNameKey] as? String
        self.rssi = rssi
    }
    
}
