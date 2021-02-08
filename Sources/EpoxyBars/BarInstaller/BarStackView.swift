// Created by eric_horacek on 3/30/20.
// Copyright © 2020 Airbnb Inc. All rights reserved.

import EpoxyCore
import UIKit

// MARK: - BarStackView

/// A stack of arbitrary bar views, typically fixed to either the top or bottom of a view
/// controller. It can also be used as a stack view that supports selection.
public class BarStackView: UIStackView, EpoxyableView {

  // MARK: Lifecycle

  /// - Parameters:
  ///   - style: The style of this view.
  required public init(style: Style) {
    self.style = style
    didUpdateCoordinator = nil
    super.init(frame: .zero)
    setup()
  }

  /// - Parameters:
  ///   - style: The style of this view.
  ///   - didUpdateCoordinator: A closure that's called after a bar coordinator has been created.
  public init(
    style: Style,
    didUpdateCoordinator: ((AnyBarCoordinating) -> Void)? = nil)
  {
    self.style = style
    self.didUpdateCoordinator = didUpdateCoordinator
    super.init(frame: .zero)
    setup()
  }

  @available(*, unavailable)
  public required init(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: Public

  /// The order that the bars are arranged on the Z axis.
  public enum ZOrder {
    /// The top bar is the highest in the Z stack. Used when pinned to the top of the screen.
    case topToBottom
    /// The bottom bar is the highest in the Z stack. Used when pinned to the bottom of the screen.
    case bottomToTop
  }

  /// The current bar models ordered from top to bottom.
  public private(set) var models = [AnyBarModel]()

  /// The view of the bar in the primary position within this stack.
  public var primaryBar: UIView? {
    primaryWrapper?.view
  }

  /// The coordinator of the bar in the primary position within this stack.
  public var primaryCoordinator: AnyBarCoordinating? {
    primaryWrapper?.coordinator
  }

  /// All coordinators in this stack, ordered from top to bottom.
  public var coordinators: [AnyBarCoordinating] {
    wrappers.compactMap { $0.coordinator }
  }

  /// All bars in this stack, ordered from top to bottom.
  public var barViews: [UIView] {
    wrappers.compactMap { $0.view }
  }

  public override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
    // Validate hitTest preconditions, since we aren't calling super.
    guard isUserInteractionEnabled, !isHidden, alpha >= 0.01 else { return nil }

    /// We allow bar views to recieve touches outside of this container,
    /// so we manually hit test all bar views.
    for wrapper in zOrderedWrappers {
      if let candidate = wrapper.hitTest(wrapper.convert(point, from: self), with: event) {
        return candidate
      }
    }

    // This view shouldn't recieve any touches
    return nil
  }

  public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    super.touchesBegan(touches, with: event)
    guard let location = touches.first?.location(in: self) else { return }

    for wrapper in wrappers {
      guard wrapper.canHighlight, let converted = wrapper.view?.convert(location, from: self) else { continue }
      if wrapper.view?.point(inside: converted, with: event) == true {
        selectedWrapper = wrapper
        break
      }
    }

