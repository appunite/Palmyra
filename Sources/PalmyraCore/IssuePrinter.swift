//
//  OutputPrinter.swift
//
//  Created by Łukasz Kasperek on 09/08/2019.
//

import Foundation
import Basic

protocol IssuePrinter {
    func printProgramFailure(error: Error)
    func printValidationOutput(_ output: ValidationOutput)
}

private func makeWriteClosure() -> (String, TerminalController.Color, Bool) -> () {
    return { [tc = TerminalController(stream: stdoutStream)!] string, color, bold in
        tc.write(string, inColor: color, bold: bold)
    }
}

struct IssuePrinterImp: IssuePrinter {
    private let write: (String, TerminalController.Color, Bool) -> ()
    
    init(write: @escaping (String, TerminalController.Color, Bool) -> () = makeWriteClosure()) {
        self.write = write
    }
    
    private func write(_ string: String, inColor color: TerminalController.Color, bold: Bool) {
        write(string, color, bold)
    }
    
    func printProgramFailure(error: Error) {
        write("ERROR: ", inColor: .red, bold: true)
        write(error.localizedDescription, inColor: .red, bold: false)
        write("\n", inColor: .red, bold: false)
    }
    
    func printValidationOutput(_ output: ValidationOutput) {
        let (fatals, warnings) = output.issues.splitIntoFatalsAndWarnings()
        if fatals.isEmpty {
            printSuccessfulValidationMessage(for: output.validatedFilePath)
        } else {
            printFailedValidationMessage(for: output.validatedFilePath)
            printFatalIssues(fatals)
        }
        if warnings.isEmpty == false {
            printWarnings(warnings)
        }
    }
    
    private func printSuccessfulValidationMessage(for filePath: String) {
        write(filePath, inColor: .green, bold: true)
        write(" validated successfully!\n", inColor: .green, bold: false)
    }
    
    private func printFailedValidationMessage(for filePath: String) {
        write(filePath, inColor: .red, bold: true)
        write(" failed to validate\n", inColor: .red, bold: false)
    }
    
    private func printFatalIssues(_ issues: [ValidationIssue]) {
        printIssues(issues, title: "ERRORS", color: .red)
    }
    
    private func printWarnings(_ issues: [ValidationIssue]) {
        printIssues(issues, title: "WARNINGS", color: .yellow)
    }
    
    private func printIssues(
        _ issues: [ValidationIssue], title: String,
        color: TerminalController.Color
    ) {
        write("\(title):\n", inColor: color, bold: true)
        for (number, issue) in issues.enumerated() {
            write("\(number + 1). ", inColor: color, bold: false)
            write(issue.localizedDescription, inColor: color, bold: false)
            write("\n", inColor: color, bold: false)
        }
    }
}
