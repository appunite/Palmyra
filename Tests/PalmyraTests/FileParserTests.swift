//
//  FileParserTests.swift
//  LocalizableValidatorTests
//
//  Created by Łukasz Kasperek on 16/08/2019.
//

import XCTest
@testable import PalmyraCore

class FileParserTests: XCTestCase {
    var sut: FileParserImp!
    let fileManager = FileManager.default
    var testFileURL: URL {
        return fileManager.temporaryDirectory
            .appendingPathComponent("Localizable.strings")
    }

    override func setUp() {
        super.setUp()
        sut = FileParserImp()
    }

    override func tearDown() {
        if fileManager.fileExists(atPath: testFileURL.path) {
            try! fileManager.removeItem(at: testFileURL)
        }
        sut = nil
        super.tearDown()
    }
    
    func testParsing_whenFileContainsSingleLineComment_shouldNotSpoilParsing() throws {
        let fileContents =
        #"""
        /* single line comment */
        "key 1" = "translation 1";
        """#
        let expectedLines = ["key 1": "translation 1"]
        try performTestExpectingSuccessfulResult(
            fileContents: fileContents,
            expectedLines: expectedLines
        )
    }
    
    func testParsing_whenFileContainsMultilineComment_shouldNotSpoilParsing() throws {
        let fileContents =
        #"""
        /* multi
        line
        comment */
        "key 2" = "translation 2";
        """#
        let expectedLines = ["key 2": "translation 2"]
        try performTestExpectingSuccessfulResult(
            fileContents: fileContents,
            expectedLines: expectedLines
        )
    }
    
    func testParsing_whenFileContainsEmptyLines_shouldNotSpoilParsing() throws {
        let fileContents =
        #"""
        /* comment */
        



        "key 2" = "translation 2";
        """#
        let expectedLines = ["key 2": "translation 2"]
        try performTestExpectingSuccessfulResult(
            fileContents: fileContents,
            expectedLines: expectedLines
        )
    }
    
    func testParsing_whenFileContainsEscapedQuotes_shouldKeepEscapes() throws {
        let fileContents =
        #"""
        "key" = "escaped \"quote\"";
        """#
        let expectedLines = ["key": #"escaped \"quote\""#];
        try performTestExpectingSuccessfulResult(
            fileContents: fileContents,
            expectedLines: expectedLines
        )
    }
    
    func testParsing_whenFileContainsEscapedNewlines_shouldKeepEscaped() throws {
        let fileContents =
        #"""
        "key" = "first line\nsecond line";
        """#
        let expectedLines = ["key": #"first line\nsecond line"#];
        try performTestExpectingSuccessfulResult(
            fileContents: fileContents,
            expectedLines: expectedLines
        )
    }

    private func performTestExpectingSuccessfulResult(
        fileContents: String,
        expectedLines: [String: String],
        file: StaticString = #file,
        line: UInt = #line
    ) throws {
        // given
        setFile(with: fileContents)
                        
        // when
        let parsed = try sut.parseFile(at: testFileURL)
                                    
        // then
        let expected = LocalizableStrings(
            path: testFileURL.path,
            lines: expectedLines
        )
        XCTAssertEqual(expected, parsed, file: file, line: line)
    }
    
    func testParsing_whenTranslationsIsMissingSemicolon_shouldThrow() {
        let fileContents =
        #"""
        "key" = "translation"
        """#
        performTestExpectingFailure(fileContents: fileContents, errorAsserts: { error in
            assertEqual(
                error: error,
                parsingError: FileParsingError(line: #""key" = "translation""#, filePath: testFileURL.path)
            )
        })
    }
    
    func testParsing_whenTranslationsHaveNonClosedComment_shouldThrow() {
        let fileContents =
        #"""
        /* comment

        "key" = "translation";
        """#
        performTestExpectingFailure(fileContents: fileContents, errorAsserts: { error in
            assertEqual(
                error: error,
                parsingError: FileParsingError(line: #"/* comment"#, filePath: testFileURL.path)
            )
        })
    }
    
    func testParsing_whenTranslationHasStringWithNonEscapedQuote_shouldThrow() {
        let fileContents =
        #"""
        "key" = "tran"slation";
        """#
        performTestExpectingFailure(fileContents: fileContents, errorAsserts: { error in
            assertEqual(
                error: error,
                parsingError: FileParsingError(line: #""key" = "tran"slation";"#, filePath: testFileURL.path)
            )
        })
    }
    
    private func performTestExpectingFailure(
        fileContents: String,
        errorAsserts: (Error) -> (),
        file: StaticString = #file,
        line: UInt = #line
    ) {
        // given
        setFile(with: fileContents)
        
        // then
        XCTAssertThrowsError(try sut.parseFile(at: testFileURL)) { error in
            errorAsserts(error)
        }
    }
    
    private func setFile(with contents: String) {
        try! contents.data(using: .utf8)!.write(to: testFileURL)
    }
}

private extension FileParserTests {
    func assertEqual(
        error: Error,
        parsingError: FileParsingError,
        file: StaticString = #file,
        line: UInt = #line) {
        XCTAssertEqual(
            error as? FileParsingError,
            parsingError,
            file: file,
            line: line
        )
    }
}
