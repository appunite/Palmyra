//
//  Errors.swift
//  Basic
//
//  Created by Łukasz Kasperek on 24/07/2019.
//

import Foundation

public enum ValidationError: LocalizedError {
    public struct MismatchedInterpolationsDescription {
        let key: String
        let value: String
        let valueCountedInterpolations: CountedInterpolations
        let referenceValue: String
        let referenceCountedInterpolations: CountedInterpolations
    }
    
    case invalidLineFormat(contents: String)
    case mismatchedInterpolations(description: MismatchedInterpolationsDescription)
    
    public var errorDescription: String? {
        switch self {
        case let .invalidLineFormat(contents):
            return "Line has invalid format: \(contents)"
        case let .mismatchedInterpolations(description):
            return ""
        }
    }
}

public struct FileFormatValidationError: LocalizedError {
    public let invalidLineContents: String
    
    public var errorDescription: String? {
        return invalidLineContents
    }
}

public struct CompoundValidationError: LocalizedError {
    let errors: [FileFormatValidationError]
    
    public var localizedDescription: String {
        return errors.map({ $0.localizedDescription }).joined(separator: "\n")
    }
}
