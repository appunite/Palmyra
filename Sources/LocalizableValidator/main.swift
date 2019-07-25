import SPMUtility
import Foundation

let parser = ArgumentParser(
    commandName: "validateLocStrings",
    usage: "<options> [paths ...]",
    overview: "Validate your Localizable.strings files",
    seeAlso: nil
)

// options
let referenceFile = parser.add(
    option: "--reference",
    shortName: "-r",
    kind: String.self,
    usage: nil,
    completion: nil
)

// arguments
let paths = parser.add(positional: "paths", kind: [String].self, optional: false)

do {
    let arguments = Array(CommandLine.arguments.dropFirst())
    let result = try parser.parse(arguments)
    let parsedPaths = result.get(paths)
    if let paths = parsedPaths {
        for path in paths {
            let url = URL(fileURLWithPath: path)
            print(url.absoluteString)
        }
    }
    if let refernceFilePath = result.get(referenceFile) {
        let url = URL(fileURLWithPath: refernceFilePath)
        print(url.absoluteString)
    }
}
