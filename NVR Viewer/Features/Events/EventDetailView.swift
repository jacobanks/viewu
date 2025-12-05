//
//  EventDetailView.swift
//  NVR Viewer
//
//  Created by Jacob Banks on 12/4/25.
//

import SwiftUI

struct EventDetailView: View {
    let event: ReviewResponse

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                HStack{
                    VStack(spacing:2){
                        Label("\(event.camera.capitalized)", systemImage: "web.camera")
                            .font(.system(size: 15))
                            .fontWeight(.regular)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(16)
                            .background(Color.orange.opacity(0.6))
                            .cardBackground(radius: .medium)

                        HStack {
                            ForEach(event.data.objects, id: \.self) { object in
                                Image(systemName: object.icon)
                            }
                        }
                        .font(.system(size: 15))
                        .fontWeight(.regular)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(16)
                        .background(Color.red.opacity(0.6))
                        .cardBackground(radius: .medium)

                        Label("\(event.severity.rawValue.capitalized)", systemImage: "moonphase.new.moon.inverse")
                            .font(.system(size: 15))
                            .fontWeight(.regular)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(16)
                            .background(Color.gray.opacity(0.6))
                            .cardBackground(radius: .medium)
                    }
                    .frame(maxWidth: .infinity, alignment: .trailing)

                    zonesView
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading, 20)
                .padding(.trailing, 20)

                if let streamURL = event.streamURL {
                    VStack(spacing: 8) {
                        Text("Video Segment")
                            .padding(.horizontal)
                            .font(.system(size: 20))
                            .fontWeight(.regular)
                            .foregroundStyle(Color(red: 0.35, green: 0.35, blue: 0.35))
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        ViewPlayVideo(urlString: streamURL.absoluteString)
                            .padding(.horizontal)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
            }
            .navigationBarTitle(event.startTime.displayString, displayMode: .inline)
            .padding(.bottom, 24)
        }
    }

    @ViewBuilder
    private var zonesView: some View {
        if !event.data.zones.isEmpty {
            VStack(spacing: 2) {
                ForEach(event.data.zones, id: \.self) { zone in
                    Rectangle()
                        .fill(Color.blue.opacity(0.6))
                        .padding(0)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .cardBackground(radius: .medium)
                        .overlay(
                            Text("\(zone)")
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

//#Preview {
//    EventDetailView(event: ReviewResponse)
//}
