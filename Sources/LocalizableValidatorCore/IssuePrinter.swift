//
//  OutputPrinter.swift
//
//  Created by Łukasz Kasperek on 09/08/2019.
//

import Foundation
import Basic

protocol OutputPrinter {
    func printValidationOutput(_ output: ValidationOutput)
}

struct OutputPrinterImp: OutputPrinter {
    private let tc: TerminalController
    
    init() {
        tc = TerminalController(stream: stdoutStream)!
    }
    
    func printSth() {
        tc.write("Siusiak", inColor: .red, bold: true)
        tc.write("Siusiak", inColor: .red, bold: false)
        tc.endLine()
        tc.write("Siusiak", inColor: .green, bold: true)
        tc.write("Siusiak", inColor: .green, bold: false)
    }
    
    func printValidationOutput(_ output: ValidationOutput) {
        if output.isValid {
            printSuccessfulValidationMessage(for: output.validatedFilePath)
        } else {
            printFailedValidationMessage(for: output.validatedFilePath)
            output.issues.errors.forEach { printValidationError($0) }
        }
        output.issues.warnings.forEach { printValidationWarning($0) }
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
    
    private func printValidationError(_ error: ValidationError) {
        tc.write("ERROR: ", inColor: .red, bold: true)
        switch error {
        case let .invalidLineFormat(contents):
            tc.write("invalid line format \"\(contents)\"", inColor: .red)
        case let .mismatchedInterpolations(description):
            tc.write("interpolations do not match for key \"\(description.key)\"")
            tc.endLine()
            tc.write("\tReference: \"\(description.referenceValue)\"", inColor: .red)
            tc.endLine()
            tc.write("\tTranslation: \"\(description.value)\"", inColor: .red)
        }
        tc.endLine()
    }
    
    private func printValidationWarning(_ warning: ValidationWarning) {
        tc.write("WARNING: ", inColor: .yellow, bold: true)
        switch warning {
        case let .missingTranslation(key):
            tc.write("missing translation for key \"\(key)\"", inColor: .yellow)
        case let .redundantTranslation(key, translation):
            tc.write("redundant translation \"\(translation)\" for key \"\(key)\"", inColor: .yellow)
        }
        tc.endLine()
    }
}
