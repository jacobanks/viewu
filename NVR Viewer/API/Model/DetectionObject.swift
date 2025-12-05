//
//  DetectionObject.swift
//  NVR Viewer
//
//  Created by Jacob Banks on 12/4/25.
//

import Foundation

enum DetectionObject: String, Decodable {
    case person
    case bicycle
    case car
    case motorcycle
    case airplane
    case bus
    case train
    case boat
    case trafficLight = "traffic light"
    case fireHydrant = "fire hydrant"
    case streetSign = "street sign"
    case stopSign = "stop sign"
    case parkingMeter = "parking meter"
    case bench
    case bird
    case cat
    case dog
    case horse
    case sheep
    case cow
    case elephant
    case bear
    case zebra
    case giraffe
    case hat
    case backpack
    case umbrella
    case shoe
    case eyeGlasses = "eye glasses"
    case handbag
    case tie
    case suitcase
    case frisbee
    case skis
    case snowboard
    case sportsBall = "sports ball"
    case kite
    case baseballBat = "baseball bat"
    case baseballGlove = "baseball glove"
    case skateboard
    case surfboard
    case tennisRacket = "tennis racket"
    case bottle
    case plate
    case wineGlass = "wine glass"
    case cup
    case fork
    case knife
    case spoon
    case bowl
    case banana
    case apple
    case sandwich
    case orange
    case broccoli
    case carrot
    case hotDog = "hot dog"
    case pizza
    case donut
    case cake
    case chair
    case couch
    case pottedPlant = "potted plant"
    case bed
    case mirror
    case diningTable = "dining table"
    case window
    case desk
    case toilet
    case door
    case tv
    case laptop
    case mouse
    case remote
    case keyboard
    case cellPhone = "cell phone"
    case microwave
    case oven
    case toaster
    case sink
    case refrigerator
    case blender
    case book
    case clock
    case vase
    case scissors
    case teddyBear = "teddy bear"
    case hairDrier = "hair drier"
    case toothbrush
    case hairBrush = "hair brush"

    var icon: String {
        switch self {
        case .person: "figure.walk"
        case .boat: "sailboat"
        case .trafficLight: "light.strip.2"
        case .fireHydrant: "fire.extinguisher"
        case .streetSign: "parkingsign.circle"
        case .stopSign: "exclamationmark.octagon"
        case .parkingMeter: "parkingsign.circle"
        default: self.rawValue
        }
    }
}
