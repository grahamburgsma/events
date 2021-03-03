import Vapor

public protocol Listener: _Listener {
    associatedtype EventType: Event

    func shouldQueue(_ event: EventType, context: ListenerContext) -> Bool

    func handle(_ event: EventType, context: ListenerContext) -> EventLoopFuture<Void>
}

extension Listener {
    public func shouldQueue(_ event: EventType, context: ListenerContext) -> Bool { true }
}

public protocol _Listener {
    func _shouldQueue<E: Event>(_ event: E, context: ListenerContext) -> Bool
    func _handle<E: Event>(_ event: E, context: ListenerContext) -> EventLoopFuture<Void>
}

extension _Listener where Self: Listener {
    public func _shouldQueue<E>(_ event: E, context: ListenerContext) -> Bool where E : Event {
        shouldQueue(event as! Self.EventType, context: context)
    }
    public func _handle<E>(_ event: E, context: ListenerContext) -> EventLoopFuture<Void> where E : Event {
        handle(event as! Self.EventType, context: context)
    }
}
