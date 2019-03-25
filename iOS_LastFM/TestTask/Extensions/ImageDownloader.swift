//
//  ImageDownloader.swift
//  TestTask
//
//  Created by Bindu on 17.09.18.
//  Copyright © 2018 APPSfactory GmbH. All rights reserved.
//

import UIKit

extension UIImageView {
    func loadImage(url: String) {
        DispatchQueue.global().async { [weak self] in
            guard let urlData = URL(string: url)
                else { return }
            if let data = try? Data(contentsOf: urlData) {
                if let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self?.image = image
                    }
                }
            }
        }
    }
}
