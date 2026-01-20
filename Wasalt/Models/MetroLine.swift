//
//  MetroLine.swift
//  Wasalt
//

import Foundation
import SwiftUI
internal import _LocationEssentials

// MARK: - Metro lines enum
enum MetroLine: String, CaseIterable, Identifiable {

    // All supported lines
    case blue = "Blue Line"
    case red = "Red Line"
    case orange = "Orange Line"
    case yellow = "Yellow Line"
    case green = "Green Line"
    case purple = "Purple Line"

    // Unique ID for SwiftUI
    var id: String { rawValue }

    // Line main color
    var color: Color {
        switch self {
        case .blue: return .blue
        case .red: return .red
        case .orange: return .orange
        case .yellow: return .yellow
        case .green: return .green
        case .purple: return .purple
        }
    }

    // Stations belonging to each line
    var stations: [Station] {
        switch self {
        case .blue: return MetroData.blueLineStations
        case .red: return MetroData.redLineStations
        case .orange: return MetroData.orangeLineStations
        case .yellow: return MetroData.yellowLineStations
        case .green: return MetroData.greenLineStations
        case .purple: return MetroData.purpleLineStations
        }
    }
}


// MARK: - Remove duplicate stations by coordinate
extension Array where Element == Station {
    func uniqueByCoordinate() -> [Station] {
        var seen = Set<String>()
        return filter {
            let key = "\($0.coordinate.latitude),\($0.coordinate.longitude)"
            return seen.insert(key).inserted
        }
    }
}


// MARK: - Create MetroLine from external string (GeoJSON, etc.)
extension MetroLine {

    init?(geoJSONName: String) {
        switch geoJSONName.lowercased() {
        case "blue line": self = .blue
        case "red line": self = .red
        case "orange line": self = .orange
        case "yellow line": self = .yellow
        case "green line": self = .green
        case "purple line": self = .purple
        default: return nil
        }
    }
}


// MARK: - Localization support
extension MetroLine {

    /// Localization key for the line name
    private var localizationKey: String {
        switch self {
        case .blue: return "metro.line.blue"
        case .red: return "metro.line.red"
        case .orange: return "metro.line.orange"
        case .yellow: return "metro.line.yellow"
        case .green: return "metro.line.green"
        case .purple: return "metro.line.purple"
        }
    }

    /// Localized display name
    var displayName: String {
        NSLocalizedString(localizationKey, comment: "")
    }
}


// MARK: - Clean station name from transfer text
extension Station {
    var cleanName: String {
        name
            .replacingOccurrences(of: " - محطة تحويل", with: "")
            .replacingOccurrences(of: " - Transfer Station", with: "")
            .replacingOccurrences(of: " - تحويل إلى:", with: "")
            .replacingOccurrences(of: " - Transfer to:", with: "")
            .replacingOccurrences(of: " - تحويل إلى", with: "")
            .replacingOccurrences(of: " - Transfer to", with: "")
    }
}
