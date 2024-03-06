//
//  MeanBox.swift
//  BLE Analyzer
//
//  Created by Christian Khederchah on 2024-03-06.
//

import Foundation
import SwiftUI

struct DataSum: View {
    let measuredValues : [MeasuredValue]
    
    
    var meanRSSI: Double {
        let rssiValues = measuredValues.map { Double($0.rssi) }
        return rssiValues.reduce(0, +) / Double(rssiValues.count)
    }
    
    var totalPointsMeasured: Int {
        return measuredValues.count
    }
    
    var largestValue: Int? {
        return measuredValues.max(by: {$0.rssi < $1.rssi})?.rssi
    }
    
    var smallestValue: Int? {
        return measuredValues.min(by:{$0.rssi < $1.rssi})?.rssi
    }
    
    var timeRange: (start: String, end: String)? {
        guard let startTime = measuredValues.first?.timestamp,
              let endTime = measuredValues.last?.timestamp else {
            return nil
        }
        return (start: startTime, end: endTime)
    }
    
    
    var rangeOfRSSI: Int? {
        guard let smallestValue = measuredValues.min(by: { $0.rssi < $1.rssi })?.rssi,
              let largestValue = measuredValues.max(by: { $0.rssi < $1.rssi })?.rssi else {
            return nil
        }
        return largestValue - smallestValue
    }
    
    var standardDeviation: Double? {
        guard !measuredValues.isEmpty else { return nil }
        
        let rssiValues = measuredValues.map { Double($0.rssi) }
        let mean = rssiValues.reduce(0, +) / Double(rssiValues.count)
        let sumOfSquaredDifferences = rssiValues.map { pow($0 - mean, 2) }.reduce(0, +)
        
        return sqrt(sumOfSquaredDifferences / Double(rssiValues.count))
    }
    
    
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
        VStack(spacing:10) {
            Text("Data Summary")
                .padding(.bottom)
                .foregroundColor(Color("TextColor"))
                .font(.largeTitle)
            
            Text("Mean: \(meanRSSI)")
            Text("Total Points Measured: \(totalPointsMeasured)")
            Text("Largest Value: \(largestValue ?? 0)") // Use 0 as default value if largestValue is nil
            Text("Smallest Value: \(smallestValue ?? 0)") // Use 0 as default value if smallestValue is nil
            Text("Median RSSI: \(medianRSSI ?? 0)") // Use 0 as default value if medianRSSI is nil
            Text("Range of RSSI: \(rangeOfRSSI ?? 0)") // Use 0 as default value if rangeOfRSSI is nil
            if let timeRange = timeRange {
                Text("Time Range: \(timeRange.start) - \(timeRange.end)")
            } else {
                Text("Time Range: -")
            }
            Text("Standard Deviation: \(standardDeviation ?? 0)") // Use 0 as default value if standardDeviation is nil
        }
        .padding()
        .cornerRadius(10)
        .shadow(radius: 5)
    }
}
