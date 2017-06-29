//  Created by Laura Skelton on 12/6/16.
//  Copyright © 2016 Airbnb. All rights reserved.

import UIKit

/// A protocol for a view that can be powered by an array of `EpoxySection`s
public protocol EpoxyInterface: class {

  /// Sets the sections on the view
  func setSections(_ sections: [EpoxySection]?, animated: Bool)

  /// Updates the item at the given data ID with the new item and configures the cell if it's visible
  func updateItem(at dataID: String, with item: EpoxyableModel, animated: Bool)

}

extension EpoxyInterface {

  /// Sets the items on the view
  public func setItems(_ items: [EpoxyableModel], animated: Bool) {
    let section = EpoxySection(items: items)
    setSections([section], animated: animated)
  }
}

/// A protocol to allow us to lay out any EpoxyView on a page without knowing the specific class type.
public protocol EpoxyView: EpoxyInterface {

  var translatesAutoresizingMaskIntoConstraints: Bool { get set }
  var layoutMargins: UIEdgeInsets { get set }
  var topAnchor: NSLayoutYAxisAnchor { get }
  var leadingAnchor: NSLayoutXAxisAnchor { get }
  var bottomAnchor: NSLayoutYAxisAnchor { get }
  var trailingAnchor: NSLayoutXAxisAnchor { get }
  func addAsSubview(to view: UIView)
  
}

extension UIView {

  public func addAsSubview(to view: UIView) {
    view.addSubview(self)
  }

}
