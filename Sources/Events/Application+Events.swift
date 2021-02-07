import Vapor

extension Application {

    public var events: Events {
        .init(self)
    }
}
