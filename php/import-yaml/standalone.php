<?php
// usage: php thisfile.php /path/to/yaml/file.yaml
[, $path] = $argv + array_fill(0, 4, '');
$credentials = ['username' => 'Admin', 'password' => 'zabbix'];
$url = 'http://z.git/master/ui/api_jsonrpc.php';

// Example how to get template file content from git.zabbix.com
// echo get_template('templates/os/windows_snmp/template_os_windows_snmp.yaml');

// Authenticate user, also set API url and auth token for all next calls to api function.
$resposne = api('user.login', $credentials, $url);

if (!is_string($resposne)) {
	var_dump($resposne);
	die('Cannot authenticate.');
}

// Importing template file from local filesystem. Replace function file_get_contents with get_template to read template directly from git.zabbix.com
$import = api('configuration.import', [
	'format' => 'yaml',
	'rules' => [
		'templates' => ['createMissing' => true, 'updateExisting' => true],
		'groups' => ['createMissing' => true, 'updateExisting' => true],
		'items' => ['createMissing' => true, 'updateExisting' => true, 'deleteMissing' => false],
		'httptests' => ['createMissing' => true, 'updateExisting' => true, 'deleteMissing' => false],
		'triggers' => ['createMissing' => true, 'updateExisting' => true, 'deleteMissing' => false],
		'discoveryRules' => ['createMissing' => true, 'updateExisting' => true, 'deleteMissing' => false],
		'graphs' => ['createMissing' => true, 'updateExisting' => true, 'deleteMissing' => false],
		'templateDashboards' => ['createMissing' => true, 'updateExisting' => true, 'deleteMissing' => false],
		'valueMaps' => ['createMissing' => true, 'updateExisting' => true, 'deleteMissing' => false]
	],
	'source' => file_get_contents($path)
]);

// Logout user. It is required to not fill session table with dead sessions.
api('user.logout');



/**
 * Make request to API. Add auth token for all requests automatically after successfull user.login action.
 *
 * @param string      $method    API method to call.
 * @param array       $params    Array of parameters for API method.
 * @param string|null $api_url   Can be omited after successfull uer.login action.
 * @return array
 */
function api(string $method, array $params = [], string $api_url = null) {
	static $auth = [], $id = 1, $url = null;

	$url = ($api_url === null) ? $url : $api_url;
	$request = [
		'jsonrpc' => '2.0',
		'method' => $method,
		'params' => $params,
		'id' => $id++
	] + $auth;
	$response = file_get_contents($url, false, stream_context_create([
		'http' => [
			'method'  => 'POST',
			'header'  => 'Content-Type: application/json',
			'content' => json_encode($request)
	]]));
	$response = json_decode($response, true);

	if ($method === 'user.login') {
		$auth = ['auth' => $response['result']];
		set_exception_handler(function () {
			echo "Logging out.",PHP_EOL;
			api('user.logout');
		});
	}

	if (array_key_exists('result', $response)) {
		return $response['result'];
	}

	echo "Incorrect API response, aborting.",PHP_EOL,
		"Request:",PHP_EOL,
		json_encode($request, JSON_PRETTY_PRINT),PHP_EOL,
		"Response:",PHP_EOL,
		json_encode($response, JSON_PRETTY_PRINT),PHP_EOL;

	throw new Exception;
}

/**
 * Get template body as string from Zabbix git repository for specific branch.
 *
 * @param string $path    Relative path to template file.
 * @param string $branch  Branch name. Default 'release/6.0'
 */
function get_template(string $path, string $branch = 'release/6.0') {
	$git_url = 'https://git.zabbix.com/projects/ZBX/repos/zabbix/raw/'.$path.'?'
		.http_build_query(['at' => 'refs/heads/'.$branch]);

	return file_get_contents($git_url);
}

