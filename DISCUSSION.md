# Differences from SwiftUI Window() or WindowGroup() Scene

You don't need to read this document to use SingleWindow. There's no further instructions, but it can help to address what brought you here. In short:  
SwiftUI/ MacOS doesn’t easily enable the window behavior of common mac apps like iTunes or Calendar, where you could close the window and retrieve it with Cmd-0. 


**SingleWindow** offers

- access to NSWindow
- program control to open a window without needing the swiftui environment variable openWindow, which requires an already existing View
- full screen zoom, not enabled with Window() Scene.
- access to the Window's stylemask - to enable/disable zoom, .closable, .miniaturizable, etc
- .isOpen - Easy *factual* app knowledge of whether the window is actually open. Many (unreliable) housekeeping functions tied to .onAppear() can be replaced.
- External monitor support
- Ability to identify the front window, needed for handling menu commands.
- does not save/restore window states across app launch. Your app could easily do this, and I may add the option in the future. But Swiftui's window state restoration gives the app no possibility of control. I don't always want my app to restore the windows.
- Having exactly one - Using Window() Scene allows multiple, and very difficult to enforce this.
- WindowDelegate functions

