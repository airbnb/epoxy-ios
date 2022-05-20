// Created by Tyler Hedrick on 3/23/21.
// Copyright © 2021 Airbnb Inc. All rights reserved.

import EpoxyCore
import UIKit

/// A view backed version of HGroup that can also be used seamlessly with Epoxy
public final class HGroupView: UIView, EpoxyableView {

  // MARK: Lifecycle

  /// Creates an `HGroupView` that can be used to render an `HGroup` backed by a `UIView`.
  /// This view is also ready to be used directly in Epoxy's `CollectionView`
  /// - Parameter style: the style for the `HGroup`
  public init(style: Style) {
    self.style = style
    hGroup = HGroup(style: style.hGroupStyle)
    super.init(frame: .zero)
    translatesAutoresizingMaskIntoConstraints = false
    insetsLayoutMarginsFromSafeArea = false
    updateLayoutMargins()
    hGroup.install(in: self)

    let bottom = hGroup.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor)
    // using a low priority allows the HGroup to hug closely to the content
    // on the vertical axis which is how UIStackView behaves
    bottom.priority = .defaultLow
    NSLayoutConstraint.activate([
      hGroup.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor),
      hGroup.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor),
      hGroup.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor),
      bottom,
    ])
  }

  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: Public

  // MARK: Style

  public struct Style: Hashable {
    /// Creates a Style for the `HGroupView`
    /// - Parameters:
    ///   - hGroupStyle: the style for the nested `HGroup`
    ///   - edgeInsets: the adaptive edge insets to use for this view
    public init(
      hGroupStyle: HGroup.Style = .init(),
      edgeInsets: GroupEdgeInsets = .zero)
    {
      self.hGroupStyle = hGroupStyle
      self.edgeInsets = edgeInsets
    }

    public var hGroupStyle: HGroup.Style
    public var edgeInsets: GroupEdgeInsets
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
      items = itemBuilder().eraseToAnyGroupItems()
    }

    public var items: [AnyGroupItem]

    public static func ==(_: Content, _: Content) -> Bool {
      // this intentionally always returns false as we want the setItems implementation
      // to handle diffing for us, and to ensure we always update behaviors
      false
    }
  }

  public override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
    super.traitCollectionDidChange(previousTraitCollection)
    updateLayoutMargins()
  }

  public func setContent(_ content: Content, animated: Bool) {
    hGroup.setItems(content.items, animated: animated)
  }

  // MARK: Private

  private let style: Style
  private let hGroup: HGroup

  private func updateLayoutMargins() {
    layoutMargins = style.edgeInsets.edgeInsets(with: traitCollection)
  }

}
