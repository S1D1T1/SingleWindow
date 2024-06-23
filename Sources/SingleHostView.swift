//
//  SingleHostView.swift
//  subclass NSHost
//
//

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
    if let onKey,
       onKey(with){
      return
    }
    super.keyDown(with: with)
  }
 
}
