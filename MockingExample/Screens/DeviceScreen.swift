//
//  DeviceView.swift
//  MockingExample
//
//  Created by Aleksander Nowakowski on 07/02/2023.
//

import SwiftUI
import CoreBluetooth
import CoreBluetoothMock

enum ConnectionState {
    case disconnected
    case connecting
    case connected
    case discoveringServices
    case disconnecting
}

struct DeviceScreen: View {
    private let peripheral: ScannedPeripheral
    
    @StateObject private var viewModel: ViewModel
    
    @State private var input = ""
    
    // For animation purposes
    @State private var value = 0.0
    private let timer = Timer.publish(every: 0.5, on: .main, in: .common).autoconnect()
    
    init(_ peripheral: ScannedPeripheral) {
        self.peripheral = peripheral
        self._viewModel = StateObject(wrappedValue: ViewModel(peripheral))
    }
    
    var body: some View {
        List {
            DetailView(title: Strings.Details.name.localized,
                       detail: peripheral.name ?? Strings.Scanner.noName.localized)
            DetailView(title: Strings.Details.connectable.localized,
                       detail: Strings.Details.yesNo(peripheral.isConnectable))
            DetailView(title: Strings.Details.state.localized,
                       detail: Strings.Details.state(viewModel.state))
            
            if viewModel.state == .connected {
                ServicesView(viewModel: viewModel)
            }
        }
        // Show "Send data" dialog.
        .alert(Strings.Dialog.title.localized, isPresented: $viewModel.showDialog) {
            TextField(Strings.Dialog.prompt.localized, text: $input)
                .autocorrectionDisabled()
#if os(iOS)
                .keyboardType(.asciiCapable)
                .textInputAutocapitalization(.characters)
#endif
            Button(Strings.Dialog.cancel.localized, role: .cancel) { }
            if viewModel.properties.contains([.write, .writeWithoutResponse]) {
                Button(Strings.Dialog.writeWithResponse.localized) {
                    Data(hex: input).map { viewModel.send(($0, .withResponse)) }
                }
                Button(Strings.Dialog.writeWithoutResponse.localized) {
                    Data(hex: input).map { viewModel.send(($0, .withoutResponse)) }
                }
            } else {
                Button(Strings.Dialog.write.localized) {
                    let type = viewModel.properties.contains(.write) ?
                        CBCharacteristicWriteType.withResponse :
                        CBCharacteristicWriteType.withoutResponse
                    Data(hex: input).map { viewModel.send(($0, type)) }
                }
            }
        } message: {
            Text(Strings.Dialog.message.localized)
        }
        // This allows to have short gaps between Characteristics.
        .environment(\.defaultMinListRowHeight, 10)
        // Show "Connecting..." view.
        .overlay {
            if viewModel.state == .connecting || viewModel.state == .discoveringServices {
                VStack {
                    Image(systemName: "wifi", variableValue: value)
                        .font(.system(size: 120))
                        .foregroundColor(.secondary)
                    Text(Strings.Details.state(viewModel.state))
                        .font(.system(size: 22))
                        .foregroundColor(.secondary)
                }
                .onReceive(timer) { _ in
                    if value < 0.9 {
                        value += 0.33
                    } else {
                        value = 0.0
                    }
                }
            }
        }
        .onAppear {
            viewModel.connect()
        }
        .onDisappear {
            viewModel.disconnect()
        }
        .navigationTitle(viewModel.name ?? Strings.Scanner.noName.localized)
    }
}

extension DeviceScreen {
    
    class ViewModel: NSObject, ObservableObject {
        @Published private(set) var state: ConnectionState = .disconnected
        @Published private(set) var services: [Service] = []
        @Published private(set) var name: String?
        @Published var showDialog = false
        
        var properties: CBCharacteristicProperties {
            return characteristic?.properties ?? []
        }
        
        private var centralManager: CBCentralManager?
        private var peripheral: CBPeripheral?
        private let uuid: UUID
        
        private var discoveriesInProgress = 0
        private var characteristic: Characteristic?
        private var writeDelegate: WriteDelegate?
        
        init(_ peripheral: ScannedPeripheral) {
            self.uuid = peripheral.peripheral.identifier
            self.name = peripheral.peripheral.name
            super.init()
            
            // Try to connect even if a non-connectable packet was received.
            
            // If you're creating the central manager in multiple places, set the `forceMock`
            // parameter to the same value.
            self.centralManager = CBCentralManagerFactory.instance(delegate: self, queue: .main,
                                                                   forceMock: false)
        }
        
        func connect() {
            state = .connecting
            if let centralManager = centralManager, centralManager.state == .poweredOn,
               let peripheral = centralManager.retrievePeripherals(withIdentifiers: [uuid]).first {
                self.peripheral = peripheral
                peripheral.delegate = self
                centralManager.connect(peripheral)
            }
        }
        
        func disconnect() {
            guard let peripheral = peripheral else { return }
            state = .disconnecting
            centralManager?.cancelPeripheralConnection(peripheral)
        }
        
        func writeRequest(to characteristic: Characteristic, using delegate: @escaping WriteDelegate) {
            self.characteristic = characteristic
            self.writeDelegate = delegate
            self.showDialog = true
        }
        
        fileprivate func send(_ request: WriteRequest) {
            writeDelegate?(request)
        }
    }
    
}

extension DeviceScreen.ViewModel: CBCentralManagerDelegate {
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            connect()
        } else {
            disconnect()
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        name = peripheral.name
        state = .discoveringServices
        discoveriesInProgress = 1
        peripheral.discoverServices(nil)
    }
    
}

extension DeviceScreen.ViewModel: CBPeripheralDelegate {
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        discoveriesInProgress -= 1
        guard let services = peripheral.services else {
            checkComplete()
            return
        }
        discoveriesInProgress += services.count * 2
        for service in services {
            peripheral.discoverIncludedServices(nil, for: service)
            peripheral.discoverCharacteristics(nil, for: service)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverIncludedServicesFor service: CBService, error: Error?) {
        discoveriesInProgress -= 1
        guard let includedServices = service.includedServices else {
            checkComplete()
            return
        }
        discoveriesInProgress += includedServices.count
        for includedService in includedServices {
            peripheral.discoverCharacteristics(nil, for: includedService)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        discoveriesInProgress -= 1
        guard let characteristics = service.characteristics else {
            checkComplete()
            return
        }
        discoveriesInProgress += characteristics.count
        for characteristic in characteristics {
            peripheral.discoverDescriptors(for: characteristic)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverDescriptorsFor characteristic: CBCharacteristic, error: Error?) {
        discoveriesInProgress -= 1
        checkComplete()
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        publish()
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        publish()
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor descriptor: CBDescriptor, error: Error?) {
        publish()
    }
    
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        publish()
    }
    
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor descriptor: CBDescriptor, error: Error?) {
        publish()
    }
    
    private func checkComplete() {
        if discoveriesInProgress == 0 {
            publish()
            state = .connected
        }
    }
    
    private func publish() {
        services = peripheral!.services?.map { Service($0) } ?? []
    }
    
}

extension Data {
    
    var hex: String {
        return map { String(format: "%02X", $0) }.joined()
    }
    
}

// As this screen requires an instance of CBPeripheral,
// a CBMPeripheralPreview may be used.
// Such object does not need to be obtained using scanner,
// and handles all requests with default values.
//
// You may override CBMPeripheralPreview to achieve custom behavior.
struct DeviceScreen_Previews: PreviewProvider {
    static var previews: some View {
        let peripheral = ScannedPeripheral(CBMPeripheralPreview(blinky))
        DeviceScreen(peripheral)
    }
}

