//
//  CardBackground.swift
//  NVR Viewer
//
//  Created by Jacob Banks on 12/4/25.
//

import SwiftUI

enum CardRadius: CGFloat {
    case small = 5
    case medium = 15
    case large = 25
}

private struct CardBackground: ViewModifier {
    let radius: CardRadius

    func body(content: Content) -> some View {
        content
            .cornerRadius(radius.rawValue)
            .shadow(color: Color.black.opacity(0.2), radius: 4)
    }
}
  
extension View {
    func cardBackground(radius: CardRadius) -> some View {
        modifier(CardBackground(radius: radius))
    }
}
