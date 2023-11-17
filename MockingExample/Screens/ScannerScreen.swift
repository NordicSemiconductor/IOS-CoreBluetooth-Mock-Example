//
//  ScannerView.swift
//  MockingExample
//
//  Created by Aleksander Nowakowski on 07/02/2023.
//

import SwiftUI
import CoreBluetooth

struct ScannerScreen: View {
    @StateObject private var viewModel = ViewModel()
    
    var body: some View {
        NavigationStack {
            List(viewModel.peripherals, id: \.id) { peripheral in
                NavigationLink {
                    DeviceScreen(peripheral)
                } label: {
                    HStack {
                        Text(peripheral.name ?? Strings.Scanner.noName.localized)
                        Spacer()
                        Image(systemName: "wifi", variableValue: peripheral.rssiValue)
                    }
                }
            }
            .overlay {
                if viewModel.peripherals.isEmpty {
                    Image(systemName: "wifi.square")
                        .font(.system(size: 120))
                        .foregroundColor(.secondary)
                }
            }
            .onAppear {
                viewModel.startScan()
            }
            .onDisappear {
                viewModel.stopScan()
            }
            .navigationTitle(Strings.Scanner.scanner.localized)
        }
    }
}

extension ScannerScreen {
    
    class ViewModel: NSObject, ObservableObject {
        @Published var peripherals = [ScannedPeripheral]()
        
        private var centralManager: CBCentralManager!
        private var scanningStarted = false
        
        override init() {
            super.init()
            
            // After adding Aliases.swift, the CBCentralManager becomes an alias for
            // CBMCentralManager (note the M in CBM...). The line below throws a compilation
            // error, as there are now two implementations of the manager: native and mock.
            //
            // To fix the error, instead of creating CBCentralManager directly, use the factory.
            //
            // The last parameter, `forceMock`, can apply mock implementation also on
            // physical devices.
            centralManager = CBCentralManagerFactory.instance(delegate: self, queue: .main,
                                                              forceMock: false)
        }
        
        func startScan() {
            scanningStarted = true
            if centralManager.state == .poweredOn {
                print("Starting scanning...")
                centralManager.scanForPeripherals(withServices: nil,
                                                  options: [CBCentralManagerScanOptionAllowDuplicatesKey: true])
            }
        }
        
        func stopScan() {
            if scanningStarted {
                print("Scanning stopped")
                scanningStarted = false
                centralManager.stopScan()
            }
        }
    }
}

extension ScannerScreen.ViewModel: CBCentralManagerDelegate {
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        print("Central Manager state: \(central.state)")
        if central.state == .poweredOn && scanningStarted {
            startScan()
        } else {
            stopScan()
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        // Search for the device if we already have it
        var p = self.peripherals.first {
            // CBMPeripheral is a protocol and cannot be Equatable.
            // Instead, compare the identifiers.
            $0.peripheral.identifier == peripheral.identifier
        }
        if p == nil {
            // Filter those without name, why not.
            guard let _ = advertisementData[CBAdvertisementDataLocalNameKey] else {
                return
            }
            p = ScannedPeripheral(peripheral)
            self.peripherals.append(p!)
        }
        // Update with new name or RSSI value.
        objectWillChange.send()
        p!.update(advertisementData: advertisementData, rssi: RSSI)
    }
    
}

// This Preview displays advertising mock peripherals.
// No additional configuration required.
struct ScannerView_Previews: PreviewProvider {
    static var previews: some View {
        ScannerScreen()
    }
}
