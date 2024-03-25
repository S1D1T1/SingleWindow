//
//  SingleWindowSampleApp.swift
//  SingleWindowSample
//
//  Created on 2/24/24.
//

import SwiftUI
import SingleWindow

@Observable
class SampleAppState {
  static var shared = SampleAppState()
  var snowflakeWindow:SingleWindow?
}

@main
struct SingleWindowSampleApp: App {

  init(){
    SampleAppState.shared.snowflakeWindow = makeSingleWindow(title: "A Unique Window",
                                                             shortcutString: "1", // Cmd-1 to toggle show/hide
                                                             content:{SnowflakeView()})

    // If you'd like the window to start out closed, you can make it later, or make it at launch & close immediately.
    // It doesnt visibly flash on/off, It's never drawn, until app later explicitly opens it.

    // SampleAppState.shared.snowflakeWindow?.close()
  }

  var body: some Scene {
    WindowGroup {
      ContentView()
    }
    .commands {
      SingleWindowCommandGroup()
    }
    /* And you may ask:
     "What if my app ONLY wants SingleWindows, and I have no WindowGroup Scene,
     then where do I hang my menu commands off of?"

     Good Question. I don't have a general answer

     My app hangs its .commands() block off of the "Settings" scene.

     */


  }
}

let snowflakeText =
"""
This is a SingleWindow.
Only one of this window exists.
Can be used as a dashboard, a clock, etc
A SingleWindow can be opened or closed by:
 • standard UI: window close button, Command-W
 • OR Programmatically

The contents of the window are persistent - 'hiding' and 'closing' are equivalent
"""

///  this is the View to install in a SingleWindow
struct SnowflakeView : View {

  var body: some View {
    VStack {
      Image(systemName: "snowflake")
        .padding(.top,50)
      Text(snowflakeText)
        .padding(50)
        .fixedSize()
    }
  }
}


#Preview {
    ContentView()
}


#Preview {
    SnowflakeView()
}
