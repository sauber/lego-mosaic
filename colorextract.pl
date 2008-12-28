#!/usr/bin/perl

use HTML::TableExtract;

open FH, "colors.html";
  my $html_string = join '', <FH>;
close FH;

#print $html;

my $te = HTML::TableExtract->new( headers => [qw(Name Parts LDrawRGB)] );
$te->parse($html_string);

my @colors;
for my $row ($te->rows) {
  #print join(',', @$row), "\n";
  push @colors, $row if $row->[2];
}

for $row ( sort { $b->[1] <=> $a->[1] } @colors ) {
  print join(',', @$row), "\n";
}
