//
//  ViewCameraDetails.swift
//  NVR Viewer
//
//  Created by Matthew Ehrhart on 11/8/25.
//

import SwiftUI

struct ViewCameraDetails2: View {
    var cameras: Cameras2
    let text: String
     
    init (text: String, cameras: Cameras2){
        self.cameras = cameras
        self.text = text
    }
    
    let widthMultiplier:CGFloat = 2/5.5
    
    var body: some View {
        Form {
            Section{
                HStack{
                    Text("Enabled")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.leading, 40)
                    Text(verbatim: String(cameras.enabled))
                        .frame( alignment: .leading)
                        .foregroundStyle(.gray)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            } header: {
                Text("Camera")
                    .font(.caption)
            }
        }
        .navigationBarTitle(text, displayMode: .inline)
    }
}

