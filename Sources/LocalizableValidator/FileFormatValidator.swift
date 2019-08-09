//
//  FileFormatValidator.swift
//  LocalizableValidator
//
//  Created by Łukasz Kasperek on 23/07/2019.
//

import Foundation

protocol FileFormatValidator {
    
}

class FileFormatValidatorImp: FileFormatValidator {
    init() {}
    
    func validateFileFormat(at fileURL: URL) -> Result<LocalizableStrings, Error> {
        return Result(catching: { try String(contentsOf: fileURL) })
            .map({ removeCommentsAndEmptyLines(from: $0) })
            .flatMap({ parseTranslationsString($0) })
            .map({ LocalizableStrings(path: fileURL.path, lines: $0) })
    }
    
    private func removeCommentsAndEmptyLines(from string: String) -> String {
        let commentsRemoved = string.replacingOccurrences(
            of: #"\/\*(\*(?!\/)|[^*])*\*\/"#,
            with: "",
            options: .regularExpression
        )
        let newlinesRemoved = commentsRemoved
            .split(whereSeparator: { $0.isNewline }).joined(separator: "\n")
        return newlinesRemoved
    }
    
    private func parseTranslationsString(_ string: String) -> Result<[Key: Translation], Error> {
        var result = [Key: Translation]()
        var errors = [FileFormatValidationError]()
        string.enumerateLines { lineString, _ in
            do {
                let (key, translation) = try self.parseLine(lineString)
                result[key] = translation
            } catch let error as FileFormatValidationError {
                errors.append(error)
            } catch {
                fatalError("Unexpected error type")
            }
        }
        if errors.isEmpty {
            return .success(result)
        } else {
            return .failure(CompoundValidationError(errors: errors))
        }
    }
    
    private func parseLine(_ lineString: String) throws -> (String, String) {
        guard let match = translationsLineRegex.firstMatch(
            in: lineString,
            options: [],
            range: lineString.startToEndNSRange) else {
                throw FileFormatValidationError(invalidLineContents: lineString)
        }
        guard match.numberOfRanges == 3 else {
            fatalError("Oops, regex needs to be checked...")
        }
        let key = String(lineString[match.range(at: 1)])
        let translation = String(lineString[match.range(at: 2)])
        return (key, translation)
    }
    
    private let translationsLineRegex = try! NSRegularExpression(
        pattern: #"^\"((?:\\.|[^\\"])*?)\"\s=\s\"((?:\\.|[^\\"])*?)\";"#
    )
}
