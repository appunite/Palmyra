//
//  OutputPrinter.swift
//
//  Created by Łukasz Kasperek on 09/08/2019.
//

import Foundation
import Basic

protocol OutputPrinter {
    func printValidationOutput(_ output: ValidationOutput)
//    func printFileParsingError(_ error: FileParsingError)
}

struct OutputPrinterImp: OutputPrinter {
    private let tc: TerminalController
    
    init() {
        tc = TerminalController(stream: stdoutStream)!
    }
    
    func printValidationOutput(_ output: ValidationOutput) {
        let (fatals, warnings) = output.issues.splitIntoFatalsAndWarnings()
        if fatals.isEmpty {
            printSuccessfulValidationMessage(for: output.validatedFilePath)
        } else {
            printFailedValidationMessage(for: output.validatedFilePath)
            printFatalIssues(fatals)
        }
        printWarnings(warnings)
    }
    
    private func printSuccessfulValidationMessage(for filePath: String) {
        tc.write(filePath, inColor: .green, bold: true)
        tc.write(" validated successfully!", inColor: .green, bold: false)
        tc.endLine()
    }
    
    private func printFailedValidationMessage(for filePath: String) {
        tc.write(filePath, inColor: .red, bold: true)
        tc.write(" failed to validate :(", inColor: .red, bold: false)
        tc.endLine()
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
        tc.write("\(title):", inColor: color, bold: true)
        tc.endLine()
        for (number, issue) in issues.enumerated() {
            tc.write("\(number). ", inColor: color)
            tc.write(issue.localizedDescription, inColor: color)
            tc.endLine()
        }
    }
}
