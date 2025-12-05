//
//  ViewLog.swift
//  NVR Viewer
//
//  Created by Matthew Ehrhart on 6/3/24.
//

import SwiftUI

struct ViewLog: View {
    var list: [LogItem] = []

    init() {
        self.list = Log.shared().getList()
    }

    var body: some View {
 
        VStack{
            ScrollView{
                ForEach(list, id: \.self) { row in
                    HStack{
                        Text(row.type)
                            .font(.caption)
                            .frame(width: 50, alignment: .topLeading)
                        Divider().frame(width: 1)
                        Text(row.page)
                            .font(.caption)
                            .frame(width: 100, alignment: .topLeading)
                        Divider().frame(width: 1)
                        Text(row.fn)
                            .font(.caption)
                            .frame( maxWidth: .infinity, alignment: .topLeading) //changed from width
                    }
                    .frame(maxWidth: .infinity, alignment: .topLeading)
                    
                    Text(row.text)
                        .font(.callout)
                        .frame(maxWidth: .infinity, alignment: .topLeading)
                        .textSelection(.enabled)
                    
                    Divider()
                }
            }
            .frame(maxWidth: .infinity, alignment: .topLeading)
        }
        .padding([.leading, .trailing], 5)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
}

//#Preview {
//    ViewLog()
//}
