// Created by eric_horacek on 9/1/21.
// Copyright © 2021 Airbnb Inc. All rights reserved.

/// A singleton that enables consumers to control how bar installers' internal implementations
/// behave across the entire app, without needing to update every place that uses it.
///
/// Can additionally be provided when initializing a bar installer to customize the behavior of
/// that specific instance.
public struct BarInstallerConfiguration {

  // MARK: Lifecycle

  public init(
    applyBars: ((_ container: BarContainer, _ bars: [BarModeling], _ animated: Bool) -> Void)? = nil)
  {
    self.applyBars = applyBars
  }

  // MARK: Public

  /// The default configuration instance used if none is provided when initializing a bar installer.
  ///
  /// Set this to a new instance to override the default configuration.
  public static var shared = BarInstallerConfiguration()

  /// A closure that's invoked whenever new bar models are set on a `BarInstaller` following its
  /// initial configuration to customize _when_ those same bars are applied to the underlying
  /// `BarContainer` by invoking the provided `apply` closure.
  ///
  /// For example, when the bar installer is actively participating in a shared element transition,
  /// this property can be used to wait until the transition is over before apply the bar models to
  /// the underlying `BarContainer` to ensure that the shared bar elements remain constant over the
  /// course of the transition.
  ///
  /// Defaults to `nil`, resulting in any new bars being immediately applied to the underlying
  /// `BarContainer`.
  ///
  /// Not calling the provided `apply` closure will result in skipped bar model updates.
  public var applyBars: ((_ container: BarContainer, _ bars: [BarModeling], _ animated: Bool) -> Void)?

}
