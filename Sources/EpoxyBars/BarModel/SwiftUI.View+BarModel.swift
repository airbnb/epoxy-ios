// Created by eric_horacek on 9/16/21.
// Copyright © 2021 Airbnb Inc. All rights reserved.

import EpoxyCore
import SwiftUI

extension View {
  /// Vends a `BarModel` representing this SwiftUI `View`.
  ///
  /// - Parameters:
  ///   - dataID: An ID that uniquely identifies this item relative to other items in the
  ///     same collection.
  ///   - reuseBehavior: The reuse behavior of the `EpoxySwiftUIHostingView`.
  ///   - ignoreSafeArea: Weather or not the underlying`EpoxySwiftUIHostingController` will ignore its safe area.
  public func barModel(
    dataID: AnyHashable? = nil,
    reuseBehavior: SwiftUIHostingViewReuseBehavior = .reusable,
    ignoreSafeArea: Bool = false)
    -> BarModel<EpoxySwiftUIHostingView<Self>>
  {
    EpoxySwiftUIHostingView<Self>.barModel(
      dataID: dataID,
      content: .init(rootView: self, dataID: dataID),
      style: .init(
        reuseBehavior: reuseBehavior,
        initialContent: .init(rootView: self, dataID: dataID),
        ignoreSafeArea: ignoreSafeArea))
      .linkDisplayLifecycle()
  }
}
