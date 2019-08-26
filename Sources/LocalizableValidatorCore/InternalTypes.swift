//
//  InternalTypes.swift
//  Basic
//
//  Created by Łukasz Kasperek on 09/08/2019.
//

import Foundation

typealias Key = String
typealias Translation = String
typealias CountedInterpolations = [String: Int]

struct LocalizableStrings: Equatable {    
    let path: String
    let lines: [Key: Translation]
}

struct ValidationOutput {
    struct Issues {
        var errors: [ValidationError] = []
        var warnings: [ValidationWarning] = []
    }
    
    let validatedFilePath: String
    let issues: Issues
    
    var isValid: Bool {
        return issues.errors.isEmpty
    }
}

enum ValidationWarning: Equatable {
    case missingTranslation(key: String)
    case redundantTranslation(key: String, translation: String)
}

enum ValidationError: Error, Equatable {
    struct MismatchedInterpolationsDescription: Equatable {
        let key: String
        let value: String
        let valueCountedInterpolations: CountedInterpolations
        let referenceValue: String
        let referenceCountedInterpolations: CountedInterpolations
    }
    
    case invalidLineFormat(contents: String)
    case mismatchedInterpolations(description: MismatchedInterpolationsDescription)
}

struct FileParsingError: Error, Equatable {
    let corruptedLines: [String]
    
    init(line: String) {
        corruptedLines = [line]
    }
    
    init(combining errors: [FileParsingError]) {
        corruptedLines = errors.reduce(into: [String]()) {
            $0.append(contentsOf: $1.corruptedLines)
        }
    }
}
