//
//  AudioRecording.swift
//  NoisyGenX
//
//  Created by AnGie on 4/23/17.
//  Copyright © 2017 AnGie. All rights reserved.
//

import Foundation
import SwiftyJSON

struct AudioRecording {
    var audiofile_status: String
    var location_history_status: String
    
    init(json: JSON) {
        audiofile_status = json["fupload"]["Status"].stringValue
        location_history_status = json["locations-log"]["Status"].stringValue
    }
}
