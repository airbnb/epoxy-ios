# Epoxy

Epoxy is a suite of declarative UI frameworks building pure UIKit applications in Swift. Epoxy is inspired and influenced by the wonderful [Epoxy framework on Android](https://github.com/airbnb/epoxy), as well as declarative UI systems in Swift such as SwiftUI.

## Installation

Epoxy can be installed using CocoaPods, Carthage or Swift Package Manager.

### CocoaPods

To get started with Epoxy using [Cocoapods](https://cocoapods.org) add `pod 'Epoxy'` to your Podfile and then follow the integration instructions [here](https://guides.cocoapods.org/using/using-cocoapods.html).

Epoxy also comes with a number of [subspecs](https://guides.cocoapods.org/syntax/podspec.html#subspec) so you only have to include what you need. The following subspecs are available:

| Subspec | Description |
| ------- | ----------- |
| `Epoxy/EpoxyCore` | Foundational module that contains the diffing algorithm and shared model storage |
| `Epoxy/EpoxyCollectionView` | Declarative API for driving content of a UICollectionView |
| `Epoxy/EpoxyNavigationController` | Declarative API for driving the navigation stack of a `UINavigationController` |
| `Epoxy/EpoxyBars` | Declarative API for fixed top and bottom bars in a `UIViewController` |

To use a subspec, simply include the name of the subspec in your `Podfile` instead of the entire library. If you only want `EpoxyCollectionView`, for example, use `pod 'Epoxy/EpoxyCollectionView'` in your `Podfile`. Using `pod 'Epoxy'` will include the entire Epoxy library.

### Carthage

To install Epoxy using [Carthage](https://github.com/Carthage/Carthage) include `github "airbnb/epoxy-ios"` in your `Cartfile` and follow the integration instructions [here](https://github.com/Carthage/Carthage#if-youre-building-for-ios-tvos-or-watchos).

### Swift Package Manager (SPM)

To install Epoxy using [Swift Package Manager](https://github.com/apple/swift-package-manager) you can follow the tutorial published by Apple [here](https://developer.apple.com/documentation/xcode/adding_package_dependencies_to_your_app) using the URL for the Epoxy repo.

## Getting Started

### EpoxyCollectionView

`EpoxyCollectionView` provides a declarative API for driving the content of a `UICollectionView`. `CollectionViewController` is a subclassable `UIViewController` that lets you easily spin up a `UICollectionView`-backed view controller with a declarative API.

The following code samples will render a single cell in a `UICollectionView` with a `TextRow` component rendered in that cell. Note that the `TextRow` component is a simple `UIView` containing 2 labels, and conforms to the [`EpoxyableView`](https://github.com/airbnb/epoxy-ios/blob/master/Sources/EpoxyCore/Views/EpoxyableView.swift) protocol.

You can either instantiate a `CollectionViewController` instance directly with sections, e.g. this view controller with a selectable row:

<table>
<tr><td> Source </td> <td> Result </td></tr>
<tr>
<td>

```swift
enum DataID {
  case row
}

let viewController = CollectionViewController(
  layout: UICollectionViewCompositionalLayout
    .list(using: .init(appearance: .plain)),
  sections: [
    SectionModel(items: [
      TextRow.itemModel(
        dataID: DataID.row,
        content: .init(title: "Tap me!"),
        style: .small)
        .didSelect { _ in
          // Handle selection
        }
    ])
  ])
```

</td>
<td>

<img width="250" alt="Screenshot" src="docs/images/tap_me_example.png">

</td>
</tr>
</table>

Or you can subclass `CollectionViewController` for more advanced scenarios, e.g. this view controller that keeps track of a running count:

<table>
<tr><td> Source </td> <td> Result </td></tr>
<tr>
<td>

```swift
class CounterViewController: CollectionViewController {
  init() {
    let layout = UICollectionViewCompositionalLayout
      .list(using: .init(appearance: .plain))
    super.init(layout: layout)
    setSections(sections, animated: false)
  }

  private enum DataID {
    case row
  }

  private var count = 0 {
    didSet { setSections(sections, animated: true) }
  }

  private var sections: [SectionModel] {
    [
      SectionModel(items: [
        TextRow.itemModel(
          dataID: DataID.row,
          content: .init(
            title: "Count \(count)",
            body: "Tap to increment"),
          style: .large)
          .didSelect { [weak self] _ in
            self?.count += 1
          }
      ])
    ]
  }
}
```

</td>
<td>

<img width="250" alt="Screenshot" src="docs/images/counter_example.gif">

</td>
</tr>
</table>

### EpoxyBars

`EpoxyBars` provides a declarative API for rendering fixed top, bottom, or input accessory bars in a `UIViewController`.

The following code example will render a `ButtonRow` component fixed to the bottom of the `UIViewController`'s view. Note that `ButtonRow` is a simple `UIView` component that contains a single `UIButton` constrained to the margins of the superview that conforms to the `EpoxyableView` protocol:

<table>
<tr><td> Source </td> <td> Result </td></tr>
<tr>
<td>

```swift
class BottomButtonViewController: UIViewController {
  override func viewDidLoad() {
    super.viewDidLoad()
    bottomBarInstaller.install()
  }

  private lazy var bottomBarInstaller = BottomBarInstaller(
    viewController: self,
    bars: bars)

  private var bars: [BarModeling] {
    [
      ButtonRow.barModel(
        content: .init(text: "Click me!"),
        behaviors: .init(didTap: {
          // Handle button selection
        }))
    ]
  }
}
```

</td>
<td>

<img width="250" alt="Screenshot" src="docs/images/bottom_button_example.png">

</td>
</tr>
</table>

### EpoxyNavigation

`EpoxyNavigation` provides a declarative API for driving the navigation stack of a `UINavigationController`.

The following code example shows how you can use this to easily drive a feature that has a flow of multiple view controllers:

<table>
<tr><td> Source </td> <td> Result </td></tr>
<tr>
<td>

```swift
class FormNavigationController: NavigationController {
  init() {
    super.init()
    setStack(stack, animated: false)
  }

  private struct State {
    var showStep2 = false
  }

  private enum DataIDs {
    case step1, step2
  }

  private var state = State() {
    didSet { setStack(stack, animated: true) }
  }

  private var stack: [NavigationModel?] {
    [step1, step2]
  }

  private var step1: NavigationModel {
    .root(dataID: DataIDs.step1) { [weak self] in
      Step1ViewController(didTapNext: {
        self?.state.showStep2 = true
      })
    }
  }

  private var step2: NavigationModel? {
    guard state.showStep2 else { return nil }

    return NavigationModel(
      dataID: DataIDs.step2,
      makeViewController: {
        Step2ViewController(didTapNext: {
          // Navigate away from this step.
        })
      },
      remove: { [weak self] in
        self?.state.showStep2 = false
      })
  }
}
```

</td>
<td>

<img width="250" alt="Screenshot" src="docs/images/form_navigation_example.gif">

</td>
</tr>
</table>

## Documentation and Tutorials

For full documentation and step-by-step tutorials please check the [wiki](https://github.com/airbnb/epoxy-ios/wiki).

There's also a full sample app with a lot of examples you can run by opening `Epoxy.xcworkspace` and running the `EpoxyExample` scheme or browse the [source of](https://github.com/airbnb/epoxy-ios/tree/master/Example).

If you still have questions, feel free to create a new issue.

## Contributing

Pull requests are welcome! We'd love help improving this library. Feel free to browse through open issues to look for things that need work. If you have a feature request or bug, please open a new issue so we can track it.

## License

Epoxy is released under the Apache License 2.0. See `LICENSE` for details.
