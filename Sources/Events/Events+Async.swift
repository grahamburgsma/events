#if compiler(>=5.5) && canImport(_Concurrency)

@available(macOS 12, iOS 15, watchOS 8, tvOS 15, *)
extension Events {
    
    public func emit<E: Event>(_ event: E) async throws {
        _ = try await emit(event).get()
    }
    
    public func trigger<L: Listener, E>(_ listener: L, for event: E, skipShouldQueue: Bool = false) async throws where L.EventType == E {
        _ = try await trigger(listener, for: event, skipShouldQueue: skipShouldQueue).get()
    }
}

#endif
