import Vapor

extension Request {

    public var events: Application.Events {
        application.events
    }
}