    updateHighlighting()
  }

  public override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
    super.touchesMoved(touches, with: event)

    /// TODO: Potentially suppport highlighting another bar that's currently beneath the touch
    /// (in the same style as `UIAlertController.Style.actionsheet`.)
    /// This would involve iterating through the wrappers to find the one contains the current point.

    guard
      let wrapper = selectedWrapper,
      let location = touches.first?.location(in: self),
      let converted = wrapper.view?.convert(location, from: self)
    else { return }

    if wrapper.view?.point(inside: converted, with: event) == false {
      selectedWrapper = nil
      updateHighlighting()
    }
  }

  public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    super.touchesEnded(touches, with: event)

    selectedWrapper?.handleSelection(animated: false)
    selectedWrapper = nil
    updateHighlighting()
  }

  public override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
    super.touchesCancelled(touches, with: event)

    selectedWrapper = nil
    updateHighlighting()
  }

  /// Updates the contents of this stack to the stack modeled by the given model array, inserting,
  /// removing, and updating any bars as needed.
  public func setBars(_ models: [BarModeling], animated: Bool) {
    let (added, removed) = updateModels(models, animated: animated)

    updateWrapperZOrder()

    // No animations are required if both added and removed are empty. Animations between existing
    // bar's wapper views's content is handled by `BarWrapperView.setModel` in `updateModels(…)`.
    if added.isEmpty, removed.isEmpty {
      return
    }

    // Only hide/shown views if animated as hiding/showing `UIStackView` subviews can sometimes
    // result in animations even if performed outside of an animation transaction.
    if animated {
      // Hide each of the added views so that we can animate them in.
      added.forEach { $0.isHidden = true }

      // Layout the new bar subviews prior to animating/transforming so their first layout pass
      // isn't animated and so they have valid frames that we can use to transform.
      //
      // Furthermore, we perform this layout on our superview since a (non-`layoutIfNeeded`) layout
      // in this subview can trigger the superview to layout if it has a dirty layout (via
      // `UIView.layoutBelowIfNeeded`), and we don't want that layout to be animated either.
      superview?.layoutIfNeeded()

      transformAddedWrappers()
    }

    let animations = {
      removed.forEach { $0.isHidden = true }
      added.forEach { view in
        view.isHidden = false
        view.transform = .identity
      }
      self.transformRemovedWrappers(removed)
    }

    let completion = {
      removed.forEach { $0.removeFromSuperview() }
    }

    if animated {
      // We do not allow consumers to pass in the duration as they can configure it by wrapping
      // this call in their own animation transaction that will override this one.
      //
      // We enable user interaction so that scrolling can continue uninterrupted while bars are
      // being shown or hidden.
      UIView.animate(
        withDuration: 0.5,
        delay: 0,
        usingSpringWithDamping: 1.0,
        initialSpringVelocity: 0,
        options: [.allowUserInteraction, .beginFromCurrentState],
        animations: animations,
        completion: { _ in completion() })
    } else {
      // Don't perform any animations (e.g. transforming, hiding/showing) if non-animated since we
      // didn't perform the animation setup.
      completion()
    }
  }

  // MARK: Private

  // An empty subview to ensure this stack view doesn't size subviews weirdly (e.g. massive width
  // values).
  private final class Spacer: UIView {
    override class var layerClass: AnyClass { CATransformLayer.self }
  }

  // The style of this view.
  private let style: Style

  /// A closure that's called after a bar coordinator has been created.
  private let didUpdateCoordinator: ((_ coordinator: AnyBarCoordinating) -> Void)?

  /// The current bar wrappers ordered from top to bottom.
  private var wrappers = [BarWrapperView]()

  /// The wrapper of the model being selected or highlighted.
  private var selectedWrapper: BarWrapperView?

  /// Wrappers ordered by their order in the Z axis (from highest to lowest)
  private var zOrderedWrappers: [BarWrapperView] {
    switch style.zOrder {
    case .topToBottom:
      return wrappers
    case .bottomToTop:
      return wrappers.reversed()
    }
  }

  private var primaryWrapper: BarWrapperView? {
    switch style.zOrder {
    case .topToBottom:
      return wrappers.first
    case .bottomToTop:
      return wrappers.last
    }
  }

  private func setup() {
    translatesAutoresizingMaskIntoConstraints = false
    layoutMargins = .zero
    insetsLayoutMarginsFromSafeArea = false
    // Ensure that each bar is focused one after another rather than jumping to the content below if
    // it extends beneath the bar stack.
    shouldGroupAccessibilityChildren = true
    axis = .vertical
    // We need to have at least one arranged subview at all times otherwise this stack view sizes
    // subviews weirdly (e.g. massive width values).
    addArrangedSubview(Spacer())
  }

  /// Updates the `wrappers` and `models` to reflect the given `models`, returning the wrappers that
  /// were added and removed.
  private func updateModels(
    _ models: [BarModeling],
    animated: Bool)
    -> (added: [BarWrapperView], removed: [BarWrapperView])
  {
    let newModels = models.map { $0.eraseToAnyBarModel() }
    let changeset = newModels.makeChangeset(from: self.models)
    // We always update all models as they could have new behavior setters even with equal content.
    self.models = newModels
    warnOnDuplicates(in: changeset)

    var removed = [BarWrapperView]()
    var added = [BarWrapperView]()

    for index in changeset.deletes.reversed() {
      let wrapper = wrappers.remove(at: index)
      removed.append(wrapper)
    }

    for index in changeset.inserts {
      let wrapper = makeWrapper(self.models[index])
      wrappers.insert(wrapper, at: index)
      // Add one since we always have the `LayoutContainer` to keep the size sensible.
      insertArrangedSubview(wrapper, at: index + 1)
      added.append(wrapper)
    }

    // We set the model on every wrapper even if they have equal diffable content. This ensures that
    // they have their behavior/coordinator updated if needed. We skip inserts since they're already
    // configured via `makeWrapper`.
    for (index, wrapper) in wrappers.enumerated() where !changeset.inserts.contains(index) {
      wrapper.setModel(self.models[index], animated: animated)
    }

    return (added: added, removed: removed)
  }

  private func makeWrapper(_ model: BarModeling) -> BarWrapperView {
    let wrapper = BarWrapperView(
      zOrder: style.zOrder,
      selectedBackgroundColor: style.selectedBackgroundColor,
      willDisplayBar: { [weak self] bar in
        self?.handleWillDisplayBar(bar)
      },
      didUpdateCoordinator: didUpdateCoordinator)
    wrapper.setModel(model, animated: false)
    return wrapper
  }

  private func handleWillDisplayBar(_ bar: UIView) {
    (bar as? HeightInvalidatingBarView)?.heightInvalidationContext = .init { [weak self] in
      self?.superview
    }
  }

  /// Updates the `zPosition` of the wrapper views to respect the `ZOrder` after an update.
  private func updateWrapperZOrder() {
    // The bottom wrapper should be highest in the z index so that new bars slide underneath it when
    // being hidden and shown.
    for (index, wrapper) in zOrderedWrappers.enumerated() {
      // We pick 1000 as a sensible max to decrement from since we would never have that may bars.
      // We don't decrement from 0 since that causes bars to be invisible for some reason.
      wrapper.layer.zPosition = CGFloat(1000 - index)
    }
  }

  // Transforms the added wrapper views either beneath the next visible wrapper or below the bottom
  // of this container if none are visible so that they animatedly slide up into view in a stack.
  private func transformAddedWrappers() {
    switch style.zOrder {
    case .bottomToTop:
      for (index, wrapper) in wrappers.enumerated() where wrapper.isHidden {
        let nextVisible = wrappers[index...].first { !$0.isHidden }
        let previousVisible = wrappers[...index].last { !$0.isHidden }

        // If there's no visible bars on either side of this bar, transform it down by the stack
        // height so that it "slides up" into view when appearing.
        if nextVisible == nil, previousVisible == nil {
          wrapper.transform = .init(translationX: 0, y: bounds.height)
        }
      }
    case .topToBottom:
      // This could use some logic to ensure that shown bars slide out as a stack rather than
      // overlapping one another creating an "unfurling" effect.
      break
    }
  }

  /// Transforms the removed wrapper views to make it appear like they're sliding underneath
  /// previous bars or the edge of the screen.
  private func transformRemovedWrappers(_ wrappers: [BarWrapperView]) {
    switch style.zOrder {
    case .topToBottom:
      // This isn't a perfect heuristic, but it's simple enough to work for what we need it to do
      // for the time being. If you want to improve the animations this could be reworked.
      for wrapper in wrappers {
        let barHeight = wrapper.view?.frame.height ?? 0
        wrapper.transform = .init(translationX: 0, y: -barHeight)
      }
    case .bottomToTop:
      // This could use some logic to ensure that hidden bars slide out as a stack rather than
      // overlapping one another creating an "furling" effect.
      break
    }
  }

  /// Outputs a warning for the given `changeset` if it contains duplicate IDs.
  private func warnOnDuplicates(in changeset: IndexChangeset) {
    guard !changeset.duplicates.isEmpty else { return }

    EpoxyLogger.shared.warn({
      var message: [String] = [
        """
        Warning! Duplicate data IDs detected. Bars with the same view type should have unique data \
        IDs within a bar stack. Duplicate data IDs can cause undefined behavior. Digest:
        """,
      ]

      for duplicateIndexes in changeset.duplicates {
        // Subscripting is safe here since `duplicateIndexes` is never empty.
        let firstIndex = duplicateIndexes[0]
        let duplicateItemID = models[firstIndex].dataID
        message.append("- Bar with ID \(duplicateItemID) duplicated at indexes \(duplicateIndexes)")
      }

      return message.joined(separator: "\n")
    }())
  }

  /// Update the background of wrappers according to the current selection.
  private func updateHighlighting() {
    for wrapper in wrappers {
      wrapper.updateSelection(isSelected: selectedWrapper === wrapper)
    }
  }

}

