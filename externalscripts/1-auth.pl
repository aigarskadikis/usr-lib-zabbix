#!/usr/bin/env perl
use warnings;
use strict;
use utf8;
binmode( STDOUT, ':utf8' );
use 5.010;
use strict;
use warnings;
use JSON::RPC::Legacy::Client;
use Data::Dumper;
use Switch;


my $client   = JSON::RPC::Legacy::Client->new();
my $url      = 'http://127.0.0.1:140/api_jsonrpc.php';
my $user     = 'Admin';
my $password = 'zabbix';

$json = {
        jsonrpc => '2.0',
        method  => 'user.login',
        params  => {
            user     => $user,
            password => $password

        },
        id => 1,
    };

$response = $client->call( $url, $json );

