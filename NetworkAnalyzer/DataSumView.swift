//
//  MeanBox.swift
//  BLE Analyzer
//
//  Created by Christian Khederchah on 2024-03-06.
//

import Foundation
import SwiftUI

struct DataSum: View {
    @Environment(\.dismiss) var dismiss
    let measuredValues : [MeasuredValue]
    
    // Mean
    var meanRSSI: Double {
        let rssiValues = measuredValues.map { Double($0.rssi) }
        return rssiValues.reduce(0, +) / Double(rssiValues.count)
    }
    
    // Total points
    var totalPointsMeasured: Int {
        return measuredValues.count
    }
    
    // Largest value
    var largestValue: Int? {
        return measuredValues.max(by: {$0.rssi < $1.rssi})?.rssi
    }
    
    // Smallest value
    var smallestValue: Int? {
        return measuredValues.min(by:{$0.rssi < $1.rssi})?.rssi
    }
    
    // Time range
    var timeRange: (start: String, end: String)? {
        guard let startTime = measuredValues.first?.timestamp,
              let endTime = measuredValues.last?.timestamp else {
            return nil
        }
        return (start: startTime, end: endTime)
    }
    
    // RSSI range
    var rangeOfRSSI: Int? {
        guard let smallestValue = measuredValues.min(by: { $0.rssi < $1.rssi })?.rssi,
              let largestValue = measuredValues.max(by: { $0.rssi < $1.rssi })?.rssi else {
            return nil
        }
        return largestValue - smallestValue
    }
    
    // Standard devation
    var standardDeviation: Double? {
        guard !measuredValues.isEmpty else { return nil }
        
        let rssiValues = measuredValues.map { Double($0.rssi) }
        let mean = rssiValues.reduce(0, +) / Double(rssiValues.count)
        let sumOfSquaredDifferences = rssiValues.map { pow($0 - mean, 2) }.reduce(0, +)
        
        return sqrt(sumOfSquaredDifferences / Double(rssiValues.count))
    }
    
    // Median
    var medianRSSI: Int?{
        let sortedRSSIValues = measuredValues.map{$0.rssi}.sorted()
        let count = sortedRSSIValues.count
        
        guard count > 0 else {return nil}
        
        if count % 2 == 0 {
            let middleIndex = count / 2
            return (sortedRSSIValues[middleIndex - 1] + sortedRSSIValues[middleIndex + 1]) / 2
        }else{
            return sortedRSSIValues[count / 2]
        }
    }
    
    
    var body: some View {
        
        ZStack{
            
            // Dismiss button
            Color.clear
                .overlay(alignment: .topTrailing){
                    Button{
                        dismiss()
                    }label: {
                        Image(systemName: "x.circle.fill")
                            .imageScale(.large)
                            .padding()
                            .foregroundColor(.secondary)
                            .opacity(0.6)
                    }
                }
            
            // Main body of view
            GeometryReader {geometry in
                VStack() {
                    Text("Data Summary")
                        .font(.largeTitle)
                    Spacer()
                    
                    //Show list of Data summary only when sheet is larger than 100, To improv .fraction(0.1) look
                    if geometry.size.height > 100{
                        Text("""
                         Mean: \(meanRSSI)
                         Median RSSI: \(medianRSSI ?? 0)
                         Total Points Measured: \(totalPointsMeasured)
                         Smallest Value: \(smallestValue ?? 0)
                         Largest Value: \(largestValue ?? 0)
                         Range of RSSI: \(rangeOfRSSI ?? 0)
                         Standard Deviation: \(standardDeviation ?? 0)
                         Time Range: \(timeRange != nil ? "\(timeRange!.start) - \(timeRange!.end)" : "-")
                         """)
                        .multilineTextAlignment(.center)
                        .lineSpacing(10)
                        .padding()
                        Spacer()
                    }
                }
                // sets correct size for Geometry reader (helps center the view)
                .frame(width: geometry.size.width, height: geometry.size.height)
            }
            .padding()
        }
    }
}
