//  Created by Laura Skelton on 6/30/17.
//  Copyright © 2017 Airbnb. All rights reserved.

import EpoxyCore
import UIKit

open class EpoxyCollectionViewController: UIViewController {

  // MARK: Lifecycle

  public init(collectionViewLayout: UICollectionViewLayout) {
    self.collectionViewLayout = collectionViewLayout
    super.init(nibName: nil, bundle: nil)
  }

  public required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: Open

  open override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .white
    loadCollectionView()
  }

  open override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
    super.traitCollectionDidChange(previousTraitCollection)
    setEpoxySectionsIfReady()
  }

  /// Override this in your subclass to return your sections.
  open func epoxySections() -> [SectionModel] {
    []
  }

  /// Returns a `CollectionView` by default. Override this to configure it differently.
  open func makeCollectionView() -> CollectionView {
    CollectionView(collectionViewLayout: collectionViewLayout)
  }

  // MARK: Public

  /// The collection view rendering the content in `epoxySections`
  ///
  /// Access triggers the view to load.
  public var collectionView: CollectionView {
    // Ensure view setup always follows the same path of `viewDidLoad` -> `loadCollectionView` for
    // consistent setup ordering when collection view access occurs before view access.
    loadViewIfNeeded()
    return loadCollectionView()
  }

  /// Updates the Epoxy view by calling the `epoxySections()` method. Optionally animated.
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
    if traitCollection.horizontalSizeClass != .unspecified {
      updateData(animated: false)
    }
  }

}
