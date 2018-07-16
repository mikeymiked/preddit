#!/usr/local/bin/perl

use strict;
use warnings;

use WWW::Mechanize;
use List::MoreUtils qw(uniq);
use Getopt::Long qw(GetOptions);
use JSON::PP;

use v5.8.0;

$ENV{PERL_LWP_SSL_VERIFY_HOSTNAME} = 0;

my $mech = WWW::Mechanize->new();
$mech->agent_alias('Mac Mozilla');

#Provide a sub and limit to scrape on the command line. If no sub or limit provided, default to /r/all and 100
my $sub;
my $limit;

GetOptions('sub=s' => \$sub,
            'limit=i' => \$limit);

if (!defined($sub)) {
    $sub = 'all';
    print "No sub provided. Scraping /r/all...\n";
}

if (!defined($limit) || $limit > 100) {
    $limit = 100;
    print "No limit provided or greater than 100. Defaulting to 100...\n";
}

$mech->get("https://www.reddit.com/r/$sub/top/.json?sort=top&t=day&limit=$limit");

my $json = JSON::PP->new()->decode($mech->content());

my @links;

foreach my $result (0..$limit) {
    my $value = $json->{data}{children}[$result]{data}{url};
    if(defined($value) and $value =~ m/(youtube\.com\/watch)|(imgur|redd\.it).*\.(jpe?g|gifv?|png)$/i) {
        push @links, $value;
    }
}

print "$_\n" for uniq @links;
