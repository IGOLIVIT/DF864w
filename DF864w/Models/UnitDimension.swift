//
//  UnitDimension.swift
//  DF864w
//
//  Physical units converter — categories and units.
//

import Foundation

enum UnitDimension: String, CaseIterable, Identifiable {
    case length = "Length"
    case mass = "Mass"
    case temperature = "Temperature"
    case area = "Area"
    case volume = "Volume"
    case time = "Time"
    case speed = "Speed"

    var id: String { rawValue }

    var units: [Unit] {
        switch self {
        case .length:
            return [
                Unit(symbol: "m", name: "Meter", factor: 1),
                Unit(symbol: "km", name: "Kilometer", factor: 0.001),
                Unit(symbol: "cm", name: "Centimeter", factor: 100),
                Unit(symbol: "mm", name: "Millimeter", factor: 1000),
                Unit(symbol: "mi", name: "Mile", factor: 1/1609.344),
                Unit(symbol: "yd", name: "Yard", factor: 1/0.9144),
                Unit(symbol: "ft", name: "Foot", factor: 1/0.3048),
                Unit(symbol: "in", name: "Inch", factor: 1/0.0254)
            ]
        case .mass:
            return [
                Unit(symbol: "kg", name: "Kilogram", factor: 1),
                Unit(symbol: "g", name: "Gram", factor: 1000),
                Unit(symbol: "mg", name: "Milligram", factor: 1_000_000),
                Unit(symbol: "t", name: "Tonne", factor: 0.001),
                Unit(symbol: "lb", name: "Pound", factor: 1/0.453592),
                Unit(symbol: "oz", name: "Ounce", factor: 1/0.0283495)
            ]
        case .temperature:
            return [
                Unit(symbol: "°C", name: "Celsius", factor: 1, offset: 0),
                Unit(symbol: "°F", name: "Fahrenheit", factor: 9.0/5.0, offset: 32),
                Unit(symbol: "K", name: "Kelvin", factor: 1, offset: 273.15)
            ]
        case .area:
            return [
                Unit(symbol: "m²", name: "Square meter", factor: 1),
                Unit(symbol: "km²", name: "Square km", factor: 1.0/1_000_000),
                Unit(symbol: "cm²", name: "Square cm", factor: 10_000),
                Unit(symbol: "ha", name: "Hectare", factor: 1.0/10_000),
                Unit(symbol: "acre", name: "Acre", factor: 1/4046.86),
                Unit(symbol: "ft²", name: "Square foot", factor: 1/0.092903),
                Unit(symbol: "in²", name: "Square inch", factor: 1/0.00064516)
            ]
        case .volume:
            return [
                Unit(symbol: "L", name: "Liter", factor: 1),
                Unit(symbol: "mL", name: "Milliliter", factor: 1000),
                Unit(symbol: "m³", name: "Cubic meter", factor: 0.001),
                Unit(symbol: "gal", name: "Gallon (US)", factor: 1/3.78541),
                Unit(symbol: "qt", name: "Quart", factor: 1/0.946353),
                Unit(symbol: "fl oz", name: "Fluid ounce", factor: 1/0.0295735),
                Unit(symbol: "cup", name: "Cup", factor: 1/0.236588)
            ]
        case .time:
            return [
                Unit(symbol: "s", name: "Second", factor: 1),
                Unit(symbol: "min", name: "Minute", factor: 1.0/60),
                Unit(symbol: "h", name: "Hour", factor: 1.0/3600),
                Unit(symbol: "d", name: "Day", factor: 1.0/86400),
                Unit(symbol: "wk", name: "Week", factor: 1.0/604800)
            ]
        case .speed:
            return [
                Unit(symbol: "m/s", name: "m/s", factor: 1),
                Unit(symbol: "km/h", name: "km/h", factor: 3.6),
                Unit(symbol: "mph", name: "mph", factor: 1/0.44704),
                Unit(symbol: "kn", name: "Knot", factor: 1/0.514444),
                Unit(symbol: "ft/s", name: "ft/s", factor: 1/0.3048)
            ]
        }
    }
}

struct Unit: Identifiable, Hashable {
    let symbol: String
    let name: String
    let factor: Double
    var offset: Double = 0

    var id: String { symbol }
}
