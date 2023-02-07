//
//  Descriptor.swift
//  MockingExample
//
//  Created by Aleksander Nowakowski on 09/02/2023.
//

import CoreBluetooth

struct Descriptor: Attribute {
    private let cccd = CBUUID(data: Data([0x29, 0x02]))
    
    private let descriptor: CBDescriptor
    
    let id: CBUUID
    let value: Any?
    
    var uuid: CBUUID {
        return id
    }
    
    init(_ descriptor: CBDescriptor) {
        self.descriptor = descriptor
        
        id = descriptor.uuid
        value = descriptor.value
    }
    
    func read() {
        descriptor.characteristic?.service?.peripheral?
            .readValue(for: descriptor)
    }
    
    func write(_ data: Data, withResponse: Bool) {
        descriptor.characteristic?.service?.peripheral?
            .writeValue(data, for: descriptor)
    }
}

extension Descriptor {
    
    var valueString: String {
        if descriptor.uuid.isEqual(cccd) {
            if descriptor.characteristic?.isNotifying ?? false {
                return "Enabled"
            } else {
                return "Disabled"
            }
        }
        guard let value = value else {
            return ""
        }
        if let bool = value as? Bool {
            return "\(bool)"
        }
        if let text = value as? String {
            return text
        }
        if let data = value as? Data {
            return "0x\(data.hex)"
        }
        return "Unknown"
    }
    
}
