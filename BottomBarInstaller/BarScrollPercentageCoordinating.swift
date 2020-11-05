// Created by noah_martin on 4/10/20.
// Copyright © 2020 Airbnb Inc. All rights reserved.

import ConstellationCoreUI
import UIKit

// MARK: - BarScrollPercentageCoordinating

/// A bar coordinator that can receive content offset percentage updates from a scroll view.
public protocol BarScrollPercentageCoordinating: AnyObject {
  /// The fractional percentage that the scroll view underneath the bar(s) has scrolled.
  var scrollPercentage: CGPoint { get set }
}

// MARK: - BarScrollPercentageConfigurable

/// The interface that all bar views or installers with content offset percentages expose.
public protocol BarScrollPercentageConfigurable: AnyObject {
  /// The fractional percentage that the scroll view underneath the bar(s) has scrolled.
  var scrollPercentage: CGPoint { get set }
}

// MARK: - BottomBarInstaller + BarScrollPercentageConfigurable

extension BottomBarInstaller: BarScrollPercentageConfigurable {
  public var scrollPercentage: CGPoint {
    get { self[.scrollPercentage] }
    set { self[.scrollPercentage] = newValue }
  }
}

// MARK: - BottomBarInstaller + UIScrollViewDelegate

extension BottomBarInstaller: UIScrollViewDelegate {
  public func scrollViewDidScroll(_ scrollView: UIScrollView) {
    let contentOffset = CGPoint(
      x: scrollView.contentOffset.x + scrollView.adjustedContentInset.left,
      y: scrollView.contentOffset.y + scrollView.adjustedContentInset.top)
    scrollPercentage = CGPoint(
      x: contentOffset.x / scrollView.contentSize.width,
      y: contentOffset.y / scrollView.contentSize.height)
  }
}

// MARK: - ScrollPercentageBarCoordinator

/// A base bar coordinator with the stored properties that are necessary to coordinate a scroll
/// content offset percentage.
public class ScrollPercentageBarCoordinator<ViewType>: BarCoordinating,
  BarScrollPercentageCoordinating where
  ViewType: BarScrollPercentageConfigurable,
  ViewType: ConstellationView,
  ViewType.Content: Equatable
{

  // MARK: Lifecycle

  public init(updateBarModel: @escaping (_ animated: Bool) -> Void) {}

  // MARK: Public

  public typealias Model = BarModel<ViewType>

  public var scrollPercentage: CGPoint = .zero {
    didSet { updateScrollPercentage() }
  }

  public func barModel(for model: BarModel<ViewType>) -> BarModeling {
    model.willDisplay { [weak self] view in
      self?.view = view
    }
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

extension BarCoordinatorProperty {
  /// A property storing the fractional percentage that the scroll view underneath the bar(s) has
  /// scrolled.
  fileprivate static var scrollPercentage: BarCoordinatorProperty<CGPoint> {
    .init(keyPath: \BarScrollPercentageCoordinating.scrollPercentage, default: .zero)
  }
}
