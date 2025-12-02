//
//  ViewLive.swift
//  NVR Viewer
//
//  Created by Matthew Ehrhart on 3/28/24.
//

import SwiftUI
import AVKit

struct ViewLive: View {
    
    let text: String
    let container: EndpointOptions
    
    @State private var player = AVPlayer()
    
    //
    @EnvironmentObject private var notificationManager2: NotificationManager
    
    init(text: String, container: EndpointOptions, player: AVPlayer = AVPlayer(), showButton: Bool) {
        self.text = text
        self.container = container
        self.player = player
    }
    
    var body: some View {
        VStack(alignment: .leading){
            ScrollView {
 
                ViewLiveLandscape(urlString: container.snapshot!, cameraName: container.cameraName! ,zoomIn: false)
                    .padding([.top], 147)  
            }
        }
        .navigationBarTitle(text, displayMode: .inline)
    }
}
 

//#Preview {
//    ViewLive(text: convertDateTime(time: 1710541384.496615), container: EndpointOptions(), showButton: true)
//}
 
