import Vapor

#if compiler(>=5.5) && canImport(_Concurrency)

@available(macOS 12, iOS 15, watchOS 8, tvOS 15, *)
public protocol AsyncListener: _Listener {
    associatedtype EventType: Event
    
    func shouldQueue(_ event: EventType, context: ListenerContext) -> Bool

    func handle(_ event: EventType, context: ListenerContext) async throws
}

@available(macOS 12, iOS 15, watchOS 8, tvOS 15, *)
extension AsyncListener {
    public func shouldQueue(_ event: EventType, context: ListenerContext) -> Bool { true }
}

@available(macOS 12, iOS 15, watchOS 8, tvOS 15, *)
extension _Listener where Self: AsyncListener {
    
    public func _shouldQueue<E>(_ event: E, context: ListenerContext) -> Bool where E : Event {
        shouldQueue(event as! Self.EventType, context: context)
    }
    
    public func _handle<E>(_ event: E, context: ListenerContext) -> EventLoopFuture<Void> where E : Event {
        let promise = context.eventLoop.makePromise(of: Void.self)
        promise.completeWithTask {
            try await self.handle(event as! Self.EventType, context: context)
        }
        return promise.futureResult
    }
}

#endif
