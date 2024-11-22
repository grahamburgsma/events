import Vapor

public protocol Listener<EventType>: Sendable {
    associatedtype EventType: Event

    func shouldHandle(_ event: EventType, context: ListenerContext) async throws -> Bool
    func handle(_ event: EventType, context: ListenerContext) async throws
}

extension Listener {
    public func shouldHandle(_ event: EventType, context: ListenerContext) async throws -> Bool { true }
}
