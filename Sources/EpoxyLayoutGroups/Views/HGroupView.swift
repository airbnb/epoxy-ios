// Created by Tyler Hedrick on 3/23/21.
// Copyright © 2021 Airbnb Inc. All rights reserved.

import EpoxyCore
import UIKit

/// A view backed version of HGroup that can also be used seamlessly with Epoxy
public final class HGroupView: UIView, EpoxyableView {

  /// Creates an `HGroupView` that can be used to render an `HGroup` backed by a `UIView`.
  /// This view is also ready to be used directly in Epoxy's `CollectionView`
  /// - Parameter style: the style for the `HGroup`
  public init(style: Style) {
    hGroup = HGroup(style: style.hGroupStyle)
    super.init(frame: .zero)
    layoutMargins = style.layoutMargins
    translatesAutoresizingMaskIntoConstraints = false
    hGroup.install(in: self)
    hGroup.constrainToMarginsWithHighPriorityBottom()
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: Style

  public struct Style: Hashable {
    /// Creates a Style for the `HGroupView`
    /// - Parameters:
    ///   - hGroupStyle: the style for the nested `HGroup`
    ///   - layoutMargins: layout margins to apply to this view
    public init(
      hGroupStyle: HGroup.Style = .init(),
      layoutMargins: UIEdgeInsets = .zero)
    {
      self.hGroupStyle = hGroupStyle
      self.layoutMargins = layoutMargins
    }

    public var hGroupStyle: HGroup.Style
    public var layoutMargins: UIEdgeInsets

    public func hash(into hasher: inout Hasher) {
      hasher.combine(hGroupStyle)
      hasher.combine(layoutMargins.top)
      hasher.combine(layoutMargins.left)
      hasher.combine(layoutMargins.right)
      hasher.combine(layoutMargins.bottom)
    }
  }

  // MARK: Content

  public struct Content: Equatable {

    /// Creates a Content model for the `HGroupView`
    /// - Parameter items: the items the `HGroup` will render
    public init(items: [GroupItemModeling]) {
      self.items = items.eraseToAnyGroupItems()
    }

    /// Creates a Content model for the `HGroupView`
    /// - Parameter itemBuilder: a builder that builds the items for the `HGroup` to render
    public init(@GroupModelBuilder _ itemBuilder: () -> [GroupItemModeling]) {
      self.items = itemBuilder().eraseToAnyGroupItems()
    }

    public var items: [AnyGroupItem]

    public static func ==(lhs: Content, rhs: Content) -> Bool {
      // this intentionally always returns false as we want the setItems implementation
      // to handle diffing for us, and to ensure we always update behaviors
      false
    }
  }

  public func setContent(_ content: Content, animated: Bool) {
    hGroup.setItems(content.items)
  }

  // MARK: Private

  private let hGroup: HGroup

}
