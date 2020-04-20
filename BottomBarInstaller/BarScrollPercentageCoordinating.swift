// Created by noah_martin on 4/10/20.
// Copyright © 2020 Airbnb Inc. All rights reserved.

import ConstellationCoreUI
import UIKit

// MARK: - BarScrollPercentageCoordinating

/// A bar coordinator that can receive content offset percentage updates from a scroll view.
public protocol BarScrollPercentageCoordinating: AnyObject {
  /// The fractional percentage that the scroll view underneath the bar(s) has scrolled.
  var scrollPercentage: CGFloat { get set }
}

// MARK: - BarScrollPercentageConfigurable

/// The interface that all bar views or installers with content offset percentages expose.
public protocol BarScrollPercentageConfigurable: AnyObject {
  /// The fractional percentage that the scroll view underneath the bar(s) has scrolled.
  var scrollPercentage: CGFloat { get set }
}

// MARK: - BottomBarInstaller

// MARK: BarScrollPercentageConfigurable

extension BottomBarInstaller: BarScrollPercentageConfigurable {
  public var scrollPercentage: CGFloat {
    get { self[.scrollPercentage] }
    set { self[.scrollPercentage] = newValue }
  }
}

// MARK: UIScrollViewDelegate

extension BottomBarInstaller: UIScrollViewDelegate {
  public func scrollViewDidScroll(_ scrollView: UIScrollView) {
    let contentOffset = scrollView.contentOffset.y + scrollView.adjustedContentInset.top
    scrollPercentage = contentOffset / scrollView.contentSize.height
  }
}

// MARK: - ScrollPercentageBarCoordinator

/// A base bar coordinator with the stored properties that are necessary to coordinate a scroll
/// content offset percentage.
public class ScrollPercentageBarCoordinator<ViewType>: BarCoordinating,
  BarScrollPercentageCoordinating where
  ViewType: BarScrollPercentageConfigurable,
  ViewType: UIView,
  ViewType: ContentConfigurableView,
  ViewType: StyledView,
  ViewType.Content: Equatable
{
  // MARK: Lifecycle

  public init(updateBarModel: @escaping (_ animated: Bool) -> Void) {}

  // MARK: Public

  public typealias Model = BarModel<ViewType>

  public func barModel(for model: BarModel<ViewType>) -> BarModeling {
    model.willDisplay { [weak self] view in
      self?.view = view
    }
  }

  public var scrollPercentage: CGFloat = 0 {
    didSet { updateScrollPercentage() }
  }

  // MARK: Private

  private weak var view: ViewType? {
    didSet { updateScrollPercentage() }
  }

  private func updateScrollPercentage() {
    view?.scrollPercentage = scrollPercentage
  }
}

// MARK: - BarCoordinatorProperty

private extension BarCoordinatorProperty {
  /// A property storing the fractional percentage that the scroll view underneath the bar(s) has
  /// scrolled.
  static var scrollPercentage: BarCoordinatorProperty<CGFloat> {
    .init(keyPath: \BarScrollPercentageCoordinating.scrollPercentage, default: 0)
  }
}
