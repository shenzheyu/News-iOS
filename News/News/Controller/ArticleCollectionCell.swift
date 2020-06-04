//
//  ArticleCollectionCell.swift
//  News
//
//  Created by Zheyu Shen on 5/6/20.
//  Copyright © 2020 Zheyu Shen. All rights reserved.
//

import UIKit

protocol removeBookmarkDelegate {
    func removeBoomark(ArticleID: String)
}

class ArticleCollectionCell: UICollectionViewCell {
    
    var articleID = ""
    var delegate:removeBookmarkDelegate?
    
    @IBOutlet weak var articleImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var sectionLabel: UILabel!
    
    @IBAction func removeBookmark(_ sender: Any) {
        delegate?.removeBoomark(ArticleID: articleID)
    }
    
    override class func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        contentView.layer.masksToBounds = true
        contentView.layer.borderWidth = 1
        contentView.layer.borderColor = CGColor.init(srgbRed: 202.0/225.0, green: 202.0/225.0, blue: 202.0/225.0, alpha: 1.0)
        
    }
}
