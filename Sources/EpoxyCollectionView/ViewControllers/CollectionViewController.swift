//  Created by Laura Skelton on 6/30/17.
//  Copyright © 2017 Airbnb. All rights reserved.

import EpoxyCore
import UIKit

/// A subclassable collection view controller that manages its sections declarative via an array of
/// `SectionModel`s that represent its scrollable content.
///
/// To update the sections of this view controller, call `setSections(_:animated:)` with a new array
/// of `SectionModel`s modeling the new content.
open class CollectionViewController: UIViewController {

  // MARK: Lifecycle

  /// Initializes a collection view controller and configures its collection view with the provided
  /// layout and sections once the view loads.
  public init(layout: UICollectionViewLayout, sections: [SectionModel]? = nil) {
    self.layout = layout
    initialSections = sections
    super.init(nibName: nil, bundle: nil)
  }

  /// Initializes a collection view controller and configures its collection view with the provided
  /// layout and a single section containing the given items once the view loads.
  ///
  /// The `SectionModel` containing the items has a data ID of `DefaultDataID.noneProvided`.
  public convenience init(layout: UICollectionViewLayout, items: [ItemModeling]) {
    let section = SectionModel(dataID: DefaultDataID.noneProvided, items: items)
    self.init(layout: layout, sections: [section])
  }

  /// Initializes a collection view controller and configures its collection view with the provided
  /// layout and sections once the view loads.
  public convenience init(
    layout: UICollectionViewLayout,
    @SectionModelBuilder sections: () -> [SectionModel])
  {
    self.init(layout: layout, sections: sections())
  }

  /// Initializes a collection view controller and configures its collection view with the provided
  /// layout and a single section containing the given items once the view loads.
  ///
  /// The `SectionModel` containing the items has a data ID of `DefaultDataID.noneProvided`.
  public convenience init(
    layout: UICollectionViewLayout,
    @ItemModelBuilder items: () -> [ItemModeling])
  {
    self.init(layout: layout, items: items())
  }

  @available(*, unavailable)
  public required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: Open

  open override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .systemBackground
    loadCollectionView()
  }

  /// A method that can be overridden by subclasses to initialize a custom `CollectionView` for this
  /// view controller.
  ///
  /// Returns a `CollectionView` with `layout` by default.
  open func makeCollectionView() -> CollectionView {
    CollectionView(layout: layout)
  }

  // MARK: Public

  /// The layout object used to initialize the collection view controller.
  public let layout: UICollectionViewLayout

  /// The collection view rendering this view controller's sections, else `nil` if it has not yet
  /// been loaded.
  public private(set) var collectionViewIfLoaded: CollectionView?

  /// The collection view that renders this view controller's sections.
  ///
  /// Access triggers the view to load.
  public var collectionView: CollectionView {
    // Ensure view setup always follows the same path of `viewDidLoad` -> `loadCollectionView` for
    // consistent setup ordering when collection view access occurs before view access.
    loadViewIfNeeded()
    return loadCollectionView()
  }

  /// Updates the sections of the `collectionView` to the provided `sections`, optionally animating
  /// the differences from the current sections.
  ///
  /// If `collectionView` has not yet been loaded, `sections` are stored until the view loads and
  /// set on `collectionView` non-animatedly at that point.
  public func setSections(_ sections: [SectionModel], animated: Bool) {
    guard let collectionView = collectionViewIfLoaded else {
      initialSections = sections
      return
    }
    collectionView.setSections(sections, animated: animated)
  }

  /// Updates the sections of the `collectionView` to a single section with the provided `items`,
  /// optionally animating the differences from the current sections.
  ///
  /// If `collectionView` has not yet been loaded, the section containing `items` is stored until
  /// the view loads and set on `collectionView` non-animatedly at that point.
  ///
  /// The `SectionModel` containing the items has a data ID of `DefaultDataID.noneProvided`.
  public func setItems(_ items: [ItemModeling], animated: Bool) {
    let section = SectionModel(dataID: DefaultDataID.noneProvided, items: items)
    setSections([section], animated: animated)
  }

  // MARK: Private

  /// The sections that should be set on the collection view when it loads, else `nil`.
  private var initialSections: [SectionModel]?

  /// Loads the collection view or returns it if already loaded.
  @discardableResult
  private func loadCollectionView() -> CollectionView {
    if let collectionView = collectionViewIfLoaded { return collectionView }

    let collectionView = makeCollectionView()
    collectionViewIfLoaded = collectionView

    view.addSubview(collectionView)
    collectionView.layoutDelegate = self

    collectionView.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      collectionView.topAnchor.constraint(equalTo: view.topAnchor),
      collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
      collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
    ])

    if let sections = initialSections {
      collectionView.setSections(sections, animated: false)
      initialSections = nil
    }

    return collectionView
  }
}
