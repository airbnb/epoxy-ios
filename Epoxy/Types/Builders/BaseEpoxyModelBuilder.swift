// Created by tyler_hedrick on 7/11/18.
// Copyright © 2018 Airbnb. All rights reserved.

import UIKit

// MARK: - BaseEpoxyModelBuilder

/// An object used to progressively build EpoxyModels
public final class BaseEpoxyModelBuilder<ViewType, DataType> where
  ViewType: UIView,
  DataType: Equatable
{

  public init(data: DataType, dataID: EpoxyStringRepresentable) {
    self.data = data
    self.dataID = dataID.epoxyStringValue
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
      makeView: makeView,
      configureView: configureView,
      didChangeState: didChangeState,
      setBehaviors: behaviorSetter,
      didSelect: didSelect,
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

  /**
   NOTE: The with(...) functions which take closures and return Void apply additively if you call them multiple times.
   This is intended to allow for layering additional logic on top of a model produced somewhere else.
   */

  public func configureView(_ configureView: @escaping (EpoxyContext<ViewType, DataType>) -> Void) -> BaseEpoxyModelBuilder {
    let oldConfigureView = self.configureView
    self.configureView = { context in
      oldConfigureView(context)
      configureView(context)
    }

    return self
  }

  public func setBehaviors(_ behaviorSetter: ((EpoxyContext<ViewType, DataType>) -> Void)?) -> BaseEpoxyModelBuilder {
    guard let newBehaviorSetter = behaviorSetter else { return self }

    if let oldBehaviorSetter = self.behaviorSetter {
      self.behaviorSetter = { context in
        oldBehaviorSetter(context)
        newBehaviorSetter(context)
      }
    } else {
      self.behaviorSetter = newBehaviorSetter
    }

    return self
  }

  public func didSelect(_ didSelect: ((EpoxyContext<ViewType, DataType>) -> Void)?) -> BaseEpoxyModelBuilder {
    guard let newDidSelect = didSelect else { return self }

    if let oldDidSelect = self.didSelect {
      self.didSelect = { context in
        oldDidSelect(context)
        newDidSelect(context)
      }
    } else {
      self.didSelect = newDidSelect
    }

    return self
  }

  public func didChangeState(_ didChangeState: ((EpoxyContext<ViewType, DataType>) -> Void)?) -> BaseEpoxyModelBuilder {
    guard let newDidChangeState = didChangeState else { return self }

    if let oldDidChangeState = self.didChangeState {
      self.didChangeState = { context in
        oldDidChangeState(context)
        newDidChangeState(context)
      }
    } else {
      self.didChangeState = newDidChangeState
    }

    return self
  }

  public func willDisplay(_ willDisplay: ((DataType, String) -> Void)?) -> BaseEpoxyModelBuilder {
    guard let newWillDisplay = willDisplay else { return self }

    if let oldWillDisplay = self.willDisplay {
      self.willDisplay = { data, string in
        oldWillDisplay(data, string)
        newWillDisplay(data, string)
      }
    } else {
      self.willDisplay = newWillDisplay
    }

    return self
  }

  public func didEndDisplaying(_ didEndDisplaying: ((DataType, String) -> Void)?) -> BaseEpoxyModelBuilder {
    guard let newDidEndDisplaying = didEndDisplaying else { return self }

    if let oldDidEndDisplaying = self.didEndDisplaying {
      self.didEndDisplaying = { data, string in
        oldDidEndDisplaying(data, string)
        newDidEndDisplaying(data, string)
      }
    } else {
      self.didEndDisplaying = newDidEndDisplaying
    }

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
