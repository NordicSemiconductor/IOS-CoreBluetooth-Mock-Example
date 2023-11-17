//
//  AttributeView.swift
//  MockingExample
//
//  Created by Aleksander Nowakowski on 08/02/2023.
//

import SwiftUI
import CoreBluetooth

typealias WriteRequest = (data: Data, writeType: CBCharacteristicWriteType)
typealias WriteDelegate = (WriteRequest) -> ()

enum Reason: Error {
    case cancelled
}

enum ActionType {
    case read
    case write
    case enable
    case disable
    
    var iconName: String {
        switch self {
        case .read:
            return "arrow.down.circle.fill"
        case .write:
            return "arrow.up.circle.fill"
        case .enable:
            return "play.circle.fill"
        case .disable:
            return "play.circle"
        }
    }
}

struct Action: Identifiable {
    let type: ActionType
    let callback: () -> ()
    
    var id: Int {
        switch type {
        case .read: return 0
        case .write: return 1
        case .enable: return 2
        case .disable: return 3
        }
    }
}

private struct ActionView: View {
    let action: Action
    
    var body: some View {
        Image(systemName: action.type.iconName)
            .foregroundColor(.nordicBlue)
            .onTapGesture {
                action.callback()
            }
    }
}

private struct PropertiesView: View {
    let properties: CBCharacteristicProperties
        
    var body: some View {
        let p: [(CBCharacteristicProperties, String, id: Int)] = [
            (.broadcast, "b.circle.fill", 0),
            (.read, "r.circle.fill", 1),
            (.writeWithoutResponse, "w.circle", 2),
            (.write, "w.circle.fill", 3),
            (.notify, "n.circle.fill", 4),
            (.indicate, "i.circle.fill", 5),
            (.authenticatedSignedWrites, "s.circle.fill", 6),
            (.extendedProperties, "e.circle.fill", 7)
        ]
        .filter { property, _, _ in properties.contains(property) }
        return ForEach(p, id: \.id) { _, name, _ in
            Image(systemName: name)
        }
        .foregroundColor(.secondary)
    }
}

enum Decor {
    case actions(_ actions: [Action])
    case text(_ text: String)
    case properties(_ properties: CBCharacteristicProperties)
}

struct AttributeView: View {
    private let verticalMargin: CGFloat = 8.0
    
    private let title: String?
    private let decor: Decor?
    private let indent: Int
    
    init(_ title: String? = nil, with decor: Decor?, indentedBy indent: Int = 0) {
        self.title = title
        self.decor = decor
        self.indent = indent
    }
    
    var body: some View {
        HStack {
            ForEach(0..<indent + 1, id: \.self) { i in
                Rectangle()
                    .inset(by: -10)
                    .offset(x: 10, y: 0)
                    .fill(Color.nordicBlue)
                    .opacity(1.0 / Double(i + 1))
                    .frame(width: 0.5, height: 16)
                    .padding(.trailing)
            }
            Text(title ?? "")
            Spacer()
            switch decor {
            case let .text(detail):
                Text(detail)
                    .font(.system(size: 17))
                    .minimumScaleFactor(0.01)
                    .lineLimit(1)
                    .foregroundColor(.secondary)
            case let .properties(properties):
                PropertiesView(properties: properties)
            case let .actions(actions):
                ForEach(actions) { action in
                    ActionView(action: action)
                }
            case .none:
                Spacer()
            }
        }
        .listRowInsets(EdgeInsets(top: verticalMargin, leading: 0, bottom: verticalMargin, trailing: 16))
    }
}

struct Separator: View {
    
    var body: some View {
        HStack {
            Rectangle()
                .inset(by: -10)
                .offset(x: 10, y: 0)
                .fill(Color.nordicBlue)
                .frame(width: 0, height: 0)
                .padding(.trailing)
            // This is a hack to indent the row separator by padding.
            Text("")
        }
        .listRowInsets(EdgeInsets())
        .frame(height: 10)
    }
}

extension Characteristic {
    
    func actions(onWrite getData: @escaping (@escaping WriteDelegate) -> ()) -> [Action] {
        let read = CBCharacteristicProperties.read
        let write: CBCharacteristicProperties = [.write, .writeWithoutResponse, .authenticatedSignedWrites]
        let notify: CBCharacteristicProperties = [.notify, .indicate]
        return [
            (read, Action(type: .read) { self.read() }),
            (write, Action(type: .write) {
                getData() { request in
                    self.write(request.data, type: request.writeType)
                }
            }),
            (notify, Action(type: isNotifying ? .disable : .enable) { self.toggle() }),
        ]
        .filter { property, _ in !properties.isDisjoint(with: property)}
        .map { _, action in action }
    }
    
}
