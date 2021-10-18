// Created by eric_horacek on 9/16/21.
// Copyright © 2021 Airbnb Inc. All rights reserved.

import EpoxyCore
import SwiftUI

extension View {
  /// Vends a `SupplementaryItemModel` representing this SwiftUI `View`.
  ///
  /// - Parameters:
  ///   - dataID: An ID that uniquely identifies this item relative to other items in the
  ///     same collection.
  ///   - reuseBehavior: The reuse behavior of the `EpoxySwiftUIHostingView`.
  public func supplementaryItemModel(
    dataID: AnyHashable,
    reuseBehavior: SwiftUIHostingViewReuseBehavior = .reusable)
    -> SupplementaryItemModel<EpoxySwiftUIHostingView<Self>>
  {
    EpoxySwiftUIHostingView<Self>.supplementaryItemModel(
      dataID: dataID,
      content: .init(rootView: self, dataID: dataID),
      style: .init(
        reuseBehavior: reuseBehavior,
        initialContent: .init(rootView: self, dataID: dataID)))
      .linkDisplayLifecycle()
  }
}
