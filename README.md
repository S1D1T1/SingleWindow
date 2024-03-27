# SingleWindow
<img src="https://img.shields.io/badge/Platforms-macOS-blue">



SingleWindow is a SwiftUI library for macOS which simplifies basic window operations which may be obscured with SwiftUI. These operations - open, close, hide, bring front, set title, etc. were more direct under AppKit, hence this library implements them with AppKit calls. SingleWindow is specifically meant to implement a "dashboard" type display of which your app needs exactly 1 copy, and its contents are preserved when it is closed.

## Uses

Use SingleWindow for a "dashboard" type window that you need exactly one of, whose contents don't depend on whether its visible or not.

## Features

- Create persistent windows for SwiftUI views
- Programmatically open or close windows
- Access to the underlying AppKit `NSWindow` object
- Support for multiple SingleWindow instances (1 dashboard, 1 clock,etc)
- Menu command for toggling window visibility, with optional keyboard shortcuts
- Option to create windows on external displays
- Ability to identify the front window - for directing menu commands

## Installation

### Swift Package Manager

SingleWindow can be installed using the Swift Package Manager. Add the package to your Xcode project by selecting `File` > `Add Package Dependencies...` and entering the repository URL:

```
https://github.com/S1D1T1/SingleWindow.git
```

## Basic Usage

Create a SingleWindow object to host your SwiftUI view, by calling `makeSingleWindow`, passing your View in a closure: 

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

### SingleWindow Public Properties

- `isOpen`: A boolean property indicating whether the window is currently open.
- `myWindow`: Direct access to the underlying `NSWindow` object.

### SingleWindow Public Methods

- `open()`: Opens the window.
- `close()`: Closes the window.
- `setWindowTitle(_:String)`: Sets the title of the window.

### SingleWindowCommandGroup: Install Menu Commands

To add a menu item in the "Window" menu for toggling the visibility of your SingleWindow, call `SingleWindowCommandGroup()` within your `.commands` block:

```swift
.commands {
    SingleWindowCommandGroup()
}
```

<p style="margin-left: 50px; margin-right: 50px;">(an aside: "*Which* .commands block", you might ask. Command blocks modify Scenes, and SingleWindow replaces some Scenes. Luckily, commands can apparently be attached to any Scene, to appear in the menu bar. My app hangs its .commands() block off of the "Settings" scene. And what if your app ONLY wants SingleWindows, and has no Scene to hang menu commands from? Good Question. I don't have a general answer)

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
