import SwiftUI

struct EventFiltersView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var filter = EventFilter.shared()

    var body: some View {
        NavigationStack {
            VStack{
                Form{
                    Section {
                        HStack{
                            Label("", systemImage: "web.camera")
                                .padding(0)
                                .foregroundStyle(Color(red: 0.153, green: 0.69, blue: 1))
                            Picker("Camera", selection: $filter.selectedCamera) {
                                ForEach(filter.cameras, id: \.self) {
                                    Text($0)
                                }
                            }.pickerStyle( .menu )
                                .frame(minWidth: 100)
                                .padding(0)
                                .tint(Color(red: 0.153, green: 0.69, blue: 1))
                        }
                        
                        HStack{
                            Label("", systemImage: "figure.walk.motion")
                                .padding(0)
                                .foregroundStyle(Color(red: 0.153, green: 0.69, blue: 1))
                            Picker("Object", selection: $filter.selectedObject) {
                                ForEach(filter.objects, id: \.self) {
                                    Text($0)
                                }
                            }.pickerStyle( .menu )
                                .frame(minWidth: 100)
                                .padding(0)
                                .tint(Color(red: 0.153, green: 0.69, blue: 1))
                        }
                        
                        HStack{
                            Label("", systemImage: "square.stack.3d.down.right.fill")
                                .padding(0)
                                .foregroundStyle(Color(red: 0.153, green: 0.69, blue: 1))
                            Picker("Zones", selection: $filter.selectedZone) {
                                ForEach(filter.zones, id: \.self) {
                                    Text($0)
                                }
                            }.pickerStyle( .menu )
                                .frame(minWidth: 100)
                                .padding(0)
                                .tint(Color(red: 0.153, green: 0.69, blue: 1))
                        }
                        
                        HStack{
                            Label("", systemImage: "lineweight")
                                .padding(0)
                                .foregroundStyle(Color(red: 0.153, green: 0.69, blue: 1))
                            Picker("Type", selection: $filter.selectedType) {
                                ForEach(filter.types, id: \.self) {
                                    Text($0)
                                }
                            }.pickerStyle( .menu )
                                .frame(minWidth: 100)
                                .padding(0)
                                .tint(Color(red: 0.153, green: 0.69, blue: 1))
                        }
                        
                    } header: {
                        Text("Filter")
                            .font(.largeTitle)
                    }
                    
                    Section {
                        DatePicker(
                            "Start Date",
                            selection: $filter.startDate,
                            in: ...Date.now,
                            displayedComponents: [.date]
                        )
                        .datePickerStyle(.compact)
                        
                        DatePicker(
                            "End Date",
                            selection: $filter.endDate,
                            in: ...Date.now,
                            displayedComponents: [.date]
                        )
                        .datePickerStyle(.compact)
                    }  header: {
                        Text("Date Range")
                            .font(.largeTitle)
                    }
                    
                    Button("Reset") {
                        filter.reset() 
                    }
                    .buttonStyle(CustomPressEffectButtonStyle())
                    .frame(maxWidth: .infinity, alignment: .trailing)
                }
            }
            .toolbar {
                ToolbarItem {
                    Button(role: .close) {
                        dismiss()
                    }
                }
            }
        }
    }

    struct CustomPressEffectButtonStyle: ButtonStyle {
            func makeBody(configuration: Configuration) -> some View {
                configuration.label
                    .padding(8)
                    .background(configuration.isPressed ? Color.gray : Color.orange.opacity(0.6))
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
}

#Preview {
    EventFiltersView()
}
 
