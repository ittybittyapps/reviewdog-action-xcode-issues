// Copyright © 2022 Itty Bitty Apps Pty Ltd. See LICENSE file.
import ArgumentParser
import Foundation

public struct XcodeIssues: AsyncParsableCommand {
    public static var configuration = CommandConfiguration(
        commandName: "xcissues",
        abstract: "A utility for reporting xcode issues in reviewdog JSON Format."
    )

    @Argument(help: "The path of the xcresult JSON file to process. If omitted, stdin is used instead.")
    var input: String?

    public init() {
    }

    public func run() throws {
        let fileHandle = input.flatMap(FileHandle.init(forReadingAtPath:)) ?? .standardInput

        guard let fileData = try fileHandle.readToEnd() else {
            return // TODO: throw an error?
        }

        let invocationRecord = try JSONDecoder().decode(ActionsInvocationRecord.self, from: fileData)
        let errorDiagnostics = invocationRecord.issues.errorSummaries?.values.compactMap { Diagnostic(issueSummary: $0, severity: .error) } ?? []
        let warningDiagnostics = invocationRecord.issues.warningSummaries?.values.compactMap { Diagnostic(issueSummary: $0, severity: .warning) } ?? []
        let allDiagnostics = errorDiagnostics + warningDiagnostics
        let result = DiagnosticResult(diagnostics: allDiagnostics)
        let jsonData = try JSONEncoder().encode(result)

        try FileHandle.standardOutput.write(contentsOf: jsonData)
    }
}

extension Diagnostic {
    init?(issueSummary: IssueSummary, severity: Severity) {
        guard let location = issueSummary.documentLocationInCreatingWorkspace,
              let startingLineNumber = location.startingLineNumber,
              let startingColumnNumber = location.startingColumnNumber
        else {
            return nil
        }

        // `DocumentLocation` uses zero-indexed line/column numbers, while rdjson uses 1-indexed line/column numbers.
        // Add 1 to each of the line/column numbers here to account for this.
        let endPosition: Position?
        if let endingLineNumber = location.endingLineNumber,
           let endingColumnNumber = location.endingColumnNumber {
            endPosition = .init(
                line: endingLineNumber + 1,
                column: endingColumnNumber + 1
            )
        } else {
            endPosition = nil
        }

        self.init(
            message: issueSummary.message.value,
            location: .init(
                path: location.path,
                range: .init(
                    start: .init(
                        line: startingLineNumber + 1,
                        column: startingColumnNumber + 1
                    ),
                    end: endPosition
                )
            ),
            severity: severity
        )
    }
}
