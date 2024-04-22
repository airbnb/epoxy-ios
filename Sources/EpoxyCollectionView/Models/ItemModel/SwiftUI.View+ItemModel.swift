// Created by eric_horacek on 9/9/21.
// Copyright © 2021 Airbnb Inc. All rights reserved.

import EpoxyCore
import SwiftUI

extension View {
  /// Vends an `ItemModel` representing this SwiftUI `View`.
  ///
  /// - Parameters:
  ///   - dataID: An ID that uniquely identifies this item relative to other items in the
  ///     same collection.
  ///   - reuseBehavior: The reuse behavior of the `EpoxySwiftUIHostingView`.
  public func itemModel(
    dataID: AnyHashable,
    reuseBehavior: SwiftUIHostingViewReuseBehavior = .reusable)
    -> ItemModel<EpoxySwiftUIHostingView<Self>>
  {
    EpoxySwiftUIHostingView<Self>.itemModel(
      dataID: dataID,
      content: .init(rootView: self, dataID: dataID),
      style: .init(
        reuseBehavior: reuseBehavior,
        forceLayoutOnLayoutMarginsChange: false,
        initialContent: .init(rootView: self, dataID: dataID)))
      .linkDisplayLifecycle()
  }
}
