import SwiftUI
import SwiftData
import AVFoundation

struct EventsListView: View {
    @ObservedObject var filter = EventFilter.shared()

    @State private var events: [ReviewResponse] = []
    @State private var showFilter = false

    var body: some View {
        List {
            ForEach(events) { event in
                eventCard(event)
                    .overlay {
                        NavigationLink("") {
                            EventDetailView(event: event)
                        }
                        .opacity(0)
                    }
                    .overlay(alignment: .center) {
                        if event.streamURL == nil {
                            ProgressView()
                        }
                    }
            }
            .listRowSeparator(.hidden)
            .listRowInsets(EdgeInsets(top: 4, leading: 4, bottom: 4, trailing: 4))
        }
        .listStyle(.plain)
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("Events")
        .toolbar {
            ToolbarItemGroup(placement: .topBarLeading) {
                Button("Filters") {
                    showFilter.toggle()
                }
            }
        }
        .task { await retrieveReviews() }
        .refreshable {
            Task { await retrieveReviews() }
        }
        .sheet(
            isPresented: $showFilter,
            onDismiss: {
                Task {
                    await retrieveReviews()
                }
            }
        ) {
            EventFiltersView()
                .presentationDetents([.large])
        }
    }

    private func eventCard(_ event: ReviewResponse) -> some View {
        AsyncImageProgressView(url: event.thumbnailURL)
            .overlay(alignment: .bottom) {
                HStack {
                    HStack {
                        ForEach(event.data.objects, id: \.self) { object in
                            Image(systemName: object.icon)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .bottomLeading)

                    Text(event.startTime.displayString)
                        .frame(maxWidth: .infinity, alignment: .bottomTrailing)
                }
                .padding(8)
                .background(LinearGradient(colors: [Color.black.opacity(0.0), Color.black.opacity(0.6)], startPoint: .top, endPoint: .bottom))
            }
    }
 
    private func retrieveReviews() async {
        do {
            events = try await FrigateService().retrieveReviewList(
                cameras: filter.selectedZone != "all" ? [filter.selectedCamera] : [],
                objects: filter.selectedZone != "all" ? [filter.selectedObject] : [],
                zones: filter.selectedZone != "all" ? [filter.selectedZone] : [],
                showDetections: filter.selectedType == "detections",
                beforeDate: filter.endDate,
                afterDate: filter.startDate
            )
        } catch {
            print("Failed to retrieve or decode events: \(error)")
        }
    }
}

struct AsyncImageProgressView: View {
    let url: URL?

    var body: some View {
        AsyncImage(url: url) { phase in
            switch phase {
            case .empty:
                ZStack {
                    Rectangle()
                        .fill(Color.secondary.opacity(0.15))
                        .frame(maxWidth: .infinity)
                        .aspectRatio(16/9, contentMode: .fit)
                        .cornerRadius(8)
                    ProgressView()
                }
            case .success(let image):
                image
                    .resizable()
                    .scaledToFit()
                    .cornerRadius(8)
            case .failure:
                ZStack {
                    Rectangle()
                        .fill(Color.secondary.opacity(0.15))
                        .frame(maxWidth: .infinity)
                        .aspectRatio(16/9, contentMode: .fit)
                        .cornerRadius(8)
                    VStack(spacing: 8) {
                        Image(systemName: "photo")
                            .font(.system(size: 28))
                            .foregroundStyle(.secondary)
                        Text("Failed to load")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding()
                }
            @unknown default:
                EmptyView()
            }
        }
    }
}

//#Preview {
//    ViewEventsHistory()
//}
