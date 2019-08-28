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

    override func setUp() {
        super.setUp()
        sut = FileParserImp()
    }

    override func tearDown() {
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
        let testFile = TestFile(contents: fileContents)
                        
        // when
        let parsed = try sut.parseFile(at: testFile.url)
                                    
        // then
        let expected = LocalizableStrings(
            path: testFile.path,
            lines: expectedLines
        )
        XCTAssertEqual(expected, parsed, file: file, line: line)
    }
    
    func testParsing_whenTranslationsIsMissingSemicolon_shouldThrow() {
        let fileContents =
        #"""
        "key" = "translation"
        """#
        performTestExpectingFailure(fileContents: fileContents, errorAsserts: { testFile, error in
            assertEqual(
                error: error,
                parsingError: FileParsingError(line: #""key" = "translation""#, filePath: testFile.path)
            )
        })
    }
    
    func testParsing_whenTranslationsHaveNonClosedComment_shouldThrow() {
        let fileContents =
        #"""
        /* comment

        "key" = "translation";
        """#
        performTestExpectingFailure(fileContents: fileContents, errorAsserts: { testFile,error in
            assertEqual(
                error: error,
                parsingError: FileParsingError(line: #"/* comment"#, filePath: testFile.path)
            )
        })
    }
    
    func testParsing_whenTranslationHasStringWithNonEscapedQuote_shouldThrow() {
        let fileContents =
        #"""
        "key" = "tran"slation";
        """#
        performTestExpectingFailure(fileContents: fileContents, errorAsserts: { testFile, error in
            assertEqual(
                error: error,
                parsingError: FileParsingError(line: #""key" = "tran"slation";"#, filePath: testFile.path)
            )
        })
    }
    
    private func performTestExpectingFailure(
        fileContents: String,
        errorAsserts: (TestFile, Error) -> (),
        file: StaticString = #file,
        line: UInt = #line
    ) {
        // given
        let testFile = TestFile(contents: fileContents)
        
        // then
        XCTAssertThrowsError(try sut.parseFile(at: testFile.url)) { error in
            errorAsserts(testFile, error)
        }
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
