//
//  RunnerTests.swift
//  PalmyraTests
//
//  Created by Łukasz Kasperek on 27/08/2019.
//

import XCTest
@testable import PalmyraCore

class RunnerIntegrationTests: XCTestCase {
    var sut: Runner!
    var receivedExitCode: Int32?

    override func setUp() {
        super.setUp()
        sut = Runner(exit: { code in
            self.receivedExitCode = code
        })
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    func testIntegration_whenValidFilesArePassed_shouldExitWithCode0() {
        // given
        let reference = TestFile(name: "English.strings", contents:
            #"""
            "key" = "key";
            """#
        )
        let translation = TestFile(name: "Polish.strings", contents:
            #"""
            "key" = "klucz";
            """#
        )
        
        // when
        sut.run(arguments: ["palmyra", "-r", reference.path, "-t", translation.path])
        
        // then
        XCTAssertEqual(receivedExitCode, 0)
    }
    
    func testIntegration_whenInvalidFilesArePassed_shouldExitWithCode1() {
        // given
        let reference = TestFile(name: "English.strings", contents:
            #"""
            "key" = "key";
            """#
        )
        let translation = TestFile(name: "Polish.strings", contents:
            #"""
            "key" = "klucz %@";
            """#
        )
        
        // when
        sut.run(arguments: ["palmyra", "-r", reference.path, "-t", translation.path])
        
        // then
        XCTAssertEqual(receivedExitCode, 1)
    }
    
    func testIntegration_whenNoFilesArePassed_shouldExitWithCode1() {
        // when
        sut.run(arguments: ["palmyra"])
        
        // then
        XCTAssertEqual(receivedExitCode, 1)
    }
}
