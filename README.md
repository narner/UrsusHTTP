# Ursus

An Urbit client for iOS in Swift.

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