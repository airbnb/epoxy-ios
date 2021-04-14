// Created by Tyler Hedrick on 1/21/20.
// Copyright © 2020 Airbnb Inc. All rights reserved.

import Foundation
import UIKit

/// A generic layout guide that models SwiftUI's `VStack`.
/// Please see the README for usage information
public final class VGroup: UILayoutGuide, Constrainable, InternalGroup {

  // MARK: Lifecycle

  /// Creates a new VGroup
  /// - Parameters:
  ///   - style: the style for this HGroup that will only be set one time
  ///   - items: the items that this HGroup will render. These can be set later with setItems()
  public init(
    style: Style = .init(),
    items: [GroupItemModeling] = [])
  {
    let erasedItems = items.eraseToAnyGroupItems()
    self.alignment = style.alignment
    self.spacing = style.spacing
    self.items = erasedItems
    self.constrainableContainers = erasedItems.map { item in
      let constrainable = item.makeConstrainable()
      item.update(constrainable)
      return ConstrainableContainer(constrainable)
    }
    super.init()
    assert(validateItems(items))
    assert(validateConstrainables(constrainableContainers))
  }

  /// Creates a new VGroup
  /// - Parameters:
  ///   - alignment: The alignment used within the group. Individual item alignments will
  ///                 take precedence over this value
  ///   - spacing: the spacing between items in a group
  ///   - items: the items rendered in this group
  public convenience init(
    alignment: ItemAlignment = .fill,
    spacing: CGFloat = 0,
    items: [GroupItemModeling] = [])
  {
    self.init(
      style: .init(alignment: alignment, spacing: spacing),
      items: items)
  }

  /// Creates a new VGroup using a result builder syntax for the items
  /// - Parameters:
  ///   - style: the style for the group
  ///   - content: the builder that provides the items for the group
  public convenience init(
    style: Style = .init(),
    @GroupModelBuilder _ content: () -> [GroupItemModeling])
  {
    self.init(
      style: style,
      items: content())
  }

  /// Creates a new VGroup
  /// - Parameters:
  ///   - alignment: The alignment used within the group. Individual item alignments will
  ///                 take precedence over this value
  ///   - spacing: the spacing between items in a group
  ///   - content: the builder that provides the items for the group
  public convenience init(
    alignment: ItemAlignment = .fill,
    spacing: CGFloat = 0,
    @GroupModelBuilder _ content: () -> [GroupItemModeling])
  {
    self.init(
      style: .init(alignment: alignment, spacing: spacing),
      items: content())
  }

  @available(*, unavailable)
  public required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: Public

  /// Immutable style values for a VGroup
  public struct Style: Hashable {
    public init(
      alignment: VGroup.ItemAlignment = .fill,
      spacing: CGFloat = 0)
    {
      self.alignment = alignment
      self.spacing = spacing
    }

    let alignment: VGroup.ItemAlignment
    let spacing: CGFloat
  }

  // MARK: Alignment

  /// Horizontal alignment options for groups
  public enum ItemAlignment: Hashable {

    /// Align leading and trailing edges of the item tightly to the leading and trailing edges of the group.
    /// Components shorter than the group's width will be stretched to the width of the group
    case fill

    /// Align the leading edge of an item to the leading edge of the group.
    /// Components shorter than the group's width will not be stretched
    case leading

    /// Align the trailing edge of an item to the trailing edge of the group.
    /// Components shorter than the group's width will not be stretched
    case trailing

    /// Align the center of the item to the center of the group horizontally.
    /// Components shorter than the group's width will not be stretched
    case center

    /// Horizontally center one item to another. The other item does not need to be in
    /// the same group, but it must share a common ancestor with the item it is centered to.
    /// Components shorter than the group's width will not be stretched
    case centered(to: Constrainable)

    /// Provide a block that returns a set of custom constraints.
    ///
    /// - Parameter alignmentID: a hashable identifier to uniquely identify this custom layout prvodier
    /// - Parameter layoutProvider: a closure used to build a custom layout given a container and a constrainable
    ///     container: the parent container that should be constrained to
    ///     constrainable: the constrainable that this alignment is affecting
    case custom(
          alignmentID: AnyHashable,
          layoutProvider: (_ container: Constrainable, _ constrainable: Constrainable) -> [NSLayoutConstraint])

    // MARK: Hashable

    public func hash(into hasher: inout Hasher) {
      switch self {
      case .fill:
        hasher.combine(HashableAlignment.fill)
      case .leading:
        hasher.combine(HashableAlignment.leading)
      case .trailing:
        hasher.combine(HashableAlignment.trailing)
      case .center:
        hasher.combine(HashableAlignment.center)
      case .centered(to: let to):
        hasher.combine(to.dataID)
      case .custom(let alignmentID, _):
        hasher.combine(alignmentID)
      }
    }

    private enum HashableAlignment {
      case fill, leading, trailing, center
    }
  }

  /// Alignment set at the group level to apply to all constrainables
  /// Individual alignments on a constrainable take precedence over the group's alignment.
  /// The default value is `.fill`
  public let alignment: ItemAlignment

  // MARK: Group

  public internal(set) var items: [AnyGroupItem] = []

  /// The space between each element
  /// For custom spacing between elements, use Spacers
  /// The default spacing value is 8
  public var spacing: CGFloat {
    didSet { constraints?.itemSpacing = spacing }
  }

  // MARK: Constrainable

  public var firstBaselineAnchor: NSLayoutYAxisAnchor {
    constrainableContainers.first?.firstBaselineAnchor ?? topAnchor
  }

  public var lastBaselineAnchor: NSLayoutYAxisAnchor {
    constrainableContainers.last?.lastBaselineAnchor ?? bottomAnchor
  }

  public func setItems(_ newItems: [GroupItemModeling]) {
    _setItems(newItems.eraseToAnyGroupItems())
  }

  public func setItems(@GroupModelBuilder _ buildItems: () -> [GroupItemModeling]) {
    setItems(buildItems())
  }

  public func isEqual(to constrainable: Constrainable) -> Bool {
    guard let other = constrainable as? VGroup else { return false }
    return other == self
  }

  public func install(in view: UIView) {
    _install(in: view)
  }

  public func uninstall() {
    _uninstall()
  }

  // MARK: Internal

  var constraints: GroupConstraints? = nil
  var constrainableContainers: [ConstrainableContainer] = []

  func generateConstraints() -> GroupConstraints? {
    VGroupConstraints.constraints(
      for: constrainableContainers,
      in: self,
      groupAlignment: alignment,
      itemSpacing: spacing)
  }

}
