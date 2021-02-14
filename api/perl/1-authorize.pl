#!/usr/bin/perl
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
  
#Authenticate yourself
my $client   = JSON::RPC::Legacy::Client->new();
my $url      = 'http://z40.catonrug.net:140/api_jsonrpc.php';
my $user     = 'Admin';
my $password = 'zabbix';

my $debug = 0;
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

print Dumper $response;
    # Check if response was successful
#    die "Authentication failed\n" unless $response->content->{'result'};

#    if ( $debug > 0 ) { print Dumper $response->content->{'result'}; }

#    return $response->content->{'result'};
