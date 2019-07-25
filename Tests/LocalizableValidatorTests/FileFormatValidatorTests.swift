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
    
    func testValidation_whenFileIsValidWithMultilineComment_shouldSuccessfullyParseAndValidate() throws {
        // given
        let fileContents =
        #"""
        /* single line comment */
        "key 1" = "translation 1";

        /* multi
        line
        comment */
        "key 2" = "translation 2";
        """#
        setFile(with: fileContents)
        
        // when
        let result = try sut.validateFileFormat(at: testFileURL)
                    
        // then
        let expected = LocalizableFile(
            path: testFileURL.path,
            lines: [
                "key 1": "translation 1",
                "key 2": "translation 2"
            ]
        )
        XCTAssertEqual(expected, result)
    }
    
    func testValidation_whenFileIsValidWithTranslationContainingNewlines_shouldSuccessfullyParseAndValidate(
        fileContents: String,
        expectedLines: [String: String],
        file: StaticString = #file,
        line: UInt = #line) throws {
        // given
                let fileContents =
                #"""
                /* single line comment */
                "key 1" = "translation 1";

                /* multi
                line
                comment */
                "key 2" = "translation 2";
                """#
                setFile(with: fileContents)
                
                // when
                let result = try sut.validateFileFormat(at: testFileURL)
                            
                // then
                let expected = LocalizableFile(
                    path: testFileURL.path,
                    lines: [
                        "key 1": "translation 1",
                        "key 2": "translation 2"
                    ]
                )
                XCTAssertEqual(expected, result)
    }
    
    private func performTestExpectingSuccessfulResult(fileContents: String) throws {
        
    }
    
    private func setFile(with contents: String) {
        try! contents.data(using: .utf8)!.write(to: testFileURL)
    }
    
    private var testFileURL: URL {
        return fileManager.temporaryDirectory
            .appendingPathComponent("Localizable.strings")
    }
}
