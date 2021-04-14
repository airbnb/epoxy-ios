// Created by Tyler Hedrick on 1/21/20.
// Copyright © 2020 Airbnb Inc. All rights reserved.

import Foundation
import UIKit

/// A generic layout guide that models SwiftUI's `HStack`.
/// Please see the README for usage information
public final class HGroup: UILayoutGuide, Constrainable, InternalGroup {

  // MARK: Lifecycle

  /// Creates a new HGroup
  /// - Parameters:
  ///   - style: the style for this HGroup that will only be set one time
  ///   - items: the items that this HGroup will render. These can be set later with setItems()
  public init(
    style: Style = .init(),
    items: [GroupItemModeling] = [])
  {
    let erasedItems = items.eraseToAnyGroupItems()
    self.alignment = style.alignment
    self.accessibilityAlignment = style.accessibilityAlignment
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
    observeContentSizeCategoryChanges()
  }

  /// Creates a new HGroup
  /// - Parameters:
  ///   - alignment: The alignment used within the group. Individual item alignments will
  ///                 take precedence over this value
  ///   - accessibilityAlignment: The accessibility alignment for the items within a group.
  ///                              these will only be used when `reflowsForAccessibiltyTypeSizes` is `true`
  ///                              and when the `preferredContentSizeCategory.isAccessibilityCategory` is `true`.
  ///                              These will also be used if `forceVerticalAccessibilityLayout` is set to `true`.
  ///                              Individual item alignments will take precedence over this value
  ///   - spacing: the spacing between items in a group
  ///   - items: the items rendered in this group
  public convenience init(
    alignment: ItemAlignment = .fill,
    accessibilityAlignment: VGroup.ItemAlignment = .leading,
    spacing: CGFloat = 0,
    items: [GroupItemModeling] = [])
  {
    self.init(
      style: .init(
        alignment: alignment,
        accessibilityAlignment: accessibilityAlignment,
        spacing: spacing),
      items: items)
  }

  /// Creates a new HGroup using a result builder syntax for the items
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

  /// Creates a new HGroup using a builder syntax for the items
  /// - Parameters:
  ///   - alignment: The alignment used within the group. Individual item alignments will
  ///                 take precedence over this value
  ///   - accessibilityAlignment: The accessibility alignment for the items within a group.
  ///                              these will only be used when `reflowsForAccessibiltyTypeSizes` is `true`
  ///                              and when the `preferredContentSizeCategory.isAccessibilityCategory` is `true`.
  ///                              These will also be used if `forceVerticalAccessibilityLayout` is set to `true`.
  ///                              Individual item alignments will take precedence over this value
  ///   - spacing: the spacing between items in a group
  ///   - content: the builder that provides the items for the group
  public convenience init(
    alignment: ItemAlignment = .fill,
    accessibilityAlignment: VGroup.ItemAlignment = .leading,
    spacing: CGFloat = 0,
    @GroupModelBuilder _ content: () -> [GroupItemModeling])
  {
    self.init(
      style: .init(
        alignment: alignment,
        accessibilityAlignment: accessibilityAlignment,
        spacing: spacing),
      items: content())
  }

  @available(*, unavailable)
  public required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: Public

  /// Immutable style values for an HGroup
  public struct Style: Hashable {
    /// Creates a style for an HGroup
    /// - Parameters:
    ///   - alignment: The alignment used within the group. Individual item alignments will
    ///                 take precedence over this value
    ///   - accessibilityAlignment: The accessibility alignment for the items within a group.
    ///                              these will only be used when `reflowsForAccessibiltyTypeSizes` is `true`
    ///                              and when the `preferredContentSizeCategory.isAccessibilityCategory` is `true`.
    ///                              These will also be used if `forceVerticalAccessibilityLayout` is set to `true`.
    ///                              Individual item alignments will take precedence over this value
    ///   - spacing: the spacing between items of the group
    public init(
      alignment: HGroup.ItemAlignment = .fill,
      accessibilityAlignment: VGroup.ItemAlignment = .leading,
      spacing: CGFloat = 0)
    {
      self.alignment = alignment
      self.accessibilityAlignment = accessibilityAlignment
      self.spacing = spacing
    }

    let alignment: HGroup.ItemAlignment
    let accessibilityAlignment: VGroup.ItemAlignment
    let spacing: CGFloat
  }

  // MARK: Alignment

  public enum ItemAlignment: Hashable {
    /// Align top and bottom edges of the item tightly to the leading and trailing edges of the group.
    /// Components shorter than the group's height will be stretched to the height of the group
    case fill

    /// Align the top edge of an item tightly to the top edge of the group.
    /// Components shorter than the group's height will not be stretched.
    case top

    /// Align the bottom edge of an item tightly to the container's bottom edge.
    /// Components shorter than the group's height will not be stretched.
    case bottom

    /// Align the center of the item to the center of the group vertically.
    /// Components shorter than the group's height will not be stretched.
    case center

