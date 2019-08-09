//
//  LocalizableStringsValidator.swift
//  Basic
//
//  Created by Łukasz Kasperek on 25/07/2019.
//

import Foundation

struct ValidationIssues {
    var errors: [ValidationError] = []
    var warnings: [ValidationWarning] = []
}

protocol LocalizableStringsValidator {
    
}

struct LocalizableStringsValidatorImp: LocalizableStringsValidator {
    func validate(translations: [Key: Translation], reference: [Key: Translation]) -> ValidationIssues {
        var issues = ValidationIssues()
        var linesToValidate = translations
        for (key, referenceValue) in reference {
            validate(
                value: linesToValidate.removeValue(forKey: key),
                referenceValue: referenceValue,
                key: key,
                issues: &issues
            )
        }
        appendWarnings(leftLines: linesToValidate, to: &issues)
        return issues
    }
    
    private func validate(value: String?, referenceValue: String, key: String, issues: inout ValidationIssues) {
        guard let value = value else {
            issues.warnings.append(.missingTranslation(key: key))
            return
        }
        let referenceCountedInterpolations = countedInterpolations(in: referenceValue)
        let valueCountedInterpolations = countedInterpolations(in: value)
        if referenceCountedInterpolations != valueCountedInterpolations {
            let description = ValidationError.MismatchedInterpolationsDescription(
                key: key,
                value: value,
                valueCountedInterpolations: valueCountedInterpolations,
                referenceValue: referenceValue,
                referenceCountedInterpolations: referenceCountedInterpolations
            )
            let error = ValidationError.mismatchedInterpolations(description: description)
            issues.errors.append(error)
        }
    }
    
    private func countedInterpolations(in string: String) -> CountedInterpolations {
        let matches = interpolationsRegex.matches(
            in: string,
            options: [], range:
            string.startToEndNSRange
        )
        return matches
            .map({ string[$0.range] })
            .map(String.init)
            .elementCounts()
    }
    
    private let interpolationsRegex = try! NSRegularExpression(
        pattern: #"%(?:([1-9]\d*)\$|\(([^\)]+)\))?(\+)?(0|'[^$])?(-)?(\d+)?(?:\.(\d+))?(hh|ll|[hlLzjt])?([b-fiosuxX@])"#
    )
    
    private func appendWarnings(leftLines: [Key: Translation], to issues: inout ValidationIssues) {
        for (key, value) in leftLines {
            issues.warnings.append(
                .redundantTranslation(key: key, translation: value)
            )
        }
    }
}

private extension Array where Element == String {
    func elementCounts() -> CountedInterpolations {
        return reduce(into: [String: Int]()) { result, element in
            result[element] = (result[element] ?? 0) + 1
        }
    }
}
