//
//  MetroLine.swift
//  Wasalt
//
//  Created by Rana Alqubaly on 11/06/1447 AH.
//



import Foundation
import SwiftUI

enum MetroLine: String, CaseIterable, Identifiable {
    case line1 = "Line 1"
    case line2 = "Line 2"
    case line3 = "Line 3"
    case line4 = "Line 4"
    case line5 = "Line 5"
    case line6 = "Line 6"

    var id: String { rawValue }

    var color: Color {
        switch self {
        case .line1: return .blue
        case .line2: return .red
        case .line3: return .green
        case .line4: return .yellow
        case .line5: return .purple
        case .line6: return .orange
        }
    }
}
