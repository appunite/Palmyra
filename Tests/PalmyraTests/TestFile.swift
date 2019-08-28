//
//  TemporaryFileManager.swift
//  Basic
//
//  Created by Łukasz Kasperek on 28/08/2019.
//

import Foundation

class TestFile {
    private let fileManager = FileManager.default
        
    let name: String
    var url: URL {
        return fileManager.temporaryDirectory.appendingPathComponent(name)
    }
    var path: String {
        return url.path
    }
    
    init(name: String = "Localizable.strings", contents: String) {
        self.name = name
        try! contents.data(using: .utf8)!.write(to: url)
    }
    
    deinit {
        delete()
    }
    
    func delete() {
        if fileManager.fileExists(atPath: path) {
            try! fileManager.removeItem(at: url)
        }
    }
}
