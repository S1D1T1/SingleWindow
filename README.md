# SingleWindow

SingleWindow is a SwiftUI library for macOS that provides a state-preserving window for your SwiftUI views. SingleWindow is explicitly tasked with enabling traditional AppKit window functionality in a SwiftUI MacOS app. It gives you app control over opening, closing, or naming your window. Additionally the user has all the control they'd normally have to open and close the window via the window controls and menu items.

## Uses

Use SingleWindow for a "dashboard" type window that you need exactly one of, whose contents don't depend on whether its visible or not.

## Features

- Create persistent windows for SwiftUI views
- Programmatically open or close windows
- Support for multiple SingleWindow instances (1 dashboard, 1 clock,etc)
- Menu command for toggling window visibility, with optional keyboard shortcuts
- Option to create windows on external displays
- Access to the underlying AppKit `NSWindow` object

## Installation

### Swift Package Manager

SingleWindow can be installed using the Swift Package Manager. Add the package to your Xcode project by selecting `File` > `Add Packages` and entering the repository URL:

```
https://github.com/S1D1T1/SingleWindow.git
```

## Usage

Create a SingleWindow that hosts your SwiftUI view, by calling `makeSingleWindow` 

```swift
import SingleWindow

// My app needs a groovy clock window
let groovyClockWindow = makeSingleWindow(
    title: "Groovy Clock",
    shortcutString: "1"
) {
    GroovyClockView()
}
```

### `makeSingleWindow` Parameters

- `title:String` The title of the window.
- `external:Bool` Optional boolean indicating whether the window should be opened on an external display, if available. default:false
- `shortcutString:String` Optional string representing the keyboard shortcut for toggling the window visibility. default: no keyboard shortcut
- `rect:NSRect` Optional initial rectangle for the window.
- `content:() -> V` A closure returning your SwiftUI view to be hosted

### Public Properties

- `isOpen`: A boolean property indicating whether the window is currently open.
- `myWindow`: Direct access to the underlying `NSWindow` object.

### Public Methods

- `open()`: Opens the window.
- `close()`: Closes the window.
- `setWindowTitle(_:String)`: Sets the title of the window.

### Install Menu Command

To add a menu item in the "Window" menu for toggling the visibility of your SingleWindow, call `SingleWindowCommandGroup()` within your `.commands` block:

```swift
.commands {
    SingleWindowCommandGroup()
}
```

The menu item will be created with the format "Show/Hide `<Your Window Title>`". If a `shortcutString` was provided when creating the SingleWindow, the menu item will also have the corresponding keyboard shortcut.

<img width="385" alt="Unknown" src="https://github.com/S1D1T1/SingleWindow/assets/156350598/645fee01-17dc-45e4-981a-0bd67dcd60bd">


## Example

You can also create a SingleWindow on an external display, if available:

```swift
let externalSingleWindow = makeSingleWindow(
    title: "Groovy Clock, Stage Left",
    external: true,
    shortcutString: "1"
) {
    GroovyClockView()
}
```

## License

SingleWindow is released under the [MIT License](LICENSE).
