//
//  HLSPlayer2.swift
//  NVR Viewer
//
//  Created by Matthew Ehrhart on 5/31/24.
//

import SwiftUI
import WebKit

struct HLSPlayer2: View {
    let urlString: String
    let cameraName: String
    @State var flagFull = false

    let menuBGColor = Color.orange.opacity(0.6)
    let menuTextColor = Color.white
    
    var body: some View {
        VStack {
            HStack {
                ZStack {
                    LinearGradient(
                        colors: [.clear, Color(red: 0.80, green: 0.80, blue: 0.80), .clear],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .ignoresSafeArea()
                    VStack {
                        Webview(url: urlString + "/api/\(cameraName)?h=480")
                            .aspectRatio(16/9, contentMode: .fill)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .edgesIgnoringSafeArea(.all)
                            .background(Color.gray.opacity(0.125))
                    }
                    .background(Color.gray.opacity(0.125))
                }
            }

            HStack(alignment: .lastTextBaseline) {
                Text(cameraName)
                    .foregroundStyle(menuTextColor)
                    .font(.system(size: 22))
                    .padding(EdgeInsets(top: 0, leading: 20, bottom: 00, trailing: 0))
                    .frame(maxWidth: .infinity, alignment: .leading)
 
                Label("", systemImage: "arrow.down.left.and.arrow.up.right.rectangle")
                    .foregroundStyle(menuTextColor)
                    .font(.system(size: 24))
                    .onTapGesture(perform: {
                        flagFull.toggle()
                    })
                    .padding(EdgeInsets(top: 0, leading: 0, bottom: 10, trailing: 20))
            }
            .padding(EdgeInsets(top: 3, leading: 0, bottom: 3, trailing: 0))
        }
        .background(menuBGColor)
        .cardBackground(radius: .medium)
        .padding(.leading,10)
        .padding(.trailing,10)
        .padding(.bottom,15)
        .navigationDestination(isPresented: $flagFull){
            ViewCameraHLSFullScreen(urlString: urlString, cameraName: cameraName)
        }
    }
}

struct Webview: UIViewRepresentable {
    
    var url: String
    func makeUIView(context: Context) -> WKWebView {
        
        guard let url = URL(string: self.url) else {
            return WKWebView()
        }
        
        let request = URLRequest(url: url)
        
        let wkWebview = WKWebView()
        wkWebview.load(request)
        return wkWebview
    }
    
    func updateUIView(_ uiView: Webview.UIViewType, context: UIViewRepresentableContext<Webview>) {
    }
}
