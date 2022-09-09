// Created by eric_horacek on 9/8/22.
// Copyright © 2022 Airbnb Inc. All rights reserved.

import SwiftUI

// MARK: - SwiftUIUIView

/// A `UIViewRepresentable` SwiftUI `View` that wraps its `Content` `UIView` within a
/// `SwiftUIMeasurementContainer`, used to size a UIKit view correctly within a SwiftUI view
/// hierarchy.
public struct SwiftUIUIView<Content: UIView, Storage>: MeasuringUIViewRepresentable, UIViewConfiguringSwiftUIView {

  // MARK: Lifecycle

  init(storage: Storage, makeContent: @escaping () -> Content) {
    self.storage = storage
    self.makeContent = makeContent
  }

  init(makeContent: @escaping () -> Content) where Storage == Void {
    storage = ()
    self.makeContent = makeContent
  }

  // MARK: Public

  /// An array of closures that are invoked to configure the represented view.
  public var configurations: [(ConfigurationContext) -> Void] = []

  /// The sizing context used to size the represented view.
  public var sizing = SwiftUIMeasurementContainerStrategy.automatic

  public func makeUIView(context _: Context) -> SwiftUIMeasurementContainer<Content> {
    SwiftUIMeasurementContainer(content: makeContent(), strategy: sizing)
  }

  public func makeCoordinator() -> Coordinator {
    Coordinator(storage: storage)
  }

  public func updateUIView(_ uiView: SwiftUIMeasurementContainer<Content>, context: Context) {
    let oldStorage = context.coordinator.storage
    context.coordinator.storage = storage

    let configurationContext = ConfigurationContext(oldStorage: oldStorage,
      viewRepresentableContext: context,
      container: uiView)

    for configuration in configurations {
      configuration(configurationContext)
    }
  }

  // MARK: Internal

  /// The current stored value, with the previous value provided to the configuration closure as
  /// the `oldStorage`.
  var storage: Storage

  /// A closure that's invoked to construct the represented view.
  var makeContent: () -> Content
}

// MARK: - SwiftUIUIView.ConfigurationContext

extension SwiftUIUIView {
  /// The configuration context that's available to configure the `Content` view whenever the
  /// `updateUIView()` method is invoked via a configuration closure.
  public struct ConfigurationContext: ViewProviding {
    /// The `UIView` that's being configured.
    ///
    /// Setting this to a new value updates the backing measurement container's `content`.
    public var view: Content {
      get { container.content }
      nonmutating set { container.content = newValue }
    }

    /// The previous value for the `Storage` of this `SwiftUIUIView`, which can be used to store
    /// values across state changes to prevent redundant view updates.
    public var oldStorage: Storage

    /// The `UIViewRepresentable.Context`, with information about the transaction and environment.
    public var viewRepresentableContext: Context

    /// A convenience accessor indicating whether this content update was animated.
    public var animated: Bool {
      viewRepresentableContext.transaction.animation != nil
    }

    /// The backing measurement container that contains the `Content`.
    public var container: SwiftUIMeasurementContainer<Content>
  }
}

// MARK: - SwiftUIUIView.Coordinator

extension SwiftUIUIView {
  /// A coordinator that stores the `storage` associated with this view.
  public final class Coordinator {

    // MARK: Lifecycle

    init(storage: Storage) {
      self.storage = storage
    }

    // MARK: Internal

    var storage: Storage
  }
}
