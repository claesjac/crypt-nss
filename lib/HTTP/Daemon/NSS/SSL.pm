# This package derived almost entirely from HTTP::Daemon by Gisle Aas
# and HTTP::Daemon::SSL by Mark Aufflick et al.

use strict;

package HTTP::Daemon::NSS::SSL;

use HTTP::Daemon;

our $VERSION = "0.05";
our @ISA = qw(Net::NSS::SSL HTTP::Daemon);

sub new {
    my ($pkg, %args) = @_;
    $args{Listen} ||= 5;
    $args{Proto} ||= 'tcp';
    my $self = $pkg->SUPER::new(%args);
	return $self;
}

sub accept {
    my $self = shift;
	my $sock = $self->SUPER::accept();
    if ($sock) {
    	$sock = $sock->as_glob(q{HTTP::Daemon::ClientConn::NSS::SSL});
        ${*$sock}{'httpd_daemon'} = $self;
        return wantarray ? ($sock, $sock->peerhost) : $sock;
    }
    else {
        return;
    }
}

sub url
{
    my $self = shift;
    my $url = "https://" . $self->sockhost . ":" . $self->sockport . "/";
    return $url;
}


package HTTP::Daemon::NSS::SSL::DummyDaemon;
our @ISA = qw(HTTP::Daemon);
sub new { bless [], shift; }

package HTTP::Daemon::NSS::SSL;

sub ssl_error {
    my ($self, $error) = @_;
    ${*$self}{'httpd_client_proto'} = 1000;
    ${*$self}{'httpd_daemon'} = new HTTP::Daemon::NSS::SSL::DummyDaemon;
    if ($error =~ /http/i and $self->opened) {
	$self->send_error(400, "Your browser attempted to make an unencrypted\n ".
		      "request to this server, which is not allowed.  Try using\n ".
		      "HTTPS instead.\n");
    }
    $self->kill_socket;
}

# we're not overriding any methods here, but we are inserting Net::NSS::SSL::AsGlob
# into the message dispatch tree

package HTTP::Daemon::ClientConn::NSS::SSL;
our @ISA = qw(Net::NSS::SSL::AsGlob HTTP::Daemon::ClientConn);
*DEBUG = \$HTTP::Daemon::DEBUG;

1;
__END__

=head1 NAME

HTTP::Daemon::NSS::SSL - a simple http server class with SSL support

=head1 SYNOPSIS

  use Crypt::NSS config_db => "db", cipher_suite => "US";
  use HTTP::Daemon::NSS::SSL;
  use HTTP::Status;

  # NSS wants your certs to be in the database
  my $d = HTTP::Daemon::NSS::SSL->new(
      SSL_ServerCertNickname => "mydomain.com", # nickname in data
      SSL_Password => "my-password", # certificate password
  ) || die;
  print "Please contact me at: <URL:", $d->url, ">\n";
  while (my $c = $d->accept) {
      while (my $r = $c->get_request) {
	  if ($r->method eq 'GET' and $r->url->path eq "/xyzzy") {
              # remember, this is *not* recommened practice :-)
	      $c->send_file_response("/etc/passwd");
	  } else {
	      $c->send_error(RC_FORBIDDEN)
	  }
      }
      $c->close;
      undef($c);
  }

=head1 DESCRIPTION

=head1 INTERFACE

=head2 CLASS METHODS

=over 4

=item new ( %args ) : HTTP::Daemon::NSS::SSL

Creates a new daemon that can handle HTTPS.

=back

=head2 INSTANCE METHODS

=cut
