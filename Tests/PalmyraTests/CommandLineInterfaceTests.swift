//
//  CommandLineInterfaceTests.swift
//  PalmyraTests
//
//  Created by Łukasz Kasperek on 28/08/2019.
//

import XCTest
@testable import PalmyraCore

class CommandLineInterfaceTests: XCTestCase {
    var sut: CommandLineInterfaceImp!

    override func setUp() {
        super.setUp()
        sut = CommandLineInterfaceImp()
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    func testProcessing_whenExistingFilePathsArePassed_shouldReturnURLs() throws {
        // given
        let referenceFile = TestFile(name: "Ref.strings", contents: "")
        let translationFile1 = TestFile(name: "Trans1.strings", contents: "")
        let translationFile2 = TestFile(name: "Trans2.strings", contents: "")
        
        // when
        let (refURL, translationsURLs) = try sut.process(arguments:
            ["palmyra", "-r", referenceFile.path, "-t", translationFile1.path, translationFile2.path]
        )
        
        // then
        XCTAssertEqual(refURL, referenceFile.url)
        XCTAssertEqual(translationsURLs, [translationFile1.url, translationFile2.url])
    }
    
    func testProcessing_whenPathToReferenceFileThatDoesntExistIsPassed_shouldThrow() {
        // given
        let refPath = "Some/Path"
        let translationFile = TestFile(name: "Trans.strings", contents: "")
        let arguments = ["palmyra", "--reference", refPath, "--translations", translationFile.path]
        
        // then
        XCTAssertThrowsError(try sut.process(arguments: arguments)) { error in
            XCTAssertEqual(
                error as? FileURLFormingError,
                FileURLFormingError(fileType: .reference, reason: .missingFile(refPath))
            )
        }
    }
    
    func testProcessing_whenPathToTranslationFileThatDoesntExistIsPassed_shouldThrow() {
        // given
        let referenceFile = TestFile(name: "Ref.strings", contents: "")
        let translationPath = "Some/Path"
        let arguments = ["palmyra", "--reference", referenceFile.path, "--translations", translationPath]
        
        // then
        XCTAssertThrowsError(try sut.process(arguments: arguments)) { error in
            XCTAssertEqual(
                error as? FileURLFormingError,
                FileURLFormingError(fileType: .translation, reason: .missingFile(translationPath))
            )
        }
    }
    
    func testProcessing_whenNoReferenceFileIsPassed_shouldThrow() {
        // given
        let translationFile = TestFile(name: "Trans.strings", contents: "")
        let arguments = ["palmyra", "--translations", translationFile.path]
        
        // then
        XCTAssertThrowsError(try sut.process(arguments: arguments)) { error in
            XCTAssertEqual(
                error as? FileURLFormingError,
                FileURLFormingError(fileType: .reference, reason: .missingPath)
            )
        }
    }
    
    func testProcessing_whenNoTranslationFileIsPassed_shouldThrow() {
        // given
        let referenceFile = TestFile(name: "Ref.strings", contents: "")
        let arguments = ["palmyra", "-r", referenceFile.path]
        
        // then
        XCTAssertThrowsError(try sut.process(arguments: arguments)) { error in
            XCTAssertEqual(
                error as? FileURLFormingError,
                FileURLFormingError(fileType: .translation, reason: .missingPath)
            )
        }
    }
}
