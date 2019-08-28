//
//  CommandLineInterface.swift
//
//  Created by Łukasz Kasperek on 28/08/2019.
//

import Foundation
import SPMUtility

// sourcery: AutoMockable
protocol CommandLineInterface {
    func process(arguments: [String]) throws -> (Foundation.URL, [Foundation.URL])
}

struct CommandLineInterfaceImp: CommandLineInterface {
    private let parser: ArgumentParser
    private let referenceFilePath: OptionArgument<String>
    private let translationFilePaths: OptionArgument<[String]>
    
    init() {
        parser = ArgumentParser(
            commandName: "palmyra",
            usage: "--reference <reference file path> --translations <translation file paths>",
            overview: "Validate your Localizable.strings files",
            seeAlso: nil
        )
        referenceFilePath = parser.add(
            option: "--reference",
            shortName: "-r",
            kind: String.self,
            usage: "path to the file with reference strings (most probably english Localizable.strings file from Base.lproj or en.lproj folders)",
            completion: .filename
        )
        translationFilePaths = parser.add(
            option: "--translations",
            shortName: "-t",
            kind: [String].self,
            usage: "paths to all of the translated Localizable.strings files",
            completion: .filename
        )
    }
    
    func process(arguments: [String]) throws -> (Foundation.URL, [Foundation.URL]) {
        let result = try parser.parse(Array(arguments.dropFirst()))
        let referenceFileURL = try makeReferenceFileURL(from: result.get(referenceFilePath))
        let translationFileURLs = try makeTranslationFileURLs(from: result.get(translationFilePaths))
        return (referenceFileURL, translationFileURLs)
    }
    
    private func makeReferenceFileURL(from maybeString: String?) throws -> Foundation.URL {
        guard let path = maybeString else {
            throw FileURLFormingError(fileType: .reference, reason: .missingPath)
        }
        guard FileManager.default.fileExists(atPath: path) else {
            throw FileURLFormingError(fileType: .reference, reason: .missingFile(path))
        }
        return URL(fileURLWithPath: path)
    }
    
    private func makeTranslationFileURLs(from maybeStrings: [String]?) throws -> [Foundation.URL] {
        guard let paths = maybeStrings else {
            throw FileURLFormingError(fileType: .translation, reason: .missingPath)
        }
        return try paths.map({ path in
            guard FileManager.default.fileExists(atPath: path) else {
                throw FileURLFormingError(fileType: .translation, reason: .missingFile(path))
            }
            return URL(fileURLWithPath: path)
        })
    }
}
