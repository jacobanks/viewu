//
//  ViewPlayVideo.swift
//  NVR Viewer
//
//  Created by Matthew Ehrhart on 3/1/24.
//

import SwiftUI
import AVKit

struct ViewPlayVideo: View {
    
    let urlString: String
    @State private var player = AVPlayer()
    
    @State private var showingAlert = false
    let cBlue = Color(red: 0.153, green: 0.69, blue: 1)
    let menuTextColor = Color.white
    
    //TODO Overlays
    var body: some View {
        VStack( spacing: 0){
            PlayerViewController(videoURL: URL(string: urlString), player: player)
                .aspectRatio( 16/9, contentMode: .fill)
                .frame(maxWidth: .infinity, maxHeight: 250, alignment: .leading)
                .onAppear {
                    player.pause()
                }
                .onDisappear {
                    player.pause()
                }
            
            HStack{
                ShareLink(item: urlString, preview: SharePreview("Viewu Video", image: urlString)) {
                    Image(systemName: "square.and.arrow.up")
                }
                .foregroundStyle(.white)
                .font(.system(size: 24))
                .frame(maxWidth: .infinity, alignment: .trailing)
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 16)
            .frame(maxWidth: .infinity, alignment: .trailing)
            .background(Color(red: 0.153, green: 0.69, blue: 1))
        }
        .cardBackground(radius: .large)
    }
}



struct PlayerViewController: UIViewControllerRepresentable {
    var videoURL: URL?
    @State var player: AVPlayer
    
    init(videoURL: URL?, player: AVPlayer){
        self.player = AVPlayer(url: videoURL!)
    }
    
    func makeUIViewController(context: Context) -> AVPlayerViewController {
        let controller = AVPlayerViewController()
        controller.modalPresentationStyle = .fullScreen
        controller.player = player
        //controller.player?.play()
        
        return controller
    }
    
    func updateUIViewController(_ playerController: AVPlayerViewController, context: Context) {}
}

struct CameraOverlayVideoClip2: View {
    let toCopy: String
    
    var body: some View {
        HStack{
            ShareLink(item: toCopy, preview: SharePreview("Viewu Video", image: toCopy)){
                Image(systemName: "square.and.arrow.up")
            }
            .foregroundStyle(.white)
            .font(.system(size: 24))
            .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .padding(.trailing, 16)
        .frame(maxWidth: .infinity, maxHeight: 50, alignment: .trailing)
        .background(Color(red: 0.153, green: 0.69, blue: 1))
    }
}
