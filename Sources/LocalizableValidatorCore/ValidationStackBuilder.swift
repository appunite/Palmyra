//
//  ValidationStackBuilder.swift
//
//  Created by Łukasz Kasperek on 26/08/2019.
//

import Foundation

public struct ValidationStackBuilder {
    public static func build() -> LocalizableValidator {
        return LocalizableValidatorImp()
    }
}
