//
//  IncludedService.swift
//  MockingExample
//
//  Created by Aleksander Nowakowski on 09/02/2023.
//

import CoreBluetooth

struct IncludedService: Attribute {
    let id: CBUUID
    let characteristics: [Characteristic]
    
    var uuid: CBUUID {
        return id
    }
    
    init(_ service: CBService) {
        id = service.uuid
        characteristics = service.characteristics?
            .map { Characteristic($0) } ?? []
    }
}
