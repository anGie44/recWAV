//
//  NetworkManager.swift
//  NoisyGenX
//
//  Created by AnGie on 4/23/17.
//  Copyright © 2017 AnGie. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import CoreLocation
import Luminous

var placeholderURL = "http://hostname/~apinilla/http-post-mp3"
var soundRequestURL = "http://hostname/~apinilla/http-request-mp3"
var counter = 1
class NetworkManager {
    
    static func getServersIPAddress(requestType:String) -> String {
        var serverHost:String!
        var currentNetwork:String!

        if Luminous.System.Network.isConnectedViaWiFi {
            currentNetwork = Luminous.System.Network.SSID
        
            if let network = currentNetwork {
                if network == "RedRover" {
                    serverHost = "10.148.11.168"
                }
                else { // assume device and server are in same local network
                    serverHost = "angies-macbook-pro.local"
                }
                var url = ""
                if requestType == "upload" {
                    url = placeholderURL.replacingOccurrences(of: "hostname", with: serverHost)
                }
                else if requestType == "request" {
                    url = soundRequestURL.replacingOccurrences(of: "hostname", with: serverHost)

                }
                return url
            }
            return "error"
        }
        return "error"
    }
    
    static func getPosts(completion: @escaping ([Post]?) -> Void) {
        
        var hostURL: URL!
        let hostname = getServersIPAddress(requestType: "request")
        if hostname != "error" {
            hostURL = URL(string: hostname)
        }
        
        
        let parameters: [String : Any] = [
            "type": "getRequests"
        ]
        if let url = hostURL {
            do {
                Alamofire.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default)
                    .validate()
                    .responseJSON { response in
                        
                        switch response.result {
                        case let .success(data):
                            let json = JSON(data)
                            var posts: [Post] = []
                            for postJSON in json.arrayValue {
                                posts.append(Post(json: postJSON))
                            }
                            
                            completion(posts)
                            
                        case .failure(let error):
                            print(error.localizedDescription)
                        }
                }
            }
        }
        
    }
    
    
    
    
    
    static func createPost(location: String, author: String, content: String, completion: @escaping (Post?) -> Void) {
        var hostURL: URL!
        let hostname = getServersIPAddress(requestType: "request")
        if hostname != "error" {
            hostURL = URL(string: hostname)
        }
        
        
        let parameters: [String : Any] = [
            "type": "createRequest",
            "location" : location,
            "author" : author,
            "content" : content
        ]
        
        if let url = hostURL {
            do {
                Alamofire.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default)
                    .validate()
                    .responseJSON { (response: DataResponse<Any>) in
                        switch response.result {
                        case let .success(data):
                            print(data)
                            let json = JSON(data)
                            let post = Post(json: json)
                            
                            completion(post)
                            
                        case let .failure(error):
                            print(error.localizedDescription)
                        }

                    }
            }
        
        }
    }
    
    static func createAudioUploadForRequest(requestID: Int, name: String, contentPath: String, startDateTime:String, endDateTime:String, locations: [String:[String:String]]?, completion: @escaping(AudioRecording?) -> Void) {
        
        let parameters: [String:String] = [
            "uploadType": "forRequest",
            "user_id" : UserDefaults.standard.string(forKey: "user_id")!,
            "audio_id": "\(name)\(counter)_\(UserDefaults.standard.string(forKey: "user_id")!)",
            "audio_st": startDateTime,
            "audio_et": endDateTime,
            "request_to_complete": "\(requestID)"
            ]
        
        var hostURL: URL!
        let hostname = getServersIPAddress(requestType: "upload")
        if hostname != "error" {
            hostURL = URL(string: hostname)
        }
        if let url = hostURL {
            do {
                Alamofire.upload(
                    multipartFormData: { multipartFormData in
                        for (key, value) in parameters {
                            multipartFormData.append(value.data(using: .utf8)!, withName: key)
                        }
                        if locations != nil {
                            do {
                                let locationJSON = JSON(locations!)
                                let locationData = try locationJSON.rawData()
                                multipartFormData.append(locationData, withName: "locations_log")
                            }
                            catch {
                                print("Unable to convert to data!")
                            }
                        }
                        multipartFormData.append(URL(string: contentPath)!, withName:"fileToUpload")
                },
                    to:url,
                    method: .post,
                    encodingCompletion: { encodingResult in
                        switch encodingResult {
                        case .success(let upload, _, _):
                            upload.responseJSON { response in
                                debugPrint(response)
                                
                                let audio = AudioRecording(json: JSON(response.data!))
                                
                                completion(audio)
                                
                            }
                            do {
                                try FileManager.default.removeItem(at: URL(string: contentPath)!)
                            }
                            catch {
                                print("Unable to remove requested file.")
                            }
                        case .failure(let encodingError):
                            print(encodingError)
                        }
                })
            }
        }
    }

    
    static func createAudioUpload(name: String, contentPath: String, startDateTime:String, endDateTime:String, locations: [String:[String:String]]?, completion: @escaping(AudioRecording?) -> Void) {
        
        let parameters: [String:String] = [
            "uploadType" : "upload",
            "user_id" : UserDefaults.standard.string(forKey: "user_id")!,
            "audio_id": "\(name)\(UserDefaults.standard.integer(forKey: "audio_upload_cnt"))_\(UserDefaults.standard.string(forKey: "user_id")!)",
            "audio_st": startDateTime,
            "audio_et": endDateTime,
        ]
        var hostURL: URL!
        let hostname = getServersIPAddress(requestType: "upload")
        if hostname != "error" {
            hostURL = URL(string: hostname)
        }
        if let url = hostURL {
            do {
                Alamofire.upload(
                    multipartFormData: { multipartFormData in
                        for (key, value) in parameters {
                            multipartFormData.append(value.data(using: .utf8)!, withName: key)
                        }
                        if locations != nil {
                            do {
                                let locationJSON = JSON(locations!)
                                let locationData = try locationJSON.rawData()
                                    multipartFormData.append(locationData, withName: "locations_log")
                            }
                            catch {
                                print("Unable to convert to data!")
                            }
                        }
                        multipartFormData.append(URL(string: contentPath)!, withName:"fileToUpload")
                },
                    to:url,
                    method: .post,
                    encodingCompletion: { encodingResult in
                        switch encodingResult {
                        case .success(let upload, _, _):
                            let updatedCount = UserDefaults.standard.integer(forKey: "audio_upload_cnt") + 1
                            UserDefaults.standard.set(updatedCount, forKey: "audio_upload_cnt")
                            upload.responseJSON { response in
                                debugPrint(response)
                                let audio = AudioRecording(json: JSON(response.data!))
                                
                                completion(audio)
                                
                            }
                            do {
                                try FileManager.default.removeItem(at: URL(string: contentPath)!)
                            }
                            catch {
                                print("Unable to remove requested file.")
                            }
                        case .failure(let encodingError):
                            print(encodingError)
                        }
                })
            }
        }
    }
}

