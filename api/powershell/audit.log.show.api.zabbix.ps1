
Add-Type @"
using System.Net;
using System.Security.Cryptography.X509Certificates;
public class TrustAllCertsPolicy : ICertificatePolicy {
    public bool CheckValidationResult(
    ServicePoint srvPoint, X509Certificate certificate,
    WebRequest request, int certificateProblem) {
        return true;
    }
}
"@

[System.Net.ServicePointManager]::CertificatePolicy = New-Object TrustAllCertsPolicy

# Set Tls versions
$allProtocols = [System.Net.SecurityProtocolType]'Ssl3,Tls,Tls11,Tls12'
[System.Net.ServicePointManager]::SecurityProtocol = $allProtocols

$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$headers.Add("Content-Type", "application/json")
$url = 'https://zabbix.contoso.com/api_jsonrpc.php'
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

# auditlog
$auditlog=Invoke-RestMethod $url -Method 'POST' -Headers $headers -Body "
{
    `"jsonrpc`": `"2.0`",
    `"method`": `"auditlog.get`",
    `"params`": {
        `"output`": `"extend`",
        `"sortfield`": `"clock`",
        `"sortorder`": `"DESC`"
    },
    `"auth`": `"$key`",
    `"id`": 1
}
" | foreach { $_.result }  

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

$auditlog | Out-GridView
