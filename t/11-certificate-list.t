#!/usr/bin/perl

use lib "t/lib";
use strict;
use warnings;

use Test::More tests => 1;
use Crypt::NSS config_dir => "db", cipher_suite => "US";

BEGIN { use_ok("Crypt::NSS::Certificates", qw(:usage)); }

my $list = Crypt::NSS::Certificates->find_user_certs_by_usage(CERT_USAGE_SSL_CLIENT);

my $certs = $list->get_nicknames();
#for (@$certs) {
#    print STDERR "$_\n";
#}