//
//  UIImageView+extensitions.swift
//  BBChat
//
//  Created by Ben on 2020/5/26.
//  Copyright © 2020 Benben. All rights reserved.
//

import UIKit

let imageCache = NSCache<NSString,UIImage>()

extension UIImageView {
    func loadCacheImage(_ url: String) {
        if url.count == 0 { return }
        if let cacheImage = imageCache.object(forKey: url as NSString) {
             self.image = cacheImage
             return
         }
         
         URLSession.shared.dataTask(with: URL(string: url)!) {[weak self] (data, response, error) in
             guard let self = self else { return }
             if let error = error {
                 print(error.localizedDescription)
                 return
             }
             let image = UIImage(data: data!)
             imageCache.setObject(image!, forKey: url as NSString)
             
             DispatchQueue.main.async {
                 self.image = image
             }
             
         }.resume()
    }
}

extension UIButton {
    func setCachImage(_ url: String,for state: UIControl.State) {
        if url.count == 0 { return }
        if let cacheImage = imageCache.object(forKey: url as NSString) {
            setImage(cacheImage, for: state)
            return
        }
        
        URLSession.shared.dataTask(with: URL(string: url)!) {[weak self] (data, response, error) in
            guard let self = self else { return }
            if let error = error {
                print(error.localizedDescription)
                return
            }
            let image = UIImage(data: data!)
            imageCache.setObject(image!, forKey: url as NSString)
            
            DispatchQueue.main.async {
                self.setImage(image, for: state)
            }
            
        }.resume()
    }
}
