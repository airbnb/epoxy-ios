//  Created by Laura Skelton on 6/4/17.
//  Copyright © 2017 Airbnb. All rights reserved.

import UIKit
import DLSPrimitives

/// Configures an Epoxy view and handles adaptivity. Subclass this to set your content in `epoxySections()`.
open class EpoxyViewController: UIViewController {

  // MARK: Open

  open override func viewDidLoad() {
    super.viewDidLoad()
    epoxyView = makeEpoxyView()
    setUpViews()
    setUpConstraints()
  }

  open override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
    super.traitCollectionDidChange(previousTraitCollection)
    setEpoxySectionsIfReady()
  }

  /// Override this in your subclass to return your Epoxy sections
  open func epoxySections() -> [EpoxySection] {
    return []
  }

  /// Returns a standard `TableView` by default. Override this to configure another view type.
  open func makeEpoxyView() -> EpoxyView {
    let tableView = TableView.standardTableView
    tableView.rowDividerConfigurer = { [weak self] divider in
      guard let divider = divider as? EpoxyDivider else { return }
      if self?.traitCollection.horizontalSizeClass == .regular {
        divider.leadingPadding = Sizes.horizontalPadding(for: .regular)
        divider.trailingPadding = Sizes.horizontalPadding(for: .regular)
      } else {
        divider.leadingPadding = Sizes.horizontalPadding(for: .compact)
        divider.trailingPadding = Sizes.horizontalPadding(for: .compact)
      }
    }
    return tableView
  }

  // MARK: Public

  public var contentOffset: CGPoint? {
    return epoxyView?.contentOffset
  }

  /// Returns the Epoxy view as an `EpoxyInterface`
  public var epoxyInterface: EpoxyInterface? {
    return epoxyView as EpoxyInterface?
  }

  /// Updates the Epoxy view by calling the `epoxySections()` method. Optionally animated.
  public func updateData(animated: Bool) {
    if isViewLoaded {
      let sections = epoxySections()
      epoxyView.setSections(sections, animated: animated)
    }
  }

  // MARK: Private

  private var epoxyView: EpoxyView!

  private func setUpViews() {
    view.backgroundColor = .white
    epoxyView.addAsSubview(to: view)
    setEpoxySectionsIfReady()
  }

  private func setUpConstraints() {
    epoxyView.translatesAutoresizingMaskIntoConstraints = false
    epoxyView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
    epoxyView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
    epoxyView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    epoxyView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
  }

  private func updateLayoutMargins() {
    let padding = Sizes.horizontalPadding(for: traitCollection.horizontalSizeClass)
    epoxyView.layoutMargins = UIEdgeInsets(
      top: 0,
      left: padding,
      bottom: 0,
      right: padding)
  }

  private func setEpoxySectionsIfReady() {
    if traitCollection.horizontalSizeClass != .unspecified {
      updateLayoutMargins()
      updateData(animated: false)
    }
  }

}
