//
//  ServicesView.swift
//  MockingExample
//
//  Created by Aleksander Nowakowski on 08/02/2023.
//

import SwiftUI
import CoreBluetooth

struct ServicesView: View {
    @StateObject var viewModel: DeviceScreen.ViewModel
    
    var body: some View {
        ForEach(viewModel.services) { service in
            ServiceView(viewModel: viewModel, service: service, indentedBy: 0)
        }
    }
}

private struct ServiceView: View {
    private let viewModel: DeviceScreen.ViewModel
    private let service: Service
    private let indent: Int
    
    init(viewModel: DeviceScreen.ViewModel, service: Service, indentedBy indent: Int) {
        self.viewModel = viewModel
        self.service = service
        self.indent = indent
    }
    
    var body: some View {
        Section(Strings.Details.service.localized) {
            AttributeView(Strings.Details.name.localized, with: .text("Unknown"), indentedBy: indent)
            AttributeView(Strings.Details.uuid.localized, with: .text(service.uuid.uuidString), indentedBy: indent)
            
            ForEachWithIndex(service.includedServices) { index, includedService in
                IncludedServiceView(viewModel: viewModel, service: includedService, indentedBy: indent + 1)
                    .listRowBackground(Rectangle().foregroundColor(.secondary.opacity(0.1)))
                Separator()
            }
            
            ForEachWithIndex(service.characteristics) { index, characteristic in
                CharacteristicView(viewModel: viewModel, characteristic: characteristic, indentedBy: indent + 1)
                if index < service.characteristics.count - 1 {
                    Separator()
                }
            }
        }
    }
}

private struct IncludedServiceView: View {
    private let viewModel: DeviceScreen.ViewModel
    private let service: IncludedService
    private let indent: Int
    
    init(viewModel: DeviceScreen.ViewModel, service: IncludedService, indentedBy indent: Int) {
        self.viewModel = viewModel
        self.service = service
        self.indent = indent
    }
    
    var body: some View {
        AttributeView(Strings.Details.name.localized, with: .text("Unknown"), indentedBy: indent)
        AttributeView(Strings.Details.uuid.localized, with: .text(service.uuid.uuidString), indentedBy: indent)
        
        ForEachWithIndex(service.characteristics) { index, characteristic in
            CharacteristicView(viewModel: viewModel, characteristic: characteristic, indentedBy: indent + 1)
            if index < service.characteristics.count - 1 {
                Separator()
            }
        }
    }
}

private struct CharacteristicView: View {
    private let viewModel: DeviceScreen.ViewModel
    private let characteristic: Characteristic
    private let indent: Int
    
    init(viewModel: DeviceScreen.ViewModel, characteristic: Characteristic, indentedBy indent: Int) {
        self.viewModel = viewModel
        self.characteristic = characteristic
        self.indent = indent
    }
    
    var body: some View {
        AttributeView(Strings.Details.name.localized, with: .text( "Unknown"), indentedBy: indent)
        AttributeView(Strings.Details.uuid.localized, with: .text(characteristic.uuid.uuidString), indentedBy: indent)
        AttributeView(Strings.Details.properties.localized, with: .properties(characteristic.properties), indentedBy: indent)
        AttributeView(Strings.Details.value.localized, with: .text(characteristic.valueString), indentedBy: indent)
        AttributeView(with: .actions(characteristic.actions(onWrite: { delegate in
            viewModel.writeRequest(to: characteristic, using: delegate)
        })), indentedBy: indent)

        ForEach(characteristic.descriptors) { descriptor in
            DescriptorView(viewModel: viewModel, descriptor: descriptor, indentedBy: indent + 1)
        }
    }
}

private struct DescriptorView: View {
    private let viewModel: DeviceScreen.ViewModel
    private let descriptor: Descriptor
    private let indent: Int
    
    init(viewModel: DeviceScreen.ViewModel, descriptor: Descriptor, indentedBy indent: Int) {
        self.viewModel = viewModel
        self.descriptor = descriptor
        self.indent = indent
    }
    
    var body: some View {
        AttributeView(Strings.Details.name.localized, with: .text("Unknown"), indentedBy: indent)
        AttributeView(Strings.Details.uuid.localized, with: .text(descriptor.uuid.uuidString), indentedBy: indent)
        AttributeView(Strings.Details.value.localized, with: .text(descriptor.valueString), indentedBy: indent)
    }
}
