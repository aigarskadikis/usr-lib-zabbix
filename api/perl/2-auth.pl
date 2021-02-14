#!/usr/bin/perl
use utf8;
use JSON::RPC::Legacy::Client;
  
#Authenticate yourself
my $client   = JSON::RPC::Legacy::Client->new();
my $url      = 'http://z40.catonrug.net:140/api_jsonrpc.php';
my $user     = 'Admin';
my $password = 'zabbix';

my ( $authID, $response, $json );
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

print $response->content->{'result'};
