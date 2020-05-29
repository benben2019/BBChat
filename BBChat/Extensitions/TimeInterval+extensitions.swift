//
//  TimeInterval+extensitions.swift
//  BBChat
//
//  Created by Ben on 2020/5/28.
//  Copyright © 2020 Benben. All rights reserved.
//

import Foundation

extension TimeInterval {
    func converToDateString(_ dateFormat: String = .shortDate) -> String {
        let date = Date(timeIntervalSince1970: self)
        let formatter = DateFormatter()
        formatter.dateFormat = dateFormat
        return formatter.string(from: date)
    }
}
