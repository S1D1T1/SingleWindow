# ``SingleWindow``

SingleWindow is a SwiftUI library for macOS that provides a persistent, state-preserving window for your app's views.

## Overview

The SingleWindow library offers a simple way to create persistent windows in your macOS applications built with SwiftUI. It provides a straightforward API for creating, managing, and customizing these windows, including the ability to open them on external displays and toggle their visibility via keyboard shortcuts or menu commands.

## Topics

### Creating SingleWindow Instances

- ``makeSingleWindow(title:external:shortcutString:rect:content:)``

### Managing SingleWindow Instances

- ``SingleWindow/open()``
- ``SingleWindow/close()``
- ``SingleWindow/setWindowTitle(_:)``
- ``SingleWindow/toggleVisibility()``

### Menu Commands

- ``SingleWindowCommandGroup``
