//
//  SingleHostView.swift
//  subclass NSHost
//
//
// ⓒ 2024 tafkad


// a NSHostingView subclass with a keydown override for use with SingleWindow

import Foundation
import SwiftUI

public final class SingleHostingView<Content: View>: NSHostingView<Content> {

  public var onKey:((_ :NSEvent)->Bool)?

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  init(onKey: ((_ :NSEvent)->Bool)? = nil,rootView: Content) {
    self.onKey = onKey
    super.init(rootView: rootView)
  }

  required public init(rootView: Content) {
    super.init(rootView: rootView)
  }

  public override func keyDown(with:NSEvent){

    // we call your keyDown handler here. It must return a Bool indicating if the event was handled

    if let onKey,
       onKey(with){
      return
    }
    super.keyDown(with: with)
  }
 
}
