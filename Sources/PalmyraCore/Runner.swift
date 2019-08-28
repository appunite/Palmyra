//
//  Runner.swift
//
//  Created by Łukasz Kasperek on 12/08/2019.
//

import Foundation

public final class Runner {
    private let commandLineInterface: CommandLineInterface
    private let fileParser: FileParser
    private let validator: Validator
    private let issuePrinter: IssuePrinter
    
    public static func make() -> Runner {
        return Runner()
    }
    
    init(
        commandLineInterface: CommandLineInterface = CommandLineInterfaceImp(),
        fileParser: FileParser = FileParserImp(),
        validator: Validator = ValidatorImp(),
        issuePrinter: IssuePrinter = IssuePrinterImp()
    ) {
        self.commandLineInterface = commandLineInterface
        self.fileParser = fileParser
        self.validator = validator
        self.issuePrinter = issuePrinter
    }
    
    public func run(arguments: [String]) {
        do {
            let (referenceFileURL, translationFileURLs) = try commandLineInterface.process(arguments: arguments)
            let referenceStrings = try fileParser.parseFile(at: referenceFileURL)
            let translationStrings = try translationFileURLs.map(fileParser.parseFile(at:))
            for translations in translationStrings {
                let output = validator.validate(translations: translations, reference: referenceStrings)
                issuePrinter.printValidationOutput(output)
                exit(output.issues.fatalsOccur ? 1 : 0)
            }
        } catch {
            issuePrinter.printProgramFailure(error: error)
            exit(1)
        }
    }
}
