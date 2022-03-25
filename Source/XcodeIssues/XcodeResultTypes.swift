// Copyright © 2022 Itty Bitty Apps Pty Ltd. See LICENSE file.
import Foundation

public struct XcodeObject<Value: Decodable>: Decodable {
    enum CodingKeys: String, CodingKey {
        case value = "_value"
    }

    public let value: Value
}

public struct XcodeArray<Value: Decodable>: Decodable {
    enum CodingKeys: String, CodingKey {
        case values = "_values"
    }

    public let values: [Value]
}

public struct ActionsInvocationRecord: Decodable {
    public let issues: ResultIssueSummaries
}

public struct ResultIssueSummaries: Decodable {
    public var errorSummaries: XcodeArray<IssueSummary>?
    public var warningSummaries: XcodeArray<IssueSummary>?
    public var testFailureSummaries: XcodeArray<TestFailureIssueSummary>?
}

public struct IssueSummary: Decodable {
    public let documentLocationInCreatingWorkspace: DocumentLocation?
    public var message: XcodeObject<String>
}

public struct TestFailureIssueSummary: Decodable {
    public let documentLocationInCreatingWorkspace: DocumentLocation?
    public var message: XcodeObject<String>
    public var producingTarget: XcodeObject<String>
    public var testCaseName: XcodeObject<String>
}

public struct DocumentLocation: Decodable {
    public let path: String
    public let startingLineNumber: Int?
    public let endingLineNumber: Int?
    public let startingColumnNumber: Int?
    public let endingColumnNumber: Int?

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let url = try container.decode(XcodeObject<URL>.self, forKey: .url)
        guard var urlComponents = URLComponents(url: url.value, resolvingAgainstBaseURL: true) else {
            throw DecodingError.dataCorruptedError(forKey: .url, in: container, debugDescription: "Invalid URL")
        }

        urlComponents.query = urlComponents.fragment
        let fragmentQueryItem = { name in
            urlComponents
                .fragmentQueryItems?
                .last(where: { $0.name == name })?
                .value
        }

        self.path = urlComponents.path
        self.startingLineNumber = fragmentQueryItem("StartingLineNumber").flatMap(Int.init)
        self.endingLineNumber = fragmentQueryItem("EndingLineNumber").flatMap(Int.init)
        self.startingColumnNumber = fragmentQueryItem("StartingColumnNumber").flatMap(Int.init)
        self.endingColumnNumber = fragmentQueryItem("EndingColumnNumber").flatMap(Int.init)
    }

    enum CodingKeys: String, CodingKey {
        case url = "url"
    }
}

extension URLComponents {
    var fragmentQueryItems: [URLQueryItem]? {
        var newComponents = URLComponents()
        newComponents.query = fragment
        return newComponents.queryItems
    }
}
