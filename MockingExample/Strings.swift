//
//  Strings.swift
//  MockingExample
//
//  Created by Aleksander Nowakowski on 07/02/2023.
//

import Foundation

struct Strings {
    enum Scanner: String {
        case scanner = "Scanner"
        case noName = "No name"
    }
    
    enum Details: String {
        case name = "Name"
        case connectable = "Connectable"
        case state = "State"
        case yes = "Yes"
        case no = "No"
        case disconnected = "Disconnected"
        case connecting = "Connecting..."
        case connected = "Connected"
        case discoveringServices = "Discovering services..."
        case disconnecting = "Disconnecting..."
        case service = "Service"
        case uuid = "UUID"
        case properties = "Properties"
        case value = "Value"
    }
    
    enum Dialog: String {
        case title = "Send data"
        case message = "Provide value in hexadecimal string."
        case prompt = "Data"
        case cancel = "Cancel"
        case write = "Write"
        case writeWithoutResponse = "Write without response"
        case writeWithResponse = "Write with response"
    }
}

extension Strings.Scanner {
    
    var localized: String {
        return NSLocalizedString(rawValue, comment: "scanner")
    }
    
}

extension Strings.Dialog {
    
    var localized: String {
        return NSLocalizedString(rawValue, comment: "dialog")
    }
    
}

extension Strings.Details {
    
    var localized: String {
        return NSLocalizedString(rawValue, comment: "details")
    }
    
    static func yesNo(_ condition: Bool) -> String {
        return condition ? Self.yes.localized : Self.no.localized
    }
    
    static func state(_ state: ConnectionState) -> String {
        switch state {
        case .disconnected:        return Self.disconnected.localized
        case .connecting:          return Self.connecting.localized
        case .connected:           return Self.connected.localized
        case .discoveringServices: return Self.discoveringServices.localized
        case .disconnecting:       return Self.disconnecting.localized
        }
    }
    
}


