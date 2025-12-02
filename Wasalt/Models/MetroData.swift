//
//  MetroData.swift
//  Wasalt
//
//  Created by Rana Alqubaly on 11/06/1447 AH.
//




import CoreLocation

struct MetroData {
    static let yellowLineStations: [Station] = [
        Station(name: "KAFD",order:8 , coordinate: .init(latitude: 24.76571265, longitude: 46.63858725), minutesToNext: 5),
        Station(name: "Ar Rabi",order:7 , coordinate: .init(latitude: 24.78634, longitude: 46.66026),minutesToNext: 5),
        Station(name: "Uthman Bin Affan",order:6 , coordinate: .init(latitude: 24.80144, longitude: 46.69604),minutesToNext: 4),
        Station(name: "SABIC",order:5 , coordinate: .init(latitude: 24.80712, longitude: 46.70935),minutesToNext: 3),
        Station(name: "PNU",order:4 , coordinate: .init(latitude: 24.84600, longitude: 46.72000),minutesToNext: 6),
        Station(name: "PNU 2",order:3 , coordinate: .init(latitude: 24.84600, longitude: 46.72000),minutesToNext: 3),
        Station(name: "Airport T5",order:2 , coordinate: .init(latitude: 24.94262, longitude: 46.71212),minutesToNext: 11),
        Station(name: "Airport T3–4",order:1 , coordinate: .init(latitude: 24.95579, longitude: 46.70236),minutesToNext: 3),
        Station(name: "Airport T1–2",order:0 , coordinate: .init(latitude: 24.95820, longitude: 46.70078),minutesToNext: 3)
    ]
}
