//
//  LocalizableStringsValidator.swift
//  Basic
//
//  Created by Łukasz Kasperek on 25/07/2019.
//

import Foundation

protocol Validator {
    func validate(translations: LocalizableStrings, reference: LocalizableStrings) -> ValidationOutput
}

struct ValidatorImp: Validator {
    func validate(translations: LocalizableStrings, reference: LocalizableStrings) -> ValidationOutput {
        var issues = ValidationOutput.Issues()
        var linesToValidate = translations.lines
        for (key, referenceValue) in reference.lines {
            validate(
                value: linesToValidate.removeValue(forKey: key),
                referenceValue: referenceValue,
                key: key,
                issues: &issues
            )
        }
        appendWarnings(leftLines: linesToValidate, to: &issues)
        return ValidationOutput(validatedFilePath: translations.path, issues: issues)
    }
    
    private func validate(value: String?, referenceValue: String, key: String, issues: inout ValidationOutput.Issues) {
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
    
    private func appendWarnings(leftLines: [Key: Translation], to issues: inout ValidationOutput.Issues) {
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
