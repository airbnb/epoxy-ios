// Created by Tyler Hedrick on 1/12/21.
// Copyright © 2021 Airbnb Inc. All rights reserved.

import ObjectiveC
import Foundation
import UIKit

/// Note that this is a quick and dirty solution for downloading images and
/// should by no means be used in a production app.
extension UIImageView {

  // MARK: Public

  public func setURL(_ url: URL?) {
    // Currently loading an image, URL is updated to nil:
    guard let url = url else {
      if let storage = storage {
        self.storage = nil
        storage.dataTask.cancel()
        image = nil
      }
      return
    }

    // We're already actively loading an image with this URL:
    if let storage = storage, storage.url == url {
      return
    }

    // We need to load the image at the URL:
    image = nil
    let task = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
      guard
        self?.storage?.url == url,
        let data = data,
        error == nil,
        let image = UIImage(data: data)
      else {
        return
      }

      DispatchQueue.main.async { [weak self] in
        // If the image changed, don't replace it.
        guard self?.storage?.url == url else { return }
        self?.image = image
      }
    }
    storage = .init(url: url, dataTask: task)
    task.resume()
  }

  // MARK: Private

  private struct Storage {
    var url: URL
    var dataTask: URLSessionDataTask
    static var key = 0
  }

  @nonobjc
  private var storage: Storage? {
    get {
      objc_getAssociatedObject(self, &Storage.key) as? Storage
    }
    set {
      // Atomic since we access this property from the URLSession background thread.
      objc_setAssociatedObject(self, &Storage.key, newValue, .OBJC_ASSOCIATION_COPY)
    }
  }
}
