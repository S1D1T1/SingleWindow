//
// SingleWindow.swift
//
//  2/7/24.
//
// part of what may become a general utility library for swiftui, focused on
// clean simple API, for normies
//


import Foundation
import AppKit
import SwiftUI

/// makeSingleWindow
///
/// Create a MacOS window hosting a SwiftUI view, which is supplied by the client code
///
/// - Parameters:
///   - title: The title which appears in the Title bar, and the "Window" menu.
///   - external: If true, place on the external screen if it exists.
///   - shortcutString: A one character string with the keyboard shortcut for its  menu item. Ie, "0" means Command-0 toggles the window
///   - rect: window's bounding rectangle
///   - content: the View hosted by the window
///
/// - Returns: a SingleWindow object
///
///  ## Why a helper function:
///  It works perfectly.  A helper function isolates the class from being Generic typed, which propagates into a whole lot of work
///  just to mollify the compiler, with no benefit to the user

public func makeSingleWindow<V:View>(title: String,
                              external:Bool = false,
                              shortcutString:String? = nil,
                              rect:NSRect = defaultRect,
                              content: @escaping () -> V) -> SingleWindow {
    let window = SingleWindow(title: title, external:external, shortcutString:shortcutString, rect:rect)
    window.myWin.contentView = NSHostingView(rootView: content())
    return window
}

public let defaultRect = NSRect(x: 200, y: 200, width: 620, height: 615)


/// Implement an AppKit window for use in SwiftUI Projects
///
///

@Observable
public class SingleWindow : NSObject, NSWindowDelegate {
  var title:String
  var myWin:NSWindow
  var showString:String
  var hideString:String
  public var isOpen = false
  var shortcut:KeyEquivalent?

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

  /// Internal function that intercepts a system close action, to hide instead. 
  public func windowWillClose(_ notification: Notification) {
    close()
  }

  // MARK: Public API

  /// open the window if it was closed
  public func open(){
    self.isOpen = true
    myWin.makeKeyAndOrderFront(nil)
  }

  /// close the window -  really just hide it
  public func close(){
    myWin.orderOut(nil)
    self.isOpen = false
  }

  /// this title is only used in the Window's title bar. It's distinct from the title used in the Window Menu
  public func setWindowTitle(_ title:String){
    myWin.title = title
  }

  // MARK: Internal

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


func SingleWindowCommandGroup() -> any Commands {
  return            CommandGroup(before: .singleWindowList){
    SingleWindowListView()
  }
}

@Observable
 class SingleWindowList {
    static var shared = SingleWindowList()
    var all:[SingleWindow] = []
}

///  Create  "Hide <Window Name> / Show <Window Name>" Menu items for toggling window visibility
///
///   To put in the Mac "Window" menu :
///```
///           CommandGroup(before: .singleWindowList){
///             SingleWindowMenuList()
///             }
///```
/// Implemented this feature via a func returning the View, instead making the View itself public.
/// a public View struct drags unneeded other stuff public along with it.
///
func SingleWindowMenuList()-> some View {
  return SingleWindowListView()
}

struct SingleWindowListView : View {
    @State var windowList = SingleWindowList.shared

   var body: some View {
        ForEach(windowList.all, id: \.self) { aWin in
            if let short = aWin.shortcut {
                Button(aWin.isOpen ? aWin.hideString : aWin.showString){
                    aWin.toggleVisibility()
                }
                .keyboardShortcut(short)
            }
            else {
                Button(aWin.isOpen ? aWin.hideString : aWin.showString){
                    aWin.toggleVisibility()
                }
            }
        }
    }
}


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
    if NSScreen.screens.count > 1 && external {
        window.toggleFullScreen(nil)  //  † this shouldn't be default behavior
    }
    return window
}
