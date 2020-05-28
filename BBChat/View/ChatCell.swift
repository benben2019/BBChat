//
//  ChatCell.swift
//  BBChat
//
//  Created by Ben on 2020/5/28.
//  Copyright © 2020 Benben. All rights reserved.
//

import UIKit

class ChatCell: UICollectionViewCell {
    
    let textLab: UILabel = {
        let lab = UILabel()
        lab.numberOfLines = 0
        lab.textColor = .white
        lab.font = UIFont.systemFont(ofSize: 15)
        return lab
    }()
    
    let timeLab: UILabel = {
        let lab = UILabel()
        lab.numberOfLines = 0
        lab.textColor = .white
        lab.font = UIFont.systemFont(ofSize: 12)
        return lab
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .buttonRed
        contentView.stack(textLab,timeLab).withAllSide(10)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
