//
//  ContentView.swift
//  SingleWindowSample
//
//

import SwiftUI
import SingleWindow

struct ContentView: View {
  @State var windowTitle=""
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("\nThis is a normal SwiftUI WindowGroup Window\n Wired up to the 'New' Menu command \n")
          
          // demo :
          // 1) programmatic opening and closing of SingleWindow
          // 2) reacting to its state - disable based on isOpen
          // 3) setting window title

// open/close exist for api-completeness.
//  in reality, I don't even use them in my own app. Just allowing user control
// to open & close via menu & window controls is enough for my app

          Button("Open Snowflake Window"){
            SampleAppState.shared.snowflakeWindow?.open()
          }
          .disabled(SampleAppState.shared.snowflakeWindow?.isOpen ?? true)
          .padding()

          Button("Close Snowflake Window"){
            SampleAppState.shared.snowflakeWindow?.close()
          }
          .disabled(!(SampleAppState.shared.snowflakeWindow?.isOpen ?? true))
          .padding()

          Button("Fullscreen Snowflake Window"){
            SampleAppState.shared.snowflakeWindow?.myWin.toggleFullScreen(nil)
          }
          .disabled(!(SampleAppState.shared.snowflakeWindow?.isOpen ?? true))
          .padding()


          TextField("Window Title",text: $windowTitle)
            .frame(width: 150)
            .onSubmit {
              SampleAppState.shared.snowflakeWindow?.setWindowTitle(windowTitle)
            }
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
