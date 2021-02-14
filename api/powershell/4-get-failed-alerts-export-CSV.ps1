$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$headers.Add("Content-Type", "application/json")
$url = 'https://zbx.catonrug.net/api_jsonrpc.php'
$user = 'api'
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

# get failed alerts
Invoke-RestMethod $url -Method 'POST' -Headers $headers -Body "
{
    `"jsonrpc`": `"2.0`",
    `"method`": `"alert.get`",
    `"params`": {
        `"output`": `"extend`"
    },
    `"auth`": `"$key`",
    `"id`": 1
}
" | foreach { $_.result } | select clock,eventid,alertid,status,userid,message | Export-Csv c:\temp\ps.csv
#" | foreach { $_.result } | select clock,eventid,alertid,status,userid,message | Out-File C:\temp\file.log
#" | foreach { $_.result } | select clock,eventid,alertid,status,userid,message | Out-GridView

# alertid
# alertid       : 738
# actionid      : 63
# eventid       : 110830
# userid        : 0
# clock         : 1595719631
# mediatypeid   : 0
# sendto        : 
# subject       : 
# message       : Zabbix server:date >> /tmp/bigger.than.avarage.log
#                 echo '02:27:07' >> /tmp/bigger.than.avarage.log
#                 echo ============ >> /tmp/bigger.than.avarage.log
# status        : 1
# retries       : 0
# error         : 
# esc_step      : 1
# alerttype     : 1
# p_eventid     : 0
# acknowledgeid : 0
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


# Select-Object Name, SamAccountName, Manager, Title, AccountExpirationDate, LastLogonDate | Export-CSV c:\users_expirationdate.csv -NoTypeInformation
# | Out-GridView