#!/usr/bin/perl -w

use strict;
use warnings;

use JSON::DWIW;

use Data::Dumper;

sub get_gsuggest {
  my $topic = shift;
  my $gs_url="http://clients1.google.com/complete/search?q=$topic";
  use LWP::Simple;
  my $gs_raw = get($gs_url) || die ("failed getting $gs_url");
  my $gs_json;
  if ($gs_raw =~ m/window\.google\.ac\.h\((.*)\)/) {
    $gs_json = $1;
    #print $gs_json;
    return $gs_json;
  }
  else {die ("Format of google suggest changed");}
    

}

sub transform_gsuggest_data {
  my $raw_gsuggest_data = shift;
  my $data=JSON::DWIW::deserialize($raw_gsuggest_data);
  my $items = $data->[1];
  my @suggestions;
  my $x = 0;
  foreach my $i (@$items) {    
    # cleanup  
    $i->[1] =~ s/\s+results\s?//;
    $i->[1] =~ s/,//g;
    $suggestions[$x]->{'body'} = $i->[0];
    $suggestions[$x]->{'n_results'} = $i->[1];
    $suggestions[$x]->{'rank'} = $i->[2];    
    $x++;
  }
  
  #print Dumper(@suggestions);
  return @suggestions;
}

#my $json_str = q/["why does yahoo",[["why does yahoo go to m.www.yahoo.com","620,000,000 results","0"],["why does yahoo messenger keep crashing","522,000 results","1"],["why does yahoo mail not work","219,000,000 results","2"],["why does yahoo messenger keep signing out","9,950,000 results","3"],["why does yahoo look different","466,000,000 results","4"],["why does yahoo have an m","407,000,000 results","5"],["why does yahoo take so long to load","5,220,000 results","6"],["why does yahoo freeze","7,980,000 results","7"],["why does yahoo mail say connection refused","33,100 results","8"],["why does yahoo mail take so long to load","622,000 results","9"]]]/;

my $topic = $ARGV[0];
my $json_str = get_gsuggest ($topic);
my @suggestions = transform_gsuggest_data ($json_str);

print "Rank\tBody\n";
print "----\t----\n";

foreach my $i (@suggestions) {
  print $i->{'rank'},"\t", $i->{'body'},"\n";
}

