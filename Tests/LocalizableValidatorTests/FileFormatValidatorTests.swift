//
//  FileFormatValidatorTests.swift
//  LocalizableValidatorTests
//
//  Created by Łukasz Kasperek on 23/07/2019.
//

import XCTest

class FileFormatValidatorTests: XCTestCase {
    var sut: FileFormatValidatorImp!
    private let fileManager = FileManager.default
    
    override func setUp() {
        super.setUp()
        sut = FileFormatValidatorImp()
    }

    override func tearDown() {
        if fileManager.fileExists(atPath: testFileURL.path) {
            try! fileManager.removeItem(at: testFileURL)
        }
        sut = nil
    }
    
    func testValidation_whenFileContainsMultilineComment_shouldSuccessfullyParseAndValidate() throws {
        let fileContents =
        """
        /* single line comment */
        "key 1" = "translation 1";

        /* multi
        line
        comment */
        "key 2" = "translation 2";
        """
        let expectedLines = [
            "key 1": "translation 1",
            "key 2": "translation 2"
        ]
        try performTestExpectingSuccessfulResult(fileContents: fileContents, expectedLines: expectedLines)
    }
    
    func testValidation_whenFileContainsTranslationWithNewlines_shouldSuccessfullyParseAndValidate() throws {
        let fileContents =
        """
        /* single line comment */
        "key 1" = "tran\nslation\n1";
        """
        let expectedLines = ["key 1": "tran\nslation\n1"]
        try performTestExpectingSuccessfulResult(fileContents: fileContents, expectedLines: expectedLines)
    }
    
    func testValidation_whenFileContainsTranslationWithEscapedQuotes_shouldSuccessfullyParseAndValidate() throws {
        let fileContents =
        """
        /* single line comment */
        "key 1" = "\"quote\" - Famous Person";
        """
        let expectedLines = ["key 1": "\"quote\" - Famous Person"]
        try performTestExpectingSuccessfulResult(fileContents: fileContents, expectedLines: expectedLines)
    }
    
    func testValidation1_whenFileContainsTranslationWithEscapedQuotes_shouldSuccessfullyParseAndValidate() throws {
        // when
        let url = Bundle(for: FileFormatValidatorTests.self).url(forResource: "Localizable", withExtension: "strings")!
        let result = sut.validateFileFormat(at: url)
        let parsed: LocalizableStrings
        switch result {
        case let .success(p):
            for value in p.lines.values {
                print(value)
            }
            parsed = p
        case let .failure(error):
            XCTFail((error as! LocalizedError).localizedDescription)
            return
        }
        
        // then
        let expected = LocalizableStrings(
            path: url.path,
            lines: ["key 1": "tran\ns \"lation\" \n1"]
        )
        print(parsed.lines.values.first!)
        XCTAssertEqual(expected, parsed)
    }
    
    private func performTestExpectingSuccessfulResult(
        fileContents: String,
        expectedLines: [String: String],
        file: StaticString = #file,
        line: UInt = #line) throws {
        // given
        setFile(with: fileContents)
                        
        // when
        let result = sut.validateFileFormat(at: testFileURL)
        
        let parsed: LocalizableStrings
        switch result {
        case let .success(p):
            parsed = p
        case let .failure(error):
            XCTFail((error as! LocalizedError).localizedDescription, file: file, line: line)
            return
        }
                                    
        // then
        let expected = LocalizableStrings(
            path: testFileURL.path,
            lines: expectedLines
        )
        XCTAssertEqual(expected, parsed, file: file, line: line)
    }
    
    private func performTestExpectingFailure(fileContents: String, expectedError: Error, file: StaticString = #file, line: UInt = #line) {
        
    }
    
    private func setFile(with contents: String) {
        try! contents.data(using: .utf8)!.write(to: testFileURL)
    }
    
    private var testFileURL: URL {
        return fileManager.temporaryDirectory
            .appendingPathComponent("Localizable.strings")
    }
}
