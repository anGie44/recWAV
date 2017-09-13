<?php

class MySQLDao {
	var $dbhost = null;
	var $dbuser = null;
	var $dbpass = null;
	var $conn = null;
	var $dname = null;

	function __construct() {
		$this->dbhost = DBConn::$dbhost;
		$this->dbuser = DBConn::$dbuser;
		$this->dbpass = DBConn::$dbpass;
		$this->dbname = DBConn::$dbname;

	}

	public function openConnection() {
		$this->conn = new mysqli($this->dbhost, $this->dbuser, $this->dbpass, $this->dbname);
		if (mysqli_connect_errno()) {
			echo new Exception("Could not establish connection with database.");
		}
	}

	public function getConnection() {
		return $this->conn;
	}

	public function closeConnection() {
		if($this->conn != null) {
			$this->conn->close();
		}
	}

	public function getUserDetails($user_id) {
		$returnValue = array();	
		$sql = "select * from users where user_id='" . $user_id ."'";
		$result = $this->conn->query($sql);
		if ($result != null && (mysqli_num_rows($result) >= 1)) {
			$row = $result->fetch_array(MYSQLI_ASSOC);
			if (!empty($row)) {
				$returnValue = $row;
			}
		}
		return $returnValue;
	}

	public function registerUser($user_id, $timestampOfUpload) {
		$sql = "insert into users ". "(user_id, firstUploadTS, recentUploadTS) ". "values ('$user_id','$timestampOfUpload','$timestampOfUpload')";
		if ($this->conn->query($sql) === TRUE) {
			return "SUCCESS";
		}		
		else {
			return "FAILURE";
		}
	}

	public function updateUploadTimestamp($user_id, $timestamp) {
		$sql = "update users set recentUploadTS = '$timestamp' where user_id = '$user_id'";
		if ($this->conn->query($sql) === TRUE) {
			return "SUCCESS";
		}
		else {
			return "FAILURE";
		}
	}

	public function insertAudioFileInfoByIds($audio_id, $user_id, $filepath, $timeOfUploadRequest, $recordingStartTime, $recordingEndTime) {
		$sql = "select * from audio_uploads where audio_id='" . $audio_id . "' and user_id='" . $user_id ."'";
		$result = $this->conn->query($sql);
		if ($result != null && (mysqli_num_rows($result) == 1)) {
			$sql = "update audio_uploads set file_path = '$filepath', uploadTS = '$timeOfUploadRequest', recordingST= '$recordingStartTime', recordingET = '$recordingEndTime' where audio_id='$audio_id' and user_id='$user_id'";
			if ($this->conn->query($sql) === TRUE) {
				return "SUCCESS";
			}		
			else {
				return "FAILURE";
			}
		}
		else {
			$sql = "insert into audio_uploads ". "(audio_id, user_id, file_path, uploadTS, recordingST, recordingET) ". "values ('$audio_id','$user_id','$filepath','$timeOfUploadRequest','$recordingStartTime','$recordingEndTime')";
			if ($this->conn->query($sql) === TRUE) {
				return "SUCCESS";
			}		
			else {
				return "FAILURE";
			}
		}
	}

	public function getUserLocationHistoryById($user_id) {
		$returnValue = array();
		$sql = "select timestamp, latitude, longitude from location_history where user_id='" . $user_id . "'";
		$result = $this->conn->query($sql);
		if ($result != null && (mysqli_num_rows($result) >= 1)) {
			for($i = 0; $i < mysqli_num_rows($result); $i++) {
				$row = $result->fetch_array(MYSQLI_ASSOC);
				if (!empty($row)) {
					array_push($returnValue, $row);
				}
			}
		}
		return $returnValue;
	}

