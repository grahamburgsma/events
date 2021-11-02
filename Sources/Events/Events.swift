import Vapor

public struct Events {

    final class Storage {
        var listeners = [String: [_Listener]]()
    }

    struct Key: StorageKey {
        typealias Value = Storage
    }

    var storage: Storage {
        if application.storage[Key.self] == nil {
            application.storage[Key.self] = .init()
        }
        return application.storage[Key.self]!
    }

    public let logger: Logger
    public let eventLoop: EventLoop
    public let application: Application

    init(_ request: Request) {
        logger = request.logger
        eventLoop = request.eventLoop
        application = request.application
    }

    init(_ application: Application) {
        logger = application.logger
        eventLoop = application.eventLoopGroup.next()
        self.application = application
    }

    public func register<E: Event>(event: E.Type, listeners: _Listener...) {
        register(event: event, listeners: listeners)
    }

    public func register<E: Event>(event: E.Type, listeners: [_Listener]) {
        assert(storage.listeners[E.name] == nil, "Event with name \(E.name) has already been registered")

        storage.listeners[E.name] = listeners
    }

    public func emit<E: Event>(_ event: E) -> EventLoopFuture<Void> {
        let context = ListenerContext(
            application: application,
            logger: logger,
            eventLoop: eventLoop,
            events: self
        )

        guard let listeners = storage.listeners[E.name] else {
            logger.warning("No listeners registered for event '\(E.name)'")
            return context.eventLoop.future()
        }

        logger.info("Event \(E.name) emitted")

        return listeners.map { (listener) in
            if listener._shouldQueue(event, context: context) {
                logger.debug("Performing listener '\(listener.self)'")
                return listener._handle(event, context: context)
            } else {
                logger.debug("Skipping listener '\(listener.self)'")
                return eventLoop.future()
            }
        }
        .flatten(on: context.eventLoop)
    }
    
    /// Directly trigger a listener with an event
    public func trigger<L: Listener, E>(_ listener: L, for event: E, skipShouldQueue: Bool = false) -> EventLoopFuture<Void> where L.EventType == E {
        let context = ListenerContext(
            application: application,
            logger: logger,
            eventLoop: eventLoop,
            events: self
        )

        if skipShouldQueue || listener._shouldQueue(event, context: context) {
            logger.debug("Performing listener '\(listener.self)'")
            return listener._handle(event, context: context)
        } else {
            logger.debug("Skipping listener '\(listener.self)'")
            return eventLoop.future()
        }
    }
}
