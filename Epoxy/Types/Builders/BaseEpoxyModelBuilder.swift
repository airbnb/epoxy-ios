// Created by tyler_hedrick on 7/11/18.
// Copyright © 2018 Airbnb. All rights reserved.

import UIKit

// MARK: - BaseEpoxyModelBuilder

/// An object used to progressively build EpoxyModels
public final class BaseEpoxyModelBuilder<ViewType, DataType> where
  ViewType: UIView,
  DataType: Equatable
{

  public init(data: DataType, dataID: String) {
    self.data = data
    self.dataID = dataID
  }

  // MARK: Public

  /// Builds the final immutable EpoxyModel from the current data
  ///
  /// - Returns: an EpoxyModel
  public func build() -> EpoxyModel<ViewType, DataType> {
    return EpoxyModel<ViewType, DataType>(
      data: data,
      dataID: dataID,
      alternateStyleID: alternateStyleID,
      builder: makeView,
      configurer: configureView,
      stateConfigurer: didChangeState,
      behaviorSetter: behaviorSetter,
      selectionHandler: didSelect,
      willDisplay: willDisplay,
      didEndDisplaying: didEndDisplaying,
      userInfo: userInfo)
  }

  public func alternateStyleID(_ alternateStyleID: String?) -> BaseEpoxyModelBuilder {
    self.alternateStyleID = alternateStyleID
    return self
  }

  public func makeView(_ makeView: @escaping () -> ViewType) -> BaseEpoxyModelBuilder {
    self.makeView = makeView
    return self
  }

  public func configureView(_ configureView: @escaping (EpoxyContext<ViewType, DataType>) -> Void) -> BaseEpoxyModelBuilder {
    self.configureView = configureView
    return self
  }

  public func setBehaviors(_ behaviorSetter: ((EpoxyContext<ViewType, DataType>) -> Void)?) -> BaseEpoxyModelBuilder {
    self.behaviorSetter = behaviorSetter
    return self
  }

  public func didSelect(_ didSelect: ((EpoxyContext<ViewType, DataType>) -> Void)?) -> BaseEpoxyModelBuilder {
    self.didSelect = didSelect
    return self
  }

  public func didChangeState(_ didChangeState: ((EpoxyContext<ViewType, DataType>) -> Void)?) -> BaseEpoxyModelBuilder {
    self.didChangeState = didChangeState
    return self
  }

  public func willDisplay(_ willDisplay: ((DataType, String) -> Void)?) -> BaseEpoxyModelBuilder {
    self.willDisplay = willDisplay
    return self
  }

  public func didEndDisplaying(_ didEndDisplaying: ((DataType, String) -> Void)?) -> BaseEpoxyModelBuilder {
    self.didEndDisplaying = didEndDisplaying
    return self
  }

  public func userInfo(_ userInfo: [EpoxyUserInfoKey: Any]) -> BaseEpoxyModelBuilder {
    self.userInfo = userInfo
    return self
  }

  public func setUserInfoValue(_ value: Any, for key: EpoxyUserInfoKey) -> BaseEpoxyModelBuilder {
    userInfo[key] = value
    return self
  }

  // MARK: Private

  private var data: DataType
  private var dataID: String
  private var alternateStyleID: String? = nil
  private var makeView: () -> ViewType = { ViewType() }
  private var configureView: (EpoxyContext<ViewType, DataType>) -> Void = { _ in }
  private var didChangeState: ((EpoxyContext<ViewType, DataType>) -> Void)? = nil
  private var behaviorSetter: ((EpoxyContext<ViewType, DataType>) -> Void)? = nil
  private var didSelect: ((EpoxyContext<ViewType, DataType>) -> Void)? = nil
  private var willDisplay: ((DataType, String) -> Void)? = nil
  private var didEndDisplaying: ((DataType, String) -> Void)? = nil
  private var userInfo: [EpoxyUserInfoKey: Any] = [:]
}

// MARK: Subscript

extension BaseEpoxyModelBuilder {
  /// provides a subscript interface to set and get values from the userInfo
  /// dictionary on a builder
  /// example usage: `builder[EpoxyUserInfoKey.customKey] = customValue`
  public subscript<T>(key: EpoxyUserInfoKey) -> T? {
    get { return userInfo[key] as? T }
    set { userInfo[key] = newValue }
  }
}
