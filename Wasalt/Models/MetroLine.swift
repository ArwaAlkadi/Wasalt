//
//  MetroLine.swift
//  Wasalt
//

import Foundation
import SwiftUI
internal import _LocationEssentials

enum MetroLine: String, CaseIterable, Identifiable {

    case line1 = "Line 1"   // Blue
    case line2 = "Line 2"   // Red
    case line3 = "Line 3"   // Orange
    case line4 = "Line 4"   // Yellow
    case line5 = "Line 5"   // Green
    case line6 = "Line 6"   // Purple

    var id: String { rawValue }

    // MARK: - Line Color
    var color: Color {
        switch self {
        case .line1: return .blue
        case .line2: return .red
        case .line3: return .orange
        case .line4: return .yellow
        case .line5: return .green
        case .line6: return .purple
        }
    }

    // MARK: - Stations per Line
    var stations: [Station] {
        switch self {
        case .line1:
            return MetroData.blueLineStations

        case .line2:
            return MetroData.redLineStations

        case .line3:
            return MetroData.orangeLineStations

        case .line4:
            return MetroData.yellowLineStations

        case .line5:
            return MetroData.greenLineStations

        case .line6:
            return MetroData.purpleLineStations
        }
    }

    // MARK: - Display Name (optional)
    var displayName: String {
        switch self {
        case .line1: return "Blue Line"
        case .line2: return "Red Line"
        case .line3: return "Orange Line"
        case .line4: return "Yellow Line"
        case .line5: return "Green Line"
        case .line6: return "Purple Line"
        }
    }
}

extension Array where Element == Station {
    func uniqueByCoordinate() -> [Station] {
        var seen = Set<String>()
        return filter {
            let key = "\($0.coordinate.latitude),\($0.coordinate.longitude)"
            return seen.insert(key).inserted
        }
    }
}

extension MetroLine {

    init?(geoJSONName: String) {
        switch geoJSONName.lowercased() {
        case "blue line": self = .line1
        case "red line": self = .line2
        case "orange line": self = .line3
        case "yellow line": self = .line4
        case "green line": self = .line5
        case "purple line": self = .line6
        default: return nil
        }
    }
}
