<?php
header('Content-Type: application/json');

$uploads_dir = dirname(__FILE__) . '/files';
$message = "";

if( isset($_FILES["ocr"]) ){
	$file = time() . ".jpg";
	move_uploaded_file($_FILES["ocr"]["tmp_name"], "$uploads_dir/$file");
	$message = shell_exec("export MODULE_PATH=/home/vagrant/.EasyOCR/ && easyocr -l ja -f $uploads_dir/$file --detail=0 --gpu=True 2>&1");
}

echo json_encode(array(
	'message' => $message
));
?>