//
//  FileFormatValidator.swift
//  LocalizableValidator
//
//  Created by Łukasz Kasperek on 23/07/2019.
//

import Foundation

public protocol FileFormatValidator {
    
}

public class FileFormatValidatorImp: FileFormatValidator {
    public init() {}
    
    public func validateFileFormat(at fileURL: URL) throws -> LocalizableFile {
        let fileContents = try String(contentsOf: fileURL)
        let onlyTranslationsString = removeCommentsAndEmptyLines(from: fileContents)
        let parsedLines = try parseTranslationsString(onlyTranslationsString)
        return LocalizableFile(
            path: fileURL.path,
            lines: parsedLines
        )
    }
    
    private func removeCommentsAndEmptyLines(from string: String) -> String {
        let commentsRemoved = string.replacingOccurrences(
            of: commentsRegex,
            with: "",
            options: .regularExpression
        )
        let newlinesRemoved = commentsRemoved
            .split(whereSeparator: { $0.isNewline }).joined(separator: "\n")
        return newlinesRemoved
    }
    
    private var commentsRegex: String {
        return #"\/\*(\*(?!\/)|[^*])*\*\/"#
    }
    
    private func parseTranslationsString(_ string: String) throws -> LocalizableFile.Lines {
        var result: LocalizableFile.Lines = [:]
        var errors: [FileFormatValidationError] = []
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
            return result
        } else {
            throw CompoundValidationError(errors: errors)
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
    
    private lazy var translationsLineRegex: NSRegularExpression = {
        let pattern = #"^"((?:\.|[^\"])*?)"\s=\s"((?:\.|[^\"])*?)";"#
        return try! NSRegularExpression(pattern: pattern)
    }()
}

private extension String {
    var startToEndNSRange: NSRange {
        return NSRange(startIndex..<endIndex, in: self)
    }
    
    subscript(_ nsRange: NSRange) -> Substring {
        let range = Range<String.Index>(nsRange, in: self)!
        return self[range]
    }
}
