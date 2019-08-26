//
//  ValidatorTests.swift
//  LocalizableValidatorTests
//
//  Created by Łukasz Kasperek on 16/08/2019.
//

import XCTest
@testable import LocalizableValidatorCore

class ValidatorTests: XCTestCase {
    var sut: ValidatorImp!

    override func setUp() {
        super.setUp()
        sut = ValidatorImp()
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    func testValidation_whenStringsHaveMatchingInterpolation_shouldOutputBeValidWithNoIssues() {
        // given
        let translations = ["key": "translated %@"].localizableStrings()
        let reference = ["key": "interpolated %@"].localizableStrings()
        
        // when
        let output = sut.validate(translations: translations, reference: reference)
        
        // then
        XCTAssert(output.isValid)
        XCTAssert(output.issues.isEmpty)
    }
    
    func testValidation_whenStringsHaveMultipleMatchingInterpolations_shouldOutputHaveNoIssues() {
        // given
        let translations = ["key": "%1$d. Tranlsation: %2$@"].localizableStrings()
        let reference = ["key": "%1$d. Reference: %2$@"].localizableStrings()
        
        // when
        let issues = sut.validate(translations: translations, reference: reference).issues
        
        // then
        XCTAssert(issues.isEmpty)
    }
    
    func testValidation_whenInterpolationIsMissingInTranslation_shouldReturnMatchingError() {
        // given
        let translations = ["key": "Translation without interpolation"].localizableStrings()
        let reference = ["key": "Reference with %@"].localizableStrings()
        
        // when
        let issues = sut.validate(translations: translations, reference: reference).issues
        
        // then
        let expectedError = ValidationError.mismatchedInterpolations(description: .init(
            key: "key",
            value: "Translation without interpolation",
            valueCountedInterpolations: [:],
            referenceValue: "Reference with %@",
            referenceCountedInterpolations: ["%@": 1]
            ))
        XCTAssertEqual([expectedError], issues.errors)
    }
    
    func testValidation_whenTranslationsHasMoreStrings_shouldWarnAboutRedundantTranslations() {
        // given
        let translations = ["key": "translation", "redundant key": "translation"].localizableStrings()
        let reference = ["key": "reference"].localizableStrings()
        
        // when
        let output = sut.validate(translations: translations, reference: reference)
        
        // then
        XCTAssertEqual(
            output.issues.warnings,
            [.redundantTranslation(key: "redundant key", translation: "translation")]
        )
    }
    
    func testValidation_whenTranslationIsMissing_shouldGenerateWarning() {
        // given
        let translations = ["key": "translation"].localizableStrings()
        let reference = ["key": "reference", "other key": "other translation"].localizableStrings()
        
        // when
        let output = sut.validate(translations: translations, reference: reference)
        
        // then
        XCTAssertEqual(
            output.issues.warnings,
            [.missingTranslation(key: "other key")]
        )
    }
    
    func testValidationOutput_shouldHaveTranslationsFilePath() {
        // given
        let translations = ["key": "translation"].localizableStrings(withPath: "/Translations/Localizable.strings")
        let reference = ["key": "reference"].localizableStrings(withPath: "/Reference/Localizable.strings")
        
        // when
        let output = sut.validate(translations: translations, reference: reference)
        
        // then
        XCTAssertEqual(output.validatedFilePath, translations.path)
    }
}

private extension ValidationOutput.Issues {
    var isEmpty: Bool {
        return errors.isEmpty && warnings.isEmpty
    }
}

private extension Dictionary where Key == String, Value == String {
    func localizableStrings(withPath path: String = "File/Path") -> LocalizableStrings {
        return LocalizableStrings(path: path, lines: self)
    }
}
