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
  ///   - reuseID: The ID that's dictates the reuse behavior of the underlying `SwiftUIHostingView`.
  public func supplementaryItemModel(
    dataID: AnyHashable,
    reuseID: SwiftUIHostingViewReuseID = .reusable)
    -> SupplementaryItemModel<SwiftUIHostingView<Self>>
  {
    SwiftUIHostingView<Self>.supplementaryItemModel(
      dataID: dataID,
      content: .init(rootView: self, dataID: dataID),
      style: .init(reuseID: reuseID, initialContent: .init(rootView: self, dataID: dataID)))
      .linkDisplayLifecycle()
  }
}