    /// Vertically center one item to another item. The other item does not need to be in
    /// the same group, but it must share a common ancestor with the item it is centered to.
    /// Components shorter than the group's height will not be stretched.
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
      case .top:
        hasher.combine(HashableAlignment.top)
      case .bottom:
        hasher.combine(HashableAlignment.bottom)
      case .center:
        hasher.combine(HashableAlignment.center)
      case .centered(to: let to):
        hasher.combine(to.dataID)
      case .custom(let alignmentID, _):
        hasher.combine(alignmentID)
      }
    }

    private enum HashableAlignment {
      case fill, top, bottom, center
    }
  }

  /// Alignment set at the group level to apply to all constrainables.
  /// Individual alignments on a constrainable take precedence over the group's alignment.
  /// The default value is `.fill`
  public let alignment: ItemAlignment

  /// Alignment used for accessibility layouts at the group level.
  /// The default value is `.leading`
  public let accessibilityAlignment: VGroup.ItemAlignment

  // MARK: Group

  public internal(set) var items: [AnyGroupItem] = []

  /// When this property is true, the HGroup will automatically relayout when
  /// accessibility type sizes are enabled to make the layout more accessible
  /// the default value of this property is `true`
  public var reflowsForAccessibilityTypeSizes = true {
    didSet { installConstraintsIfNeeded() }
  }

  /// When this property is true, HGroup will only use the vertical accessibility
  /// layout. This is useful if you need to toggle a horizontal and vertical layout
  /// manually instead of relying on the built-in support from `reflowsForAccessibilityTypeSizes`
  public var forceVerticalAccessibilityLayout = false {
    didSet { installConstraintsIfNeeded() }
  }

  /// The space between elements.
  /// If you need custom spacing between elements use Spacer instead
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

  /// Chainable accessor for `reflowsForAccessibilityTypeSizes` for use in result builder syntax
  public func reflowsForAccessibilityTypeSizes(_ reflow: Bool) -> HGroup {
    reflowsForAccessibilityTypeSizes = reflow
    return self
  }

  /// Chainable accessor for `forceVerticalAccessibilityLayout` for use in result builder syntax
  public func forceAccessibilityVerticalLayout(_ forceIn: Bool) -> HGroup {
    forceVerticalAccessibilityLayout = forceIn
    return self
  }

  public func setItems(_ newItems: [GroupItemModeling]) {
    _setItems(newItems)
  }

  public func setItems(@GroupModelBuilder _ buildItems: () -> [GroupItemModeling]) {
    setItems(buildItems())
  }

  public func install(in view: UIView) {
    _install(in: view)
  }

  public func uninstall() {
    _uninstall()
  }

  public func isEqual(to constrainable: Constrainable) -> Bool {
    guard let other = constrainable as? HGroup else { return false }
    return other == self
  }

  // MARK: Internal

  var constrainableContainers: [ConstrainableContainer] = []
  var constraints: GroupConstraints? = nil

  func generateConstraints() -> GroupConstraints? {
    assert(owningView != nil, "There must be an owningView before generating constraints")

    if shouldUseAccessibilityLayout {
      return accessibilityVerticalAxisConstraints()
    } else {
      return standardConstraints()
    }
  }

  // MARK: Private

  private var preferredContentSizeCategory = UITraitCollection.current.preferredContentSizeCategory

  private func observeContentSizeCategoryChanges() {
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(handleContentSizeCategoryChangeNotification(notification:)),
      name: UIContentSizeCategory.didChangeNotification,
      object: nil)
  }

  @objc
  private func handleContentSizeCategoryChangeNotification(notification: NSNotification) {
    guard let newContentSize = notification.userInfo?[UIContentSizeCategory.newValueUserInfoKey] as? UIContentSizeCategory else {
      return
    }
    // calculate if we were using an accessibility layout before the change
    let oldShouldUseAccessibilityLayout = shouldUseAccessibilityLayout

    // make the change to the new preferredContentSizeCategory
    preferredContentSizeCategory = newContentSize

    // determine if we will use an accessibility layout with the update
    let newShouldUseAccessibilityLayout = shouldUseAccessibilityLayout

    // only install constraints if we need to
    if oldShouldUseAccessibilityLayout != newShouldUseAccessibilityLayout {
      installConstraintsIfNeeded()
    }
  }

  private var shouldUseAccessibilityLayout: Bool {
    // If dynamic type is in the accessibility category, we
    // reflow the HGroup to be vertical to improve usability
    let shouldReflowForAccessibility = preferredContentSizeCategory.isAccessibilityCategory &&
      reflowsForAccessibilityTypeSizes

    return shouldReflowForAccessibility || forceVerticalAccessibilityLayout
  }

  private func standardConstraints() -> GroupConstraints {
    HGroupConstraints.constraints(
      for: constrainableContainers,
      in: self,
      groupAlignment: alignment,
      itemSpacing: spacing)
  }

  private func accessibilityVerticalAxisConstraints() -> GroupConstraints {
    VGroupConstraints.constraints(
      for: constrainableContainers,
      in: self,
      groupAlignment: accessibilityAlignment,
      itemSpacing: spacing,
      useAccessibilityAlignment: true)
  }

}