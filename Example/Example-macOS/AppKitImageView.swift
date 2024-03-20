// Created by Cal Stephens on 3/7/24.
// Copyright © 2024 Airbnb Inc. All rights reserved.

import AppKit
import EpoxyCore
import SwiftUI

struct AppKitImageView: View {
  var image: NSImage
  var sizing: SwiftUIMeasurementContainerStrategy = .automatic

  var body: some View {
    NSImageView.swiftUIView {
      NSImageView()
    }.configure { context in
      context.view.layerContentsPlacement = .scaleProportionallyToFit
      context.view.imageScaling = .scaleProportionallyUpOrDown
      context.view.image = image
    }.sizing(sizing)
  }

  func resizable() -> Self {
    var copy = self
    copy.sizing = .proposed
    return copy
  }
}
