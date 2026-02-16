//
//  ConverterViewModel.swift
//  DF864w
//

import Foundation
import Combine

final class ConverterViewModel: ObservableObject {
    @Published var dimension: UnitDimension
    @Published var sourceUnitSymbol: String
    @Published var targetUnitSymbol: String
    @Published var inputText: String = ""
    @Published var resultText: String = ""

    private var cancellables = Set<AnyCancellable>()

    init(dimension: UnitDimension = .length) {
        self.dimension = dimension
        let units = dimension.units
        self.sourceUnitSymbol = units[0].symbol
        self.targetUnitSymbol = units.count > 1 ? units[1].symbol : units[0].symbol
        setupBinding()
    }

    var sourceUnit: Unit? { dimension.units.first { $0.symbol == sourceUnitSymbol } }
    var targetUnit: Unit? { dimension.units.first { $0.symbol == targetUnitSymbol } }

    private func setupBinding() {
        $dimension
            .combineLatest($sourceUnitSymbol)
            .combineLatest($targetUnitSymbol)
            .combineLatest($inputText)
            .debounce(for: .milliseconds(150), scheduler: RunLoop.main)
            .sink { [weak self] payload in
                let (((dim, fromSym), toSym), text) = payload
                self?.updateResult(dimension: dim, fromSymbol: fromSym, toSymbol: toSym, inputText: text)
            }
            .store(in: &cancellables)
    }

    private func updateResult(dimension: UnitDimension, fromSymbol: String, toSymbol: String, inputText: String) {
        let trimmed = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, let value = Double(trimmed.replacingOccurrences(of: ",", with: ".")) else {
            resultText = ""
            return
        }
        let units = dimension.units
        guard let from = units.first(where: { $0.symbol == fromSymbol }),
              let to = units.first(where: { $0.symbol == toSymbol }) else {
            resultText = ""
            return
        }
        let result = ConversionService.convert(value: value, from: from, to: to, dimension: dimension)
        resultText = formatNumber(result)
    }

    private func formatNumber(_ n: Double) -> String {
        if n == 0 { return "0" }
        let absN = abs(n)
        if absN >= 1_000_000 || (absN < 0.0001 && absN > 0) {
            return String(format: "%.6g", n)
        }
        if absN >= 1 || absN < 0.01 {
            return String(format: "%.4f", n)
        }
        var s = String(format: "%.6f", n)
        while s.hasSuffix("0") { s.removeLast() }
        if s.hasSuffix(".") { s.removeLast() }
        return s
    }

    func swapUnits() {
        swap(&sourceUnitSymbol, &targetUnitSymbol)
    }

    func setDimension(_ dim: UnitDimension) {
        dimension = dim
        let units = dim.units
        sourceUnitSymbol = units[0].symbol
        targetUnitSymbol = units.count > 1 ? units[1].symbol : units[0].symbol
    }
}
