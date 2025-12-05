//
//  ViewCamera.swift
//  NVR Viewer
//
//  Created by Matthew Ehrhart on 3/1/24.
//

import Foundation
import SwiftUI
import WebKit
import VLCKitSPM
import TipKit

struct ViewCamera: View {
    @EnvironmentObject private var config: NVRConfiguration

    let title: String
    var developerModeIsOn: Bool = UserDefaults.standard.bool(forKey: "developerModeIsOn")

    @AppStorage("camerGo2Rtc") private var camerGo2Rtc: Bool = true
    @AppStorage("cameraHLS") private var cameraHLS: Bool = false

    var body: some View {
        ScrollView {
            VStack {
                ViewTipsLiveCameras(
                    title: "Live Cameras",
                    message: "You can change the camera stream from the Settings page. To reduce load times, use a sub-stream whenever possible."
                )
                .padding(15)
         
                Section {
                    VStack {
                        ForEach(config.config?.cameras.values.sorted(by: { $0.name < $1.name }) ?? []) { camera in
                            if camera.enabled {
                                if camerGo2Rtc, let input = camera.ffmpeg.inputs.first(where: { $0.roles.contains(.record) }) ?? camera.ffmpeg.inputs.first {
                                    let url = verifyGo2RTCUrl(urlString: input.path)
                                    StreamRTSP2(urlString: url, cameraName: camera.name)
                                        .padding(0)

                                    if developerModeIsOn {
                                        Text(url)
                                            .textSelection(.enabled)
                                    }
                                } else if cameraHLS {
                                    let url = config.getUrl()
                                    HLSPlayer2(urlString: url, cameraName: camera.name, flagFull: false)

                                    if developerModeIsOn {
                                        Text(url + "/api/\(camera.name)?h=720")
                                            .textSelection(.enabled)
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        .navigationBarTitle(title, displayMode: .inline)
        .toolbarBackground(.visible, for: .navigationBar)
        .scrollIndicators(.hidden)
    }

    func verifyGo2RTCUrl(urlString: String) -> String {
        let tmp = urlString.split(separator: ":")
        let data = Array(tmp[1])
        let ip = String(data[2...])
        
        if ip == "127.0.0.1" || ip == "localhost" {
            let newAddress = tmp[0] + "://" + config.getIP() + ":" + String(tmp[2])
            return newAddress
        }
        return urlString
    }
}


