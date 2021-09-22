import Foundation
import AnyCodable

public struct Registration: Codable {
    public var id: String
    public var method: String
    public var registerOptions: AnyCodable?
}

public struct RegistrationParams: Codable {
    public var registrations: [Registration]
}

public struct Unregistration: Codable {
    public var id: String
    public var method: String
}

public struct UnregistrationParams: Codable {
    public var unregistrations: [Unregistration]
}
