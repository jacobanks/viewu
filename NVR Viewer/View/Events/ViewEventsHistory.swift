//
//  ViewEventsHistory.swift
//  NVR Viewer
//
//  Created by Matthew Ehrhart on 3/5/24.
//

import SwiftUI
import SwiftData

struct ViewEventsHistory: View {
    //
    @State var index = 0
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    let cNVR = APIRequester()
    
    @State private var showFilter = false

    @ObservedObject var filter2 = EventFilter.shared()
    @ObservedObject var epsSuper = EndpointOptionsSuper.shared()
    @ObservedObject var epsSup3 = EndpointOptionsSuper.shared()
    @ObservedObject var nvrManager = NVRConfig.shared() //was stateobject
    
    @Environment(\.scenePhase) var scenePhase
     
    init() {
        
    }
    
    var body: some View {
        VStack{
            List {
                ForEach(epsSup3.list3, id: \.sid) { container in 
                    
                    if container.id! != "" {
                        ViewEventCard(frameTime: container.frameTime!) 
                    }
                }
            }
            .toolbar {
                ToolbarItemGroup(placement: .primaryAction) {
                    HStack{
                        Text("\(epsSup3.list3.count)")
                            .font(.system(size: 20))
                            .fontWeight(.regular)
                            .foregroundColor(.gray)
                        Label(!nvrManager.getConnectionState() ? "" : "", systemImage: "cable.connector")
                            .frame(alignment: .leading)
                            .foregroundStyle(nvrManager.getConnectionState() ? .white : .red)
                    } 
                }
                ToolbarItemGroup(placement: .topBarLeading) {
                    Button("Filters") {
                        showFilter.toggle()
                    }
                }
            }
            .task{
                EventStorage.shared.readAll3(completion: { res in
                    epsSup3.list3 = res!
                })
            }
            .listStyle(PlainListStyle())
            .listRowInsets(EdgeInsets.init(top: 0, leading: 0, bottom: 0, trailing: 0))
            .scrollContentBackground(.hidden)
            .environment(\.defaultMinListRowHeight, 50)
            .padding(0)
        }
        .sheet(isPresented: $showFilter) {
            ViewFilter()
                .presentationDetents([.large])
        }
        .navigationDestination(for: EndpointOptions.self){ eps in
            ViewEventDetail(text: convertDateTime(time: eps.frameTime!), container: eps, showButton: false, showClip: true)
        }
    }
 
    private func deserializeObject(object: Data?) ->  String{
        
        let jsonString = String(data: object!, encoding: .utf8)!
        return jsonString
    }
    
    private func convertDateTime(time: Double) -> String{
        let date = Date(timeIntervalSince1970: time)
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = DateFormatter.Style.short
        dateFormatter.dateStyle = DateFormatter.Style.medium
        dateFormatter.timeZone = .current
        var localDate = dateFormatter.string(from: date)
        localDate.replace("at", with: "")
        return localDate
    }
}

//#Preview {
//    ViewEventsHistory()
//}


