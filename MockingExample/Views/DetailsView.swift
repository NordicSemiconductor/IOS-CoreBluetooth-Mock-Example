//
//  DetailsView.swift
//  MockingExample
//
//  Created by Aleksander Nowakowski on 08/02/2023.
//

import SwiftUI
import CoreBluetooth

struct DetailView: View {
    let title: String
    let detail: String
    
    var body: some View {
        HStack {
            Text(title)
            Spacer()
            Text(detail)
                .font(.system(size: 17))
                .minimumScaleFactor(0.01)
                .lineLimit(1)
                .foregroundColor(.secondary)
        }
    }
}
