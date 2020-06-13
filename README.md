# Ursus

An Urbit HTTP/`%eyre` client for iOS/macOS in Swift.

## Usage

Ursus is very much a work in progress - better documentation and a demo app to come. Here's a quick sketch for now:

```swift
let ursus = Ursus(url: URL(string: "http://localhost")!, code: "fipfes-fipfes-fipfes-fipfes")
ursus.authenticationRequest().response { response in
    ursus.subscribeRequest(
        ship: "fipfes-fipfes-fipfes-fipfes--fipfes-fipfes-fipfes-fipfes",
        app: "chat-view",
        path: "/primary",
        handler: { event in
            print("On subscribe event:", event)
        }
    )
}
```

## Installation

Ursus can be installed using Cocoapods by adding `pod 'Ursus', '~> 1.0'` to your `Podfile`.

I can probably help set up Carthage or Swift Package Manager support if you need it.

## Todo list

Things that would make this codebase nicer:

- [ ] Add `kebab-case` instance for `JSONDecoder.KeyDecodingStrategy` (there does exist a `snake_case` instance)
- [ ] Write Combine publishers for pokes and subscribes
- [ ] Write our own `EventSource`, supporting a Combine publisher
- [ ] Split off atom manipulation utilities into their own library (see [util.js](https://github.com/urbit/urbit/blob/master/pkg/interface/chat/src/js/lib/util.js), [urbit-ob](https://github.com/urbit/urbit-ob), [urbit-hob](https://github.com/urbit/urbit-hob))

## Other clients

- [channel.js](https://github.com/urbit/urbit/blob/master/pkg/arvo/app/launch/js/channel.js)
- [urlock.py](https://github.com/baudtack/urlock-py/blob/master/urlock/urlock.py)

## Dependencies

- [Alamofire](https://github.com/Alamofire/Alamofire)
- [IKEventSource](https://github.com/inaka/EventSource)
- [UInt128](https://github.com/Jitsusama/UInt128)
