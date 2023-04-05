#if compiler(>=5.5) && canImport(_Concurrency)

@available(macOS 12, iOS 15, watchOS 8, tvOS 15, *)
extension Events {

    /// Emit event and perform listeners asynchronously
    public func emit<E: Event>(_ event: E) {
        Task {
            try await emitSync(event)
        }
    }

    /// Emit event and perform listeners syncronously
    public func emitSync<E: Event>(_ event: E) async throws {
        _ = try await emit(event).get()
    }
    
    public func trigger<E: Event>(_ listener: _Listener, for event: E, skipCheck: Bool = false) async throws {
        _ = try await trigger(listener, for: event, skipCheck: skipCheck).get()
    }
}

#endif
