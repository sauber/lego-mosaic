#!/usr/bin/perl

use HTML::TableExtract;

open FH, "colors.html";
  $html = join '', <FH>;
close FH;

#print $html;

$te = HTML::TableExtract->new( headers => [qw(Name Parts LDrawRGB)] );
 $te->parse($html_string);

 foreach $row ($te->rows) {
	     print join(',', @$row), "\n";
	      }

