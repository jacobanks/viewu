//
//  NVRConfig.swift
//  NVR Viewer
//
//  Created by Matthew Ehrhart on 3/3/24.
//

import Foundation


@MainActor
final class NVRConfiguration: ObservableObject {
    @Published var config: NVRConfigurationCall2?

    var https: Bool = UserDefaults.standard.bool(forKey: "nvrIsHttps")
    var url: String = UserDefaults.standard.string(forKey: "nvrIPAddress") ?? "0.0.0.0"
    var port: String = UserDefaults.standard.string(forKey: "nvrPortAddress") ?? "5000"

    @Published var connectionState: NVRConnectionState = .disconnected

    func setHttps(http: Bool) {
        self.https = http
    }
    
    func setIP(ip: String) {
        self.url = ip
    }
    
    func setPort(port: String) {
        self.port = port
    }
    
    func getIP() -> String {
        return url
    }
    
    func getUrl() -> String {
        
        var http: String {
            if https {
                return "https://"
            } else {
                return "http://"
            }
        }
        
        let url: String = http + url + ":" + port
        return url
    }
    
    func getConnectionState() -> Bool {
        
        var isConnected: Bool {
            switch self.connectionState {
            case .connected: 
                return true
            case .disconnected:
                return false
            }
        }
        return isConnected
    }
    
    func checkConnectionStatus() async {
        connectionState = await FrigateService().checkConnection()
    }
}

