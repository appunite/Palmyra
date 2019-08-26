//
//  LocalizableValidator.swift
//  Basic
//
//  Created by Łukasz Kasperek on 12/08/2019.
//

import Foundation
import SPMUtility

public protocol LocalizableValidator {
    func run() throws
}

class LocalizableValidatorImp: LocalizableValidator {
    private let parser: ArgumentParser
    private let referenceFilePath: OptionArgument<String>
    private let translationFilePaths: OptionArgument<[String]>
    private let arguments: [String]
    private let fileParser: FileParser
    private let validator: Validator
    private let outputPrinter: OutputPrinter
    
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
            commandName: "hancock",
            usage: "<options> [paths ...]",
            overview: "Validate your Localizable.strings files",
            seeAlso: nil
        )
        referenceFilePath = parser.add(
            option: "--reference",
            shortName: "-r",
            kind: String.self,
            usage: "Path to the file with reference translation (most probably Localizable.strings file from Base.lproj or en.lproj folder)",
            completion: .filename
        )
        translationFilePaths = parser.add(
            option: "--translations",
            shortName: "-t",
            kind: [String].self,
            usage: "Paths to all of the translated Localizable.strings files",
            completion: .filename
        )
    }
    
    func run() throws {
        let arguments = Array(CommandLine.arguments.dropFirst())
        let result = try parser.parse(arguments)
        guard let referenceFileURL = result.get(referenceFilePath).map(URL.init(fileURLWithPath:)) else {
            exit(1)
        }
        guard let translationFileURLs = result.get(translationFilePaths)?.map(URL.init(fileURLWithPath:)) else {
            exit(1)
        }
        switch fileParser.parseFile(at: referenceFileURL) {
        case let .success(referenceStrings):
            
        case let .failure(error):
            
        }
        guard case let .success(referenceStrings) = referenceFileParsingResult else {
            referenceFileParsingResult.
        }
    }
}
