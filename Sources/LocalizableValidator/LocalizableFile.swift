//
//  LocalizableFile.swift
//  LocalizableValidator
//
//  Created by Łukasz Kasperek on 23/07/2019.
//

import Foundation

public struct LocalizableFile: Equatable {
    public typealias Lines = [String: String]
    
    public init(path: String, lines: Lines) {
        self.path = path
        self.lines = lines
    }
    
    public let path: String
    public let lines: Lines
}
