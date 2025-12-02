//
//  ViewUIImageFull.swift
//  NVR Viewer
//
//  Created by Matthew Ehrhart on 3/1/24.
//

import SwiftUI

struct ViewUIImageFull: View{
    
    let cNVR = APIRequester()
    let urlString: String
    @State var data: Data?
    @State var zoomIn: Bool = false
    
    let cBlue = Color(red: 0.153, green: 0.69, blue: 1)
    let menuTextColor = Color.white
    
    @State private var showingAlert = false
    
    //Full Screen
    @State private var isFullScreen = false
    
    //Pinch and Zoom
    @State private var currentScale: CGFloat = 1.0
    @State private var finalScale: CGFloat = 1.0
    
    var body: some View {
        VStack {
            if let data = data, let uiimage = UIImage(data: data){
                VStack( spacing: 0){
                    Image(uiImage: uiimage)
                        .resizable()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .scaledToFill()

                    HStack(alignment: .lastTextBaseline, spacing: 8){
                        VStack(spacing: 2) {
                            Label("", systemImage: "square.and.arrow.down")
                                .foregroundStyle(menuTextColor)
                                .foregroundStyle(.blue.opacity(0.6))
                                .font(.system(size: 24))
                                .onTapGesture {
                                    Task {
                                        let urlString = urlString
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
                        }

                        Label("", systemImage: "arrow.down.left.and.arrow.up.right.rectangle")
                            .foregroundStyle(menuTextColor)
                            .font(.system(size: 24))
                            .onTapGesture {
                                isFullScreen.toggle()
                            }
                    }
                    .padding(.vertical, 8)
                    .padding(.horizontal, 16)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .background(cBlue.opacity(0.6))
                }
                .cardBackground(radius: .large)
                .frame(maxWidth: .infinity)
            } else {
                //Dummy Space
                Text("")
                    .aspectRatio(contentMode: /*@START_MENU_TOKEN@*/.fill/*@END_MENU_TOKEN@*/)
                    .frame(width: 250,height: 150)
                    .onAppear{
                        
                        cNVR.fetchImage(urlString: urlString){ (data, error) in
                            
                            if let error = error {
                                
                                Log.shared().print(page: "ViewUIImageFull", fn: "onAppear", type: "ERROR", text: "\(error)")
                                //if Event Snapshot is empty, show this instead
                                cNVR.fetchImage(urlString: "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQoBAeYwmKevvqaidagwfKDT6UXrei3kiWYlw&usqp=CAU"){ (data, error) in
                                    self.data = data
                                }
                                
                            } else {
                                self.data = data
                            }
                        }
                    }
            }
        }
        .navigationDestination(isPresented: $isFullScreen){
            ViewUIImageFull2(urlString: urlString) 
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

    private func downloadImage(from urlString: String) async -> UIImage? {
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
}
