# Epoxy

Epoxy is a suite of declarative UI frameworks for use in iOS applications written in Swift. It is inspired and influenced by the wonderful [Epoxy framework on Android](https://github.com/airbnb/epoxy), as well as declarative UI systems in Swift such as SwiftUI.

## Installation

Epoxy can be installed using CocoaPods, Carthage or Swift Package Manager.

### CocoaPods

To get started with Epoxy using [Cocoapods](https://cocoapods.org) add `pod 'Epoxy'` to your Podfile and then follow the integration tutorial [here](https://guides.cocoapods.org/using/using-cocoapods.html).

Epoxy also comes with a number of [subspecs](https://guides.cocoapods.org/syntax/podspec.html#subspec) so you only have to include what you need. The following subspecs are available:

| Subspec | Description |
| ------- | ----------- |
| `Epoxy/EpoxyCore` | Foundational module that contains the diffing algorithm and shared model storage |
| `Epoxy/EpoxyCollectionView` | Declarative API for driving content of a UICollectionView |
| `Epoxy/EpoxyNavigationController` | Declarative API for driving the navigation stack of a `UINavigationController` |
| `Epoxy/EpoxyBars` | Declarative API for fixed top and bottom bars in a `UIViewController` |

To use a subspec, simply include the name of the subspec in your `Podfile` instead of the entire library. If you only want `EpoxyCollectionView`, for example, use `pod 'Epoxy/EpoxyCollectionView'` in your `Podfile`. Using `pod 'Epoxy'` will include the entire Epoxy library.

### Carthage

To install Epoxy using [Carthage](https://github.com/Carthage/Carthage) include `github "airbnb/epoxy-ios"` in your `Cartfile` and follow the integrations instructions [here](https://github.com/Carthage/Carthage#if-youre-building-for-ios-tvos-or-watchos).

### Swift Package Manager (SPM)

To install Epoxy using [Swift Package Manager](https://github.com/apple/swift-package-manager) you can follow the tutorial published by Apple [here](https://developer.apple.com/documentation/xcode/adding_package_dependencies_to_your_app) using the URL for the Epoxy repo.

## Getting Started

### EpoxyCollectionView

`EpoxyCollectionView` provides a declarative API for driving the content of a `UICollectionView`. `EpoxyCollectionViewController` is a subclassable `UIViewController` that lets you easily spin up a `UICollectionView`-backed view controller with a declarative API.

The following code sample will render a single cell in a `UICollectionView` with a `UIButton` rendered in that cell:

```swift
import Epoxy

final class FeatureViewController: EpoxyCollectionViewController {
  private enum DataIDs {
    case ctaRow
  }

  override func epoxySections -> [SectionModel] {
    [
      SectionModel(items: [
        Row.itemModel(
          dataID: DataIDs.ctaRow,
          content: .init(title: "Click me!", body: ""),
          style: .large)
        .didSelect { context in 
          // handle selection here
        }
      ])
    ]
  }
}
```

### EpoxyBars

`EpoxyBars` provides a declarative API for rendering fixed top and bottom bars in a `UIViewController`

The following code example will render a `UIButton` fixed to the bottom of the `UIViewController's` view:

```swift
final class FeatureViewController: UIViewController {

  override func viewDidLoad() {
    super.viewDidLoad()
    bottomBarInstaller.setBars(bars, animated: false)
    bottomBarInstaller.install()
  }

  private lazy var bottomBarInstaller = BottomBarInstaller(viewController: self)

  private var bars: [BarModeling] {
    [
      ButtonRow.barModel(
        content: .init(title: "Click me!"),
        behaviors: .init(buttonWasTapped: { [weak self] button in 
          // handle selection of button here
        }))
    ]
  }

}
```

### EpoxyNavigation

`EpoxyNavigation` provides a declarative API for driving the navigation stack of a `UINavigationController`. 

The following code example shows how you can use this to easily drive a feature that has a flow of multiple view controllers:

```swift
final class FormViewController: NavigationController {

  override func viewDidLoad() {
    super.viewDidLoad()
    setStack(stack, animated: false)
  }

  // MARK: Private

  private struct State {
    var showStep2 = false
  }

  private enum DataIDs {
    case step1
    case step2
  }

  private var state = State() {
    didSet {
      setStack(stack, animated: true)
    }
  }

  private var stack: [NavigationModel?] {
    [
      step1,
      step2
    ]
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
      makeViewController: { [weak self] in
        let vc = Step2ViewController()
        vc.didTapNext = {
          // Navigate away from this form
        }
        return vc
      },
      remove: { [weak self] in
        self?.state.showStep2 = false
      })
  }
}
```

## Documentation and Tutorials

For full documentation and step-by-step tutorials please check the [wiki](https://github.com/airbnb/epoxy-ios/wiki).

There's also a full sample app with a lot of examples you can run [here](https://github.com/airbnb/epoxy-ios/tree/master/Example).

If you still have questions, feel free to create a new issue.

## Contributing

Pull requests are welcome! We'd love help improving this library. Feel free to browse through open issues to look for things that need work. If you have a feature request or bug, please open a new issue so we can track it.

## License

Epoxy is released under the Apache License 2.0. See `LICENSE` for details.
