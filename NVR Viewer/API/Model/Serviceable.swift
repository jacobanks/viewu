//
//  Serviceable.swift
//  NVR Viewer
//
//  Created by Jacob Banks on 12/4/25.
//

import Foundation

protocol Serviceable {}

extension Serviceable {
    func data(request: URLRequest?, file: String = #file, function: String = #function) async throws -> Data {
        guard let request else {
            throw URLError(.badServerResponse)
        }
        print("REQUEST: \(request.url?.absoluteString ?? "ERR")")
        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            // Build a more informative error including status code and a short body preview
            let preview = String(data: data, encoding: .utf8)?.prefix(256) ?? "<non-utf8 body>"
            let userInfo: [String: Any] = [
                "statusCode": httpResponse.statusCode,
                "bodyPreview": String(preview)
            ]
            throw NSError(domain: "FrigateService.HTTPError", code: httpResponse.statusCode, userInfo: userInfo)
        }
        logResponse(data: data, file: file, function: function)
        return data
    }

    private func logResponse(data: Data, file: String, function: String) {
        if let obj = try? JSONSerialization.jsonObject(with: data, options: []),
           let prettyData = try? JSONSerialization.data(withJSONObject: obj, options: [.prettyPrinted, .sortedKeys]),
           let prettyString = String(data: prettyData, encoding: .utf8) {
//                                    print("Pretty JSON response data:\n\(prettyString)")
            Log.shared().print(page: file, fn: function, type: "Result", text: "\n\(prettyString)")
        }
    }
}

enum Service {
    protocol Routable {
        var method: HTTPMethod { get }
        var path: String { get }
        var urlRequest: URLRequest? { get }
        var url: URL? { get }
    }

    enum HTTPMethod: String {
        case GET, POST, PUT, PATCH, DELETE
    }
}

extension URLRequest {
    init(url: URL, method: Service.HTTPMethod) {
        self.init(url: url)
        httpMethod = method.rawValue
    }
}
