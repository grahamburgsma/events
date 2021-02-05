import Vapor

extension Request {

    public var events: Application.Events {
        application.events
    }

    public func trigger<E: Event>(_ event: E) -> EventLoopFuture<Void> {
        events.trigger(event, logger: logger, on: eventLoop)
    }
}
