//
//  Runner.swift
//
//  Created by Łukasz Kasperek on 12/08/2019.
//

import Foundation
import SPMUtility

public final class Runner {
    private let parser: ArgumentParser
    private let referenceFilePath: OptionArgument<String>
    private let translationFilePaths: OptionArgument<[String]>
    private let arguments: [String]
    private let fileParser: FileParser
    private let validator: Validator
    private let outputPrinter: OutputPrinter
    
    public static func make() -> Runner {
        return Runner()
    }
    
    init(
        arguments: [String] = CommandLine.arguments,
        fileParser: FileParser = FileParserImp(),
        validator: Validator = ValidatorImp(),
        outputPrinter: OutputPrinter = OutputPrinterImp()
    ) {
        self.arguments = arguments
        self.fileParser = fileParser
        self.validator = validator
        self.outputPrinter = outputPrinter
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
    
    public func run() {
        let arguments = Array(CommandLine.arguments.dropFirst())
        do {
            let result = try parser.parse(arguments)
            let referenceFileURL = try makeReferenceFileURL(from: result.get(referenceFilePath))
            let translationFileURLs = try makeTranslationFileURLs(from: result.get(translationFilePaths))
            let referenceStrings = try fileParser.parseFile(at: referenceFileURL)
            let translationStrings = try translationFileURLs.map(fileParser.parseFile(at:))
            for translations in translationStrings {
                let output = validator.validate(translations: translations, reference: referenceStrings)
                outputPrinter.printValidationOutput(output)
            }
        } catch {
            outputPrinter.printProgramFailure(error: error)
            exit(1)
        }
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
