//
//  MeanBox.swift
//  BLE Analyzer
//
//  Created by Christian Khederchah on 2024-03-06.
//

import Foundation
import SwiftUI

struct MeanBox: View {
    let meanRSSI: Double
    let dismissAction: () -> Void

    var body: some View {
        VStack {
            Text("Mean RSSI: \(Int(meanRSSI)) dBm")
            Button(action: {
                dismissAction()
            }) {
                Text("Close")
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 5)
    }
}
