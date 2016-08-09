# Ursus

An Urbit HTTP client for iOS in Swift.

## Links

- [Urbit web](http://urbit.org/docs/using/web/)
- [`%eyre` specification](http://urbit.org/docs/arvo/internals/eyre/specification/)

## Usage

Ursus is very much a work in progress, and with `%eyre`'s HTTP interface subject to change this is mostly just a proof of concept for now. However, authentication is supported, and you can send messages to apps running on your ship.

To get set up, first you need to set the `baseURL` on the Ursus client to the URL your planet is being served on. This might be something like `"https://pittyp-pittyp.urbit.org"` or `"http://localhost:8080"`. 

```swift
Ursus.baseURL = "https://pittyp-pittyp.urbit.org"
```

Then, we can request an Auth object and sign in, using your ship's name and code (you can print out the code in dojo, using `+code`).

```swift
let ship = "pittyp-pittyp"
let code = "xxxxxx-xxxxxx-xxxxxx-xxxxxx"

Ursus.GETAuth().then { auth -> Promise<Auth> in
    return Ursus.PUTAuth(oryx: auth.oryx!, ship: ship, code: code)
}.then { auth in
    self.auth = auth // Save the authentication object somewhere
    print("Signed in successfully")
}.error { error in
    print("Something went wrong", error.localizedDescription)
}
```

Easy! Signing out is about as simple:

```swift
let ship = "pittyp-pittyp"
let oryx = self.auth!.oryx!

Ursus.DELETEAuth(oryx: oryx, ship: ship).then {
    self.auth = nil // Throw away our authentication object
    print("Signed out successfully")
}.error { error in
    print("Something went wrong", error.localizedDescription)
}
```

Sending a message is also straightforward:

```swift
let appl = "examples-click"
let mark = "examples-click-clique"
let xyro = "click"
let wire = "/"

let auth = self.auth!

Ursus.POSTTo(appl: appl, mark: mark, xyro: xyro, wire: wire, auth: auth).then {
    print("Success")
}.error { error in
    print("Something went wrong", error.localizedDescription)
}
```

## Demo application

There is a demo application in the `Ursus Demo` folder. You will need to open `AppDelegate.swift` and make sure `Ursus.baseURL` is set.

The application can [authenticate](http://urbit.org/docs/arvo/internals/eyre/specification/#-1-3-authentication) your session, and [send a message](http://urbit.org/docs/arvo/internals/eyre/specification/#-1-4-messaging) to the [`%examples-click`](https://github.com/urbit/examples/tree/d3ac46d8f68335cb4dcf178e3953a829655d9a82/gall/click) application, if you have it running.

![Ursus Demo screenshot](/Ursus Demo/Screenshot.png?raw=true "Ursus Demo screenshot")

## Cocoapods

Ursus can be installed by adding `pod 'Ursus', '~> 0.1'` to your `Podfile`.

I can set up Carthage support if you need it.

## Next steps/goals/ideas

- Set up [subscriptions](http://urbit.org/docs/arvo/internals/eyre/specification/#-1-5-subscriptions)

- Persistent authorization (using SSKeychain/SAMKeychain) and clean up ship/oryx vs auth arguments

- Generalised support for phonetic base strings (perhaps object that conforms to `StringLiteralConvertible`, enum for galaxies, stars etc. Might be best to wait until after the great renaming, though)

- Easy specification of ship/event/desk when making a request (e.g.: `"http://localhost:8080/~pittyp-pittyp/sandbox/0"`)

- Mark specification

- Clean usage of `/~/as`, `/~/am`, `/~/to`, `/~/of` etc

- Figure out what to do about Status objects (`{ok: true}`). Should they be handled earlier in the `responseObject` chain? Might need some special handling of `500` responses etc...

## Dependencies

- [Alamofire](https://github.com/Alamofire/Alamofire)
- [AlamofireObjectMapper](https://github.com/tristanhimmelman/AlamofireObjectMapper)
- [ObjectMapper](https://github.com/Hearst-DD/ObjectMapper)
- [PromiseKit](https://github.com/mxcl/PromiseKit) (quite opinionated, I'd like to remove this eventually...)
