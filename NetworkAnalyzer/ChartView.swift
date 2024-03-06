//
//  ChartView.swift
//  NetworkAnalyzer
//
//  Created by Christian Khederchah on 2024-03-01.
//

import SwiftUI
import CoreBluetooth
import Charts
import Combine

struct SecondScreen: View{
    
    let ble: BluetoothScanner
   
    // Data from the chosen peripheral.
    let advertisedData: String
    let rssi: Int
    let timestamp: String
    
    // List with measured values.
    let measuredValues: [MeasuredValue]
    
    // private variables for selection
    @State private var selectedXValue: String?
    @State private var selectedYValue: Int?
    @State private var isScanningState = false
    @State private var isPopoverPresented = false
    
    var correspondingYValue: Int? {
        guard let selectedXValue = selectedXValue else { return nil }
        return measuredValues.first { $0.timestamp == selectedXValue }?.rssi
    }
    
    // Initializer
       init(ble: BluetoothScanner, advertisedData: String, rssi: Int, timestamp: String, measuredValues: [MeasuredValue]) {
           self.ble = ble
           self.advertisedData = advertisedData
           self.rssi = rssi
           self.timestamp = timestamp
           self.measuredValues = measuredValues
       }

    
    
    var body: some View {
        
        VStack{
            HStack{
                
                //Disconnect button
                Button(action: {
                    ble.stopScan()
                    isScanningState = false
                    print(ble.isScanning)
                }){
                   Text("Stop Scan")
                }
                .padding()
                .background(ble.isScanning ? Color.red : Color.gray)
                .foregroundColor(Color.white)
                .cornerRadius(5)
                .disabled(!isScanningState)
                .bold()
                
                // Display selected time
                if let selectedXValue = selectedXValue{
                    Text("Selected time: \(selectedXValue)")
                        .foregroundColor(Color("TextColor"))
                } else {
                    Text("Selected time: -")
                        .foregroundColor(Color("TextColor"))
                }
                
                //Display selected signal strength
                if let selectedYValue = correspondingYValue{
                    Text("RSSI: \(selectedYValue) dBm")
                        .foregroundColor(Color("TextColor"))
                } else {
                    Text("RSSI: - dBm")
                        .foregroundColor(Color("TextColor"))
                }
            }
            
            .onReceive(ble.objectWillChange) { _ in
                isScanningState = ble.isScanning
                
            }
            
            // Displaying measured values in a graph.
            Chart{
                ForEach(measuredValues){ points in
                    LineMark(x: .value("timestamp", points.timestamp), y: .value("rssi", points.rssi))
                }
                .symbol(by: .value("", "RSSI"))
                
            // Rulemark to highlight selected timestamp
                if let selectedValue = selectedXValue {
                    RuleMark(x: .value("selected", selectedValue))
                    
                    //Customizing the Rulemark
                        .foregroundStyle(Color.gray.opacity(0.3))
                        .offset(yStart: -10)
                        .zIndex(-1)
                    }
                }
            
            
        //List with all measured values and corresponding timestamp
            List(measuredValues.reversed(), id: \.id){ measuredValue in
                VStack(alignment: .leading) {
                    Text("RSSI: \(measuredValue.rssi)")
                        .foregroundColor(Color("TextColor"))
                    Text("Timestamp: \(measuredValue.timestamp)")
                        .foregroundColor(Color("TextColor"))
                    
                }
            }
        }
        
        .navigationBarTitle("Measured Values")
        
        //Chart axis configurations
        .chartXAxis(.hidden)
        .chartYAxis{
            AxisMarks(values: [-20, -30, -40, -50, -60, -70, -80, -90, -105])
        }

        
        //Scroll configurations
        .chartScrollableAxes(isScanningState ? [] : [.horizontal])
        .chartXVisibleDomain(length: 10)
        .chartScrollTargetBehavior(
            .valueAligned(unit: 1))
        
        //Selection
        .chartXSelection(value: $selectedXValue)
        .chartYSelection(value: $selectedYValue)
        
        
        .onChange(of: selectedYValue){ oldValue, newValue in
            //print("\(newValue)")
        }
    }
}

struct MeasuredValue: Identifiable{
    let id = UUID()
    let rssi : Int
    let timestamp : String
    
}
