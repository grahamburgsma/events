import Vapor

public struct ListenerContext: Sendable {

    /// The application object
    public let application: Application

    /// The logger object
    public var logger: Logger

    public let events: Events
}
