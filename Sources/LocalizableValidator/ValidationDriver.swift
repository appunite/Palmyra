//
//  ValidationDriver.swift
//  LocalizableValidator
//
//  Created by Łukasz Kasperek on 23/07/2019.
//

import Foundation

class ValidationDriver {
    let referenceFileURL: URL
    let translationFilesURLs: [URL]
    
//    private let fileParser = LocalizableFileParser()
    
    init(referenceFileURL: URL, translationFilesURLs: [URL]) {
        self.referenceFileURL = referenceFileURL
        self.translationFilesURLs = translationFilesURLs
    }
    
    func runValidation() throws {
        
    }
    
    
}
