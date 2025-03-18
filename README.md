# SingleWindow
<img src="https://img.shields.io/badge/Platforms-macOS-blue">



SingleWindow is a SwiftUI library for macOS which simplifies standard Mac window operations which may be obscured in pure SwiftUI. Your window hosts a SwiftUI View **and** has use of traditional operations such as open, close, hide, bring front, set title, etc. which were more direct under AppKit. Hence this library implements them with AppKit calls - explicitly, windows created via this library do not live in the `Scene` framework. SingleWindow makes it simple to create a "dashboard" type display of which your app needs exactly 1 (Single) copy, and its contents are preserved when it is closed.

## Uses

Use SingleWindow for a "dashboard" type window that you need exactly one of, whose contents don't depend on whether its visible or not.

## Features

- Create persistent windows for SwiftUI views
- Programmatically open or close windows
- Restore windows to their locations from previous app run - keyed on window name.
    - also attempts to restore to the screen that window was on, if it is found
- Programmatic control of window zooming
- Access to the underlying AppKit `NSWindow` object
- Support for multiple SingleWindow instances (1 dashboard, 1 clock,etc)
- Menu command for toggling window visibility, with optional keyboard shortcuts
    - Menu item is correctly titled "Hide <yourWin>" or "Show <yourWin>" based on its visibility.
- Option to create windows on external displays
- Auto save/restore window positions
- Ability to identify the front window - eg, for directing menu commands
- Option to create floating utility window which stays above other windows
- Some Event handling which requires NSHostView
    - Scroll Wheel handler 
    - Optional Key event handler, which catches some keyDowns that get lost via the nuances of SwiftUI focus management

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
    shortcutString: "1"    // Command-1 toggles the Groovy Clock
) {
    GroovyClockView()
}
```

### `makeSingleWindow` Parameters

- `title:String` The title of the window.
- `external:Bool` Optional boolean indicating whether the window should be opened on an external display, if available. default:false
- `shortcutString:String` Optional string representing the keyboard shortcut for toggling the window visibility. default: no keyboard shortcut
- `rect:NSRect` Optional initial rectangle for the window.
- `onKey:((_ :NSEvent)->Bool)?` Optional key event handler
- `onScroll:((_ :NSEvent)->Bool)?` Optional scroll event handler
- `content:() -> V` A closure returning your SwiftUI view to be hosted

### SingleWindow Public Properties

- `isOpen`: A boolean property indicating whether the window is currently open.
- `myWindow`: Direct access to the underlying `NSWindow` object.

### SingleWindow Public Methods

- `open()`: Opens the window.
- `close()`: Closes the window.  
  *Note* open/close do not dispose of the window or any contents, they just hide. This will not generate .onAppear messages in your SwiftUI Views.
- `setWindowTitle(_:String)`: Sets the title of the window.

### SingleWindowCommandGroup: Install Menu Commands

To add a menu item in the "Window" menu for toggling the visibility of your SingleWindow, call `SingleWindowCommandGroup()` within your `.commands` block:

```swift
.commands {
    SingleWindowCommandGroup()
}
```

    (an aside: "*Which* .commands block", you might ask. Command blocks modify Scenes, and SingleWindow replaces some Scenes. Luckily, commands can apparently be attached to any Scene, to appear in the menu bar. My app hangs its .commands() block off of the "Settings" scene. And what if your app ONLY wants SingleWindows, and has no Scene to hang menu commands from? Good Question. I don't have a general answer)

The menu item will be created with the format "Show/Hide `<Your Window Title>`". If a `shortcutString` was provided when creating the SingleWindow, the menu item will also have the corresponding keyboard shortcut.

<img width="385" alt="Unknown" src="https://github.com/S1D1T1/SingleWindow/assets/156350598/645fee01-17dc-45e4-981a-0bd67dcd60bd">


## Examples

You can also create a SingleWindow on an external display, if available:

```swift
let externalSingleWindow = makeSingleWindow(
    title: "Groovy Clock, Stage Left",
    external: true,
    shortcutString: "1"  // Command-1 toggles the Groovy Clock
) {
    GroovyClockView()
}
```
Apply a menu command to the front window, by examining your SingleWindow objects, using AppKit properties
```swift
        // Command-Option-T toggles toolbar on the front window
        Button("Toggle Toolbar"){
          if appWindowStates.imageBrowserWindow.myWin.isKeyWindow {
            ImageBrowserState.shared.showToolbar.toggle()
          }
          else if appWindowStates.galleryWindow.myWin.isKeyWindow {
            GalleryWindowState.shared.showToolbar.toggle()
          }
        }.keyboardShortcut("t",modifiers: [.command,.option])
```

## License

SingleWindow is released under the [MIT License](LICENSE).
