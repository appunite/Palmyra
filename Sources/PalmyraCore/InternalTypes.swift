//
//  InternalTypes.swift
//  Basic
//
//  Created by Łukasz Kasperek on 09/08/2019.
//

import Foundation

typealias Key = String
typealias Translation = String

struct LocalizableStrings: Equatable {    
    let path: String
    let lines: [Key: Translation]
}

struct ValidationOutput {
    let validatedFilePath: String
    let issues: [ValidationIssue]
}

enum ValidationIssue: LocalizedError, Equatable {
    struct MismatchedInterpolationsDescription: Equatable {
        let key: String
        let value: String
        let referenceValue: String
    }
    
    case invalidLineFormat(contents: String)
    case mismatchedInterpolations(description: MismatchedInterpolationsDescription)
    case missingTranslation(key: String)
    case redundantTranslation(key: String, translation: String)
    
    var isFatal: Bool {
        switch self {
        case .invalidLineFormat, .mismatchedInterpolations: return true
        case .missingTranslation, .redundantTranslation: return false
        }
    }
    
    var errorDescription: String? {
        switch self {
        case let .invalidLineFormat(contents):
            return #"Invalid line format "\#(contents)""#
        case let .mismatchedInterpolations(description):
            return #"""
            "Interpolations do not match for key "\#(description.key)""
                Reference: "\#(description.referenceValue)"
                Translation: "\#(description.value)"
            """#
        case let .missingTranslation(key):
            return #"Missing translation for key "\#(key)""#
        case let .redundantTranslation(key, translation):
            return #"Redundant translation "\#(translation)" for key "\#(key)""#
        }
    }
}

extension Collection where Element == ValidationIssue {
    var fatalsOccur: Bool {
        return contains(where: { $0.isFatal })
    }
    
    func splitIntoFatalsAndWarnings() -> ([ValidationIssue], [ValidationIssue]) {
        var fatals = [ValidationIssue]()
        var warnings = [ValidationIssue]()
        for issue in self {
            issue.isFatal ? fatals.append(issue) : warnings.append(issue)
        }
        return (fatals, warnings)
    }
}

struct FileURLFormingError: LocalizedError {
    enum StringsFileType {
        case reference, translation
    }
    enum Reason {
        case missingPath, missingFile(String)
    }
    
    let fileType: StringsFileType
    let reason: Reason
    
    var errorDescription: String? {
        switch (fileType, reason) {
        case (.reference, .missingPath):
            return "Missing reference file path"
        case (.reference, let .missingFile(path)):
            return "Reference file at \(path) doesn't exist"
        case (.translation, .missingPath):
            return "Missing translations file paths"
        case (.translation, let .missingFile(path)):
            return "Translation file at \(path) doesn't exist"
        }
    }
}

struct FileParsingError: LocalizedError, Equatable {
    let filePath: String
    let corruptedLines: [String]
    
    init(line: String, filePath: String) {
        corruptedLines = [line]
        self.filePath = filePath
    }
    
    init(combining errors: [FileParsingError]) {
        self.filePath = errors.first!.filePath
        corruptedLines = errors.reduce(into: [String]()) {
            $0.append(contentsOf: $1.corruptedLines)
        }
    }
    
    var errorDescription: String? {
        return "File at \(filePath) parsing failed due to lines:\n" + corruptedLines.joined(separator: "\n")
    }
}
