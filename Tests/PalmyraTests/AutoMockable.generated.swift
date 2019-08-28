// Generated using Sourcery 0.16.2 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

















import Foundation
@testable import PalmyraCore


// sourcery:inline:FileParser.AutoMockable
class FileParserMock: FileParser {
    //MARK: - parseFile

    var parseFileAtThrowableError: Error?
    var parseFileAtCallsCount = 0
    var parseFileAtCalled: Bool {
        return parseFileAtCallsCount > 0
    }
    var parseFileAtReceivedFileURL: URL?
    var parseFileAtReturnValue: LocalizableStrings!
    var parseFileAtClosure: ((URL) throws -> LocalizableStrings)?

    func parseFile(at fileURL: URL) throws -> LocalizableStrings {
        if let error = parseFileAtThrowableError {
            throw error
        }
        parseFileAtCallsCount += 1
        parseFileAtReceivedFileURL = fileURL
        return try parseFileAtClosure.map({ try $0(fileURL) }) ?? parseFileAtReturnValue
    }


}
// sourcery:end

// sourcery:inline:IssuePrinter.AutoMockable
class IssuePrinterMock: IssuePrinter {
    //MARK: - printProgramFailure

    var printProgramFailureErrorCallsCount = 0
    var printProgramFailureErrorCalled: Bool {
        return printProgramFailureErrorCallsCount > 0
    }
    var printProgramFailureErrorReceivedError: Error?
    var printProgramFailureErrorClosure: ((Error) -> Void)?

    func printProgramFailure(error: Error) {
        printProgramFailureErrorCallsCount += 1
        printProgramFailureErrorReceivedError = error
        printProgramFailureErrorClosure?(error)
    }

    //MARK: - printValidationOutput

    var printValidationOutputCallsCount = 0
    var printValidationOutputCalled: Bool {
        return printValidationOutputCallsCount > 0
    }
    var printValidationOutputReceivedOutput: ValidationOutput?
    var printValidationOutputClosure: ((ValidationOutput) -> Void)?

    func printValidationOutput(_ output: ValidationOutput) {
        printValidationOutputCallsCount += 1
        printValidationOutputReceivedOutput = output
        printValidationOutputClosure?(output)
    }


}
// sourcery:end

// sourcery:inline:Validator.AutoMockable
class ValidatorMock: Validator {
    //MARK: - validate

    var validateTranslationsReferenceCallsCount = 0
    var validateTranslationsReferenceCalled: Bool {
        return validateTranslationsReferenceCallsCount > 0
    }
    var validateTranslationsReferenceReceivedArguments: (translations: LocalizableStrings, reference: LocalizableStrings)?
    var validateTranslationsReferenceReturnValue: ValidationOutput!
    var validateTranslationsReferenceClosure: ((LocalizableStrings, LocalizableStrings) -> ValidationOutput)?

    func validate(translations: LocalizableStrings, reference: LocalizableStrings) -> ValidationOutput {
        validateTranslationsReferenceCallsCount += 1
        validateTranslationsReferenceReceivedArguments = (translations: translations, reference: reference)
        return validateTranslationsReferenceClosure.map({ $0(translations, reference) }) ?? validateTranslationsReferenceReturnValue
    }


}
// sourcery:end
