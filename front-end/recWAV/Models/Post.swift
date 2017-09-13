//
//  Post.swift
//  Blog-iOS
//
//  Created by Daniel Li on 11/16/16.
//  Copyright © 2016 CUAppDev. All rights reserved.
//

import Foundation
import SwiftyJSON

/**
    A Post is a blog submission. It has an Int `id`, a Date `date`, a String `title`, and a String `content`.
 */
struct Post {
    var id: Int
    var date: Date
    var dateComplete: Date?
    var location: String
    var author: String
    var content: String
    var status: String
    var classification: String?
    
    init(json: JSON) {
        id = json["id"].intValue
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        date = dateFormatter.date(from: json["date"].stringValue)!
        location = json["location"].stringValue
        author = json["author"].stringValue
        content = json["content"].stringValue
        status = json["status"].stringValue
        if status == "complete" {
            dateComplete = dateFormatter.date(from: json["datecomplete"].stringValue)!
            classification = "\(json["classification"].stringValue)"
        }
    }
}
