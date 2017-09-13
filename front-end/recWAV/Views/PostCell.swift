//
//  PostCell.swift
//  Blog-iOS
//
//  Created by Daniel Li on 11/16/16.
//  Copyright © 2016 CUAppDev. All rights reserved.
//

import UIKit

class PostCell: UICollectionViewCell {
    
    var titleLabel: UILabel!
    var authorLabel: UILabel!
    var dateLabel: UILabel!
    var contentLabel: UILabel!
    var statusLabel: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = UIColor.white
        
        titleLabel = UILabel(frame: CGRect(x: cellMargin, y: cellMargin, width: frame.width - 2*cellMargin - cellDateLabelWidth, height: cellTitleLabelHeight))
        titleLabel.font = UIFont(name: "Avenir-Medium", size: 17.0)
        addSubview(titleLabel)
        
        dateLabel = UILabel(frame: CGRect(x: titleLabel.frame.maxX, y: cellMargin, width: cellDateLabelWidth, height: cellTitleLabelHeight))
        dateLabel.font = UIFont(name: "Avenir-Medium", size: 12.0)
        dateLabel.textColor = UIColor.lightGray
        dateLabel.textAlignment = .right
        addSubview(dateLabel)
        
        authorLabel = UILabel(frame: CGRect(x: cellMargin, y: titleLabel.frame.maxY + 4.0, width: frame.width - 2*cellMargin, height: cellAuthorLabelHeight))
        authorLabel.font = UIFont(name: "Avenir-Medium", size: 12.0)
        authorLabel.textColor = UIColor.gray
        addSubview(authorLabel)
        
        contentLabel = UILabel(frame: CGRect(x: cellMargin, y: authorLabel.frame.maxY, width: frame.width - 2*cellMargin, height: frame.height - authorLabel.frame.maxY - cellMargin))
        contentLabel.font = UIFont(name: "Avenir-Medium", size: 14.0)
        contentLabel.textColor = UIColor.darkGray
        contentLabel.lineBreakMode = .byWordWrapping
        contentLabel.numberOfLines = 0
        addSubview(contentLabel)
        
        
        statusLabel = UILabel(frame: CGRect(x: cellMargin, y: titleLabel.frame.maxY + 4.0, width: frame.width - 2*cellMargin, height: cellAuthorLabelHeight))
        statusLabel.font = UIFont(name: "Avenir-Medium", size: 14.0)
        statusLabel.textAlignment = .right
        statusLabel.lineBreakMode = .byWordWrapping
        statusLabel.numberOfLines = 0
        addSubview(statusLabel)

        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func handle(post: Post) {
        titleLabel.text = post.location
        authorLabel.text = post.author
        dateLabel.text = format(date: post.date)
        contentLabel.text = post.content
        statusLabel.text = post.status.uppercased()
        statusLabel.textColor = post.status == "complete" ? UIColor(red: 0.00, green: 0.6, blue: 0.1686, alpha: 1.00) : UIColor.red
    }
    
    fileprivate func format(date: Date) -> String {
        let now = Date()
        let secondsSincePost = now.timeIntervalSince(date)
        
        switch secondsSincePost {
        case -Double.greatestFiniteMagnitude..<10:
            return "Just now"
        case 10..<30:
            return "\(Int(secondsSincePost))s"
        case 30..<3600:
            return "\(Int(secondsSincePost / 60.0))m"
        case 3600..<86400:
            return Int(secondsSincePost / 60.0 / 60.0) > 1 ? "\(Int(secondsSincePost / 60.0 / 60.0))hrs" : "\(Int(secondsSincePost / 60.0 / 60.0))hr"
        default:
            return "\(Int(secondsSincePost / 60.0 / 60.0 / 24.0))d"
        }
    }
}
