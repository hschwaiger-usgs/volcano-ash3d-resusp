<html><body>

<?php

$files = scandir(__DIR__ . '/Resusp');
foreach ($files as $file) {
	if (filetype(__DIR__ . '/Resusp/' . $file) === 'dir') { continue; }
	//echo __DIR__ . '/Resusp/' . $file . '<br/>';
	echo "<a href='./Resusp/$file'>$file</a><br/>";
}

?>

</body></html>
