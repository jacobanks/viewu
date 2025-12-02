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
    //Load Config
    @ObservedObject var filter2 = EventFilter.shared()
    let nvr = NVRConfig.shared()
    //FRIGATE 16+ reguires NVRConfigurationCall2
    //@ObservedObject var config = NVRConfigurationSuper.shared()
    @ObservedObject var config = NVRConfigurationSuper2.shared()
    
    let cNVR = APIRequester()
    
    //
    @EnvironmentObject private var notificationManager2: NotificationManager
    
    @StateObject var nts = NotificationTemplateString.shared()
    @StateObject var mqttManager = MQTTManager.shared()
    @StateObject var nvrManager = NVRConfig.shared()
    @StateObject var notificationManager = NotificationManager() //this may not be needed here
    
    @State private var showNVR = false // move to settings
    @State private var selection: Int = 0

    //@AppStorage("resetTips") var resetTips = false
    @AppStorage("developerModeIsOn") var developerModeIsOn = false
    @AppStorage("frigateAlertsRetain")  var frigateAlertsRetain: Int = 10
    @AppStorage("frigateDetectionsRetain")  var frigateDetectionsRetain: Int = 10
    @AppStorage("frigateVersion")  var frigateVersion: String = "0.0-0"
    @AppStorage("background_fetch_events_epochtime") private var backgroundFetchEventsEpochtime: String = "0"
    @AppStorage("isOnboarding") var isOnboarding: Bool = true
    @AppStorage("showTips") var showTips: Bool = true
    
    @Environment(\.scenePhase) var scenePhase
    
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
                ViewEventListHome()
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
            //Load Defaults for app
            DispatchQueue.main.async {
                let url = nvr.getUrl()
                let urlString = url + "/api/config"
                print(urlString)
                cNVR.fetchNVRConfig(urlString: urlString ){ (data, error) in
                    
                    guard let data = data else { return }
                    
                    if developerModeIsOn {
                        do {
                            Log.shared().print(page: "ContentView", fn: "task::cnvr.fetchNVRConfig", type: "Info", text: "Entry")
                            if let responseString = String(data: data, encoding: .utf8) {
                                print("Raw response data: \(responseString)")
                                Log.shared().print(page: "ContentView", fn: "task::cnvr.fetchNVRConfig", type: "Result", text: "\(responseString)")
                            }
                        }
                    }
                    
                    do {
                        
                        //print("=1===============================================================================================")
                        
                        //FRIGATE 16+ reguires NVRConfigurationCall2
                        config.item = try JSONDecoder().decode(NVRConfigurationCall2.self, from: data)
                        
                        
                        //print("=2===============================================================================================")
                        //print(config.item)
                        //                        if let dataJson = jsonObject.data(using: .utf8) {
                        //                            let epsArray = try! JSONDecoder().decode([EndpointOptions].self, from: dataJson)
                        //                            ViewEventInformation( endPointOptionsArray: epsArray)
                        //                        }
                        
                        filter2.setCameras(items: config.item.cameras)
                        filter2.setObject(items: config.item.cameras)
                        filter2.setZones(items: config.item.cameras)
                        
                        frigateVersion = config.item.version
                        frigateAlertsRetain = config.item.record.alerts.retain.days
                        frigateDetectionsRetain = config.item.record.detections.retain.days
                        
                        // Delete non-retained snapshots
                        for (_, value) in config.item.cameras{
                            
                            let daysBack = value.snapshots.retain.default
                            let db:Int = Int(daysBack)
                            let _ = EventStorage.shared.delete(daysBack:db, cameraName: value.name)
                        }
                        
                    }catch (let err){
                        
                        //print("=3==========")
                        print(err)
                        
                        Log.shared().print(page: "ContentView", fn: "task::cnvr.fetchNVRConfig 1001.1", type: "ERROR", text: "\(err)")
                        
                        do {
                            if let json = try JSONSerialization.jsonObject(with: data, options: .fragmentsAllowed ) as? [String: Any] {
                                
                                Log.shared().print(page: "ContentView", fn: "task::cnvr.fetchNVRConfig 2001.1", type: "Info", text: "\(json)")
                            }
                        } catch(let err) {
                            
                            Log.shared().print(page: "ContentView", fn: "task::cnvr.fetchNVRConfig 2001.2", type: "ERROR", text: "\(err)")
                        }
                    }
                }
                
                //Load Events
                cNVR.fetchEventsInBackground(urlString: nvr.getUrl(), backgroundFetchEventsEpochtime: backgroundFetchEventsEpochtime, epsType: "ctask" )
                
            }
        }
        .onReceive(notificationManager2.$newPage) {
            guard let notificationSelection = $0 else  { return }
            self.selection = notificationSelection
        }
        .onChange(of: scenePhase) { _, newScenePhase in
            DispatchQueue.main.async {
                if newScenePhase == .active {
                    cNVR.fetchEventsInBackground(urlString: nvr.getUrl(), backgroundFetchEventsEpochtime: backgroundFetchEventsEpochtime, epsType: "scenePhase")
                }
            }
        }
        .onAppear {
            Task {
                await sheduleBackgroundTask()
            }
            //check accesibilty to nvr
            nvrManager.checkConnectionStatus(){data,error in
                //do nothing
            }
            //TODO check if connection is disconnected first
            //connect to mqtt broker
            mqttManager.initializeMQTT()
            mqttManager.connect()
        }
        .environmentObject(mqttManager)
        .environmentObject(nvrManager)
    }
    
    func sheduleBackgroundTask() async {
        let request = BGAppRefreshTaskRequest(identifier: "viewu_refresh")
        request.earliestBeginDate = Calendar.current.date(byAdding: .second, value: 30 * 60, to: Date())
        do {
            try BGTaskScheduler.shared.submit(request)
            print("DEBUG: Background Task Scheduled!")
        } catch(let error) {
            print("DEBUG: Scheduling Error \(error.localizedDescription)")
        }
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

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(MQTTManager.shared())
            .environmentObject(NVRConfig.shared())
    }
}

extension AnyTransition {
    static var moveAndFade: AnyTransition {
        AnyTransition.slide
    }
}
