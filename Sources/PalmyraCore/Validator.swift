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
        var issues = [ValidationIssue]()
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
    
    private func validate(value: String?, referenceValue: String, key: String, issues: inout [ValidationIssue]) {
        guard let value = value else {
            issues.append(.missingTranslation(key: key))
            return
        }
        let referenceCountedInterpolations = countedInterpolations(in: referenceValue)
        let valueCountedInterpolations = countedInterpolations(in: value)
        if referenceCountedInterpolations != valueCountedInterpolations {
            let description = ValidationIssue.MismatchedInterpolationsDescription(
                key: key,
                value: value,
                referenceValue: referenceValue
            )
            let error = ValidationIssue.mismatchedInterpolations(description: description)
            issues.append(error)
        }
    }
    
    private func countedInterpolations(in string: String) -> [String: Int] {
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
    
    private func appendWarnings(leftLines: [Key: Translation], to issues: inout [ValidationIssue]) {
        for (key, value) in leftLines {
            issues.append(.redundantTranslation(key: key, translation: value))
        }
    }
}

private extension Array where Element == String {
    func elementCounts() -> [String: Int] {
        return reduce(into: [String: Int]()) { result, element in
            result[element] = (result[element] ?? 0) + 1
        }
    }
}
