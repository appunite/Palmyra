//
//  Errors.swift
//  Basic
//
//  Created by Łukasz Kasperek on 24/07/2019.
//

import Foundation

public struct FileFormatValidationError: LocalizedError {
    public let invalidLineContents: String
    
    public var localizedDescription: String {
        return invalidLineContents
    }
}

public struct CompoundValidationError: LocalizedError {
    let errors: [FileFormatValidationError]
    
    public var localizedDescription: String {
        return errors.map({ $0.localizedDescription }).joined(separator: "\n")
    }
}
