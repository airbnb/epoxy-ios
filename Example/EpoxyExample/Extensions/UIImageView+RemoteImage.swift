// Created by Tyler Hedrick on 1/12/21.
// Copyright © 2021 Airbnb Inc. All rights reserved.

import Foundation
import UIKit

/// Note that this is a quick and dirty solution for downloading images and
/// should by no means be used in a production app.
extension UIImageView {
  public func setURL(_ url: URL) {
    image = nil
    URLSession.shared.dataTask(with: url) { data, response, error in
      guard let data = data, error == nil else { return }
      let image = UIImage(data: data)
      DispatchQueue.main.async {
        self.image = image
      }
    }.resume()
  }
}
