import Vapor

extension Application {

    public var events: Events {
        .init(application: self)
    }

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

        public let application: Application

        public func register<E: Event>(event: E.Type, listeners: _Listener...) {
            register(event: event, listeners: listeners)
        }

        public func register<E: Event>(event: E.Type, listeners: [_Listener]) {
            assert(storage.listeners[E.name] == nil, "Event with name \(E.name) has already been registered")

            storage.listeners[E.name] = listeners
        }

        public func trigger<E: Event>(_ event: E, logger: Logger? = nil, on eventLoop: EventLoop? = nil) -> EventLoopFuture<Void> {
            let context = ListenerContext(
                application: application,
                logger: logger ?? application.logger,
                eventLoop: eventLoop ?? application.eventLoopGroup.next()
            )

            guard let listeners = storage.listeners[E.name] else {
                logger?.warning("No listeners registered for event '\(E.name)'")
                return context.eventLoop.future()
            }

            return listeners.map {
                $0._handle(event, context: context)
            }
            .flatten(on: context.eventLoop)
        }
    }
}
