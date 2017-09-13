//
//  RecorderViewController.swift
//  NoisyGenX
//
//  Created by AnGie on 4/22/17.
//  Copyright © 2017 AnGie. All rights reserved.
//

import UIKit
import CoreLocation
import AVFoundation
import DGElasticPullToRefresh
import SideMenu

class RecorderViewController: UIViewController, URLSessionDelegate, URLSessionTaskDelegate, URLSessionDataDelegate, AVAudioRecorderDelegate {
    
    var flashing:Bool!
    
    var startRecording: UIButton!
    var stopRecording: UIButton!
//    var uploadRecording: UIButton!
    
    var stackView: UIStackView!
    
    var recordingSession: AVAudioSession!
    var audioRecorder: AVAudioRecorder!
    
    var audioURL: URL!
    var audioStartRecordingDateTime:String!
    var audioEndRecordingDateTime:String!
    
    var delegate: MapDataDelegate?
    
    var locationsLog:[String:[String:String]]!
    
    var formatter:DateFormatter!
    
    var context: String!
    var requestID: Int!
    

    init(context: String, requestID: Int) {
        self.context = context
        self.requestID = requestID
        super.init(nibName: nil, bundle: nil)

    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        let height: CGFloat = 64

        let navigationBar = UINavigationBar(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: height))
        navigationBar.barStyle = .black
        navigationBar.shadowImage = UIImage()
        navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationBar.barTintColor = .blogBlue
        navigationBar.tintColor = .white
        navigationBar.isTranslucent = false
        
        let navItem = UINavigationItem()
        navItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "close"), style: .done, target: nil, action: #selector(cancelButtonPressed))
        navItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "upload"), style: .done, target: nil, action: #selector(uploadRecordingAudio))
        
        navigationBar.items = [navItem]
        view.addSubview(navigationBar)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        view.backgroundColor = .white
        
    
        
