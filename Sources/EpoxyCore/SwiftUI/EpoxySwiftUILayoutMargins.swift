// Created by eric_horacek on 10/8/21.
// Copyright © 2021 Airbnb Inc. All rights reserved.

import SwiftUI

private struct EpoxyLayoutMargins: EnvironmentKey {
  static let defaultValue = EdgeInsets()
}

extension EnvironmentValues {
  var epoxyLayoutMargins: EdgeInsets {
    get { self[EpoxyLayoutMargins.self] }
    set { self[EpoxyLayoutMargins.self] = newValue }
  }
}

struct EpoxyLayoutMarginsPadding: ViewModifier {
  @Environment(\.epoxyLayoutMargins) var epoxyLayoutMargins

  func body(content: Content) -> some View {
    content.padding(epoxyLayoutMargins)
  }
}

extension View {
  public func epoxyLayoutMargins() -> some View {
    modifier(EpoxyLayoutMarginsPadding())
  }
}
