import Foundation

public struct ConfigurationItem: Codable {
    public var scopeUri: DocumentUri?
    public var section: String?
}

public struct ConfigurationParams: Codable {
    public var items: [ConfigurationItem]
}
