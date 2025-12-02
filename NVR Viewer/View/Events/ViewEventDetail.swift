//
//  ViewEventDetail.swift
//  NVR Viewer
//
//  Created by Matthew Ehrhart on 3/1/24.
//
//  Depreciated

import SwiftUI
import AVKit
import SwiftData
import UIKit
import Photos

struct ViewEventDetail: View {
    
    let text: String
    let container: EndpointOptions
    
    @State private var player = AVPlayer()
    
    var frigatePlusOn: Bool = UserDefaults.standard.bool(forKey: "frigatePlusOn")
    var developerModeIsOn: Bool = UserDefaults.standard.bool(forKey: "developerModeIsOn")
    
    //
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.verticalSizeClass) var verticalSizeClass
    
    @EnvironmentObject private var notificationManager2: NotificationManager
    @State var selection: Int = 0
    @State var showButton: Bool
    @State var showClip: Bool
    
    let menuBGColor = Color.orange.opacity(0.6)
    let menuTextColor = Color.white
    let cBlue = Color(red: 0.153, green: 0.69, blue: 1)
  
    //Orientation and Landscape/Portrait Mode
    private var idiom : UIUserInterfaceIdiom { UIDevice.current.userInterfaceIdiom }
    @State var orientation = UIDevice.current.orientation
    let orientationChanged = NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)
        .makeConnectable()
        .autoconnect()
    
    init(text: String, container: EndpointOptions, showButton: Bool, showClip: Bool) {
        self.text = text
        self.container = container
        self.showButton = showButton
        self.showClip = showClip
    }
    
    @State private var showingAlert = false
    
    
    //TODO Overlays
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                //Top Layout Display Info
                HStack{
                    VStack(spacing:2){
                        Label("\(container.cameraName!.capitalized)", systemImage: "web.camera")
                            .font(.system(size: 15))
                            .fontWeight(.regular)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(16)
                            .background(Color.orange.opacity(0.6))
                            .modifier(CardBackground2())

                            Label("\(container.label!.capitalized)", systemImage: "figure.walk.motion")
                                .font(.system(size: 15))
                                .fontWeight(.regular)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .padding(16)
                                .background(Color.red.opacity(0.6))
                                .modifier(CardBackground2())
                        
                        
                        if developerModeIsOn {
                            Label("\(container.type!)", systemImage: "moonphase.new.moon.inverse")
                                .font(.system(size: 15))
                                .fontWeight(.regular)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .padding(16)
                                .background(Color.gray.opacity(0.6))
                                .modifier(CardBackground2())
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .trailing)

                    if let enteredZones = container.enteredZones {
                        // TODO: Fix truncated text (use normal frames)
                        EnteredZones(zones: enteredZones)
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading, 20)
                .padding(.trailing, 20)
                
                //Video Segment
                if showClip, container.m3u8 != nil {
                    VStack(spacing: 8) {
                        Text("Video Segment")
                            .padding(.horizontal)
                            .font(.system(size: 20))
                            .fontWeight(.regular)
                            .foregroundStyle(Color(red: 0.35, green: 0.35, blue: 0.35))
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        ViewPlayVideo(urlString: container.m3u8!)
                            .padding(.horizontal)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }

                if let snapshot = container.snapshot, container.id != nil && container.frigatePlus != nil {
                    VStack(spacing: 8) {
                        Text("Snapshot")
                            .padding(.horizontal)
                            .font(.system(size: 20))
                            .fontWeight(.regular)
                            .foregroundStyle(Color(red: 0.35, green: 0.35, blue: 0.35))
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        ViewUIImageFull(urlString: snapshot)
                            .padding(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 60))
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
            } // End of ScrollView
            .navigationBarTitle(text, displayMode: .inline)
            .padding(.bottom, 24)
        }
    }
    
    struct CardBackground2: ViewModifier {
        func body(content: Content) -> some View {
            content
                .cornerRadius(15)
                .shadow(color: Color.black.opacity(0.2), radius: 4)
        }
    }
    
    struct EnteredZones: View {
        
        let zones:String
        var enteredZones: Array<Substring>;
        
        @State var orientation = UIDevice.current.orientation
        private var idiom : UIUserInterfaceIdiom { UIDevice.current.userInterfaceIdiom }
        
        let orientationChanged = NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)
            .makeConnectable()
            .autoconnect()
        
        init(zones: String) {
            self.zones = zones
            enteredZones = zones.split(separator: "|")
        }
        
        var body: some View {
            if !enteredZones.isEmpty {
                // TODO: Confirm this looks good with fake data
                VStack(spacing:2){
                    ForEach(enteredZones, id: \.self) { zone in
                        Rectangle()
                            .fill(Color.blue.opacity(0.6))
                            .padding(0)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .modifier(CardBackground2())
                            .overlay(
                                Label("\(zone)", systemImage: "")
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
                    .modifier(CardBackground2())
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
    }
    
    struct CameraOverlayVideoClip: View {
        
        let toCopy: String
        private var idiom : UIUserInterfaceIdiom { UIDevice.current.userInterfaceIdiom }
        @State var orientation = UIDevice.current.orientation
        let orientationChanged = NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)
            .makeConnectable()
            .autoconnect()
        
        var body: some View {
            
            if idiom == .pad{
                
                if orientation.isLandscape {
                    HStack{
                        
                        ShareLink(item: toCopy, preview: SharePreview("Viewu Video", image: toCopy)){
                            Image(systemName: "square.and.arrow.up")
                        }
                        .frame(alignment: .trailing)
                        .foregroundColor(.white)
                        .fontWeight(.bold)
                    }
                    .padding(EdgeInsets(top: 0, leading: 0, bottom: 20, trailing: 30))
                }
                else {
                    
                    HStack{
                        
                        ShareLink(item: toCopy, preview: SharePreview("Viewu Video", image: toCopy)){
                            Image(systemName: "square.and.arrow.up")
                        }
                        .frame(alignment: .trailing)
                        .foregroundColor(.white)
                        .fontWeight(.bold)
                    }
                    .padding(EdgeInsets(top: 0, leading: 0, bottom: 40, trailing: 80))
                }
            }
            else {
                
                if orientation.isLandscape {
                    HStack{
                        
                        ShareLink(item: toCopy, preview: SharePreview("Viewu Video", image: toCopy)){
                            Image(systemName: "square.and.arrow.up")
                        }
                        .frame(alignment: .trailing)
                        .foregroundColor(.white)
                        .fontWeight(.bold)
                    }
                    .padding(EdgeInsets(top: 0, leading: 0, bottom: 30, trailing: 35))
                }
                else {
                    
                    HStack{
                        
                        ShareLink(item: toCopy, preview: SharePreview("Viewu Video", image: toCopy)){
                            Image(systemName: "square.and.arrow.up")
                        }
                        .foregroundStyle(.white)
                        .font(.system(size: 24))
                        
                        .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 40))
                        .frame(maxWidth: .infinity, maxHeight: 300, alignment: .trailing)
                    }
                    .padding(EdgeInsets(top: 00, leading: 0, bottom: 0, trailing: 40))
                    .frame(maxWidth: .infinity, maxHeight: 300, alignment: .trailing)
                    
                }
            }
        }
    }
    
    struct CameraOverlaySnapShot: View {
        
        let nvr = NVRConfig.shared()
        let cNVR = APIRequester()
        
        let eventId: String
        let toCopy: String
        @State var frigatePlus: Bool
        var frigatePlusOn: Bool = UserDefaults.standard.bool(forKey: "frigatePlusOn")
        
        private var idiom : UIUserInterfaceIdiom { UIDevice.current.userInterfaceIdiom }
        @State var orientation = UIDevice.current.orientation
        let orientationChanged = NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)
            .makeConnectable()
            .autoconnect()
        
        @ObservedObject var epsSuper = EndpointOptionsSuper.shared()
        
        @State private var showingAlert = false
        
        var body: some View {
            
            if idiom == .pad{
                
                if orientation.isLandscape {
                    HStack{
                        
                        Button{
                            UIPasteboard.general.string = toCopy
                        } label: {
                            Image(systemName: "doc.on.doc")
                        }
                        .frame(width: 340, alignment: .trailing)
                        .foregroundColor(.white)
                        .fontWeight(.bold)
                        
                        ShareLink(item: toCopy, preview: SharePreview("Viewu SnapshotE", image: toCopy)){
                            Image(systemName: "square.and.arrow.up")
                        }
                        .frame(alignment: .trailing)
                        .foregroundColor(.white)
                        .fontWeight(.bold)
                        
                        if !frigatePlus{
                            if frigatePlusOn {
                                Button{
                                    
                                    frigatePlus = true
                                    
                                    let url = nvr.getUrl()
                                    let urlString = url + "/api/events/\(eventId)/plus"
                                    cNVR.postImageToFrigatePlus(urlString: urlString, eventId: eventId ){ (data, error) in
                                        
                                        guard let data = data else { return }
                                        
                                        do {
                                            if let json = try JSONSerialization.jsonObject(with: data, options: .fragmentsAllowed ) as? [String: Any] {
                                                
                                                if let res = json["success"] as? Int {
                                                    //print(res)
                                                    if res == 1 {
                                                        
                                                        EventStorage.shared.updateFrigatePlus(id:eventId, value: true)
                                                        
                                                        EventStorage.shared.readAll3(completion: { res in
                                                            //self.epsSup3 = res!
                                                            epsSuper.list3 = res!
                                                            return
                                                        })
                                                    } else {
                                                        
                                                        if let msg = json["message"] as? String {
                                                            print(msg)
                                                            
                                                            if (msg == "PLUS_API_KEY environment variable is not set" ){
                                                                frigatePlus = false
                                                                EventStorage.shared.updateFrigatePlus(id: eventId, value: false)
                                                                Log.shared().print(page: "ViewEventDetail", fn: "button", type: "ERROR", text: "PLUS_API_KEY environment variable is not set")
                                                            }
                                                        }
                                                    }
                                                }
                                            }
                                        } catch(let error) {
                                            
                                            Log.shared().print(page: "ViewEventDetail", fn: "button", type: "ERROR", text: "\(error)")
                                            print(error)
                                        }
                                    }
                                    
                                } label: {
                                    Image(systemName: "plus.rectangle")
                                }
                                .foregroundColor(.white)
                                .fontWeight(.bold)
                            }
                        }
                    }
                    .padding(EdgeInsets(top: 0, leading: 0, bottom: 30, trailing: 70))
                }
                else {
                    HStack{
                        
                        Button{
                            UIPasteboard.general.string = toCopy
                        } label: {
                            Image(systemName: "doc.on.doc")
                        }
                        .frame(width: 340, alignment: .trailing)
                        .foregroundColor(.white)
                        .fontWeight(.bold)
                        
                        ShareLink(item: toCopy, preview: SharePreview("Viewu SnapshotE", image: toCopy)){
                            Image(systemName: "square.and.arrow.up")
                        }
                        .frame(alignment: .trailing)
                        .foregroundColor(.white)
                        .fontWeight(.bold)
                        
                        if !frigatePlus{
                            if frigatePlusOn {
                                Button{
                                    
                                    frigatePlus = true
                                    
                                    let url = nvr.getUrl()
                                    let urlString = url + "/api/events/\(eventId)/plus"
                                    cNVR.postImageToFrigatePlus(urlString: urlString, eventId: eventId ){ (data, error) in
                                        
                                        guard let data = data else { return }
                                        
                                        do {
                                            if let json = try JSONSerialization.jsonObject(with: data, options: .fragmentsAllowed ) as? [String: Any] {
                                                
                                                if let res = json["success"] as? Int {
                                                    //print(res)
                                                    if res == 1 {
                                                        
                                                        EventStorage.shared.updateFrigatePlus(id:eventId, value: true)
                                                        
                                                        EventStorage.shared.readAll3(completion: { res in
                                                            //self.epsSup3 = res!
                                                            epsSuper.list3 = res!
                                                            return
                                                        })
                                                    } else {
                                                        
                                                        if let msg = json["message"] as? String {
                                                            print(msg)
                                                            
                                                            if (msg == "PLUS_API_KEY environment variable is not set" ){
                                                                frigatePlus = false
                                                                EventStorage.shared.updateFrigatePlus(id: eventId, value: false)
                                                                Log.shared().print(page: "ViewEventDetail", fn: "button", type: "ERROR", text: "PLUS_API_KEY environment variable is not set")
                                                            }
                                                        }
                                                    }
                                                }
                                            }
                                        } catch(let error) {
                                            
                                            Log.shared().print(page: "ViewEventDetail", fn: "button", type: "ERROR", text: "\(error)")
                                            print(error)
                                        }
                                    }
                                    
                                } label: {
                                    Image(systemName: "plus.rectangle")
                                }
                                .foregroundColor(.white)
                                .fontWeight(.bold)
                            }
                        }
                    }
                    .padding(EdgeInsets(top: 0, leading: 0, bottom: 35, trailing: 60))
                }
            }
            else {
                if orientation.isLandscape {
                    HStack{
                        
                        Button{
                            UIPasteboard.general.string = toCopy
                        } label: {
                            Image(systemName: "doc.on.doc")
                        }
                        .frame(width: 340, alignment: .trailing)
                        .foregroundColor(.white)
                        .fontWeight(.bold)
                        
                        ShareLink(item: toCopy, preview: SharePreview("Viewu SnapshotE", image: toCopy)){
                            Image(systemName: "square.and.arrow.up")
                        }
                        .frame(alignment: .trailing)
                        .foregroundColor(.white)
                        .fontWeight(.bold)
                        
                        if !frigatePlus{
                            if frigatePlusOn {
                                Button{
                                    
                                    frigatePlus = true
                                    
                                    let url = nvr.getUrl()
                                    let urlString = url + "/api/events/\(eventId)/plus"
                                    cNVR.postImageToFrigatePlus(urlString: urlString, eventId: eventId ){ (data, error) in
                                        
                                        guard let data = data else { return }
                                        
                                        do {
                                            if let json = try JSONSerialization.jsonObject(with: data, options: .fragmentsAllowed ) as? [String: Any] {
                                                
                                                if let res = json["success"] as? Int {
                                                    //print(res)
                                                    if res == 1 {
                                                        
                                                        EventStorage.shared.updateFrigatePlus(id:eventId, value: true)
                                                        
                                                        EventStorage.shared.readAll3(completion: { res in
                                                            //self.epsSup3 = res!
                                                            epsSuper.list3 = res!
                                                            return
                                                        })
                                                    } else {
                                                        
                                                        if let msg = json["message"] as? String {
                                                            print(msg)
                                                            
                                                            if (msg == "PLUS_API_KEY environment variable is not set" ){
                                                                frigatePlus = false
                                                                EventStorage.shared.updateFrigatePlus(id: eventId, value: false)
                                                                Log.shared().print(page: "ViewEventDetail", fn: "button", type: "ERROR", text: "PLUS_API_KEY environment variable is not set")
                                                            }
                                                        }
                                                    }
                                                }
                                            }
                                        } catch(let error) {
                                            
                                            Log.shared().print(page: "ViewEventDetail", fn: "button", type: "ERROR", text: "\(error)")
                                            print(error)
                                        }
                                    }
                                    
                                } label: {
                                    Image(systemName: "plus.rectangle")
                                }
                                .foregroundColor(.white)
                                .fontWeight(.bold)
                            }
                        }
                    }
                    .padding(EdgeInsets(top: 0, leading: 0, bottom: 10, trailing: 20))
                }
                else {
                    HStack{
                        
                        //                        Button{
                        //                            UIPasteboard.general.string = toCopy
                        //                        } label: {
                        //                            Image(systemName: "doc.on.doc")
                        //                        }
                        //                        .frame(width: 340, alignment: .trailing)
                        //                        .foregroundColor(.white)
                        //                        .fontWeight(.bold)
                        
                        //                        ShareLink(item: toCopy, preview: SharePreview("Viewu SnapshotE", image: toCopy)){
                        //                            Image(systemName: "square.and.arrow.up")
                        //                        }
                        //                        .frame(alignment: .trailing)
                        //                        .foregroundColor(.white)
                        //                        .fontWeight(.bold)
                        
                        Label("", systemImage: "square.and.arrow.down")
                            .onTapGesture {
                                Task {
                                    let urlString = toCopy
                                    if let image = await downloadImage(from: urlString) {
                                        ImageSaver().saveToPhotoLibrary(image)
                                        
                                        showingAlert = true
                                    }
                                    
                                }
                            }
                            .alert(isPresented: $showingAlert) {
                                Alert(title: Text("Image Saved"),
                                      message: Text("This image has been saved to Photos"),
                                      dismissButton: .default(Text("OK")))
                            }
                        
                            .frame(alignment: .trailing)
                            .foregroundColor(.white)
                            .fontWeight(.bold)
                        
                        
                        
                        if !frigatePlus{
                            if frigatePlusOn {
                                Button{
                                    
                                    frigatePlus = true
                                    
                                    let url = nvr.getUrl()
                                    let urlString = url + "/api/events/\(eventId)/plus"
                                    cNVR.postImageToFrigatePlus(urlString: urlString, eventId: eventId ){ (data, error) in
                                        
                                        guard let data = data else { return }
                                        
                                        do {
                                            if let json = try JSONSerialization.jsonObject(with: data, options: .fragmentsAllowed ) as? [String: Any] {
                                                
                                                if let res = json["success"] as? Int {
                                                    //print(res)
                                                    if res == 1 {
                                                        
                                                        EventStorage.shared.updateFrigatePlus(id:eventId, value: true)
                                                        
                                                        EventStorage.shared.readAll3(completion: { res in
                                                            //self.epsSup3 = res!
                                                            epsSuper.list3 = res!
                                                            return
                                                        })
                                                    } else {
                                                        
                                                        if let msg = json["message"] as? String {
                                                            print(msg)
                                                            
                                                            if (msg == "PLUS_API_KEY environment variable is not set" ){
                                                                frigatePlus = false
                                                                EventStorage.shared.updateFrigatePlus(id: eventId, value: false)
                                                                Log.shared().print(page: "ViewEventDetail", fn: "button", type: "ERROR", text: "PLUS_API_KEY environment variable is not set")
                                                            }
                                                        }
                                                    }
                                                }
                                            }
                                        } catch(let error) {
                                            
                                            Log.shared().print(page: "ViewEventDetail", fn: "button", type: "ERROR", text: "\(error)")
                                            print(error)
                                        }
                                    }
                                    
                                } label: {
                                    Image(systemName: "plus.rectangle")
                                }
                                .foregroundColor(.white)
                                .fontWeight(.bold)
                            }
                        }
                    }
                    .padding(EdgeInsets(top: 0, leading: 0, bottom: 10, trailing: 70))
                }
            }
            
            
        }
        
        
        
        /*
         func saveImageToPhotos(image: UIImage) {
         PHPhotoLibrary.requestAuthorization(for: .addOnly) { status in
         switch status {
         case .authorized:
         UIImageWriteToSavedPhotosAlbum(image, self, #selector(self.image(_:didFinishSavingWithError:contextInfo:)), nil)
         case .denied, .restricted:
         print("Access to photo library denied or restricted.")
         // Handle denied/restricted access (e.g., show an alert)
         case .notDetermined:
         // This case should ideally not be reached if requestAuthorization is called
         print("Photo library access not determined.")
         case .limited:
         // Handle limited access in iOS 14+
         print("Limited access to photo library.")
         @unknown default:
         fatalError("Unknown PHAuthorizationStatus")
         }
         }
         }
         
         //@objc
         func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
         if let error = error {
         print("Error saving image: \(error.localizedDescription)")
         } else {
         print("Image saved successfully to Photos.")
         }
         }
         */
    }
}

