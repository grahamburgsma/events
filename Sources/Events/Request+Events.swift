import Vapor

extension Request {

    public var events: Events {
        .init(self)
    }
}
