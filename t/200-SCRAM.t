#!/usr/bin/env perl6

use v6.c;
use Test;

use Auth::SCRAM;
#use OpenSSL::Digest;
#use Base64;

#-------------------------------------------------------------------------------
# A user credentials database used to store added users to the system
# Credentials must be read from somewhere and saved to the same somewhere.
class Credentials {
  has Hash $!credentials-db;
  has Auth::SCRAM $!scram;

  #-----------------------------------------------------------------------------
  submethod BUILD ( Str:D :$username, Str:D :$password ) {

    $!scram .= new(
      :username($username),
      :password($password),
      :server-side(self),
      :basic-use
    );

  }

  #-----------------------------------------------------------------------------
  method add-user ( $username, $password ) {

    my Buf $salt = self.salt;
    my Int $iter = self.iterations;
    my Buf $mangled-password = $!scram.mangle-password($password);

    isa-ok $sc, Auth::SCRAM;
  }
}

#-------------------------------------------------------------------------------
# Example from rfc
# C: n,,n=user,r=fyko+d2lbbFgONRv9qkxdawL
# S: r=fyko+d2lbbFgONRv9qkxdawL3rfcNHYJY1ZVvWVs7j,s=QSXCR+Q6sek8bf92,i=4096
# C: c=biws,r=fyko+d2lbbFgONRv9qkxdawL3rfcNHYJY1ZVvWVs7j,
#    p=v0X8v3Bz2T0CJGbJQyF0X+HI4Ts=
# S: v=rmF9pqV8S7suAoZWja4dJRkFsKQ=
#
class MyServer {

  #-----------------------------------------------------------------------------
  submethod BUILD ( Str:D :$username, Str:D :$password ) {

    my Auth::SCRAM $sc .= new(
      :username($username),
      :password($password),
      :server-side(self)
    );


    $sc.s-nonce-size = 24;
    $sc.s-nonce = '3rfcNHYJY1ZVvWVs7j';
    
  }

  #-----------------------------------------------------------------------------
  # return server first message to client, then receive and
  # return client final response
  method server-first ( Str:D $server-first-message --> Str ) {

    is $server-first-message,
       'r=fyko+d2lbbFgONRv9qkxdawL3rfcNHYJY1ZVvWVs7j,s=QSXCR+Q6sek8bf92,i=4096',
       $server-first-message;

    < c=biws
      r=fyko+d2lbbFgONRv9qkxdawL3rfcNHYJY1ZVvWVs7j
      p=v0X8v3Bz2T0CJGbJQyF0X+HI4Ts=
    >.join(',');
  }

  #-----------------------------------------------------------------------------
  # return server final message
  method server-final ( Str:D $server-final-message --> Str ) {

  }

  #-----------------------------------------------------------------------------
  # method auth-id() is optional and called when gs2 header provides it
  method authzid ( Str $username, Str $authzid --> Bool ) {

  }

  #-----------------------------------------------------------------------------
  # method salt() is optional
  method salt ( --> Buf ) {

    Buf.new( 65, 37, 194, 71, 228, 58, 177, 233, 60, 109, 255, 118);
  }

  # method iterations() is optional

  # method mangle-password() is optional

  #-----------------------------------------------------------------------------
  # method cleanup() is optional
  method cleanup ( ) {

    diag 'been here, done that';
  }

  #-----------------------------------------------------------------------------
  method error ( Str:D $message --> Str ) {

  }
}

#-------------------------------------------------------------------------------
subtest {

  # Preparations
  my MyServer $ms .= new(
    :username<user>,
    :password<pencil>
  );

  # Server listens on socket and gets request to process client first message
#  my Str $client-first-message = 'n,,n=user,r=fyko+d2lbbFgONRv9qkxdawL';

#  my $error = $sc.start-scram(:$client-first-message);
#  is $error, '', "Empty error: '$error'";

}, 'SCRAM tests';

#-------------------------------------------------------------------------------
done-testing;
