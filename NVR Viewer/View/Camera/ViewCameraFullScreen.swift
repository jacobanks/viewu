//
//  ViewCameraFullScreen.swift
//  NVR Viewer
//
//  Created by Matthew Ehrhart on 5/7/24.
//

import Foundation
import VLCKitSPM
import SwiftUI

struct ViewCameraFullScreen: View {
    
    let urlString: String 
    let cameraName: String
    @State var mediaPlayer: VLCMediaPlayer = VLCMediaPlayer()
    let cBlue = Color(red: 0.153, green: 0.69, blue: 1)
    let menuTextColor = Color.white
    @State var isMuted: Bool = false

    var body: some View {
        VStack {
            ZStack {
                LinearGradient(
                    colors: [.orange, cBlue, .orange],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                
                ProgressView {
                    Text("Loading: \(urlString)")
                        .labelStyle(VerticalLabelStyle(show: false))
                        .foregroundStyle(menuTextColor)
                }

                VLCPlayerRepresentable(rtspURL: URL(string: urlString)!, mediaPlayer: mediaPlayer)
                    .aspectRatio(16/9, contentMode: .fit)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .onAppear(){
                        mediaPlayer.audio?.isMuted = false
                        isMuted = mediaPlayer.audio?.isMuted ?? true
                        mediaPlayer.play()
                    }
                    .onDisappear(){
                        mediaPlayer.stop()
                    }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .edgesIgnoringSafeArea(.all)
            .toolbar {
                Button {
                    isMuted.toggle()
                    mediaPlayer.audio?.isMuted.toggle()
                } label: {
                    Label("", systemImage: isMuted ? "speaker.slash" : "speaker")
                }
            }
        }
        .toolbar(.hidden, for: .tabBar)
    }
}
 
