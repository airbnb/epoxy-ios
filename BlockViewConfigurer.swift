//  Created by Laura Skelton on 3/14/17.
//  Copyright © 2017 Airbnb. All rights reserved.

import UIKit

// MARK: BlockConfigurableView

/// A protocol for views that can be configured with a specific data type.
public protocol BlockConfigurableView {

  associatedtype Data

  /**
   A function that configures the given view with the specified data.

   - Parameter view: A view of this type to be configured
   - Parameter data: The data to be used to configure the view
   */
  static func configureView(_ view: Self, with data: Data)
}

// MARK: BlockViewConfigurer

/// A flexible `ListItem` class for configuring views of a specific type with data of a specific type, 
/// using blocks for creation and configuration. This was designed to be used in a `ListInterface` 
/// to lazily create and configure views as they are recycled in a `UITableView` or `UICollectionView`.
public class BlockViewConfigurer<ViewType, DataType>: ViewConfigurer where
  ViewType: UIView,
  DataType: Equatable
{
  // MARK: Lifecycle

  /**
   Initializes a `ListItem` that creates and configures a specific type of view for display in a `ListInterface`.

   - Parameters:
    - builder: Something that returns this view type. It will be wrapped in a closure and called as needed to lazily create views.
    - configurer: A closure that configures this view type with the specified data type.
    - data: The data this view takes for configuration, specific to this particular list item instance.
    - dataID: An optional ID to differentiate this row from other rows, used when diffing.
   
   - Returns: A `ListItem` instance that will create the specified view type with this data.
   */
  public init(
    builder: @escaping @autoclosure () -> ViewType,
    configurer: @escaping (ViewType, DataType) -> Void,
    data: DataType,
    dataID: String? = nil)
  {
    self.data = data
    self.builder = builder
    self.configurer = configurer
    self.dataID = dataID
  }

  // MARK: Public

  public private(set) var dataID: String?
  public private(set) var data: DataType

  public func isDiffableItemEqual(to otherDiffableItem: Diffable) -> Bool {
    if let other = otherDiffableItem as? BlockViewConfigurer<ViewType, DataType> {
      return self.data == other.data
    } else {
      return false
    }
  }

  public func makeView() -> ViewType {
    return builder()
  }

  public func configureView(_ view: ViewType, animated: Bool) {
    configurer(view, data)
  }

  // MARK: Private

  private let builder: () -> ViewType
  private let configurer: (ViewType, DataType) -> Void
}

extension BlockConfigurableView where
  Self: UIView,
  Self.Data: Equatable
{
  /**
   A convenience method to create a `ListItem` that creates and configures this type of view for display in a `ListInterface`.

   - Parameter builder: Something that returns this view type. It will be wrapped in a closure and called as needed to lazily create views.
   - Parameter data: The data this view takes for configuration, specific to this particular list item instance.
   - Parameter dataID: An optional ID to differentiate this row from other rows, used when diffing.

   - Returns: A `ListItem` instance that will create the specified view type with this data.
   
   - Note: The `builder` parameter will be wrapped in a closure automatically. The view will not be created until it is needed.
   */
  public static func with(
    builder: @escaping @autoclosure () -> Self = Self(),
    data: Data,
    dataID: String? = nil) -> BlockViewConfigurer<Self, Data>
  {
    return BlockViewConfigurer<Self, Data>(
      builder: builder,
      configurer: { view, data in
        Self.configureView(view, with: data)
    },
      data: data,
      dataID: dataID)
  }

  /**
   A convenience method to create a `ListItem` that creates and configures this type of view for display in a `ListInterface`.

   - Parameter data: The data this view takes for configuration, specific to this particular list item instance.
   - Parameter dataID: An optional ID to differentiate this row from other rows, used when diffing.

   - Returns: A `ListItem` instance that will create the specified view type with this data.
   
   - Note: This uses an empty `init()` to create the view. Don't use this if you need to use a different `init()`.
   */
  /*
  public static func with(
    data: Data,
    dataID: String? = nil) -> BlockViewConfigurer<Self, Data>
  {
    return BlockViewConfigurer<Self, Data>(
      builder: Self(),
      configurer: { view, data in
        Self.configureView(view, with: data)
    },
      data: data,
      dataID: dataID)
  }
 */
}

/// If you mark a view with this protocol, you can use these nice convenience methods to create 
/// a BlockViewConfigurer, eg. `MyCustomView.listItem(....)
public protocol ConfigurableView { }

extension ConfigurableView where
Self: UIView
{
  /**
   A convenience method to create a `ListItem` that creates and configures this type of view for display in a `ListInterface`.

   - Parameter builder: Something that returns this view type. It will be wrapped in a closure and called as needed to lazily create views.
   - Parameter configurer: Something that configures this view type with the given data.
   - Parameter data: The data this view takes for configuration, specific to this particular list item instance.
   - Parameter dataID: An optional ID to differentiate this row from other rows, used when diffing.

   - Returns: A `ListItem` instance that will create the specified view type with this data.

   - Note: The `builder` parameter will be wrapped in a closure automatically. The view will not be created until it is needed.
   */
  public static func listItem<DataType: Equatable>(
    builder: @escaping @autoclosure () -> Self,
    configurer: @escaping (Self, DataType) -> Void,
    data: DataType,
    dataID: String? = nil) -> BlockViewConfigurer<Self, DataType>
  {
    return BlockViewConfigurer<Self, DataType>(
      builder: builder,
      configurer: configurer,
      data: data,
      dataID: dataID)
  }

  /**
   A convenience method to create a `ListItem` that creates and configures this type of view for display in a `ListInterface`.

   - Parameter configurer: Something that configures this view type with the given data.
   - Parameter data: The data this view takes for configuration, specific to this particular list item instance.
   - Parameter dataID: An optional ID to differentiate this row from other rows, used when diffing.

   - Returns: A `ListItem` instance that will create the specified view type with this data.

   - Note: This uses an empty `init()` to create the view. Don't use this if you need to use a different `init()`.
   */
  public static func listItem<DataType: Equatable>(
    configurer: @escaping (Self, DataType) -> Void,
    data: DataType,
    dataID: String? = nil) -> BlockViewConfigurer<Self, DataType>
  {
    return BlockViewConfigurer<Self, DataType>(
      builder: Self(),
      configurer: configurer,
      data: data,
      dataID: dataID)
  }

}
