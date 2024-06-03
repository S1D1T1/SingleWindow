//
//  SingleHostView.swift
//  subclass NSHost
//
//

import Foundation
import SwiftUI

public final class SingleHostingView<Content: View>: NSHostingView<Content> {

  public var onKey:((_ :NSEvent)->Void)?

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  required init(rootView: Content) {
    super.init(rootView: rootView)
  }

  public override func keyDown(with:NSEvent){
    if let onKey {
      onKey(with)
    }
  }
  /*
   override func mouseDown(with event: NSEvent){
   print("mouse")
   }
   override func acceptsFirstMouse(for event: NSEvent?) -> Bool {
   print("at least you asked")
   return false
   }

   // caution this is called multiple times for a single click - or even for no click at all
   override func  hitTest(_ point: NSPoint) -> NSView {
   print("hitTest:\(point)")
   //print("background: \(inBG)")
   return self
   }
   */
}

