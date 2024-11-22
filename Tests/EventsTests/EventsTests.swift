import XCTVapor
@testable import Events

final class EventsTests: XCTestCase {
    func testExample() {
        let app = Application(.testing)
        defer { app.shutdown() }

        app.events.register(
            event: TestEvent.self,
            listeners: TestListener()
        )

        app.events.emit(TestEvent())
    }
}

struct TestEvent: Event {}

struct TestListener: Listener {
    func handle(_ event: TestEvent, context: ListenerContext) async throws {

    }
}
