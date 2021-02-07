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

    public func trigger<E: Event>(_ event: E) -> EventLoopFuture<Void> {
        let context = ListenerContext(
            application: application,
            logger: logger,
            eventLoop: eventLoop
        )

        guard let listeners = storage.listeners[E.name] else {
            logger.warning("No listeners registered for event '\(E.name)'")
            return context.eventLoop.future()
        }

        return listeners.map {
            $0._handle(event, context: context)
        }
        .flatten(on: context.eventLoop)
    }
}
