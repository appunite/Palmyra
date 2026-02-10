//
//  FileParser.swift
//  Basic
//
//  Created by Łukasz Kasperek on 16/08/2019.
//

import Foundation

protocol FileParser {
    func parseFile(at fileURL: URL) throws -> LocalizableStrings
}

class FileParserImp: FileParser {
    init() {}
    
    func parseFile(at fileURL: URL) throws -> LocalizableStrings {
        let fileContents = try String(contentsOf: fileURL)
        let commentAndEmptylinesStrippedContents = removeCommentsAndEmptyLines(from: fileContents)
        let lines = try parseTranslationsString(commentAndEmptylinesStrippedContents, filePath: fileURL.path)
        return LocalizableStrings(path: fileURL.path, lines: lines)
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
    
    private func parseTranslationsString(_ string: String, filePath: String) throws -> [Key: Translation] {
        var result = [Key: Translation]()
        var errors = [FileParsingError]()
        string.enumerateLines { lineString, _ in
            do {
                let (key, translation) = try self.parseLine(lineString, filePath: filePath)
                result[key] = translation
            } catch let error as FileParsingError {
                errors.append(error)
            } catch {
                fatalError("Unexpected error type")
            }
        }
        if errors.isEmpty {
            return result
        } else {
            throw FileParsingError(combining: errors)
        }
    }
    
    private func parseLine(_ lineString: String, filePath: String) throws -> (String, String) {
        guard let match = translationsLineRegex.firstMatch(
            in: lineString,
            options: [],
            range: lineString.startToEndNSRange) else {
                throw FileParsingError(line: lineString, filePath: filePath)
        }
        guard match.numberOfRanges == 3 else {
            fatalError("Oops, regex needs to be checked...")
        }
        let key = String(lineString[match.range(at: 1)])
        let translation = unescapeUnicodeSequences(String(lineString[match.range(at: 2)]))
        return (key, translation)
    }
    
    private func unescapeUnicodeSequences(_ string: String) -> String {
        let matches = unicodeEscapeRegex.matches(
            in: string,
            options: [],
            range: string.startToEndNSRange
        )
        guard !matches.isEmpty else { return string }
        var result = string
        for match in matches.reversed() {
            let hexString = String(string[match.range(at: 1)])
            if let codePoint = UInt32(hexString, radix: 16),
               let scalar = Unicode.Scalar(codePoint) {
                let range = Range<String.Index>(match.range, in: result)!
                result.replaceSubrange(range, with: String(Character(scalar)))
            }
        }
        return result
    }
    
    private let unicodeEscapeRegex = try! NSRegularExpression(
        pattern: #"\\U([0-9A-Fa-f]{4})"#
    )
    
    private let translationsLineRegex = try! NSRegularExpression(
        pattern: #"^\"((?:\\.|[^\\"])*?)\"\s*=\s*\"((?:\\.|[^\\"])*?)\";"#
    )
}
