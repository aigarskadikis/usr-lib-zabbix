#!/usr/bin/perl
use utf8;
use JSON::RPC::Legacy::Client;
use Data::Dumper;
  
#Authenticate yourself
my $client   = JSON::RPC::Legacy::Client->new();
my $url      = 'http://z40.catonrug.net:140/api_jsonrpc.php';
my $user     = 'Admin';
my $password = 'zabbix';

my $id = 0;
  
$json = {
        jsonrpc => '2.0',
        method  => 'user.login',
        params  => {
            user     => $user,
            password => $password
        },
        id => $id++,
    };

$response = $client->call( $url, $json );

$authID = $response->content->{'result'};

print "$authID\n";

    $json = {
        jsonrpc => '2.0',
        method  => 'user.logout',
        params  => {},
        id      => $id++,
        auth    => $authID,

    };


$response = $client->call( $url, $json );
#print Dumper $response;
print $response->jsontext;

