$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$headers.Add("Content-Type", "application/json")
$url = 'http://demo.zabbix.demo/api_jsonrpc.php'
$user = 'Admin'
$password = 'zabbix'

# authorization
$key = Invoke-RestMethod $url -Method 'POST' -Headers $headers -Body "
{
    `"jsonrpc`": `"2.0`",
    `"method`": `"user.login`",
    `"params`": {
        `"user`": `"$user`",
        `"password`": `"$password`"
    },
    `"id`": 1
}
" | foreach { $_.result }
echo $key

# download all proxy IDs and names
$allProxies=Invoke-RestMethod $url -Method 'POST' -Headers $headers -Body "
{
    `"jsonrpc`": `"2.0`",
    `"method`": `"proxy.get`",
    `"params`": {
        `"output`": [`"proxyid`",`"host`"]
        
    },
    `"auth`": `"$key`",
    `"id`": 1
}
" | foreach { $_.result }  

# download availability of devices which are enabled and the monitoring has been scheduled
$allHosts=Invoke-RestMethod $url -Method 'POST' -Headers $headers -Body "
{
    `"jsonrpc`": `"2.0`",
    `"method`": `"host.get`",
    `"params`": {
        `"output`": [`"interfaces`",`"error`",`"name`",`"available`",`"proxy_hostid`"],
        `"selectInterfaces`": `"extend`",
        `"filter`": {`"status`":`"0`"}
    },
    `"auth`": `"$key`",
    `"id`": 1
}
" | foreach { $_.result }  

# this will be an object which stores a data. it's not a text sting!
$totalResult = @()

foreach($res in $allHosts) {

# go through each host
$totalResult += [PSCustomObject]@{

# create a loop to find what is name of Zabbix proxy
Proxy = $allProxies | where {($_.proxyid -like $res.proxy_hostid )} | foreach { $_.host }
# there is a possibility that no name has found. in this case the field will remain empty

# put a host visiable name, if visiable name is not configured then grab host name
Host = $res.name

# while working with interface block it's required to locate the main interface with ($_.main -like 1)
Type = $res.interfaces | where {($_.main -like 1 )} | foreach { $_.type -replace "1", "ZBX" -replace "2", "SNMP" -replace "3", "IPMI" -replace "4", "JMX" }
Port = $res.interfaces | where {($_.main -like 1 )} | foreach { $_.port }

Status = $res | foreach { $_.available -replace "0", "unknown" -replace "1", "monitored" -replace "2", "not reachable" }

# some environments prefer an IP address for passive checks, some environments prefer DNS entry
# the following command will determine the connection (IP or DNS) which is configured and print IP or DNS
"Connection" = switch ($res.interfaces | where {($_.main -like 1 )} | foreach { $_.useip }){0 {$res.interfaces | where {($_.main -like 1 )}|foreach { $_.dns }} 1 {$res.interfaces | where {($_.main -like 1 )}|foreach { $_.ip }}}

# if host is not available then we need to know why
"Last error" = $res.error

}
}

# log out
Invoke-RestMethod $url -Method 'POST' -Headers $headers -Body "
{
    `"jsonrpc`": `"2.0`",
    `"method`": `"user.logout`",
    `"params`": [],
    `"id`": 1,
    `"auth`": `"$key`"
}
" 

$totalResult | Out-GridView