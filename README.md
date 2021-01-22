# Epoxy

Epoxy is a suite of declarative UI APIs for building [UIKit](https://developer.apple.com/documentation/uikit) applications in Swift. Epoxy is inspired and influenced by the wonderful [Epoxy framework on Android](https://github.com/airbnb/epoxy), as well as other declarative UI frameworks in Swift such as [SwiftUI](https://developer.apple.com/documentation/swiftui).

Epoxy was developed at [Airbnb](https://www.airbnb.com/) and powers thousands of screens in apps that are shipped to millions of users. It has been developed and refined for years by [dozens of contributors](https://github.com/airbnb/epoxy-ios/graphs/contributors).

## Installation

Epoxy can be installed using [CocoaPods](#CocoaPods) or [Swift Package Manager](#Swift-Package-Manager-(SPM)).

### CocoaPods

To get started with Epoxy using [Cocoapods](https://cocoapods.org) add the following to your `Podfile` and then follow the [integration instructions](https://guides.cocoapods.org/using/using-cocoapods.html).

```ruby
pod 'Epoxy'
```

Epoxy is separated into a number of distinct [podspecs](https://guides.cocoapods.org/syntax/podspec.html) for each [module](#modules) so you only have to include what you need.

### Swift Package Manager (SPM)

To install Epoxy using [Swift Package Manager](https://github.com/apple/swift-package-manager)  you can follow the [tutorial published by Apple](https://developer.apple.com/documentation/xcode/adding_package_dependencies_to_your_app) using the URL for the Epoxy repo with the current version.

Epoxy is separated into a number of [library products](https://swift.org/package-manager/#products) for each [module](#modules) so you only have to include what you need.

## Modules

Epoxy has a modular architecture so you only have to include what you need for your use case:

| Module | Description |
| ------ | ----------- |
| `Epoxy` | Includes all of the below modules in a single import statement |
| [`EpoxyCollectionView`](#EpoxyCollectionView) | Declarative APIs for driving content of a [`UICollectionView`](https://developer.apple.com/documentation/uikit/uicollectionview) |
| [`EpoxyNavigationController`](#EpoxyNavigationController) | Declarative APIs for driving the navigation stack of a [`UINavigationController`](https://developer.apple.com/documentation/uikit/uinavigationcontroller) |
| [`EpoxyBars`](#EpoxyBars) | Declarative APIs for adding fixed top and bottom bar stacks to a [`UIViewController`](https://developer.apple.com/documentation/uikit/uiviewcontroller) |
| `EpoxyCore` | Foundational APIs that are used to build all Epoxy declarative UI APIs |

## Getting Started

### EpoxyCollectionView

`EpoxyCollectionView` provides a declarative API for driving the content of a `UICollectionView`. `CollectionViewController` is a subclassable `UIViewController` that lets you easily spin up a `UICollectionView`-backed view controller with a declarative API.

The following code samples will render a single cell in a `UICollectionView` with a `TextRow` component rendered in that cell. Note that the `TextRow` component is a simple `UIView` containing two labels, and conforms to the [`EpoxyableView`](https://github.com/airbnb/epoxy-ios/blob/master/Sources/EpoxyCore/Views/EpoxyableView.swift) protocol.

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

`EpoxyBars` provides a declarative API for rendering fixed top, fixed bottom, or [input accessory](https://developer.apple.com/documentation/uikit/uiresponder/1621119-inputaccessoryview) bar stacks in a `UIViewController`.

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

### EpoxyNavigationController

`EpoxyNavigationController` provides a declarative API for driving the navigation stack of a `UINavigationController`.

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

  private enum DataID {
    case step1, step2
  }

  private var state = State() {
    didSet { setStack(stack, animated: true) }
  }

  private var stack: [NavigationModel?] {
    [step1, step2]
  }

  private var step1: NavigationModel {
    .root(dataID: DataID.step1) { [weak self] in
      Step1ViewController(didTapNext: {
        self?.state.showStep2 = true
      })
    }
  }

  private var step2: NavigationModel? {
    guard state.showStep2 else { return nil }

    return NavigationModel(
      dataID: DataID.step2,
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

There's also a full sample app with a lot of examples that you can either run via the `EpoxyExample` scheme in `Epoxy.xcworkspace` or just [browse its source](https://github.com/airbnb/epoxy-ios/tree/master/Example).

If you still have questions, feel free to create a new issue.

## FAQ

### Why would I use Epoxy and UIKit instead of SwiftUI?

SwiftUI is a declarative UI framework that was introduced by Apple in iOS 13. We've found that while SwiftUI has a fantastic API and is certainly the future of building UI on Apple platforms in the long term. However, in the short to medium term we have found that SwiftUI is not a good fit for most of our production use cases:
- SwiftUI behavior is unstable across iOS versions, with large behavior differences between minor and even patch iOS versions, especially on iOS 13
- It is not possible to substitute a SwiftUI `View` for a `UIView`, which makes it hard to mix UIKit and SwiftUI in large apps or gradually migrate to SwiftUI, especially in apps with custom UI components
- SwiftUI does not yet have the flexibility or maturity of the equivalent UIKit APIs, requiring you to "drop down" to UIKit, often after implementing a large fraction of your requirements using SwiftUI APIs
- SwiftUI hides the underlying view rendering system from consumers, limiting flexibility and introspection capabilities
- SwiftUI requires Swift reflection metadata, which large Swift apps often strip via the `SWIFT_REFLECTION_METADATA_LEVEL=none` build setting to reduce their binary size

## Contributing

Pull requests are welcome! We'd love help improving this library. Feel free to browse through open issues to look for things that need work. If you have a feature request or bug, please open a new issue so we can track it.

## License

Epoxy is released under the Apache License 2.0. See `LICENSE` for details.
