# Events

Events provides a simple observer pattern to subscribe and listen for events in your Vapor application. This idea is based on [Laravel Events](https://laravel.com/docs/events).

## Registering Events & Listeners

```swift
// Event
struct ThingHappened: Event { ... }

// Listeners
struct NofifyThing: Listener { ... }
struct SendEmailAboutThing: Listener { ... }

app.events.register(
    ThingHappened.self, 
    listeners: [
        NotifyThing.self, 
        SendEmailAboutThing.self
    ]
)
```

## Emitting Events

```swift
let event = ThingHappened()
req.events.emit(event)
```
