//
//  Station.swift
//  Wasalt
//

import Foundation
import CoreLocation

// MARK: - Station Model
struct Station: Identifiable {

    let id = UUID()
    let name: String
    let order: Int
    let coordinate: CLLocationCoordinate2D
    let minutesToNext: Int?
    let minutesToPrevious: Int?
}
