#!/usr/bin/perl

use lib "t/lib";
use strict;
use warnings;

use Test::More tests => 2;
use Test::Exception;
use Test::Crypt::NSS::SelfServ;

use Crypt::NSS config_dir => "db", cipher_suite => "US";

start_ssl_server(config_dir => "db", port => 4433, password => "crypt-nss");

my $socket = Net::NSS::SSL->new(PeerPort => 4433, PeerHost => "127.0.0.1", Blocking => 1);
$socket = $socket->as_glob;
isa_ok($socket, "GLOB");
print $socket "GET / HTTP/1.1\n\n";
my $data = "";
sysread($socket, $data, 2048);
ok($data);
stop_ssl_server();

