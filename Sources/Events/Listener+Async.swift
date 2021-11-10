import Vapor

#if compiler(>=5.5) && canImport(_Concurrency)

public protocol AsyncListener: _Listener {
    associatedtype EventType: Event

    @available(macOS 12, iOS 15, watchOS 8, tvOS 15, *)
    func handle(_ event: EventType, context: ListenerContext) async throws
}

extension AsyncListener {
    public func shouldQueue(_ event: EventType, context: ListenerContext) -> Bool { true }
}

extension AsyncListener {
    
    @available(macOS 12, iOS 15, watchOS 8, tvOS 15, *)
    public func _handle(_ event: EventType, context: ListenerContext) -> EventLoopFuture<Void> {
        let promise = context.eventLoop.makePromise(of: Void.self)
        promise.completeWithTask {
            try await self.handle(event, context: context)
        }
        return promise.futureResult
    }
}

#endif
