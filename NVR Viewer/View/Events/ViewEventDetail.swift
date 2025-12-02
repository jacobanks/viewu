//
//  ViewEventDetail.swift
//  NVR Viewer
//
//  Created by Matthew Ehrhart on 3/1/24.
//
//  Depreciated

import SwiftUI
import AVKit
import SwiftData
import UIKit
import Photos

struct ViewEventDetail: View {
    
    let text: String
    let container: EndpointOptions
    
    @State private var player = AVPlayer()
    
    var frigatePlusOn: Bool = UserDefaults.standard.bool(forKey: "frigatePlusOn")
    var developerModeIsOn: Bool = UserDefaults.standard.bool(forKey: "developerModeIsOn")
    
    //
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.verticalSizeClass) var verticalSizeClass
    
    @EnvironmentObject private var notificationManager2: NotificationManager
    @State var selection: Int = 0
    @State var showButton: Bool
    @State var showClip: Bool
    
    let menuBGColor = Color.orange.opacity(0.6)
    let menuTextColor = Color.white
    let cBlue = Color(red: 0.153, green: 0.69, blue: 1)

    init(text: String, container: EndpointOptions, showButton: Bool, showClip: Bool) {
        self.text = text
        self.container = container
        self.showButton = showButton
        self.showClip = showClip
    }
    
    @State private var showingAlert = false
    
    
    //TODO Overlays
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                //Top Layout Display Info
                HStack{
                    VStack(spacing:2){
                        Label("\(container.cameraName!.capitalized)", systemImage: "web.camera")
                            .font(.system(size: 15))
                            .fontWeight(.regular)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(16)
                            .background(Color.orange.opacity(0.6))
                            .cardBackground(radius: .medium)

                            Label("\(container.label!.capitalized)", systemImage: "figure.walk.motion")
                                .font(.system(size: 15))
                                .fontWeight(.regular)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .padding(16)
                                .background(Color.red.opacity(0.6))
                                .cardBackground(radius: .medium)
                        
                        
                        if developerModeIsOn {
                            Label("\(container.type!)", systemImage: "moonphase.new.moon.inverse")
                                .font(.system(size: 15))
                                .fontWeight(.regular)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .padding(16)
                                .background(Color.gray.opacity(0.6))
                                .cardBackground(radius: .medium)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .trailing)

                    if let enteredZones = container.enteredZones {
                        // TODO: Fix truncated text (use normal frames)
                        EnteredZones(zones: enteredZones)
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading, 20)
                .padding(.trailing, 20)
                
                //Video Segment
                if showClip, container.m3u8 != nil {
                    VStack(spacing: 8) {
                        Text("Video Segment")
                            .padding(.horizontal)
                            .font(.system(size: 20))
                            .fontWeight(.regular)
                            .foregroundStyle(Color(red: 0.35, green: 0.35, blue: 0.35))
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        ViewPlayVideo(urlString: container.m3u8!)
                            .padding(.horizontal)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }

                if let snapshot = container.snapshot, container.id != nil && container.frigatePlus != nil {
                    VStack(spacing: 8) {
                        Text("Snapshot")
                            .padding(.horizontal)
                            .font(.system(size: 20))
                            .fontWeight(.regular)
                            .foregroundStyle(Color(red: 0.35, green: 0.35, blue: 0.35))
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        ViewUIImageFull(urlString: snapshot)
                            .padding(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 60))
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
            } // End of ScrollView
            .navigationBarTitle(text, displayMode: .inline)
            .padding(.bottom, 24)
        }
    }

    struct EnteredZones: View {
        
        let zones:String
        var enteredZones: Array<Substring>;
        
        init(zones: String) {
            self.zones = zones
            enteredZones = zones.split(separator: "|")
        }
        
        var body: some View {
            if !enteredZones.isEmpty {
                // TODO: Confirm this looks good with fake data
                VStack(spacing:2){
                    ForEach(enteredZones, id: \.self) { zone in
                        Rectangle()
                            .fill(Color.blue.opacity(0.6))
                            .padding(0)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .cardBackground(radius: .medium)
                            .overlay(
                                Label("\(zone)", systemImage: "")
                                    .font(.system(size: 15))
                                    .fontWeight(.regular)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity, maxHeight: 20)
                            )
                            .padding(.trailing, 40)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(0)
            } else {
                Text("No Zones Detected")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .font(.system(size: 15))
                    .fontWeight(.regular)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue.opacity(0.6))
                    .cardBackground(radius: .medium)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
    }
}
