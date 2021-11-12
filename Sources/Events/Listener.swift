import Vapor

public protocol Listener: _Listener {
    associatedtype EventType: Event

    func shouldHandle(_ event: EventType, context: ListenerContext) -> EventLoopFuture<Bool>

    func handle(_ event: EventType, context: ListenerContext) -> EventLoopFuture<Void>
}

extension Listener {
    public func shouldHandle(_ event: EventType, context: ListenerContext) -> EventLoopFuture<Bool> {
        context.eventLoop.future(true)
    }
}

public protocol _Listener {
    func _shouldHandle<E: Event>(_ event: E, context: ListenerContext) -> EventLoopFuture<Bool>
    func _handle<E: Event>(_ event: E, context: ListenerContext) -> EventLoopFuture<Void>
}

extension _Listener where Self: Listener {
    public func _shouldHandle<E>(_ event: E, context: ListenerContext) -> EventLoopFuture<Bool> where E : Event {
        shouldHandle(event as! Self.EventType, context: context)
    }
    public func _handle<E>(_ event: E, context: ListenerContext) -> EventLoopFuture<Void> where E : Event {
        handle(event as! Self.EventType, context: context)
    }
}
