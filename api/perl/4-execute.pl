#!/usr/bin/env perl
use utf8;
use JSON::RPC::Legacy::Client;
use Data::Dumper;
  
#Authenticate yourself
my $client   = JSON::RPC::Legacy::Client->new();
my $url      = 'http://z40.catonrug.net:140/api_jsonrpc.php';
my $user     = 'Admin';
my $password = 'zabbix';

my $id = 0;

$key = $client->call($url, 
{
        jsonrpc => '2.0',
        method  => 'user.login',
        params  => {
            user     => $user,
            password => $password
        },
        id => $id++,
}
)->content->{'result'};

# list all proxies
$result = $client->call( $url,
{
    jsonrpc => '2.0',
    method => 'proxy.get',
    params => {
        output => ['name']
    },
    auth => $key,
    id => $id++,
}
);
print Dumper $result;
print $result->content->{'result'}->[0]{'proxyid'};

print $client->call( $url,
{
        jsonrpc => '2.0',
        method  => 'user.logout',
        params  => {},
        auth    => $key,
        id      => $id++,
}
)->jsontext;
#print $response->jsontext;

