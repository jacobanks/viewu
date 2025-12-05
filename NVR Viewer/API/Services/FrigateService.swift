//
//  FrigateService.swift
//  NVR Viewer
//
//  Created by Jacob Banks on 12/3/25.
//

import Foundation

struct FrigateService: Serviceable {
    func retrieveConfig() async throws -> NVRConfigurationCall2 {
        let data = try await data(request: Routes.config.urlRequest)
        let reviews = try JSONDecoder().decode(NVRConfigurationCall2.self, from: data)
        return reviews
    }

    func retrieveReviewList(
        cameras: [String],
        objects: [String],
        zones: [String],
        showDetections: Bool,
        beforeDate: Date,
        afterDate: Date
    ) async throws -> [ReviewResponse] {
        let route = Routes.reviews(
            cameras: cameras,
            objects: objects,
            zones: zones,
            showDetections: showDetections,
            beforeDate: beforeDate,
            afterDate: afterDate
        )
        let data = try await data(request: route.urlRequest)
        let reviews = try JSONDecoder().decode([ReviewResponse].self, from: data)
        return reviews
    }

    func checkConnection() async -> NVRConnectionState {
        do {
            let _ = try await data(request: Routes.connectionStatus.urlRequest)
            return .connected
        } catch {
            return .disconnected
        }
    }
}

private extension FrigateService {
    enum Routes: Service.Routable {
        case config
        case reviews(
            cameras: [String],
            objects: [String],
            zones: [String],
            showDetections: Bool,
            beforeDate: Date,
            afterDate: Date
        )
        case connectionStatus

        var path: String {
            switch self {
            case .config: return "api/config"
            case .reviews: return "api/review"
            case .connectionStatus: return "api/version"
            }
        }

        var method: Service.HTTPMethod {
            switch self {
            case .config, .reviews, .connectionStatus:
                return .GET
            }
        }

        var url: URL? {
            // TODO: Get base URL from user defaults
            URL(string: "http://10.0.0.196:5000/\(path)")
        }

        var urlRequest: URLRequest? {
            guard let url else { return nil }
            var request = URLRequest(url: url, method: method)

            switch self {
            case let .reviews(cameras, objects, zones, showDetections, beforeDate, afterDate):
                request.url?.append(queryItems: [
                    URLQueryItem(name: "before", value: String(beforeDate.timeIntervalSince1970)),
                    URLQueryItem(name: "after", value: String(afterDate.timeIntervalSince1970))
                ])
                if !cameras.isEmpty {
                    request.url?.append(
                        queryItems: [URLQueryItem(name: "cameras", value: cameras.joined(separator: ","))]
                    )
                }
                if !objects.isEmpty {
                    request.url?.append(
                        queryItems: [URLQueryItem(name: "labels", value: objects.joined(separator: ","))]
                    )
                }
                if !zones.isEmpty {
                    request.url?.append(
                        queryItems: [URLQueryItem(name: "zones", value: zones.joined(separator: ","))]
                    )
                }
                if !showDetections {
                    request.url?.append(
                        queryItems: [URLQueryItem(name: "severity", value: "alert")]
                    )
                }
            default: break
            }

            return request
        }
    }
}
