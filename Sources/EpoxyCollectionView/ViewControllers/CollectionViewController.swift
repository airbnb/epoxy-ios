//  Created by Laura Skelton on 6/30/17.
//  Copyright © 2017 Airbnb. All rights reserved.

import EpoxyCore
import UIKit

/// A subclassable `UIViewController` with its content provided by an overridden `epoxySections()`
/// method, queried first when a valid `traitCollection` is determined and subsequently whenever
/// `updateData(animated:)` is called.
open class CollectionViewController: UIViewController {

  // MARK: Lifecycle

  /// Initializes a collection view controller and configures the collection view with the provided
  /// layout.
  public init(collectionViewLayout: UICollectionViewLayout) {
    self.collectionViewLayout = collectionViewLayout
    super.init(nibName: nil, bundle: nil)
  }

  @available(*, unavailable)
  public required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: Open

  open override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .systemBackground
    loadCollectionView()
  }

  open override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
    super.traitCollectionDidChange(previousTraitCollection)
    setEpoxySectionsIfReady()
  }

  /// Override this in your subclass to return your sections.
  ///
  /// Queried first when a valid `traitCollection` is determined and subsequently whenever
  /// `updateData(animated:)` is called.
  open func epoxySections() -> [SectionModel] {
    []
  }

  /// Returns a `CollectionView` by default. Override this to configure it differently.
  open func makeCollectionView() -> CollectionView {
    CollectionView(collectionViewLayout: collectionViewLayout)
  }

  // MARK: Public

  /// The collection view rendering the content in `epoxySections()`
  ///
  /// Access triggers the view to load.
  public var collectionView: CollectionView {
    // Ensure view setup always follows the same path of `viewDidLoad` -> `loadCollectionView` for
    // consistent setup ordering when collection view access occurs before view access.
    loadViewIfNeeded()
    return loadCollectionView()
  }

  /// Updates the collection view sections by calling the `epoxySections()` method, optionally
  /// animating the updates.
  public func updateData(animated: Bool) {
    if isViewLoaded && traitCollection.horizontalSizeClass != .unspecified {
      let sections = epoxySections()
      collectionView.setSections(sections, animated: animated)
    }
  }

  // MARK: Private

  private let collectionViewLayout: UICollectionViewLayout
  private var _collectionView: CollectionView?

  @discardableResult
  private func loadCollectionView() -> CollectionView {
    if let collectionView = _collectionView { return collectionView }

    let collectionView = makeCollectionView()
    _collectionView = collectionView

    view.addSubview(collectionView)
    collectionView.layoutDelegate = self

    collectionView.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      collectionView.topAnchor.constraint(equalTo: view.topAnchor),
      collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
      collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
    ])

    setEpoxySectionsIfReady()
    return collectionView
  }

  private func setEpoxySectionsIfReady() {
    guard traitCollection.horizontalSizeClass != .unspecified else { return }
    updateData(animated: false)
  }
}