// MARK: StyledView

extension BarStackView {

  /// The style to be used.
  public struct Style: Hashable {

    // MARK: Lifecycle

    public init(
      selectedBackgroundColor: UIColor? = nil,
      zOrder: BarStackView.ZOrder = .topToBottom)
    {
      self.selectedBackgroundColor = selectedBackgroundColor
      self.zOrder = zOrder
    }

    // MARK: Public

    /// The selected background color to apply.
    public var selectedBackgroundColor: UIColor?

    /// The order that the bars are arranged on the Z axis.
    public var zOrder: BarStackView.ZOrder

    // MARK: Internal

    static var topToBottom: Self {
      .init(zOrder: .topToBottom)
    }

    static var bottomToTop: Self {
      .init(zOrder: .bottomToTop)
    }

  }
}

// MARK: ContentConfigurableView

extension BarStackView {

  /// The content of the stack view.
  public struct Content: Equatable {

    /// The bar models to be rendered.
    public let models: [BarModeling]

    /// - Parameters:
    ///   - models: The bar models to be rendered.
    public init(models: [BarModeling]) {
      self.models = models
    }

    public static func ==(lhs: Self, rhs: Self) -> Bool {
      // The content should never be equal since we need the `models`'s behavior to be updated on
      // every content change.
      false
    }
  }

  /// Update the content of the stack view.
  public func setContent(_ content: Content, animated: Bool) {
    setBars(content.models, animated: animated)
  }
}
