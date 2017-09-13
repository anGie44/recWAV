//
//  AddPostViewController.swift
//  Blog-iOS
//
//  Created by Daniel Li on 11/17/16.
//  Copyright © 2016 CUAppDev. All rights reserved.
//

import UIKit

class AddPostViewController: UIViewController {

    var titleField: UITextField!
    var contentTextView: UITextView!
    var contentTextViewPlaceholderLabel: UILabel!
    
    var postButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        setupBarButtons()
        
        view.backgroundColor = .white
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        titleField.becomeFirstResponder()
    }
    
    func setupViews() {
        titleField = UITextField(frame: CGRect(x: 8.0, y: 0.0, width: view.frame.width - 16.0, height: 44.0))
        titleField.placeholder = "Location"
        titleField.addTarget(self, action: #selector(validateFields), for: .editingChanged)
        titleField.font = UIFont(name: "Avenir-Medium", size: 17.0)
        titleField.autocapitalizationType = .words
        view.addSubview(titleField)
        
        let border = UIView(frame: CGRect(x: 0.0, y: titleField.frame.maxY, width: view.frame.width, height: 0.5))
        border.backgroundColor = UIColor.gray
        view.addSubview(border)
        
        contentTextView = UITextView(frame: CGRect(x: 0.0, y: titleField.frame.maxY + 1.0, width: view.frame.width, height: view.frame.height - titleField.frame.maxY - (navigationController?.navigationBar.frame.maxY ?? 0.0)))
        contentTextView.showsHorizontalScrollIndicator = false
        contentTextView.delegate = self
        contentTextView.backgroundColor = .clear
        contentTextView.font = UIFont(name: "Avenir-Medium", size: 14.0)
        contentTextView.textContainerInset = UIEdgeInsets(top: 8.0, left: 3.0, bottom: 8.0, right: 8.0)
        view.addSubview(contentTextView)
        
        contentTextViewPlaceholderLabel = UILabel()
        contentTextViewPlaceholderLabel.font = UIFont(name: "Avenir-Medium", size: 14.0)
        contentTextViewPlaceholderLabel.text = "Write any additional details (e.g. time of day) ..."
        contentTextViewPlaceholderLabel.textColor = UIColor(white: 0.8, alpha: 1.0)
        contentTextViewPlaceholderLabel.sizeToFit()
        contentTextViewPlaceholderLabel.frame.origin = CGPoint(x: 8.0, y: contentTextView.frame.origin.y + 8.0)
        view.insertSubview(contentTextViewPlaceholderLabel, belowSubview: contentTextView)
    }
    
    func setupBarButtons() {
        let cancelButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelButtonPressed))
        cancelButton.tintColor = .white
        navigationItem.leftBarButtonItem = cancelButton
        
        postButton = UIBarButtonItem(title: "Request", style: .done, target: self, action: #selector(postButtonPressed))
        postButton.tintColor = .white
        postButton.isEnabled = false
        navigationItem.rightBarButtonItem = postButton
    }
    
    func postButtonPressed() {
        NetworkManager.createPost(location: titleField.text ?? "", author: "Anonymous", content: contentTextView.text, completion: { (post: Post?) in
            if let post = post,
                let postsViewController = (self.presentingViewController as? UINavigationController)?.topViewController as? HomeViewController {
                postsViewController.containerViewB.posts.insert(post, at: 0)
//                postsViewController.containerViewC.postsRequested.insert(post, at: 0)

                postsViewController.updateCollectionView(setupView: "global")
//                postsViewController.updateCollectionView(setupView: "personal")
                self.dismiss(animated: true, completion: nil)
            }
        })
    }
    
    func cancelButtonPressed() {
        dismiss(animated: true, completion: nil)
    }

}

extension AddPostViewController: UITextViewDelegate, UITextFieldDelegate {
    
    func validateFields() {
        postButton.isEnabled = titleField.text != "" && contentTextView.text != ""
        
        contentTextViewPlaceholderLabel.isHidden = contentTextView.text != ""
    }
    
    func textViewDidChange(_ textView: UITextView) {
        validateFields()
    }
    
}
