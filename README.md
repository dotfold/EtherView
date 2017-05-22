# e t h e r v i e w

An application to view aggregate trade information from Ethereum exchanges. Originally this was designed to use several sources, however integrating WAMP protocol support for Poloniex proved to be more difficult than I had allowed time for, and Bitmex, while it does have a plain WebSocket API, does not currently trade in USD-ETH currency pairs, so this was left off the initial implementation.

This project is using Swift 3 and requires XCode 8.2 or greater.


### Dependencies:

This app is built nearly entirely using RxSwift observable sequences, as such there are several dependencies to make interacting with the iOS control mechanisms much easier.

Dependencies are managed through Carthage, the framework files are committed into source.


### Image sources:

Ethereum logo: https://www.ethereum.org/assets
Bitfinex logo: https://bitfinex.readme.io/v2/docs
