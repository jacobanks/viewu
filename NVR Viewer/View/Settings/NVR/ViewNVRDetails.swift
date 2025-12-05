//
//  ViewNVRDetails.swift
//  NVR Viewer
//
//  Created by Matthew Ehrhart on 4/1/24.
//

import SwiftUI

struct ViewNVRDetails: View {
    @EnvironmentObject private var config: NVRConfiguration

    var body: some View {
        Form {
            Section{
                ForEach(config.config?.cameras.values.sorted(by: { $0.name < $1.name }) ?? []) { camera in
                    NavigationLink {
                        ViewCameraDetails2(text: "\(camera.name.uppercased()) Camera Details", cameras: camera)
                    } label: {
                        Text("\(camera.name.uppercased())")
                    }
                }
            } header: {
                Text("Cameras")
                    .font(.caption)
                    .foregroundColor(.orange)
            }
            
            Section{
                HStack{
                    Text("ClientID")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.leading, 40)
                    Text(config.config?.mqtt.client_id ?? "n/a")
                        .frame( alignment: .leading)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                HStack{
                    Text("Host")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.leading, 40)
                    Text("\(config.config?.mqtt.host ?? "n/a")")
                        .frame( alignment: .leading)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                HStack{
                    Text("Port")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.leading, 40)
                    Text("\(String(config.config?.mqtt.port ?? 1))")
                        .frame( alignment: .leading)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                HStack{
                    Text("Topic")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.leading, 40)
                    Text("\(config.config?.mqtt.topic_prefix ?? "n/a")")
                        .frame( alignment: .leading)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                HStack{
                    Text("Interval2")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.leading, 40)
                    Text("\(config.config?.mqtt.stats_interval ?? -1)")
                        .frame( alignment: .leading)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
            } header: {
                Text("MQTT")
                    .font(.caption)
                    .foregroundColor(.orange)
            }
          
//            if ( config.config?.go2rtc.streams != nil  ){ 
//                //streams: ["" : [] ])
//                Section {
//                    ForEach(Array(config.config?.go2rtc.streams!.keys ).sorted(by: {$0 < $1}), id: \.self) { value in
//                      if !value.isEmpty {
//                        Text("\(value)")
//                              .frame(maxWidth: .infinity, alignment: .leading)
//                            .padding(.leading, 75)
//  
//                            ForEach(config.config?.go2rtc.streams![value]!, id: \.self) { item in
//                                ScrollView(.horizontal){
//                                    Text("\(item)")
//                                        .textSelection(.enabled)
//                                        .foregroundStyle(.secondary)
//                                        .padding(.leading, 0)
//                                        .frame(maxWidth: .infinity, alignment: .leading)
//                                }
//                            }
//                        }
//                   }
//                } header: {
//                    Text("Go2RTC")
//                        .font(.caption)
//                        .foregroundColor(.orange)
//                }
//            }
              
          
            
        }
        .background(Color(UIColor.secondarySystemBackground)) //very light gray
        .navigationBarTitle("NVR Configuration", displayMode: .inline)
    }
    
}

struct HorizontalLabelStyle: LabelStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            configuration.icon.font(.system(size: 18, weight: .medium, design: .default))
            configuration.title.font(.system(size: 17)) 
        }
    }
}

//#Preview {
//    ViewNVRDetails()
//}
