//
//  MockingExampleApp.swift
//  MockingExample
//
//  Created by Aleksander Nowakowski on 07/02/2023.
//

import SwiftUI
import CoreBluetoothMock

@main
struct MockingExampleApp: App {
    
    init() {
        CBMCentralManagerMock.simulateInitialState(.poweredOn)
    }
    
    var body: some Scene {
        WindowGroup {
            ScannerScreen()
        }
    }
}
