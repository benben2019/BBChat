//
//  String+extensitions.swift
//  BBChat
//
//  Created by Ben on 2020/5/29.
//  Copyright © 2020 Benben. All rights reserved.
//
import UIKit

extension String {
    func textSize(_ maxWidth: CGFloat,
                  maxHeight: CGFloat = CGFloat(MAXFLOAT),
                  attributes: [NSAttributedString.Key : Any]?) -> CGSize {
        return NSString(string: self).boundingRect(with: .init(width: maxWidth, height: maxHeight),
                                                   options: [.usesLineFragmentOrigin,.usesFontLeading],
                                                   attributes: attributes,
                                                   context: nil)
            .size
    }
}
