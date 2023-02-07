//
//  Characteristic.swift
//  MockingExample
//
//  Created by Aleksander Nowakowski on 09/02/2023.
//

import CoreBluetooth

struct Characteristic: Attribute {
    private let characteristic: CBCharacteristic
    
    let id: CBUUID
    let properties: CBCharacteristicProperties
    let value: Data?
    let descriptors: [Descriptor]
    let isNotifying: Bool
    
    var uuid: CBUUID {
        return id
    }
    
    init(_ characteristic: CBCharacteristic) {
        self.characteristic = characteristic
        
        id = characteristic.uuid
        properties = characteristic.properties
        isNotifying = characteristic.isNotifying
        value = characteristic.value
        descriptors = characteristic.descriptors?
            .map { Descriptor($0) } ?? []
    }
    
    func read() {
        characteristic.service?.peripheral?
            .readValue(for: characteristic)
    }
    
    func write(_ data: Data, type: CBCharacteristicWriteType) {
        characteristic.service?.peripheral?
            .writeValue(data, for: characteristic, type: type)
    }
    
    func toggle() {
        characteristic.service?.peripheral?
            .setNotifyValue(!isNotifying, for: characteristic)
    }
}

extension Characteristic {
    
    var valueString: String {
        guard let value = value else {
            return ""
        }
        return "0x\(value.hex)"
    }
    
}
