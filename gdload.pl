#!/usr/bin/perl

# Test loading a png file with GD

use strict;
use GD;

my $img = GD::Image->new( $ARGV[ 0 ] );
my( $w, $h ) = $img->getBounds;
print "The image '$ARGV[ 0 ]' is $w x $h pixels.";

printf "The color of the pixel in the middle is: [0x%02x:0x%02x:0x%02x].\n",
    $img->rgb( $img->getPixel( $w/2, $h/2 ) );

for my $y ( 0 .. $h-1 ) {
  for my $x ( 0 .. $w-1 ) {
    printf "[0x%02x:0x%02x:0x%02x].\n", $img->rgb( $img->getPixel($x,$y) );
  }
}


