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
            centralManager = CBCentralManager(delegate: self, queue: .main)
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
        var p = self.peripherals.first { $0.peripheral == peripheral }
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
//
//struct ScannerView_Previews: PreviewProvider {
//    static var previews: some View {
//        ScannerScreen()
//    }
//}
