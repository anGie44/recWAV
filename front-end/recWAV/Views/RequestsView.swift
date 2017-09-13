//
//  RequestsView.swift
//  Blog-iOS
//
//  Created by Daniel Li on 11/16/16.
//  Copyright © 2016 CUAppDev. All rights reserved.
//

import UIKit
import DGElasticPullToRefresh


class RequestsView: UIView {
    
    var posts: [Post] = []
    
    var collectionView: UICollectionView!
    var emptyLabel: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .white
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
}


