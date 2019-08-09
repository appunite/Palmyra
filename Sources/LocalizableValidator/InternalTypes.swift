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
