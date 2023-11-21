//
//  UIImage+.swift
//  MeloPlace
//
//  Created by 김요한 on 2023/08/25.
//

import Foundation
import UIKit

extension UIImage {
    func resize(size: CGSize) -> UIImage {
        let size = size
        let render = UIGraphicsImageRenderer(size: size)
        let renderImage = render.image { context in
            self.draw(in: CGRect(origin: .zero, size: size))
        }
        
        return renderImage
    }
}
