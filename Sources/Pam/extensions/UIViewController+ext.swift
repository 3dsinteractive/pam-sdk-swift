//
//  File.swift
//  
//
//  Created by narongrit kanhanoi on 23/6/2564 BE.
//

import UIKit

extension UIViewController {
    static func loadFromNib() -> Self {
        func instantiateFromNib<T: UIViewController>() -> T {
            return T.init(nibName: String(describing: T.self), bundle: Bundle.module)
        }

        return instantiateFromNib()
    }
}
