//
//  MapViewModel.swift
//  Wasalt
//
//  Created by Rana Alqubaly on 12/06/1447 AH.
//


import Foundation
import MapKit
import CoreLocation
import _MapKit_SwiftUI
import Combine


/*
 🔴 File Contents | محتوى الكود
     •    MapViewModel → Manages the map view, metro stations, and route polylines.
     •    LocationManager → continuously tracks the user’s real GPS location.
 */


//MARK: - MapViewModel → Manages the map view, metro stations, and route polylines.
class MapViewModel: ObservableObject {

    @Published var mapCamera = MapCameraPosition.region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 24.774265, longitude: 46.738586),
            span: MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2)
        )
    )

    @Published var stations: [Station] = [
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

    // All lines
    @Published var allRoutePolylines: [(name: String, points: [MKMapPoint])] = []

    // Selected line (Yellow line by default)
    @Published var selectedLineName: String? = "Yellow line"

    init() {
        loadBundledMetroGeoJSON()
    }

    // MARK: Load GeoJSON
    func loadBundledMetroGeoJSON() {
        guard let url = Bundle.main.url(forResource: "metro_lines", withExtension: "geojson"),
              let data = try? Data(contentsOf: url) else { return }

        do {
            let decoder = MKGeoJSONDecoder()
            let objects = try decoder.decode(data)

            for obj in objects {
                if let feature = obj as? MKGeoJSONFeature,
                   let propsData = feature.properties,
                   let props = try? JSONSerialization.jsonObject(with: propsData) as? [String: Any],
                   let lineName = props["metrolinename"] as? String {

                    for geometry in feature.geometry {
                        if let poly = geometry as? MKPolyline {
                            let points = convertPolylineToPoints(poly)
                            allRoutePolylines.append((name: lineName, points: points))
                        } else if let multi = geometry as? MKMultiPolyline {
                            for poly in multi.polylines {
                                let points = convertPolylineToPoints(poly)
                                allRoutePolylines.append((name: lineName, points: points))
                            }
                        }
                    }
                }
            }

        } catch {
            print("GeoJSON decode error: \(error)")
        }
    }

    // MARK: Convert MKPolyline to smooth points
    private func convertPolylineToPoints(_ polyline: MKPolyline) -> [MKMapPoint] {
        var pts: [MKMapPoint] = []
        let p = polyline.points()
        for i in 0..<polyline.pointCount {
            pts.append(p[i])
        }

        // Insert PNU, KAFD in the correct place
        pts = insertStationsIntoPolyline(pts)

        return pts
    }
    
    
    
    func insertStationsIntoPolyline(_ pts: [MKMapPoint]) -> [MKMapPoint] {
        var result = pts

        for station in stations {
            let stationPoint = MKMapPoint(station.coordinate)

            // Find nearest segment
            var bestIndex = 0
            var bestDistance = Double.greatestFiniteMagnitude

            for i in 0..<result.count - 1 {
                let a = result[i]
                let b = result[i+1]

                // midpoint of segment
                let mid = MKMapPoint(x: (a.x + b.x) / 2, y: (a.y + b.y) / 2)
                let d = hypot(mid.x - stationPoint.x, mid.y - stationPoint.y)

                if d < bestDistance {
                    bestDistance = d
                    bestIndex = i + 1
                }
            }

            // Only insert if station is close enough (200m)
            if bestDistance < 200 {
                result.insert(stationPoint, at: bestIndex)
            }
        }

        return result
    }



    // MARK: Linear interpolation
    func interpolatePolyline(_ points: [MKMapPoint], step: Double = 100) -> [MKMapPoint] {
        var smoothPoints: [MKMapPoint] = []
        for i in 0..<points.count-1 {
            let p0 = points[i]
            let p1 = points[i+1]
            smoothPoints.append(p0)

            let distance = hypot(p1.x - p0.x, p1.y - p0.y)
            let steps = max(1, Int(distance / step))
            for j in 1..<steps {
                let t = Double(j) / Double(steps)
                let x = p0.x + (p1.x - p0.x) * t
                let y = p0.y + (p1.y - p0.y) * t
                smoothPoints.append(MKMapPoint(x: x, y: y))
            }
        }
        smoothPoints.append(points.last!)
        return smoothPoints
    }

    // MARK: Catmull-Rom spline for smooth curves
    func catmullRomSpline(points: [MKMapPoint], samples: Int = 10) -> [MKMapPoint] {
        guard points.count > 3 else { return points }
        var result: [MKMapPoint] = []

        for i in 0..<(points.count - 3) {
            let p0 = points[i]
            let p1 = points[i+1]
            let p2 = points[i+2]
            let p3 = points[i+3]

            for j in 0..<samples {
                let t = Double(j) / Double(samples)
                let tt = t * t
                let ttt = tt * t

                let x = 0.5 * ((2*p1.x) +
                               (-p0.x + p2.x) * t +
                               (2*p0.x - 5*p1.x + 4*p2.x - p3.x) * tt +
                               (-p0.x + 3*p1.x - 3*p2.x + p3.x) * ttt)

                let y = 0.5 * ((2*p1.y) +
                               (-p0.y + p2.y) * t +
                               (2*p0.y - 5*p1.y + 4*p2.y - p3.y) * tt +
                               (-p0.y + 3*p1.y - 3*p2.y + p3.y) * ttt)

                result.append(MKMapPoint(x: x, y: y))
            }
        }

        // append last points to finish the line
        result.append(contentsOf: points.suffix(2))
        return result
    }
    
    
    func distanceBetweenStations(_ from: Station, _ to: Station) -> Double {
          let loc1 = CLLocation(latitude: from.coordinate.latitude, longitude: from.coordinate.longitude)
          let loc2 = CLLocation(latitude: to.coordinate.latitude, longitude: to.coordinate.longitude)
          return loc1.distance(from: loc2)
      }
      
      // Travel time in minutes given speed in km/h
      func minutesBetweenStations(_ from: Station, _ to: Station, speedKmh: Double = 30) -> Int {
          let distanceMeters = distanceBetweenStations(from, to)
          let distanceKm = distanceMeters / 1000
          let timeHours = distanceKm / speedKmh
          return Int(timeHours * 60)
      }

      // Optional: cumulative travel times along a line
      func cumulativeTravelTimes(for lineStations: [Station], speedKmh: Double = 30) -> [String: Int] {
          var times: [String: Int] = [:]
          var cumulative = 0

          for i in 0..<lineStations.count-1 {
              let from = lineStations[i]
              let to = lineStations[i+1]
              cumulative += minutesBetweenStations(from, to, speedKmh: speedKmh)
              times[to.name] = cumulative
          }
          return times
      }
  }












//MARK: - LocationManager → continuously tracks the user’s real GPS location.
final class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    
    @Published var userLocation: CLLocation?
    
    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        
        if let modes = Bundle.main.object(forInfoDictionaryKey: "UIBackgroundModes") as? [String],
           modes.contains("location") {
            manager.allowsBackgroundLocationUpdates = true
            manager.pausesLocationUpdatesAutomatically = false
        }
    }
    
    func requestPermission() {
        manager.requestWhenInUseAuthorization()
    }
    
    func start() {
        manager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            manager.startUpdatingLocation()
        default:
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        userLocation = locations.last
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location error:", error.localizedDescription)
    }
}
