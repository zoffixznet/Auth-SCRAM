#!/usr/bin/env perl6

use v6.c;
use Test;

use Auth::SCRAM;
use OpenSSL::Digest;
use Base64;

#-------------------------------------------------------------------------------
# Example from rfc
# C: n,,n=user,r=fyko+d2lbbFgONRv9qkxdawL
# S: r=fyko+d2lbbFgONRv9qkxdawL3rfcNHYJY1ZVvWVs7j,s=QSXCR+Q6sek8bf92,i=4096
# C: c=biws,r=fyko+d2lbbFgONRv9qkxdawL3rfcNHYJY1ZVvWVs7j,
#    p=v0X8v3Bz2T0CJGbJQyF0X+HI4Ts=
# S: v=rmF9pqV8S7suAoZWja4dJRkFsKQ=
#
class MyClient {

  # send client first message to server and return server response
  method message1 ( Str:D $string --> Str ) {

    is $string, 'n,,n=user,r=fyko+d2lbbFgONRv9qkxdawL', $string;

    'r=fyko+d2lbbFgONRv9qkxdawL3rfcNHYJY1ZVvWVs7j,s=QSXCR+Q6sek8bf92,i=4096';
  }

  method message2 ( Str:D $string --> Str ) {
  
  }

  method message3 ( Str:D $string --> Str ) {
  
  }

  method user-hash-password ( Str:D $username, Str:D $password --> Str ) {

    $password;
  }

  method error ( Str:D $message --> Str ) {

  }
}

#-------------------------------------------------------------------------------
subtest {

  my Auth::SCRAM $sc .= new(
    :username<user>,
    :password<pencil>,
    :client-side(MyClient.new),
  );
  isa-ok $sc, Auth::SCRAM;

  $sc.c-nonce-size = 24;
  $sc.c-nonce = 'fyko+d2lbbFgONRv9qkxdawL';

  $sc.start-scram;

}, 'SCRAM tests';

#-------------------------------------------------------------------------------
done-testing;
