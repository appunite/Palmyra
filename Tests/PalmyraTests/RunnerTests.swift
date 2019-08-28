//
//  RunnerTests.swift
//  PalmyraTests
//
//  Created by Łukasz Kasperek on 27/08/2019.
//

import XCTest
@testable import PalmyraCore

class RunnerTests: XCTestCase {
    var sut: Runner!
    var fileParserMock: FileParserMock!
    var validatorMock: ValidatorMock!
    var issuePrinterMock: IssuePrinterMock!

    override func setUp() {
        super.setUp()
        fileParserMock = FileParserMock()
        validatorMock = ValidatorMock()
        issuePrinterMock = IssuePrinterMock()
    }

    override func tearDown() {
        issuePrinterMock = nil
        validatorMock = nil
        fileParserMock = nil
        sut = nil
        super.tearDown()
    }
    
    private func preconfigureSutWithArguments(_ args: [String]) {
        sut = Runner(
            arguments: args,
            fileParser: fileParserMock,
            validator: validatorMock,
            issuePrinter: issuePrinterMock
        )
    }
    
    func testArgumentParsing_whenExistingFilePathsArePassed_shouldDelegateFurtherWorkToFileParser() {
        // given
        var collectedFileURLs = [URL]()
        fileParserMock.parseFileAtClosure = { url in
            collectedFileURLs.append(url)
            return LocalizableStrings(path: url.path, lines: [:])
        }
        let referenceFile = TestFile(name: "Ref.strings", contents: "")
        let translationFile = TestFile(name: "Trans.strings", contents: "")
        preconfigureSutWithArguments(
            ["palmyra", "-r", referenceFile.path, "-t", translationFile.path]
        )
        
        // when
        sut.run()
        
        // then
        XCTAssertEqual(
            collectedFileURLs,
            [referenceFile.url, translationFile.url]
        )
    }
    
    
}
