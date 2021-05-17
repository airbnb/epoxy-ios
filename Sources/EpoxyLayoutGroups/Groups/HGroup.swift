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
    alignment = style.alignment
    accessibilityAlignment = style.accessibilityAlignment
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

    // MARK: Lifecycle

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

    // MARK: Internal

    let alignment: HGroup.ItemAlignment
    let accessibilityAlignment: VGroup.ItemAlignment
    let spacing: CGFloat
  }

  /// Alignment set at the group level to apply to all constrainables.
  /// Individual alignments on a constrainable take precedence over the group's alignment.
  /// The default value is `.fill`
  public let alignment: ItemAlignment

  /// Alignment used for accessibility layouts at the group level.
  /// The default value is `.leading`
  public let accessibilityAlignment: VGroup.ItemAlignment

  // MARK: Group

  public internal(set) var items: [AnyGroupItem] = [] {
    didSet {
      resetIndexMap()
    }
  }

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

  public func setItems(_ newItems: [GroupItemModeling], animated: Bool) {
    _setItems(newItems, animated: animated)
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
    guard let other = constrainable as? HGroup else { return false }
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
    assert(owningView != nil, "There must be an owningView before generating constraints")

    if shouldUseAccessibilityLayout {
      return accessibilityVerticalAxisConstraints()
    } else {
      return standardConstraints()
    }
  }

  // MARK: Private

  private var preferredContentSizeCategory = UITraitCollection.current.preferredContentSizeCategory

  private var shouldUseAccessibilityLayout: Bool {
    // If dynamic type is in the accessibility category, we
    // reflow the HGroup to be vertical to improve usability
    let shouldReflowForAccessibility = preferredContentSizeCategory.isAccessibilityCategory &&
      reflowsForAccessibilityTypeSizes

    return shouldReflowForAccessibility || forceVerticalAccessibilityLayout
  }

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
