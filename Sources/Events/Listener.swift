import Vapor

public protocol Listener: _Listener {
    associatedtype EventType: Event

    func handle(_ event: EventType, context: ListenerContext) -> EventLoopFuture<Void>
}

public protocol _Listener {
    func _handle<E: Event>(_ event: E, context: ListenerContext) -> EventLoopFuture<Void>
}

extension _Listener where Self: Listener {
    public func _handle<E>(_ event: E, context: ListenerContext) -> EventLoopFuture<Void> where E : Event {
        handle(event as! Self.EventType, context: context)
    }
}
