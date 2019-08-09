//
//  Warnings.swift
//  Basic
//
//  Created by Łukasz Kasperek on 09/08/2019.
//

import Foundation

enum ValidationWarning {
    case missingTranslation(key: String)
    case redundantTranslation(key: String, translation: String)
}