func downloadImage(from urlString: String) async -> UIImage? {
    guard let url = URL(string: urlString) else {
        print("Invalid URL")
        return nil
    }
    
    do {
        // Asynchronously download the data
        let (data, _) = try await URLSession.shared.data(from: url)
        // Create a UIImage from the downloaded data
        return UIImage(data: data)
    } catch {
        print("Error downloading image: \(error.localizedDescription)")
        return nil
    }
}

class ImageSaver: NSObject {
    func saveToPhotoLibrary(_ image: UIImage) {
        // This function asks for permission and saves the image
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(saveCompleted), nil)
    }
    
    @objc func saveCompleted(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeMutableRawPointer) {
        if let error = error {
            // Handle the error (e.g., user denied permission)
            print("Save error: \(error.localizedDescription)")
        } else {
            // Image saved successfully
            print("Image saved successfully!")
        }
    }
}

func isLargeiPad() -> Bool {
    let screenHeight = UIScreen.main.bounds.height
    let screenWidth = UIScreen.main.bounds.width
    let longerDimension = max(screenHeight, screenWidth)
     
    return longerDimension > 1300
}

func isLargeiPhone() -> Bool {
    
    if UIDevice.current.userInterfaceIdiom == .phone {
        let screenHeight = UIScreen.main.nativeBounds.height / UIScreen.main.nativeScale
         
        return screenHeight >= 900.0
        
    }
    return false
}
 
