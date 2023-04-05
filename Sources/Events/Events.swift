import Vapor

public struct Events {

    final class Storage {
        var listeners = [String: [any Listener]]()
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

    public func register<E: Event>(event: E.Type, listeners: any Listener...) {
        register(event: event, listeners: listeners)
    }

    public func register<E: Event>(event: E.Type, listeners: [any Listener]) {
        assert(storage.listeners[E.name] == nil, "Event with name \(E.name) has already been registered")

        storage.listeners[E.name] = listeners
    }

    /// Emit event and perform listeners asynchronously
    public func emit<E: Event>(_ event: E, performListenersConcurrently: Bool = true) {
        Task {
            try await emitSync(event)
        }
    }

    /// Emit event and perform listeners syncronously
    public func emitSync<E: Event>(_ event: E, performListenersConcurrently: Bool = true) async throws {
        let context = ListenerContext(
            application: application,
            logger: logger,
            eventLoop: eventLoop,
            events: self
        )

        guard let listeners = storage.listeners[E.name] else {
            logger.warning("No listeners registered for event '\(E.name)'")
            return
        }

        logger.info("Event \(E.name) emitted")

        if performListenersConcurrently {
            await withThrowingTaskGroup(of: Void.self) { group in
                for listener in listeners {
                    group.addTask {
                        try await checkAndPerformHandle(listener, for: event, context: context)
                    }
                }
            }
        } else {
            for listener in listeners {
                try await checkAndPerformHandle(listener, for: event, context: context)
            }
        }
    }
    
    /// Directly trigger a listener with an event
    public func trigger<E: Event, L: Listener>(_ listener: L, for event: E, skipCheck: Bool = false) async throws where L.EventType == E {
        let context = ListenerContext(
            application: application,
            logger: logger,
            eventLoop: eventLoop,
            events: self
        )

        if skipCheck {
            logger.debug("Performing listener '\(listener.self)'")
            try await listener.handle(event, context: context)
        } else {
            try await checkAndPerformHandle(listener, for: event, context: context)
        }
    }
    
    private func checkAndPerformHandle<E: Event>(_ listener: some Listener, for event: E, context: ListenerContext) async throws {
        let listener = listener as! any Listener<E>
        if try await listener.shouldHandle(event, context: context) {
            logger.debug("Performing listener '\(listener.self)'")
            try await listener.handle(event, context: context)
        } else {
            logger.debug("Skipping listener '\(listener.self)'")
        }
    }
}
