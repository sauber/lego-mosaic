#!/usr/bin/perl

use warnings;
use strict;
use GD;
use Image::Resize;
use Data::Dumper;

sub legocolor {
  return (
    [qw(27 42 52)],    # Black
    [qw(109 110 108)], # Dark Grey
    [qw(1991 93 183)], # Light Grey
    [qw(242 243 242)], # White
    [qw(196 40 27)],   # Red
    [qw(105 64 39)],   # Brown
    [qw(245 205 47)],  # Yellow
    [qw(40 127 70)],   # Green
    [qw(13 105 171)],  # Blue
  );
}

# The set of bricks I have
#
sub mybricks {
  my @def = qw(
    Black     212121  7
    White     FFFFFF  3
    Red       C40026 20
    OldGrey   C1C2C1  2
    Yellow    FFDC00 23
    Blue      0033B2 12
    OldDkGray 635F52  7
    Green     008C14 12
    Tan       E8CFA1 15
    Brown     5C2000  5
    Orange    F96000  9
    DkRed     78001C  3
    TrBlue    0020A0  1
    TrLtBlue  AEEFEC  2
    DkGreen   27462C  6
    BtGreen   6BEE90  7
    DkTan     C59750  6
    DKYellow  FDB300  1
    BtOrange  FB8700  3
  );

  my @set;
  while ( @def ) {
    my $name = shift @def;
    my $hex  = shift @def;
    my $num  = shift @def;
    my $r = hex substr $hex, 0, 2;
    my $g = hex substr $hex, 2, 2;
    my $b = hex substr $hex, 4, 2;
    #print "$name - $num [ $r, $g, $b ]\n";
    for ( 1 .. $num) {
      push @set, [ $r, $g, $b ];
    }
  }
  return @set;
}

# Generate a set of bricks of random color
# First generate 8 random color
# Then choose from the random color and add to set
#
sub brickset {
  my($size) = shift;

  #my @colors;
  #for my $n ( 1 .. 8 ) {
    #push @colors, [ int rand 256, int rand 256, int rand 256 ];
  #}
  my @colors = legocolor();
  #warn Dumper @colors;
  my @set;
  for my $n ( 1 .. $size ) {
    push @set, $colors[int rand @colors];
  }
  #warn Dumper @set;
  return @set;
}

# Generate a random image
#
sub origimage {
  my($size) = shift;

  my @img;
  my $r = my $g = my $b = 0;
  for my $n ( 1 .. $size ) {
    #push @img, [ int rand 256, int rand 256, int rand 256 ];
    push @img, [ $r, $g, $b ];
    $r = ($r+1+int rand 7) % 256;
    $g = ($g+1+int rand 11) % 256;
    $b = ($b+1+int rand 13) % 256;
  }
  #warn Dumper @img;
  return @img;
}

sub readimage {
  my $orig = Image::Resize->new( $ARGV[0] );
  my $img = $orig->resize(12, 12, 0);
  #my $img = GD::Image->new( $ARGV[ 0 ] );
  my @pixels;
  #my( $w, $h ) = $img->getBounds;
  #print "The image '$ARGV[ 0 ]' is $w x $h pixels.";

  #printf "The color of the pixel in the middle is: [0x%02x:0x%02x:0x%02x].\n",
      #$img->rgb( $img->getPixel( $w/2, $h/2 ) );

  for my $y ( 0 .. 11 ) {
    for my $x ( 0 .. 11 ) {
      #printf "[0x%02x:0x%02x:0x%02x].\n", $img->rgb( $img->getPixel($x,$y) );
      push @pixels, [ $img->rgb( $img->getPixel($x,$y) ) ];
    }
  }
  return @pixels;
}

# 3D distance between two coordinates
#
sub distance {
  my($ax,$ay,$az,$bx,$by,$bz) = @_;

  return sqrt( ($ax-$bx)**2 + ($ay-$by)**2 + ($az-$bz)**2 );
}

# Compare if a swap will help improving color match
#
sub improve {
  my($orig1, $new1, $orig2, $new2 ) = @_;

  my $d1 = distance(@$orig1,@$new1);
  my $d2 = distance(@$orig2,@$new2);
  my $d3 = distance(@$orig1,@$new2);
  my $d4 = distance(@$orig2,@$new1);

  return ( $d1+$d2)-($d3+$d4);
}

# Swap around some bricks
#
sub swap {
  my($orig,$new) = @_;

  my $size = @$orig;
  for my $n ( 1 .. 200000 ) {
    my $i = int rand $size;
    my $j = int rand $size;
    next if $i == $j;
    my $better = improve($orig->[$i], $new->[$i], $orig->[$j], $new->[$j]);
    if ( $better > 0 ) {
      #warn "$n: Swapping $i and $j - $better\n";
      ($new->[$i], $new->[$j]) = ($new->[$j], $new->[$i]);
    } else {
      #warn "Keeping $i and $j - $better\n";
    }
  }
}

# Convert color tuple to html code
#
sub htmlcolor {
  sprintf "#%02X%02X%02X", @_;
}

# Print out html
sub dumphtml {
  my @table = @_;

  #warn Dumper \@table;
  #exit;
  my $l = sqrt(@{$table[0]});
  print "<table><tr>";
  for my $t ( 0 .. $#table ) {
    my $p = 0;
    print "<td><table border=1 cellpadding=0 cellspacing=0>";
    for my $r ( 1 .. $l ) {
      print "<tr>";
      for my $c ( 1 .. $l ) {
        printf "<td bgcolor=%s>88<td>", htmlcolor(@{$table[$t][$p++]});
      }
      print "</tr>\n";
    }
    print "</table></td>\n";
  }
  print "</tr></table>";
}


#mybricks();
my $size = 12**2;
my @orig = readimage($size);
#my @new = brickset($size);
my @new = mybricks($size);
my @first = @new;
swap(\@orig, \@new);
dumphtml(\@orig, \@new, \@first);
