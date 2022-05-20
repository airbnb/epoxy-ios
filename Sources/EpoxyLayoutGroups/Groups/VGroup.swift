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
  ///   - style: the style for this VGroup that will only be set one time
  ///   - items: the items that this VGroup will render. These can be set later with setItems()
  public init(
    style: Style = .init(),
    items: [GroupItemModeling] = [])
  {
    let erasedItems = items.eraseToAnyGroupItems()
    animation = style.animation
    alignment = style.alignment
    spacing = style.spacing
    self.items = erasedItems
    constrainableContainers = erasedItems.map { item in
      let constrainable = item.makeConstrainable()
      item.update(constrainable, animated: false)
      return ConstrainableContainer(constrainable)
    }
    super.init()
    resetIndexMap()
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
  public required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: Public

  /// Immutable style values for a VGroup
  public struct Style: Hashable {
    public init(
      alignment: VGroup.ItemAlignment = .fill,
      spacing: CGFloat = 0,
      animation: LayoutGroupUpdateAnimation = .spring())
    {
      self.alignment = alignment
      self.spacing = spacing
      self.animation = animation
    }

    let alignment: VGroup.ItemAlignment
    let spacing: CGFloat
    let animation: LayoutGroupUpdateAnimation
  }

  /// Alignment set at the group level to apply to all constrainables
  /// Individual alignments on a constrainable take precedence over the group's alignment.
  /// The default value is `.fill`
  public let alignment: ItemAlignment

  /// LayoutGroupUpdateAnimation is used to customize the layout group's animation. Hgroup uses a default spring with the following values
  /// The default values are:
  /// duration: `500 ms`,
  /// delay: `0 ms` delay,
  /// spring dampening ratio:`1.0`,
  /// initial velocity of `0.0`.
  public let animation: LayoutGroupUpdateAnimation

  // MARK: Group

  public internal(set) var items: [AnyGroupItem] = [] {
    didSet {
      resetIndexMap()
    }
  }

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

  public func setItems(_ newItems: [GroupItemModeling], animated: Bool) {
    _setItems(newItems, animated: animated, animation: animation)
  }

  public func setItems(@GroupModelBuilder _ buildItems: () -> [GroupItemModeling], animated: Bool = false) {
    setItems(buildItems(), animated: animated)
  }

  public func constrainable(with dataID: AnyHashable) -> Constrainable? {
    _constrainable(with: dataID)
  }

  public func groupItem(with dataID: AnyHashable) -> AnyGroupItem? {
    _groupItem(with: dataID)
  }

  public func install(in view: UIView) {
    _install(in: view)
  }

  public func uninstall() {
    _uninstall()
  }

  public func isEqual(to constrainable: Constrainable) -> Bool {
    guard let other = constrainable as? VGroup else { return false }
    return other == self
  }

  // MARK: Internal

  var constrainableContainers: [ConstrainableContainer] = []
  var dataIDIndexMap: [AnyHashable: Int] = [:]
  var constraints: GroupConstraints? = nil

  /// This is internal as it's only used for animated changes. If you want to remove
  /// a subview from a group, you should call `setItems` with only the items you want
  /// rendered instead.
  var isHidden = false {
    didSet {
      for container in constrainableContainers {
        container.setHiddenForAnimatedUpdates(isHidden)
      }
    }
  }

  func generateConstraints() -> GroupConstraints? {
    VGroupConstraints.constraints(
      for: constrainableContainers,
      in: self,
      groupAlignment: alignment,
      itemSpacing: spacing)
  }

}
