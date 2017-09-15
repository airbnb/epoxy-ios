//  Created by Laura Skelton on 6/4/17.
//  Copyright © 2017 Airbnb. All rights reserved.

import UIKit
import DLSPrimitives

/// Configures an Epoxy view and handles adaptivity. Subclass this to set your content in `epoxySections()`.
open class EpoxyTableViewController: UIViewController {

  // MARK: Open

  open override func viewDidLoad() {
    super.viewDidLoad()
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

  /// Override this in your subclass to return the data IDs of any dividers you wish to hide.
  open func hiddenDividerDataIDs() -> [String] {
    return []
  }

  /// Returns a standard `TableView` by default. Override this to configure it differently.
  open func makeTableView() -> TableView {
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
    return tableView.contentOffset
  }

  public lazy var tableView: TableView = {
    assert(self.isViewLoaded, "Accessed tableView before view was loaded.")
    return self.makeTableView()
  }()

  /// Updates the Epoxy view by calling the `epoxySections()` method. Optionally animated.
  public func updateData(animated: Bool) {
    if isViewLoaded {
      let sections = epoxySections()
      tableView.setSections(sections, animated: animated)
      tableView.hideBottomDivider(for: hiddenDividerDataIDs())
    }
  }

  // MARK: Private

  private func setUpViews() {
    view.backgroundColor = .white
    view.addSubview(tableView)
    setEpoxySectionsIfReady()
  }

  private func setUpConstraints() {
    tableView.translatesAutoresizingMaskIntoConstraints = false
    let constraints = [
      tableView.topAnchor.constraint(equalTo: view.topAnchor),
      tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
      tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
    ]
    NSLayoutConstraint.activate(constraints)
  }

  private func updateLayoutMargins() {
    let padding = Sizes.horizontalPadding(for: traitCollection.horizontalSizeClass)
    tableView.layoutMargins = UIEdgeInsets(
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
