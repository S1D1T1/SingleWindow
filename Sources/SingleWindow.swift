// SingleWindow.swift
//
//  2/7/24.
//
// clean simple API, for normies
//
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
                              content: @escaping () -> V) -> SingleWindow {
    let window = SingleWindow(title: title, external:external, shortcutString:shortcutString, rect:rect)
    window.myWin.contentView = SingleHostingView(rootView: content())
    return window
}

public let defaultRect = NSRect(x: 200, y: 200, width: 620, height: 615)


/// Implement an AppKit window for use in SwiftUI Projects
/// This window hosts a SwiftUI View, but does *not* exist in the `Scene` Framework
@Observable
public class SingleWindow : NSObject, NSWindowDelegate {
  var title:String
  public var myWin:NSWindow
  var showString:String
  var hideString:String
  public var isOpen = false
  var shortcut:KeyEquivalent?

  /// Initializes a new instance of the `SingleWindow` class.
  ///
  /// - Parameters:
  ///   - title: The title of the window.
  ///   - external: If `true`, the window is placed on the external screen if one exists. Default is `false`.
  ///   - shortcutString: A one-character string representing the keyboard shortcut for toggling the window visibility via the menu item. Default is `nil`.
  ///   - rect: The bounding rectangle for the window. Default is `defaultRect`.
  init(title: String, external:Bool = false, shortcutString:String? = nil, rect:NSRect = defaultRect) {
    self.title = title
    self.showString = "Show \(title)" //  this actually prevents memory leaks, compared to generating dynamically
    self.hideString = "Hide \(title)" //
    self.myWin = makeWindow(with: title, external:external, rect: rect)
    self.isOpen = true
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

  // MARK: Internal

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

  public func toggleFullScreen() {
    myWin.toggleFullScreen(nil)
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
func makeWindow(with title: String, external:Bool = false, rect:NSRect = defaultRect) -> NSWindow {
    var destScreen:NSScreen

    let window = NSWindow(
        contentRect: NSRect(x: 0, y: 0, width: 0, height: 0),
        styleMask: [.closable, .titled, .resizable],
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
#endif  //  macos
