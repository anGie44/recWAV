//
//  SideMenuTableView.swift
//  NoisyGenX
//
//  Created by AnGie on 4/30/17.
//  Copyright © 2017 AnGie. All rights reserved.
//

import UIKit

protocol MapDataDelegate {
    func handleDataCollection(state:String) -> [String:[String:String]]?
}

class SideMenuTableView: UITableViewController, MapDataDelegate{
    
    let labels = ["Home", "Record", "Settings"]
    let labelImgs = ["home", "record", "settings"]
    var delegate: MapDataDelegate?
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "menuCell", for: indexPath)
        cell.textLabel?.text = labels[indexPath.row]
        cell.imageView?.image = UIImage(named: labelImgs[indexPath.row])
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return labels.count
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let toPresent = labels[indexPath.row]
        switch toPresent {
            case "Home":
                print ("Presenting Home Screen")
    
        case "Settings":
                print("Presenting Settings Controller")
        case "Record":
            let recorderViewController = RecorderViewController(context: "userUpload", requestID: -1)
            recorderViewController.delegate = self
            present(recorderViewController, animated: true, completion: nil)

        default:
                print ("Table View Menu Item")
            
        }
    }
    
    func handleDataCollection(state: String) -> [String : [String : String]]? {
        if state == "init" {
            return delegate?.handleDataCollection(state: "init")
        }
        else {
            return delegate?.handleDataCollection(state: "fin")

        }
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
        // this will be non-nil if a blur effect is applied
        guard tableView.backgroundView == nil else {
            return
        }
        
        // Set up a cool background image for demo purposes
//        let imageView = UIImageView(image: UIImage(named: "saturn"))
//        imageView.contentMode = .scaleAspectFit
//        imageView.backgroundColor = UIColor.black.withAlphaComponent(0.2)
//        tableView.backgroundView = imageView
        tableView.tableFooterView = UIView()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "menuCell")
        

    }
    

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
    }
}
