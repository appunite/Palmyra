//
//  IssuePrinterTests.swift
//  PalmyraTests
//
//  Created by Łukasz Kasperek on 27/08/2019.
//

import XCTest
@testable import PalmyraCore
import Basic

class IssuePrinterTests: XCTestCase {
    var sut: IssuePrinterImp!
    var outputRecord: [PrinterOutput] = []

    override func setUp() {
        super.setUp()
        outputRecord = []
        sut = IssuePrinterImp(write: { string, color, bold in
            self.outputRecord.append(
                PrinterOutput(string: string, color: color, bold: bold)
            )
        })
    }

    override func tearDown() {
        sut = nil
        outputRecord = []
        super.tearDown()
    }
    
    func testPrintingProgramFailure_shouldOutputErrorLocalizedDescriptionInRedAndEndLine() {
        // given
        let error = TestError(description: "Failure")
        
        // when
        sut.printProgramFailure(error: error)
        
        // then
        verifyOutput([
            .init(string: "ERROR: ", color: .red, bold: true),
            .init(string: "Failure", color: .red, bold: false),
            .init(string: "\n", color: .red, bold: false)
        ])
    }
    
    func testValidationOutputPrinting_whenThereAreNoFatals_shouldPrintSuccessMessage() {
        // given
        let vo = makeValidationOutput(with: [
            .missingTranslation(key: "key")
        ])
        
        // when
        sut.printValidationOutput(vo)
        
        // then
        verifyOutput([
            .init(string: "/test/path", color: .green, bold: true),
            .init(string: " validated successfully!\n", color: .green, bold: false)
        ], compareMode: .head)
    }
    
    func testValidationOutputPrinting_whenThereAreWarnings_shouldPrintThemInYellow() {
        // given
        let vo = makeValidationOutput(with: [
            .missingTranslation(key: "key"),
            .redundantTranslation(key: "key2", translation: "translation")
        ])
        
        // when
        sut.printValidationOutput(vo)
        
        // then
        verifyOutput([
            .init(string: "WARNINGS:\n", color: .yellow, bold: true),
            .init(string: "1. ", color: .yellow, bold: false),
            .init(string: #"Missing translation for key "key""#, color: .yellow, bold: false),
            .init(string: "\n", color: .yellow, bold: false),
            .init(string: "2. ", color: .yellow, bold: false),
            .init(string: #"Redundant translation "translation" for key "key2""#, color: .yellow, bold: false),
            .init(string: "\n", color: .yellow, bold: false)
        ], compareMode: .tail)
    }
    
    func testValidationOutputPrinting_whenFatalsOccur_shouldPrintFailureMessage() {
        // given
        let vo = makeValidationOutput(with: [
            .invalidLineFormat(contents: "line")
        ])
        
        // when
        sut.printValidationOutput(vo)
        
        // then
        verifyOutput([
            .init(string: "/test/path", color: .red, bold: true),
            .init(string: " failed to validate\n", color: .red, bold: false)
        ], compareMode: .head)
    }
    
    func testValidationOutputPrinting_whenFatalsOccur_shouldPrintThemInRed() {
        // given
        let vo = makeValidationOutput(with: [
            .invalidLineFormat(contents: "line"),
            .mismatchedInterpolations(description: .init(key: "key", value: "value", referenceValue: "ref"))
        ])
        
        // when
        sut.printValidationOutput(vo)
        
        // then
        verifyOutput([
            .init(string: "ERRORS:\n", color: .red, bold: true),
            .init(string: "1. ", color: .red, bold: false),
            .init(string: #"Invalid line format "line""#, color: .red, bold: false),
            .init(string: "\n", color: .red, bold: false),
            .init(string: "2. ", color: .red, bold: false),
            .init(string:
                #"""
                "Interpolations do not match for key "key""
                    Reference: "ref"
                    Translation: "value"
                """#,
                  color: .red, bold: false),
            .init(string: "\n", color: .red, bold: false)
        ], compareMode: .tail)
    }
    
    private func makeValidationOutput(with issues: [ValidationIssue]) -> ValidationOutput {
        return ValidationOutput(
            validatedFilePath: "/test/path",
            issues: issues
        )
    }
    
    private enum CompareMode {
        case head, tail, strict
    }
    private func verifyOutput(
        _ expected: [PrinterOutput],
        compareMode: CompareMode = .strict,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        switch compareMode {
        case .head:
            XCTAssertEqual(
                expected, Array(outputRecord.prefix(expected.count)),
                file: file,
                line: line
            )
        case .tail:
            XCTAssertEqual(
                expected, Array(outputRecord.suffix(expected.count)),
                file: file,
                line: line
            )
        case .strict:
            XCTAssertEqual(
                expected, outputRecord,
                file: file,
                line: line
            )
        }
    }
}

struct PrinterOutput: Equatable {
    let string: String
    let color: TerminalController.Color
    let bold: Bool
}

struct TestError: LocalizedError {
    private let description: String
    
    init(description: String = "Test") {
        self.description = description
    }
    
    var errorDescription: String? {
        return description
    }
}
