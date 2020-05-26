//
//  UIViewController+extensitions.swift
//  BBChat
//
//  Created by Ben on 2020/5/26.
//  Copyright © 2020 Benben. All rights reserved.
//

import UIKit

extension UIViewController {
    func alert(_ msg: String) {
        let alert = UIAlertController(title: nil, message: msg, preferredStyle: .alert)
        let confirm = UIAlertAction(title: "确定", style: .default, handler: nil)
        alert.addAction(confirm)
        present(alert, animated: true, completion: nil)
    }
}