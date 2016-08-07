# Ursus

An Urbit client for iOS in Swift.

## Usage

For now, Ursus only supports authentication with your planet.

First, you need to set the `baseURL` on the Ursus client to the URL your planet is being served on. This might be something like `"https://pittyp-pittyp.urbit.org"` or `"http://localhost:8080"`. 

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

Ursus.DELETEAuth(oryx: oryx, ship: ship).then { auth in
    self.auth = nil // Throw away our authentication object
    print("Signed out successfully")
}.error { error in
    print("Something went wrong", error.localizedDescription)
}
```

## Next steps

Set up the ability to send messages to a given app. The [`%click` example app](https://github.com/urbit/examples/tree/master/gall/click) is likely to be a good start.

## Dependecies

## Demo application

To run the demo application, you will need to open `AppDelegate.swift` and 

## Wishlist

- Carthage
- Place to stash Auth
- Support for those `{ok: true}` ok/error responses
- Demo app (which works with `pod Ursus try`)
- Phonetic base validation (enum + StringLiteralConvertible)
- Should be able to specify ship/event/desk before a request
- Persistent auth with SSKeychain/SAMKeychain
- Generalised support for galaxies, stars, planets etc
- Send messages to individual apps
- Find better way to handle base URL
- Error cases:
    - Invalid response
    - Planet offline
    - Code incorrect
    - Phonetic base invalid
- Marks, the basic paths like `/~/as`, `/~/am`, `/~/to`, `/~/of` etc