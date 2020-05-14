// Created by eric_horacek on 3/30/20.
// Copyright © 2020 Airbnb Inc. All rights reserved.

import ConstellationElementsCoreUI
import UIKit

/// A stack of arbitrary bar views, typically fixed to either the top or bottom of a view
/// controller.
public class BarStackView: UIStackView {

  // MARK: Lifecycle

  public init(
    zOrder: ZOrder,
    willDisplayBar: ((_ bar: UIView) -> Void)? = nil,
    didUpdateCoordinator: ((AnyBarCoordinating) -> Void)? = nil)
  {
    self.zOrder = zOrder
    self.willDisplayBar = willDisplayBar
    self.didUpdateCoordinator = didUpdateCoordinator
    super.init(frame: .zero)
    translatesAutoresizingMaskIntoConstraints = false
    layoutMargins = .zero
    insetsLayoutMarginsFromSafeArea = false
    axis = .vertical
    // We need to have at least one arranged subview at all times otherwise this stack view sizes
    // subviews weirdly (e.g. massive width values).
    addArrangedSubview(LayoutContainer())
  }

  public required init(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: UIView

  public override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
    guard let view = super.hitTest(point, with: event) else { return nil }

    // This view shouldn't ever receive touches, but since it can contain interactive elements we
    // need to ignore them via a hit test, not `isUserInteractionEnabled`.
    return view === self ? nil : view
  }

  // MARK: Public

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

  /// Updates the contents of this stack to the stack modeled by the given model array, inserting,
  /// removing, and updating any bars as needed.
  public func setModels(_ models: [BarModeling], animated: Bool) {
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

  /// The order that the bars are in on the Z axis.
  public enum ZOrder {
    /// The top bar is the highest in the Z stack. Used when pinned to the top of the screen.
    case topToBottom
    /// The bottom bar is the highest in the Z stack. Used when pinned to the bottom of the screen.
    case bottomToTop
  }

  // MARK: Private

  // The direction that the bars are Z stacked in.
  private let zOrder: ZOrder

  /// A closure that will be invoked prior to adding the bar view to the view hierarchy.
  private let willDisplayBar: ((_ bar: UIView) -> Void)?

  /// A closure that's called after the coordinator has been created.
  private let didUpdateCoordinator: ((_ coordinator: AnyBarCoordinating) -> Void)?

  /// The current bar wrappers ordered from top to bottom.
  private var wrappers = [BarWrapperView]()

  /// The current bar models ordered from top to bottom.
  private var models = [AnyBarModel]()

  private var primaryWrapper: BarWrapperView? {
    switch zOrder {
    case .topToBottom:
      return wrappers.first
    case .bottomToTop:
      return wrappers.last
    }
  }

  /// Updates the `wrappers` and `models` to reflect the given `models`, returning the wrappers that
  /// were added and removed.
  private func updateModels(
    _ models: [BarModeling],
    animated: Bool)
    -> (added: [BarWrapperView], removed: [BarWrapperView])
  {
    let newModels = models.map { $0.barModel }
    let changeset = newModels.makeChangeset(from: self.models)
    // We always update all models as they could have new behavior setters even with equal content.
    self.models = newModels

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
      zOrder: zOrder,
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
    willDisplayBar?(bar)
  }

  /// Updates the `zPosition` of the wrapper views to respect the `ZOrder` after an update.
  private func updateWrapperZOrder() {
    let wrappers: [BarWrapperView]
    switch zOrder {
    case .bottomToTop:
      wrappers = self.wrappers.reversed()
    case .topToBottom:
      wrappers = self.wrappers
    }

    // The bottom wrapper should be highest in the z index so that new bars slide underneath it when
    // being hidden and shown.
    for (index, wrapper) in wrappers.enumerated() {
      // We pick 1000 as a sensible max to decrement from since we would never have that may bars.
      // We don't decrement from 0 since that causes bars to be invisible for some reason.
      wrapper.layer.zPosition = CGFloat(1000 - index)
    }
  }

  // Transforms the added wrapper views either beneath the next visible wrapper or below the bottom
  // of this container if none are visible so that they animatedly slide up into view in a stack.
  private func transformAddedWrappers() {
    switch zOrder {
    case .bottomToTop:
      // The offset at which the next stacked wrapper should be placed with a key of the view that
      // they're placed beneath.
      var offsets = [UIView: CGFloat]()

      for (index, wrapper) in wrappers.enumerated() where wrapper.isHidden {
        let barHeight = wrapper.view?.frame.height ?? 0
        if let nextVisibleWrapper = wrappers[index...].first(where: { !$0.isHidden }) {
          var offset = offsets[nextVisibleWrapper, default: 0]
          offset += barHeight
          wrapper.transform = .init(translationX: 0, y: offset)
          offsets[nextVisibleWrapper] = offset
        } else {
          let offset = offsets[self, default: bounds.height]
          wrapper.transform = .init(translationX: 0, y: offset)
          offsets[self, default: 0] += barHeight
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
    switch zOrder {
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

}
