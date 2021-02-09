import Vapor

public struct ListenerContext {

    /// The application object
    public let application: Application

    /// The logger object
    public var logger: Logger

    /// An event loop to run the process on
    public let eventLoop: EventLoop

    public let events: Events
}
