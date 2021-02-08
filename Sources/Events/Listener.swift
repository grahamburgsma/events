import Vapor

public protocol Listener: _Listener {
    associatedtype EventType: Event

    static func shouldQueue(_ event: EventType, context: ListenerContext) -> Bool

    static func handle(_ event: EventType, context: ListenerContext) -> EventLoopFuture<Void>
}

extension Listener {
    public static func shouldQueue(_ event: EventType, context: ListenerContext) -> Bool { true }
}

public protocol _Listener {
    static func _shouldQueue<E: Event>(_ event: E, context: ListenerContext) -> Bool
    static func _handle<E: Event>(_ event: E, context: ListenerContext) -> EventLoopFuture<Void>
}

extension _Listener where Self: Listener {
    public static func _shouldQueue<E>(_ event: E, context: ListenerContext) -> Bool where E : Event {
        shouldQueue(event as! Self.EventType, context: context)
    }
    public static func _handle<E>(_ event: E, context: ListenerContext) -> EventLoopFuture<Void> where E : Event {
        handle(event as! Self.EventType, context: context)
    }
}
