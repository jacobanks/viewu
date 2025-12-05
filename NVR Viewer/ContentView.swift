//
//  ContentView.swift
//  NVR Viewer
//
//  Created by Matthew Ehrhart on 3/1/24.
//

import SwiftUI
import CocoaMQTT
import SwiftData
import TipKit
import BackgroundTasks

struct ContentView: View {
    @ObservedObject var filter2 = EventFilter.shared()

    @StateObject private var config = NVRConfiguration()
    @EnvironmentObject private var notificationManager: NotificationManager

    @StateObject var mqttManager = MQTTManager.shared()

    @State private var selection: Int = 0

    @AppStorage("developerModeIsOn") var developerModeIsOn = false
    @AppStorage("frigateVersion") var frigateVersion: String = "0.0-0"

    var body: some View{
        TabView(selection: $selection) {
            NavigationStack {
                ViewCamera(title: "Live Cameras")
            }
            .tabItem {
                Label("Live", systemImage: "house")
            }
            .tag(0)
                
            NavigationStack {
                EventsListView()
            }
            .tabItem {
                Label("Events", systemImage: "bell")
            }
            .tag(1)
            
            if developerModeIsOn {
                NavigationStack {
                    ViewLog()
                }
                .tabItem {
                    Label("Log", systemImage: "note.text")
                }
                .tag(2)
            }

            NavigationStack {
                ViewSettings(title: "Settings")
            }
            .tabItem {
                Label("Settings", systemImage: "gearshape.2")
            }
            .tag(3)
        }
        .task {
            do {
                config.config = try await FrigateService().retrieveConfig()

//                filter2.setCameras(items: config.config?.cameras)
//                filter2.setObject(items: config.config?.cameras)
//                filter2.setZones(items: config.config?.cameras)

                if let version = config.config?.version {
                    frigateVersion = version
                }
            } catch {
                print(error)
                Log.shared().print(page: "ContentView", fn: "task::cnvr.fetchNVRConfig 1001.1", type: "ERROR", text: "\(error)")
            }
        }
        .onReceive(notificationManager.$newPage) {
            guard let notificationSelection = $0 else  { return }
            self.selection = notificationSelection
        }
        .onAppear {
            //check accesibilty to nvr
            Task {
                await config.checkConnectionStatus()
            }
            //TODO check if connection is disconnected first
            //connect to mqtt broker
            mqttManager.initializeMQTT()
            mqttManager.connect()
        }
        .environmentObject(mqttManager)
        .environmentObject(config)
    }
}

struct VerticalLabelStyle: LabelStyle {
    var show: Bool

    init(show: Bool){
        self.show = show
    }

    func makeBody(configuration: Configuration) -> some View {
        VStack {
            configuration.icon.font(.system(size: 18))
            configuration.title.font(.system(size: 10))
        }
    }
}

//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView()
//            .environmentObject(MQTTManager.shared())
//    }
//}
