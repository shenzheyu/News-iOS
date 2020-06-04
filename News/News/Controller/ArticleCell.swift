//
//  ArticleCell.swift
//  News
//
//  Created by Zheyu Shen on 4/26/20.
//  Copyright © 2020 Zheyu Shen. All rights reserved.
//

import UIKit

protocol addBookmarkDelegate {
    func addBookmark(articleID: String)
}

class ArticleCell: UITableViewCell {
    
    @IBOutlet weak var articleImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var sectionLabel: UILabel!
    @IBOutlet weak var bookmarkImage: UIButton!
    
    var articleID = ""
    var delegate:addBookmarkDelegate?
    
    @IBAction func addBookmark(_ sender: Any) {
        delegate?.addBookmark(articleID: articleID)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: 2, left: 0, bottom: 2, right: 0))
        contentView.layer.cornerRadius = 10
        contentView.layer.masksToBounds = true
        contentView.layer.borderWidth = 1
        contentView.layer.borderColor = CGColor.init(srgbRed: 202.0/225.0, green: 202.0/225.0, blue: 202.0/225.0, alpha: 1.0)
        
    }

}
