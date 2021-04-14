// Created by Tyler Hedrick on 3/23/21.
// Copyright © 2021 Airbnb Inc. All rights reserved.

import EpoxyCore
import UIKit

/// A view backed version of VGroup that can also be used seamlessly with Epoxy
public final class VGroupView: UIView, EpoxyableView {

  // MARK: Lifecycle

  /// Creates a `VGroupView` that can be used to render a `VGroup` backed by a `UIView`.
  /// This view is also ready to be used directly in Epoxy's `CollectionView`
  /// - Parameter style: the style for the `VGroup`
  public init(style: Style) {
    vGroup = VGroup(style: style.vGroupStyle)
    super.init(frame: .zero)
    layoutMargins = style.layoutMargins
    translatesAutoresizingMaskIntoConstraints = false
    vGroup.install(in: self)
    vGroup.constrainToMarginsWithHighPriorityBottom()
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: Public

  // MARK: Style

  public struct Style: Hashable {

    // MARK: Lifecycle

    /// Creates a Style for the `VGroupView`
    /// - Parameters:
    ///   - vGroupStyle: the style for the nested `VGroup`
    ///   - layoutMargins: layout margins to apply to this view
    public init(
      vGroupStyle: VGroup.Style = .init(),
      layoutMargins: UIEdgeInsets = .zero)
    {
      self.vGroupStyle = vGroupStyle
      self.layoutMargins = layoutMargins
    }

    // MARK: Public

    public var vGroupStyle: VGroup.Style
    public var layoutMargins: UIEdgeInsets

    public func hash(into hasher: inout Hasher) {
      hasher.combine(vGroupStyle)
      hasher.combine(layoutMargins.top)
      hasher.combine(layoutMargins.bottom)
      hasher.combine(layoutMargins.left)
      hasher.combine(layoutMargins.right)
    }
  }

  // MARK: Content

  /// Creates a Content model for the `VGroupView`
  /// - Parameter items: the items the `VGroup` will render
  public struct Content: Equatable {
    public init(items: [GroupItemModeling]) {
      self.items = items.eraseToAnyGroupItems()
    }

    /// Creates a Content model for the `VGroupView`
    /// - Parameter itemBuilder: a builder that builds the items for the `VGroup` to render
    public init(@GroupModelBuilder _ itemBuilder: () -> [GroupItemModeling]) {
      items = itemBuilder().eraseToAnyGroupItems()
    }

    public var items: [AnyGroupItem]

    public static func ==(lhs: Content, rhs: Content) -> Bool {
      // this intentionally always returns false as we want the setItems implementation
      // to handle diffing for us, and to ensure we always update behaviors
      false
    }
  }

  public func setContent(_ content: Content, animated: Bool) {
    vGroup.setItems(content.items)
  }

  // MARK: Private

  private let vGroup: VGroup

}
