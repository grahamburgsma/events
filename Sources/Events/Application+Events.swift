import Vapor

extension Application {

    public var events: Events {
        .init(application: self)
    }

    public struct Events {

        final class Storage {
            var listeners = [String: [Any]]()

            public init(_ application: Application) {
            }
        }

        struct Key: StorageKey {
            typealias Value = Storage
        }

        var storage: Storage {
            if application.storage[Key.self] == nil {
                application.storage[Key.self] = .init(application)
            }
            return application.storage[Key.self]!
        }

        public let application: Application


        public func register<Event, L: Listener>(event: Event.Type, listeners: [L]) where L.EventType == Event {
            storage.listeners[Event.name] = listeners
        }

        public func trigger<E: Event>(_ event: E, logger: Logger? = nil, on eventLoop: EventLoop? = nil) -> EventLoopFuture<Void> {
            let listeners = storage.listeners[E.name] as! [AnyListener<E>]

            let context = ListenerContext(
                application: application,
                logger: logger ?? application.logger,
                eventLoop: eventLoop ?? application.eventLoopGroup.next()
            )

            return listeners.map {
                $0.handle(event, context: context)
            }
            .flatten(on: context.eventLoop)
        }
    }
}
