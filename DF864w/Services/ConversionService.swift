//
//  ConversionService.swift
//  DF864w
//

import Foundation

enum ConversionService {
    /// Converts using Foundation Measurement when possible; otherwise factor formula.
    static func convert(value: Double, from: Unit, to: Unit, dimension: UnitDimension) -> Double {
        guard from.factor != 0, to.factor != 0 else { return 0 }
        if let fromDim = foundationUnit(dimension: dimension, symbol: from.symbol),
           let toDim = foundationUnit(dimension: dimension, symbol: to.symbol) {
            let m = Measurement(value: value, unit: fromDim)
            return m.converted(to: toDim).value
        }
        if from.offset == 0, to.offset == 0 {
            return value * to.factor / from.factor
        }
        let base = (value - from.offset) / from.factor
        return base * to.factor + to.offset
    }

    private static func foundationUnit(dimension: UnitDimension, symbol: String) -> Dimension? {
        switch dimension {
        case .length:
            switch symbol {
            case "m": return UnitLength.meters
            case "km": return UnitLength.kilometers
            case "cm": return UnitLength.centimeters
            case "mm": return UnitLength.millimeters
            case "mi": return UnitLength.miles
            case "yd": return UnitLength.yards
            case "ft": return UnitLength.feet
            case "in": return UnitLength.inches
            default: return nil
            }
        case .mass:
            switch symbol {
            case "kg": return UnitMass.kilograms
            case "g": return UnitMass.grams
            case "mg": return UnitMass.milligrams
            case "t": return UnitMass.metricTons
            case "lb": return UnitMass.pounds
            case "oz": return UnitMass.ounces
            default: return nil
            }
        case .temperature:
            switch symbol {
            case "°C": return UnitTemperature.celsius
            case "°F": return UnitTemperature.fahrenheit
            case "K": return UnitTemperature.kelvin
            default: return nil
            }
        case .area, .volume, .time, .speed:
            return nil
        }
    }
}