	public function getUserLocationHistoryByIdAndDate($user_id, $timestamp) {
		$returnValue = array();
		$sql = "select locationTS, latitude, longitude from location_history where user_id='" . $user_id . "' and timestamp='" . $timestamp . "'";
		$result = $this->conn->query($sql);
		if ($result != null && (mysqli_num_rows($result) >= 1)) {
			for($i = 0; $i < mysqli_num_rows($result); $i++) {
				$row = $result->fetch_array(MYSQLI_ASSOC);
				if (!empty($row)) {
					array_push($returnValue, $row);
				}
			}
		}
		return $returnValue;
	}

	public function getUsersDateOfFirstUpload($user_id) {
		$returnValue = array();
		$sql = "select firstUploadTS from users where user_id='" . $user_id . "'";
		$result = $this->conn->query($sql);
		if ($result != null && (mysqli_num_rows($result) >= 1)) {
			$row = $result->fetch_array(MYSQLI_ASSOC);
			if(!empty($row)) {
				$returnValue = $row;
			}
		}
		return $returnValue;
	}

	public function getUsersDateOfRecentUpload($user_id) {
		$returnValue = array();
		$sql = "select recentUploadTS from users where user_id='" . $user_id . "'";
		$result = $this->conn->query($sql);
		if ($result != null && (mysqli_num_rows($result) >= 1)) {
			$row = $result->fetch_array(MYSQLI_ASSOC);
			if(!empty($row)) {
				$returnValue = $row;
			}
		}
		return $returnValue;
	}

	public function getUserAudioFilesWithId($user_id) {
		$returnValue = array();
		$sql = "select file_path from audio_uploads where user_id='" . $user_id . "'";
		$result = $this->conn->query($sql);
		if ($result != null && (mysqli_num_rows($result) >= 1)) {
			for($i = 0; $i < mysqli_num_rows($result); $i++) {
				$row = $result->fetch_array(MYSQLI_ASSOC);
				if (!empty($row)) {
					array_push($returnValue, $row);
				}
			}
		}
		return $returnValue;
	}

	public function insertLocationHistoryByIds($user_id, $audio_id, $data) {
		/* data is json decoded array */
		foreach ($data as $k=>$v) {
			$arr = get_object_vars($v);
			$latitude = floatval($arr["latitude"]);
			$longitude = floatval($arr["longitude"]);
			$sql = "insert into location_history ". "(user_id, audio_id, locationTS, latitude, longitude) ". "values ('$user_id', '$audio_id', '$k', '$latitude', '$longitude')";
			if ($this->conn->query($sql) === TRUE) {
				continue;
			}
			else {
				return 0;
			}
		}
		return 1;	
	}

	public function insertUserRequest($author, $desired_location, $timeOfRequest, $content) {
		$status = "incomplete";
		$desired_location  = $this->conn->real_escape_string($desired_location);
		$sql = "insert into requests ". "(author, locationPOI, timeRequested, status, content) ". "values ('$author', '$desired_location', '$timeOfRequest', '$status', '$content')";
		if ($this->conn->query($sql) === TRUE) {
			return $this->conn->insert_id;
		}
		else {
			return -1;
		}
	}

	public function getRequests() {
		$returnValue = array();
		$sql = "select id, author, locationPOI as location, timeRequested as date, timeCompleted as datecomplete, status, content, classification from requests";
		$result = $this->conn->query($sql);
		if ($result != null && (mysqli_num_rows($result) >= 1)) {
			for($i = 0; $i < mysqli_num_rows($result); $i++) {
				$row = $result->fetch_array(MYSQLI_ASSOC);
				if (!empty($row)) {
					array_push($returnValue, $row);
				}
			}
		}
		return $returnValue;
	}

	public function updateRequestStatus($id, $timeOfUploadRequest, $classification) {
		$status = "complete";
		$myClass = "TBD";
		if ($classification != null) {
			$myClass = $classification;
		}
		$sql = "update requests set status = '$status', timeCompleted = '$timeOfUploadRequest', classification = '$myClass' where id = '$id'";
		if ($this->conn->query($sql) === TRUE) {
			return "SUCCESS";
		}
		else {
			return "FAILURE";
		}
	}
	
}
?>
