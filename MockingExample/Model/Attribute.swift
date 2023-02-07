//
//  Attribute.swift
//  MockingExample
//
//  Created by Aleksander Nowakowski on 09/02/2023.
//

import CoreBluetooth

protocol Attribute: Identifiable {
    var uuid: CBUUID { get }
}
