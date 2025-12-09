//
//  MetroData.swift
//  Wasalt
//
//  Created by Rana Alqubaly on 12/06/1447 AH.
//


import CoreLocation

struct MetroData {
    static let yellowLineStations: [Station] = [
        Station(name: "station.kafd".localized,        order: 8, coordinate: .init(latitude: 24.7671553, longitude: 46.6432711), minutesToNext: 5),
        Station(name: "station.ar_rabi".localized,     order: 7, coordinate: .init(latitude: 24.7862360, longitude: 46.6601248), minutesToNext: 5),
        Station(name: "station.uthman_bin_affan".localized, order: 6, coordinate: .init(latitude: 24.8013955, longitude: 46.6961421), minutesToNext: 4),
        Station(name: "station.sabic".localized,       order: 5, coordinate: .init(latitude: 24.8070691, longitude: 46.7095294), minutesToNext: 3),
        Station(name: "station.pnu1".localized,        order: 4, coordinate: .init(latitude: 24.8414744, longitude: 46.7174164), minutesToNext: 6),
        Station(name: "station.pnu2".localized,        order: 3, coordinate: .init(latitude: 24.8596218, longitude: 46.7045103), minutesToNext: 3),
        Station(name: "station.airport_t5".localized,  order: 2, coordinate: .init(latitude: 24.9407856, longitude: 46.7102385), minutesToNext: 11),
        Station(name: "station.airport_t3_4".localized, order: 1, coordinate: .init(latitude: 24.9560402, longitude: 46.7021429), minutesToNext: 3),
        Station(name: "station.airport_t1_2".localized, order: 0, coordinate: .init(latitude: 24.9609970, longitude: 46.6989819), minutesToNext: 3)
    ]
}
