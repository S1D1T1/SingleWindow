// SingleWindow.swift
//
//  2/7/24.
//
// clean simple API, for normies
//
// ⓒ 2024 tafkad

#if os(macOS)

import Foundation
import AppKit
import SwiftUI

/// Creates a macOS window hosting a SwiftUI view.
///
/// - Parameters:
///   - title: The title that appears in the title bar and the "Window" menu.
///   - external: If `true`, the window is placed on the external screen if one exists. Default is `false`.
///   - shortcutString: A one-character string representing the keyboard shortcut for toggling the window visibility via the menu item. For example, "0" means Command-0 toggles the window. Default is `nil`.
///   - rect: The bounding rectangle for the window. Default is `defaultRect`.
///   - content: A closure returning the SwiftUI view to be hosted by the window.
///
/// - Returns: A `SingleWindow` object.
///  ## Why a helper function:
///  It works perfectly.  A helper function isolates the class from being Generic typed, which generates complexity
public func makeSingleWindow<V:View>(title: String,
                                     external:Bool = false,
                                     shortcutString:String? = nil,
                                     rect:NSRect = defaultRect,
                                     onKey:MainActorEventHandler? = nil,
                                     onScrollWheel:MainActorEventHandler? = nil,
                                     onMinimize: (() -> Void)? = nil,
                                     onRestore: (() -> Void)? = nil,
                                     content: @escaping () -> V) -> SingleWindow {
  let window = SingleWindow(
    title: title,
    external:external,
    shortcutString:shortcutString,
    rect:rect,
    onMinimize: onMinimize,
    onRestore: onRestore
  )
  if let onKey {
    window.myWin.contentView = SingleHostingView(onKey:onKey, onScrollWheel:onScrollWheel, rootView: content())
  }
  else if let onScrollWheel {
    window.myWin.contentView = SingleHostingView(onKey:nil, onScrollWheel:onScrollWheel, rootView: content())
  }
  else {
    window.myWin.contentView = NSHostingView(rootView: content())

  }
  if !title.isEmpty {
  //  window.myWin.setFrameUsingName(title)
    window.myWin.restoreFrameToMatchingScreen(withName: title)
  }
  return window
}

public let defaultRect = NSRect(x: 200, y: 200, width: 620, height: 615)


/// Implement an AppKit window for use in SwiftUI Projects
/// This window hosts a SwiftUI View, but does *not* exist in the `Scene` Framework
@Observable public class SingleWindow : NSObject, NSWindowDelegate {
  var title:String
  public var myWin:NSWindow
  var showString:String
  var hideString:String
  public var isOpen = false
  var shortcut:KeyEquivalent?
  var onMinimize: (() -> Void)?
  var onRestore: (() -> Void)?

  /// Initializes a new instance of the `SingleWindow` class.
  ///
  /// - Parameters:
  ///   - title: The title of the window.
  ///   - external: If `true`, the window is placed on the external screen if one exists. Default is `false`.
  ///   - shortcutString: A one-character string representing the keyboard shortcut for toggling the window visibility via the menu item. Default is `nil`.
  ///   - rect: The bounding rectangle for the window. Default is `defaultRect`.
  init(
    title: String,
    external:Bool = false,
    shortcutString:String? = nil,
    rect:NSRect = defaultRect,
    onMinimize: (() -> Void)? = nil,
    onRestore: (() -> Void)? = nil
  ) {
    self.title = title
    self.showString = "Show \(title)" //  this actually prevents memory leaks, compared to generating dynamically
    self.hideString = "Hide \(title)" //
    self.myWin = makeWindow(with: title, external:external, rect: rect)
    self.isOpen = true
    self.onMinimize = onMinimize
    self.onRestore = onRestore
    if let firstchar = shortcutString?.first {
      self.shortcut = KeyEquivalent(firstchar)
    }

    super.init()
    self.myWin.delegate = self

    SingleWindowList.shared.all.append(self)
  }

  /// Internal function that intercepts a system close action, to hide instead. Public only due to compiler requirement
  /// - Parameter notification: The notification object containing information about the close action.
  public func windowWillClose(_ notification: Notification) {
    close()
  }

  public func windowDidMiniaturize(_ notification: Notification) {
    if let onMinimize {
      onMinimize()
    }
  }

  public func windowDidDeminiaturize(_ notification: Notification) {
    if let onRestore {
      onRestore()
    }
  }

  // MARK: Public API

  /// open the window if it was closed
  public func open(){
    self.isOpen = true
    myWin.makeKeyAndOrderFront(nil)
  }

  /// close (hide, actually) the window
  public func close(){
    myWin.orderOut(nil)
    self.isOpen = false
  }

  /// Sets the title of the window.
  ///
  /// - Parameter title: The new title for the window.
  public func setWindowTitle(_ title:String){
    /// this title is only used in the Window's title bar. It's distinct from the title used in the Window Menu †
    myWin.title = title
  }

  public func toggleFullScreen() {
    myWin.toggleFullScreen(nil)
  }

  public func isFullScreen() -> Bool {
    myWin.styleMask.contains(.fullScreen)
  }

