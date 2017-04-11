//
//  UIImage+Async.swift
//  Bookloop
//
//  Created by Charley Luckhardt on 12/7/16.
//  Copyright © 2016 Charles Luckhardt. All rights reserved.
//

import UIKit
import ObjectiveC

var AssociatedObjectHandle: UInt8 = 0

extension UIImageView {
    var lastURLString: String {
        get {
            return objc_getAssociatedObject(self, &AssociatedObjectHandle) as! String
        }
        set {
            objc_setAssociatedObject(self, &AssociatedObjectHandle, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    func downloadAsync(fromURL urlString: String) {
        self.lastURLString = urlString
        guard let url = URL(string: urlString) else { return }
        
        DispatchQueue.global().async {
            let data = try? Data(contentsOf: url)
            DispatchQueue.main.async {
                if url.absoluteString == self.lastURLString && data != nil {
                    self.image = UIImage(data: data!)
                }
            }
        }
    }
}
