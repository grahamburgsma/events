import Vapor

public struct Events {

    final class Storage {
        var listeners = [String: [_Listener.Type]]()
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

    public func register<E: Event>(event: E.Type, listeners: _Listener.Type...) {
        register(event: event, listeners: listeners)
    }

    public func register<E: Event>(event: E.Type, listeners: [_Listener.Type]) {
        assert(storage.listeners[E.name] == nil, "Event with name \(E.name) has already been registered")

        storage.listeners[E.name] = listeners
    }

    public func emit<E: Event>(_ event: E) -> EventLoopFuture<Void> {
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
            if $0._shouldQueue(event, context: context) {
                return $0._handle(event, context: context)
            } else {
                return eventLoop.future()
            }
        }
        .flatten(on: context.eventLoop)
    }
}
