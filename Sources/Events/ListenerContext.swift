import Vapor

public struct ListenerContext {

    /// The application object
    public let application: Application

    /// The logger object
    public var logger: Logger

    public let events: Events
}
