<?php
// usage: php thisfile.php apiauth /path/to/yaml/file.yaml
[, $auth, $path, $id] = $argv + array_fill(0, 4, '');
$auth !== '' or die('Define api key'.PHP_EOL);
($path !== '' && file_exists($path)) or die("Incorrect path $path".PHP_EOL);
echo json_encode([
    'jsonrpc' => '2.0',
    'method' => 'configuration.import',
    'params' => [
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
    ],
    'auth' => $auth,
    'id' => $id !== '' ? $id : (string)time()
]);

