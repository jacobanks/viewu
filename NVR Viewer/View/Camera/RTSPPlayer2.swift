//
//  RTSPPlayer2.swift
//  NVR Viewer
//
//  Created by Matthew Ehrhart on 3/30/24.
//

import Foundation
import VLCKitSPM
import SwiftUI

struct VLCPlayerRepresentable: UIViewRepresentable {
    let rtspURL: URL
    let mediaPlayer : VLCMediaPlayer

    func makeUIView(context: Context) -> UIView {
        let playerView = UIView()
        mediaPlayer.drawable = playerView // Assign the UIView as the drawable surface
        mediaPlayer.media = VLCMedia(url: rtspURL)
        return playerView
    }

    func updateUIView(_ uiView: UIView, context: Context) {}
}

struct StreamRTSP2: View {
    let urlString: String
    let cameraName: String
    
    @State var mediaPlayer : VLCMediaPlayer = VLCMediaPlayer()
    @State var flagMute = true
    @State var flagFull = false
    @State var isLoading = true

    let menuBGColor = Color.orange.opacity(0.6)
    let menuTextColor = Color.white
    let cBlue = Color(red: 0.153, green: 0.69, blue: 1)
    
    var body: some View {
        VStack {
            ZStack {
                if isLoading {
                    LinearGradient(
                        colors: [.clear, cBlue, .clear],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .ignoresSafeArea()
                }

                Text("Loading: \(urlString)")
                    .labelStyle(VerticalLabelStyle(show: false))
                    .foregroundStyle(menuTextColor)

                if let url = URL(string: urlString) {
                    VStack {
                        VLCPlayerRepresentable(rtspURL: url, mediaPlayer: mediaPlayer)
                            .padding(0)
                            .aspectRatio(16/9, contentMode: .fit)
                            .onAppear(){
                                //isLoading = false
                                mediaPlayer.audio?.isMuted = flagMute
                                mediaPlayer.play()
                            }
                            .onDisappear(){
                                mediaPlayer.stop()
                            }
                    }
                    .background(Color.gray.opacity(0.125))
                }
            }
            .padding(0)

            HStack(alignment: .firstTextBaseline){
                HStack(alignment: .lastTextBaseline){
                    Text("\(cameraName)")
                        .foregroundStyle(menuTextColor)
                        .font(.system(size: 22))
                        .onTapGesture(perform: {
                            
                        })
                        .padding(EdgeInsets(top: 0, leading: 20, bottom: 00, trailing: 0))
                        .frame(maxWidth: .infinity, alignment: .leading)

                    Label("", systemImage: flagMute ? "speaker.slash" : "speaker")
                        .foregroundStyle(menuTextColor)
                        .font(.system(size: 24))
                        .onTapGesture(perform: {
                            flagMute.toggle()
                            mediaPlayer.audio?.isMuted = flagMute
                        })
                        .padding(.trailing,20)

                    Label("", systemImage: "arrow.down.left.and.arrow.up.right.rectangle")
                        .foregroundStyle(menuTextColor)
                        .font(.system(size: 24))
                        .onTapGesture(perform: {
                            flagFull.toggle()
                        })
                        .padding(EdgeInsets(top: 0, leading: 0, bottom: 10, trailing: 20))
                }
                .padding(EdgeInsets(top: 3, leading: 0, bottom: 3, trailing: 0))

                Spacer()
            }
        }
        .background(menuBGColor)
        .cardBackground(radius: .medium)
        .padding(.leading,10)
        .padding(.trailing,10)
        .padding(.bottom,10)
        .navigationDestination(isPresented: $flagFull){
            ViewCameraFullScreen(urlString: urlString, cameraName: cameraName)
        }
    }
}
