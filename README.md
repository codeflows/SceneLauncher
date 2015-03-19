![Logo](src/Images.xcassets/AppIcon.appiconset/Icon-60%403x.png)

Ableton Live scene launcher app for iOS 8+, written in Swift as a learning project.

### Setting up Ableton and OSC

See the [SceneLauncher website](http://codeflo.ws/SceneLauncher/) for setup instructions.

### Building

iOS 8+ framework dependencies ([ReactiveCocoa](https://github.com/ReactiveCocoa/ReactiveCocoa), [Cartography](https://github.com/robb/Cartography)) are installed using [Carthage](https://github.com/Carthage/Carthage):

    # Needed if you get the "Multiple matching codesigning identities found" error
    export CODE_SIGN_IDENTITY="..." 
    carthage update

[OSCKit](https://github.com/256dpi/OSCKit) is installed using [CocoaPods](https://github.com/cocoapods/cocoapods)

    pod install

### Copyright

Jari Aarniala, 2015.

License TODO
