//
//  ViewEventList.swift
//  NVR Viewer
//
//  Created by Matthew Ehrhart on 3/1/24.
//

import SwiftUI
import SwiftData

struct ViewEventListHome: View {
    
    @StateObject var mqttManager = MQTTManager.shared()
    @StateObject var nvrManager = NVRConfig.shared()
    
    init(){
    }
    
    var body: some View {
        VStack {
            ViewEventList(title: "Event Timeline")
        }
        .navigationBarTitle("Event Timeline", displayMode: .inline)
        .environmentObject(mqttManager)
        .environmentObject(nvrManager)
    }
    
    struct ViewEventList: View {
        
        let title: String
        @EnvironmentObject private var mqttManager: MQTTManager
        @EnvironmentObject private var nvrManager: NVRConfig
        
        var body: some View {
            
            VStack {
                //Layout 1
                //ViewLiveEvent()
                
                //History
                ViewEventsHistory()
                
                //Quick Date Filter
                ViewQuickDayFilter()
            }
        }
    }
}
