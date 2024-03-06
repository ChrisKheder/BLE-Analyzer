//
//  ContentView2.swift
//  NetworkAnalyzer
//
//  Created by Christian Khederchah on 2024-03-01.
//

import SwiftUI
import CoreBluetooth
import Charts

struct ContentView: View {
    @ObservedObject private var ble = BluetoothScanner()
    @State private var searchText = ""
    @State var graphView: Bool = false
    
       
    var body: some View{
        NavigationView{
            VStack{
                HStack{
                    TextField("Search", text: $searchText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    Button(action: {
                        self.searchText = ""
                    }){
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .opacity(searchText == "" ? 0 : 1)
                }
                .padding()
                
                List(ble.discoveredPeripherals.filter{
                    self.searchText.isEmpty ? true : $0.peripheral.name?.lowercased().contains(self.searchText.lowercased()) == true
                }, id: \.peripheral.identifier) { DiscoveredPeripheral in
                    NavigationLink(destination: SecondScreen(ble: ble, advertisedData: DiscoveredPeripheral.advertisedData, rssi: DiscoveredPeripheral.rssi, timestamp: DiscoveredPeripheral.timestamp, measuredValues: DiscoveredPeripheral.measuredValues)){
                        VStack(alignment: .leading) {
                            Text(DiscoveredPeripheral.peripheral.name ?? "Unknown Name")
                                .foregroundColor(Color("TextColor"))
                            Text(DiscoveredPeripheral.advertisedData)
                                .foregroundColor(Color("TextColor"))
                        }
                    }
                }
                Button(action: {
                    if self.ble.isScanning{
                        self.ble.stopScan()
                    } else {
                        self.ble.startScan()
                    }
                }){
                    if ble.isScanning {
                        Text("Stop Scanning")
                    } else{
                        Text("Start Scanning")
                    }
                }
                .padding()
                .background(ble.isScanning ? Color.red : Color.blue)
                .foregroundColor(Color.white)
                .cornerRadius(5)
            }
        }
        .navigationBarTitle("Bluetooth Devices")
    }
}
    
    
