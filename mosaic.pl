#!/opt/local/bin/perl

use warnings;
use strict;
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

# Generate a set of bricks of random color
# First generate 8 random color
# Then choose from the random color and add to set
#
sub brickset {
  my($size) = shift;

  my @colors;
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
      warn "$n: Swapping $i and $j - $better\n";
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


my $size = 12**2;
my @orig = origimage($size);
my @new = brickset($size);
my @first = @new;
swap(\@orig, \@new);
dumphtml(\@orig, \@new, \@first);
