<?php

require("DBConn.php");
require("MySQLDao.php");

$requestType = $_POST["uploadType"];
$userId = $_POST["user_id"];
$audioId = $_POST["audio_id"];
$audioStartTime = $_POST["audio_st"];
$audioEndTime = $_POST["audio_et"];
$locationsData = $_POST["locations_log"];
date_default_timezone_set('America/New_York');
$timeOfUploadRequest = date('Y-m-d H:i:s', $_SERVER['REQUEST_TIME']);

$target_dir = "./uploads";

$dao = new MySQLDao();
$dao->openConnection();

$JSONMessage = array();

/* initial null check of post parameters */
if ($userId == null) {
	$JSONMessage["userID"] = array('Message'=>'Please provide a valid user_id.', 'Status'=>'Error');
}

if ($audioId == null) {
	$JSONMessage["audioID"] = array('Message' => 'Please provide a valid audio_id.', 'Status' => 'Error');
}

if ($audioStartTime == null || $audioEndTime == null) {
	$JSONMessage["audioRecordingTimes"] = array('Message' => 'Please provide a valid start and/or end timestamps for audio file.', 'Status' => 'Error');
}

if ($locationsData == null) {
	$JSONMessage["locationData"] = array('Message' => 'Location Data did not correctly POST',
		'Status' => 'Error');
}
// if (count($JSONMessage) > 0) {
// 	echo json_encode($JSONMessage);
// }

/* check if user exists in db */
/* if exists, insert data appropriately
/* else, register user, then insert data appropriately 
 */
$userDetails = $dao->getUserDetails($userId);

if (!empty($userDetails)) { 
	/* update most recent upload timestamp */
	$result = $dao->updateUploadTimestamp($userId, $timeOfUploadRequest);
	if ($result == "SUCCESS") {
		$JSONMessage["dbupdate"] = array("Message" => "The user " . $userId . " was updated to reflect most recent upload.",
			"Status" => "OK");
	}
	else {
		$JSONMessage["dbupdate"] = array("Message" => "The user " . $userId . " could not be udated.",
			"Status" => "Error");
	}
}
else {
	$result = $dao->registerUser($userId, $timeOfUploadRequest);
	if ($result == "SUCCESS") {
		$JSONMessage["user-register"] = array("Message" => "The user " . $userId . " was successfully added to db.", "Status" => "OK");
	}
	else {
		$JSONMessage["user-register"] = array("Message" => "The user " . $userId . " could not be added to db.",
			"Status" => "Error");
	}
}

/* (1) upload audio file to server */

if (!file_exists($target_dir)) {
	mkdir($target_dir, 0777, true);
}

$target_dir = $target_dir . "/" . $audioId . ".m4a";

/* audio file upload and db insertion */
/* if type = forRequest, need to return classification */
if (move_uploaded_file($_FILES["fileToUpload"]["tmp_name"], $target_dir)){
	$JSONMessage["fupload"] = array("Message" => "The file " . basename($_FILES["fileToUpload"]["name"]). " has been uploaded.", "Status" => "OK");
	/* convert to WAV */
	$filename_array = explode(".", $target_dir);
	$dstWavFile = "." . $filename_array[1] . ".wav";
	$cmd = `afconvert $target_dir $dstWavFile -d LEI24 -f WAVE`;
	$rm_cmd = `rm $target_dir`;

	if ($dao->insertAudioFileInfoByIds($audioId, $userId, $dstWavFile, $timeOfUploadRequest, $audioStartTime, $audioEndTime) == "SUCCESS") {
		$JSONMessage["audioDB"] = array("Message" => "Metadata of audio file successfully added for your records.", "Status" => "OK");
	}
	else {
		$JSONMessage["audioDB"] = array("Message" => "Sorry, there was an error adding metadata of your audio file to our databases.", "Status" => "Error");
	}
	if ($requestType == "forRequest") {
		/* run classification and mark request as complete */

		$python = '/usr/local/bin/python3';
		$pyfile = '/Users/apinilla/Sites/scripts/audioProcessing.py';
		$resultClassification = shell_exec("$python $pyfile $dstWavFile");
		$resultClassification = rtrim($resultClassification);

		$id = $_POST["request_to_complete"];
		if ($dao->updateRequestStatus($id, $timeOfUploadRequest, $resultClassification) == "SUCCESS") {
			$JSONMessage["request-status"] = array("Message" => "Status and classfication updated succesfully.", "Status" => "OK");
		}
		else {
			$JSONMessage["request-status"] = array("Message" => "Status and/or classification could not be updated.", "Status" => "Error");
		}
	}
}
else {
	$JSONMessage["fupload"] = array("Message" => "Sorry, there was an error uploading your file.",
		"Status" => "Error");
}

/* convert audio file from .m4a -> .wav for data processing */
/*
$wav_target_dir = "./waveFiles";
if(!file_exists($wav_target_dir)) {
    mkdir($wav_target_dir, 0777, true);
}
*/


/* (2) upload location data file to server
/* location history file processing and db insertion */

$target_dir = "./logs";
if (!file_exists($target_dir)) {
	mkdir($target_dir, 0777, true);
}

$file = "log_" . $audioId . ".json";
if (file_put_contents($file, $_POST["locations_log"]) != FALSE) {
	$dir = $target_dir . "/" . $file;
	if (rename($file, $dir)) {
		$JSONMessage["locations-log"] = array("Message" => "Locations log was successfully uploaded.",
			"Status" => "OK");

		if(uploadLocationDataToDB($userId, $audioId)) {
		 	$JSONMessage["locations-db"] = array("Message" => "A log of your location history was successfully added for your records.",
				"Status" => "OK");
		}
		else {
			$JSONMessage["locations-db"] = array("Message" => "Sorry, there was an error uploading your location history to our databases.",
				"Status" => "Error");
		}
	}
	else {
		$JSONMessage["locations-log"] = array("Message" => "Locations log could not be saved to a directory.",
			"Status" => "Error");
	}
}
else {
	$JSONMessage["locations-log"] = array("Message" => "Locations log could not be saved to a json file.",
		"Status" => "Error");
}



echo json_encode($JSONMessage);

function uploadLocationDataToDB($user_id, $audio_id) {
	/* read file data and pass to dao */
	$result = 0;
	global $dao, $locationsData;
	if (($jsonData = (array)json_decode($locationsData)) != NULL) {
		$result = $dao->insertLocationHistoryByIds($user_id, $audio_id, $jsonData);
	}
	return $result;
}

?>