//        let sideMenu = SideMenuTableView()
//        let menuLeftNavigationController = UISideMenuNavigationController(rootViewController: sideMenu)
//        menuLeftNavigationController.leftSide = true
//        SideMenuManager.menuLeftNavigationController = menuLeftNavigationController
        
        
        recordingSession = AVAudioSession.sharedInstance()
        do {
            try recordingSession.setCategory(AVAudioSessionCategoryPlayAndRecord)
            try recordingSession.setActive(true)
            recordingSession.requestRecordPermission() { [unowned self] allowed in
                DispatchQueue.main.async {
                    if allowed {
                        self.loadRecordingUI()
                    }
                    else {
                        self.loadFailUI()
                    }
                }
            }
        } catch {
            self.loadFailUI()
        }
        setupStackView()
        setBarButton()
        flashing = false
        formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
    }
    
    
    func cancelButtonPressed() {

        self.dismiss(animated: true, completion: nil)
    }
    
    
    func setupStackView() {
        stackView = UIStackView()
        stackView.spacing = 30
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.distribution = UIStackViewDistribution.fillEqually
        stackView.alignment = .center
        stackView.axis = .vertical
        view.addSubview(stackView)
        
        stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }


    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if !flag {
            stopRecordingAudio(success: false)
        }
    }
    
    func loadRecordingUI() {
        
        startRecording = UIButton(type: .system)
        startRecording.setTitle("Start", for: .normal)
        startRecording.setImage(UIImage(named: "record"), for: .normal)
        
        startRecording.titleLabel?.font = UIFont.preferredFont(forTextStyle: .title1)
//        startRecording.layer.borderColor = UIColor.blue.cgColor
//        startRecording.layer.borderWidth = 1
        startRecording.translatesAutoresizingMaskIntoConstraints = false
        startRecording.addTarget(self, action: #selector(recordTapped), for: .touchUpInside)
        
        stopRecording = UIButton(type: .system)
        stopRecording.setTitle("Stop", for: .normal)
        stopRecording.titleLabel?.font = UIFont.preferredFont(forTextStyle: .title1)

//        stopRecording.layer.borderColor = UIColor.blue.cgColor
//        stopRecording.layer.borderWidth = 1
        stopRecording.translatesAutoresizingMaskIntoConstraints = false
        stopRecording.addTarget(self, action: #selector(stopRecordingAudio), for: .touchUpInside)
        
//        uploadRecording = UIButton(type: .system)
//        uploadRecording.setTitle("Upload", for: .normal)
//        uploadRecording.setImage(UIImage(named: "upload"), for: .normal)
//        uploadRecording.titleLabel?.font = UIFont.preferredFont(forTextStyle: .title1)
//
//        uploadRecording.layer.borderColor = UIColor.blue.cgColor
//        uploadRecording.layer.borderWidth = 1
//        uploadRecording.translatesAutoresizingMaskIntoConstraints = false
//        uploadRecording.addTarget(self, action: #selector(uploadRecordingAudio), for: .touchUpInside)
        
        stackView.addArrangedSubview(startRecording)
        stackView.addArrangedSubview(stopRecording)
//        stackView.addArrangedSubview(uploadRecording)

    }
    
    func loadFailUI() {
        let failLabel = UILabel()
        failLabel.font = UIFont.preferredFont(forTextStyle: .headline)
        failLabel.text = "Recording failed: please ensure the app has access to your microphone."
        failLabel.numberOfLines = 0
        stackView.addArrangedSubview(failLabel)
    }
    
    func setBarButton() {
        let uploadButton = UIBarButtonItem(image: UIImage(named: "upload"), style: .done, target: nil, action: #selector(uploadRecordingAudio))
        uploadButton.tintColor = .white
        navigationItem.rightBarButtonItem = uploadButton
    }
    
//    func mapButtonPressed() {
//        let viewMapViewController = UINavigationController(rootViewController: HomeViewController())
//        viewMapViewController.navigationBar.barStyle = .black
//        viewMapViewController.navigationBar.barTintColor = .blogBlue
//        viewMapViewController.navigationBar.isTranslucent = false
//        present(viewMapViewController, animated: true, completion: nil)
//    }
    
    func recordTapped() {
        if audioRecorder == nil {
            startRecordingAudio()
        }
        else {
            stopRecordingAudio(success: true)
        }
    }
    
    func blink() {
        if !flashing {
            self.startRecording.alpha = 1.0
            UIView.animate(withDuration: 0.5, delay: 0.0, options: [.curveEaseInOut, .repeat, .autoreverse, .allowUserInteraction], animations: {() -> Void in self.startRecording.alpha = 0.0}, completion: {(finished:Bool) -> Void in })
            flashing = true
        }
        else {
            UIView.animate(withDuration: 0.1, delay: 0.0, options: [.curveEaseInOut, .beginFromCurrentState], animations: {() -> Void in self.startRecording.alpha = 1.0}, completion: {(finished: Bool) -> Void in })
        }
    }

    func startRecordingAudio() {
        view.backgroundColor = UIColor(red: 0.6, green: 0, blue: 0, alpha: 1)
        
        blink()
        stopRecording.setTitle("Tap to Stop", for: .normal)
        
        audioURL = RecorderViewController.getRecordingURL()
        print(audioURL.absoluteString)
        
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        do {
            audioRecorder = try AVAudioRecorder(url: audioURL, settings: settings)
            audioRecorder.delegate = self
            audioRecorder.record()
            audioStartRecordingDateTime = formatter.string(from: Date())
            beginTrackingUserLocation()
        }
        catch {
            stopRecordingAudio(success: false)
        }
    }
    
    func stopRecordingAudio(success: Bool) {
        view.backgroundColor = UIColor(red: 0, green: 0.6, blue: 0, alpha: 1)
        blink()
        audioRecorder.stop()
        audioRecorder = nil
        stopTrackingUserLocation()
        
        startRecording.setTitleColor(.white, for: .normal)
        stopRecording.setTitleColor(.white, for: .normal)
//        uploadRecording.setTitleColor(.white, for: .normal)
        
        if success {
            startRecording.setTitle("Tap to Re-record", for: .normal)
            audioEndRecordingDateTime = formatter.string(from: Date())
            flashing = false
        }
        else {
            startRecording.setTitle("Tap to Record", for: .normal)
            let ac = UIAlertController(title: "Record Failed", message: "There was a problem recording your audio; please try again.", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        }
        
        
    }
    
    func uploadRecordingAudio() {
        if self.context == "completeRequest" {
            NetworkManager.createAudioUploadForRequest(requestID: self.requestID, name: "audio", contentPath: audioURL.absoluteString, startDateTime: audioStartRecordingDateTime, endDateTime: audioEndRecordingDateTime, locations: locationsLog, completion: {(audio:AudioRecording?) in
                if let audio = audio {
                    let ac = UIAlertController(title: "Thank you!", message: "You helped complete the audio classification request.", preferredStyle: .alert)
                    ac.addAction(UIAlertAction(title: "OK", style: .default, handler: {(ac: UIAlertAction!) in
                        self.dismiss(animated: true, completion: nil
//                            {self.presentingViewController?.navigationController?.popViewController(animated: true)}
//                                        { self.presentingViewController?.dismiss(animated: true, completion: nil) }
                                    )}))
                                self.present(ac, animated: true)
                            }
                
                })
        }
        else {
            NetworkManager.createAudioUpload(name: "audio", contentPath: audioURL.absoluteString, startDateTime: audioStartRecordingDateTime, endDateTime: audioEndRecordingDateTime, locations: locationsLog, completion: {(audio:AudioRecording?) in
            if let audio = audio {
                if audio.audiofile_status == "OK" {
                    let ac_file = UIAlertController(title: "Successfully Uploaded Your Audio!", message: nil, preferredStyle: .alert)
                    ac_file.addAction(UIAlertAction(title: "OK", style: .default, handler: {(ac_file: UIAlertAction!) in
                        if audio.location_history_status == "OK" {
                            let ac_log = UIAlertController(title: "Successfully Logged Your Location History!", message: nil, preferredStyle: .alert)
                            ac_log.addAction(UIAlertAction(title: "OK", style: .default, handler: {(ac_log: UIAlertAction!) in
                                self.dismiss(animated: true, completion: nil)}))
                            self.present(ac_log, animated: true)
                        }
                    }))
                    self.present(ac_file, animated: true)
                }
            }
        })
        }
    }
    
    func beginTrackingUserLocation() {
        delegate?.handleDataCollection(state: "init")
    }
    
    func stopTrackingUserLocation() {
        locationsLog = delegate?.handleDataCollection(state: "fin")
        if let log = locationsLog {
            for data in log {
                print("\(data.value["latitude"]!)")
                print("\(data.value["longitude"]!)")
            }
        }
    }

    class func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
    
    class func getRecordingURL() -> URL {
        return getDocumentsDirectory().appendingPathComponent("audio.m4a")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}


