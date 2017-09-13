//
//  PostDetailViewController.swift
//  Blog-iOS
//
//  Created by Daniel Li on 11/17/16.
//  Copyright © 2016 CUAppDev. All rights reserved.
//

import UIKit

class PostDetailViewController: UIViewController {

    var post: Post
    
    init(post: Post) {
        self.post = post
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var authorLabel: UILabel!
    var contentTextView: UITextView!
    var provideAudio: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .collectionViewBackground
        title = post.location
        
        setupViews()
    }
    
    func setupViews() {
        authorLabel = UILabel(frame: CGRect(x: 16.0, y: 16.0, width: view.frame.width - 32.0, height: 32.0))
        authorLabel.text = post.author
        authorLabel.font = UIFont(name: "Avenir-Medium", size: 17.0)
        authorLabel.textAlignment = .center
        authorLabel.textColor = UIColor.gray
        view.addSubview(authorLabel)
        
        contentTextView = UITextView(frame: CGRect(x: 16.0, y: authorLabel.frame.maxY, width: view.frame.width - 32.0, height: view.frame.height - authorLabel.frame.maxY))
        contentTextView.text = post.status == "complete" ? "Details: \(post.content)\n\nNoise Classification: \(post.classification!)\n\nRequest Completed: \(format(date: post.dateComplete!))" : "Details: \(post.content)"
        contentTextView.showsHorizontalScrollIndicator = false
        contentTextView.isEditable = false
        contentTextView.backgroundColor = .clear
        contentTextView.font = UIFont(name: "Avenir-Medium", size: 14.0)
        contentTextView.textContainerInset = UIEdgeInsets(top: 8.0, left: 3.0, bottom: 8.0, right: 8.0)
        view.addSubview(contentTextView)
        
        provideAudio = UIButton(frame: CGRect(x: 16.0, y:40.0, width: view.frame.width/2.0, height: 32.0))
        provideAudio.layer.borderColor = UIColor.blogBlue.cgColor
        provideAudio.layer.borderWidth = 1
        provideAudio.layer.cornerRadius = 2
        provideAudio.titleLabel?.font = UIFont(name: "Avenir-Medium", size: 17.0)
        provideAudio.setTitle("Provide Audio", for: .normal)
        provideAudio.setTitleColor(UIColor.gray, for: .normal)
        provideAudio.addTarget(self, action: #selector(provideAudioButtonPressed), for: .touchUpInside)
        provideAudio.translatesAutoresizingMaskIntoConstraints = false
        provideAudio.center.x = view.center.x - 8.0
        
        provideAudio.isHidden = post.status == "complete" ? true: false
        
        contentTextView.addSubview(provideAudio)
        
    }
    
    func provideAudioButtonPressed() {
        
        let recorderViewController = RecorderViewController(context: "completeRequest", requestID: post.id)
        
        for i in 0..<((navigationController?.viewControllers)!.count) {
            if (navigationController?.viewControllers[i].isKind(of: HomeViewController.self))! {
                recorderViewController.delegate = navigationController?.viewControllers[i] as! HomeViewController
            }
        }
        present(recorderViewController, animated: true, completion: nil)
    }
    
    fileprivate func format(date: Date) -> String {
        let now = Date()
        let secondsSincePost = now.timeIntervalSince(date)
        
        switch secondsSincePost {
        case -Double.greatestFiniteMagnitude..<10:
            return "Just now"
        case 10..<30:
            return "\(Int(secondsSincePost))s ago"
        case 30..<3600:
            return "\(Int(secondsSincePost / 60.0))m ago"
        case 3600..<86400:
            return Int(secondsSincePost / 60.0 / 60.0) > 1 ? "\(Int(secondsSincePost / 60.0 / 60.0))hrs ago" : "\(Int(secondsSincePost / 60.0 / 60.0))hr ago"
        default:
            return "\(Int(secondsSincePost / 60.0 / 60.0 / 24.0))d ago"
        }
    }


}
