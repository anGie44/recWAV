//
//  UserView.swift
//  NoisyGenX
//
//  Created by AnGie on 5/2/17.
//  Copyright © 2017 AnGie. All rights reserved.
//

import UIKit
import DGElasticPullToRefresh

class UserView: UIView {
    var postsRequested: [Post] = []
    var postsCompleted: [Post] = []
    
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
