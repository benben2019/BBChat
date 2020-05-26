//
//  UserCell.swift
//  BBChat
//
//  Created by Ben on 2020/5/26.
//  Copyright © 2020 Benben. All rights reserved.
//

import UIKit
import Foundation

class UserCell: UITableViewCell {
    
    let iconImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.backgroundColor = .lightGray
        iv.layer.cornerRadius = 25
        iv.clipsToBounds = true
        return iv
    }()
    
    let nameLab: UILabel = {
        let lab = UILabel()
        lab.font = UIFont.systemFont(ofSize: 16)
        lab.textColor = .black
        return lab
    }()
    
    let subLab: UILabel = {
        let lab = UILabel()
        lab.font = UIFont.systemFont(ofSize: 12)
        lab.textColor = .lightGray
        return lab
    }()
    
    var user: User! {
        didSet {
            updateData()
        }
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        addSubview(iconImageView)
        addSubview(nameLab)
        addSubview(subLab)
        
        hstack(iconImageView.withSize(.init(width: 50, height: 50)),
               stack(nameLab,
                     subLab,
                     spacing: 6),
               UIView(),
               spacing: 10,
               alignment: .center)
        .withAllSide(10)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateData() {
        
        nameLab.text = user.username
        subLab.text = user.uid
        
        iconImageView.image = nil
        
        guard let url = user.iconUrl,url.count > 0 else { return }
        
        iconImageView.loadCacheImage(url)
        
    }
}
