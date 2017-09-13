<?php
require("DBConn.php");
require("MySQLDao.php");

$dao = new MySQLDao();
$dao->openConnection();

$data = json_decode(file_get_contents('php://input'), true);

if ($data["type"] == "getRequests") {
	$requests = $dao->getRequests();
	echo json_encode($requests);
}

else {
	$desired_location = $data["location"];
	$author = $data["author"];
	$content = $data["content"];
	date_default_timezone_set('America/New_York');
	$timeOfRequest = date('Y-m-d H:i:s', $_SERVER['REQUEST_TIME']);



	$JSONMessage = array();

	if ($desired_location == null) {
		$JSONMessage["desiredLocation"] = array('Message'=>'Please provide a valid location', 'Status'=>'Error');
	}

	if ($author == null) {
		$JSONMessage["author-msg"] = array('Message' => 'Please provide a valid author', 'Status' => 'Error');
	}

	if ($content == null) {
		$JSONMessage["content-msg"] = array('Message' => 'Please provide a valid audio request.', 'Status' => 'Error');
	}

	/* save request data to db w/status: incomplete */


	$id = $dao->insertUserRequest($author, $desired_location, $timeOfRequest, $content);
	if ($id != -1 ) {
		$JSONMessage["requestsDB"] = array("Message" => "Metadata of your audio request successfully added for your records.", "Status" => "OK");
	}
	else {
		$JSONMessage["requestsDB"] = array("Message" => "Sorry, there was an error adding metadata of your audio request to our databases.", "Status" => "Error");
	}

	$JSONMessage["id"] = $id;
	$JSONMessage["date"] = $timeOfRequest;
	$JSONMessage["location"] = $desired_location;
	$JSONMessage["author"] = $author;
	$JSONMessage["content"] = $content;
	$JSONMessage["status"] = "incomplete";

	echo json_encode($JSONMessage);
}

?>