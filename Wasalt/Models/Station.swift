//
//  Station 2.swift
//  Wasalt
//
//  Created by Rana Alqubaly on 12/06/1447 AH.
//

// MARK: - Station Model
import Foundation
import CoreLocation

struct Station: Identifiable {

    let id = UUID()
    let name: String
    let order: Int
    let coordinate: CLLocationCoordinate2D
    let minutesToNext: Int?
    let minutesToPrevious: Int?
    let isTransferStation: Bool
    let transferLines: [MetroLine]?
}
