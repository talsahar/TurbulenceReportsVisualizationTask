//
//  H3.swift
//  H3Test
//
//  Created by Alex Kovalov on 20.03.2025.
//

import Foundation
import CoreLocation
import H3Wrapper

public typealias H3Index = UInt64

public class H3 {

    public static let res: Int32 = 5

    public static func hexToCoord(_ hex: String) -> CLLocationCoordinate2D {

        return indexToCoord(hexToIndex(hex))
    }

    public static func indexToCoord(_ h3Index: H3Index) -> CLLocationCoordinate2D {

        var latLng = LatLng()
        let error = cellToLatLng(h3Index, &latLng)
        if error != 0 {
            print("h3HexToCoord cellToLatLng error: \(error)")
        }
        return CLLocationCoordinate2D(latitude: radsToDegs(latLng.lat), longitude: radsToDegs(latLng.lng))
    }

    public static func hexToIndex(_ hex: String) -> H3Index {

        var index = H3Index()
        let error = stringToH3(hex, &index)
        if error != 0 {
            print("h3HexToCoord stringToH3 error: \(error)")
        }
        return index
    }
}