    /// Toggles the visibility of the window.
  /// this presumes its in sync with menu title
  /// One subtle behavior , of debatable value:
  ///     if window is visible, but not in front, then bring it front. ie, not strictly a visibility toggle
  ///     but this feels like it matches the user's intent
  ///
  func toggleVisibility() {
    let isKeyWindow = NSApp.keyWindow === myWin

    if myWin.isVisible && isKeyWindow {
      close()
    }
    else {
      open()
    }
  }

  }

///  Creates  "Hide <Window Name> / Show <Window Name>" Menu items for toggling window visibility
///
///   To put these in the Mac "Window" menu, add this to your `.commands` block :
///```
///           SingleWindowCommandGroup()
///```
public struct SingleWindowCommandGroup: Commands {
  public init(){}
    public var body: some Commands {
        CommandGroup(before: .windowList) {
          SingleWindowListView()
              }
          }
      }

/// A class that manages a shared list of `SingleWindow` instances.
@Observable
 class SingleWindowList {
    static var shared = SingleWindowList()
    var all:[SingleWindow] = []

   private init(){

     NotificationCenter.default.addObserver(self,
                                            selector: #selector(saveWindowStates),
                                            name: NSApplication.willTerminateNotification,
                                            object: nil)
   }

   @objc private func saveWindowStates(_ notification: Notification) {
     for window in all  where !window.title.isEmpty{
         window.myWin.saveFrame(usingName: window.title)
     }
   }


}

/// A SwiftUI view that displays menu items for toggling the visibility of `SingleWindow` instances.
struct SingleWindowListView : View {
    @State var windowList = SingleWindowList.shared

   var body: some View {
        ForEach(windowList.all, id: \.self) { aWin in
          // Menu command with shortcut
            if let short = aWin.shortcut {
                Button(aWin.isOpen ? aWin.hideString : aWin.showString){
                    aWin.toggleVisibility()
                }
                .keyboardShortcut(short)
            }
            // menu command without shortcut
            else {
                Button(aWin.isOpen ? aWin.hideString : aWin.showString){
                    aWin.toggleVisibility()
                }
            }
        }
    }
}

/// Creates an `NSWindow` instance with the specified parameters.
///
/// - Parameters:
///   - title: The title of the window.
///   - external: If `true`, the window is placed on the external screen if one exists. Default is `false`.
///   - rect: The bounding rectangle for the window. Default is `defaultRect`.
///
/// - Returns: An `NSWindow` instance.
/// When you wanna get sh*t  done, AppKit
func makeWindow(with title: String, 
                external:Bool = false,
                rect:NSRect = defaultRect,
                onMouseDown:((_ :NSEvent)->Bool)? = nil) -> NSWindow {
    var destScreen:NSScreen

    let window = NSWindow(
        contentRect: NSRect(x: 0, y: 0, width: 0, height: 0),
        styleMask: [.closable, .titled, .resizable,.miniaturizable],
        backing: .buffered,
        defer: false)

    if external {  /// place on second screen, full size
        guard NSScreen.screens.last != nil
        else {
            print("Failed to find last display")
            return window
        }
        destScreen = NSScreen.screens.last!
        window.setFrame(destScreen.frame, display: true)
    }
    else { /// place on primary screen
        destScreen = NSScreen.screens.first!
        window.setFrame(rect, display: true)
    }
    window.level = NSWindow.Level.normal

    window.isReleasedWhenClosed = false
    window.title = title
    window.standardWindowButton(.closeButton)?.isHidden = false
    window.orderFront(nil)
    return window
}


extension NSWindow {
  func restoreFrameToMatchingScreen(withName windowName: String) {
    // First get the stored frame data
    guard let frameData = UserDefaults.standard.string(forKey: "NSWindow Frame " + windowName) else {
      return
    }

    let components = frameData.components(separatedBy: " ").compactMap { Double($0) }
    guard components.count >= 8 else { return }

    let storedWindowX = components[0]
    let storedWindowY = components[1]
    let storedWindowWidth = components[2]
    let storedWindowHeight = components[3]
    let storedScreenOriginX = components[4]
    let storedScreenOriginY = components[5]
    let storedScreenWidth = components[6]
    let storedScreenHeight = components[7]

    // Find the matching screen based on dimensions
    let matchingScreen = NSScreen.screens.first { screen in
      let fullFrame = screen.frame
      // Use visibleFrame for height since that accounts for menu bar
      let visibleFrame = screen.visibleFrame
      return abs(fullFrame.width - storedScreenWidth) < 1 &&
      abs(visibleFrame.height - storedScreenHeight) < 1 &&
      abs(fullFrame.minX - storedScreenOriginX) < 1 &&
      abs(visibleFrame.minY - storedScreenOriginY) < 1
    }

    if let targetScreen = matchingScreen {
      // Calculate the new frame relative to the target screen
      let newFrame = NSRect(
        x: targetScreen.frame.minX + (storedWindowX - storedScreenOriginX),
        y: targetScreen.frame.minY + (storedWindowY - storedScreenOriginY),
        width: storedWindowWidth,
        height: storedWindowHeight
      )

      // First call setFrameUsingName to restore other window properties
      self.setFrameUsingName(windowName)

      // Then adjust the frame to the correct screen
      self.setFrame(newFrame, display: true)
    } else {
      // Fallback to standard restoration if we can't find the matching screen
      self.setFrameUsingName(windowName)
    }
  }
}


#endif  //  macos
