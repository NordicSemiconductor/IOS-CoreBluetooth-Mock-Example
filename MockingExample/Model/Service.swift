//
//  Service.swift
//  MockingExample
//
//  Created by Aleksander Nowakowski on 09/02/2023.
//

import CoreBluetooth

struct Service: Attribute {
    let id: CBUUID
    let characteristics: [Characteristic]
    let includedServices: [IncludedService]
    
    var uuid: CBUUID {
        return id
    }
    
    init(_ service: CBService) {
        id = service.uuid
        characteristics = service.characteristics?
            .map { Characteristic($0) } ?? []
        includedServices = service.includedServices?
            .map { IncludedService($0) } ?? []
    }
}
