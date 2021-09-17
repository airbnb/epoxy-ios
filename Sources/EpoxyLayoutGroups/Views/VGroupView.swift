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
    self.style = style
    vGroup = VGroup(style: style.vGroupStyle)
    super.init(frame: .zero)
    translatesAutoresizingMaskIntoConstraints = false
    updateLayoutMargins()
    vGroup.install(in: self)

    let bottom = vGroup.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor)
    // using a low priority allows the VGroup to hug closely to the content
    // on the vertical axis which is how UIStackView behaves
    bottom.priority = .defaultLow
    NSLayoutConstraint.activate([
      vGroup.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor),
      vGroup.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor),
      vGroup.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor),
      bottom,
    ])
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: Public

  // MARK: Style

  public struct Style: Hashable {
    /// Creates a Style for the `VGroupView`
    /// - Parameters:
    ///   - vGroupStyle: the style for the nested `VGroup`
    ///   - edgeInsets: the adaptive edge insets for this view
    public init(
      vGroupStyle: VGroup.Style = .init(),
      edgeInsets: GroupEdgeInsets = .zero)
    {
      self.vGroupStyle = vGroupStyle
      self.edgeInsets = edgeInsets
    }

    public var vGroupStyle: VGroup.Style
    public var edgeInsets: GroupEdgeInsets
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
    vGroup.setItems(content.items, animated: animated)
  }

  // MARK: Private

  private let style: Style
  private let vGroup: VGroup

  private func updateLayoutMargins() {
    layoutMargins = style.edgeInsets.edgeInsets(with: traitCollection)
  }
}
