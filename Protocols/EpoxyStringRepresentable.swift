import Foundation

// MARK: - EpoxyStringRepresentable

/// Protocol for a type that can be represented by a string value
public protocol EpoxyStringRepresentable {

  var stringValue: String { get }

  init?(stringValue: String)
}

public extension EpoxyStringRepresentable {
  public init?(optionalStringValue: String?) {
    guard let someStringValue = optionalStringValue else { return nil }
    self.init(stringValue: someStringValue)
  }
}

// MARK: - String

extension String: EpoxyStringRepresentable {

  public var stringValue: String {
    return self
  }

  public init?(stringValue: String) {
    self.init(stringValue)
  }
}

// MARK: - RawRepresentable

extension RawRepresentable where RawValue == String {

  public var stringValue: String {
    return rawValue
  }

  public init?(stringValue: String) {
    self.init(rawValue: stringValue)
  }
}

// MARK: - Int

extension Int: EpoxyStringRepresentable {

  public var stringValue: String {
    return String(self)
  }

  public init?(stringValue: String) {
    self.init(stringValue)
  }
}
