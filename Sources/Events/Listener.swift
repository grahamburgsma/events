import Vapor

public protocol Listener {
    associatedtype EventType: Event

    func handle(_ event: EventType, context: ListenerContext) -> EventLoopFuture<Void>
}

struct AnyListener<E: Event>: Listener {
    private let _handle: (_ event: E, _ context: ListenerContext) -> EventLoopFuture<Void>

    init<Factory: Listener>(_ carFactory: Factory) where Factory.EventType == E {
        _handle = carFactory.handle
    }

    func handle(_ event: E, context: ListenerContext) -> EventLoopFuture<Void> {
        return _handle(event, context)
    }
}
