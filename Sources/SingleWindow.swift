//  SingleWindow.swift
//
//  2/7/24.
//

#if os(macOS)
import Foundation
import AppKit
import SwiftUI

/// makeSingleWindow
///
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

    /// intercept a system close action . hide instead
    public func windowWillClose(_ notification: Notification) {
        close()
    }

    func close(){
        myWin.orderOut(nil)
        self.isOpen = false
    }

    /// this is distinct from the title  used in the Show/ Hide Menu
    public func setWindowTitle(_ title:String){

        myWin.title = title
    }

    /// this presumes its in sync with menu title
  /// One subtle behavior , of debatable value:
  ///     if window is visible, but not in front, then bring it front. ie, not strictly a visibility toggle
  ///     but this feels like it matches the user's intent
  ///
    func showHideMenuCommand() {
        let isKeyWindow = NSApp.keyWindow === myWin

        if myWin.isVisible && isKeyWindow {
            close()
        }
        else {
            self.isOpen = true
            myWin.makeKeyAndOrderFront(nil)
        }
    }
}
#elseif os(iOS)
class iPadWindowRep {
    public func setWindowTitle(_ s:String){}
    var isOpen = true
}
#endif

#if os(macOS)


@Observable
 class SingleWindowList {
    static var shared = SingleWindowList()
    var all:[SingleWindow] = []
}

///  Create a Hide <Window Name> / Show <Window Name> Menu item for toggling window viz
///   To put in the Mac "Window" menu, do like this :
///
///           CommandGroup(before: .singleWindowList){
///             SingleWindowMenuList()
///             }

public func SingleWindowMenuList()-> some View {
  return SingleWindowListView()
}

 struct SingleWindowListView : View {
    @State var windowList = SingleWindowList.shared


   var body: some View {
        ForEach(windowList.all, id: \.self) { aWin in
            if let short = aWin.shortcut {
                Button(aWin.isOpen ? aWin.hideString : aWin.showString){
                    aWin.showHideMenuCommand()
                }
                .keyboardShortcut(short)
            }
            else {
                Button(aWin.isOpen ? aWin.hideString : aWin.showString){
                    aWin.showHideMenuCommand()
                }
            }
        }
    }
}


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
#endif
