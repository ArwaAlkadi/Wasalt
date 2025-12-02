//
//  Station.swift
//  Wasalt
//
//  Created by Arwa Alkadi on 19/11/2025.
//

//بيانات واحداثيات مواقع محطات المترو
// Models/Place.swift
import Foundation
import CoreLocation

struct Station: Identifiable {
    let id = UUID()
    let name: String
    let order: Int              // position along the line
    let coordinate: CLLocationCoordinate2D
    let minutesToNext: Int?     // travel time to the next station
}
