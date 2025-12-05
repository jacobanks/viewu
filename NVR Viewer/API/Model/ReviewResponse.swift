//
//  ReviewResponse.swift
//  NVR Viewer
//
//  Created by Jacob Banks on 12/4/25.
//

import Foundation

struct ReviewResponse: Decodable, Identifiable {
    enum CodingKeys: String, CodingKey {
        case id, camera, severity, data
        case startTime = "start_time"
        case endTime = "end_time"
        case thumbnailPath = "thumb_path"
    }

    let id: String
    let camera: String
    let startTime: TimeInterval
    let endTime: TimeInterval?
    let severity: Severity
    private let thumbnailPath: String
    let data: ReviewData

    struct ReviewData: Decodable {
        enum CodingKeys: String, CodingKey {
            case detections, objects, zones
            case subLabels = "sub_labels"
        }

        let detections: [String]
        let objects: [DetectionObject]
        let subLabels: [String]
        let zones: [String]
    }

    enum Severity: String, Decodable {
        case alert, detection
    }
}

extension ReviewResponse {
    var streamURL: URL? {
        guard let endTime else { return nil }
        return URL(string: "http://10.0.0.196:5000/vod/\(camera)/start/\(startTime)/end/\(endTime)/master.m3u8")
    }

    var thumbnailURL: URL? {
        let parsedPath = thumbnailPath.replacingOccurrences(of: "/media/frigate", with: "")
        return URL(string: "http://10.0.0.196:5000\(parsedPath)")
    }
}
