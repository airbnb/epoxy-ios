// Created by Cal Stephens on 3/7/24.
// Copyright © 2024 Airbnb Inc. All rights reserved.

import EpoxyCore
import SwiftUI

// MARK: - LayoutDemoView

struct LayoutDemoView: View {
  var body: some View {
    HStack {
      VStack {
        AppKitImageView(image: .example)
          .frame(maxWidth: 100)

        Text("maxWidth: 100")
      }

      VStack {
        AppKitImageView(image: .example)
          .frame(maxHeight: 100)

        Text("maxHeight: 100")
      }

      VStack {
        AppKitImageView(image: .example)
          .resizable()

        Text("resizable")
      }

      VStack {
        AppKitImageView(image: .example)

        Text("intrinsic content size")
      }
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
  }
}

extension NSImage {
  static var example: NSImage {
    NSImage(named: "ExampleImage")!
  }
}
