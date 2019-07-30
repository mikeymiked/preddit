#!/usr/bin/perl

# Scrapes a given subreddit with a given limit
# and downloads the JPG, JPEG, GIF, and PNG files
# found.

use strict;
use warnings;

use WWW::Mechanize;
use List::MoreUtils qw(uniq);
use Getopt::Long qw(GetOptions);
use JSON::PP;

$ENV{PERL_LWP_SSL_VERIFY_HOSTNAME} = 0;

my $mech = WWW::Mechanize->new();
$mech->agent_alias('Mac Mozilla');

# Provide a sub and limit to scrape on the command line. If no sub or limit provided, default to /r/all and 100
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

# Filter images posted to imgur and Reddit and download them
foreach my $result (0..$limit) {
    my $value = $json->{data}{children}[$result]{data}{url};
    #(youtube\.com\/watch)|
    if(defined($value) and $value =~ m/(imgur|redd\.it).*\.(jpe?g|gif|png)$/i) {
        my $image = (split(/\//, $value))[-1];
        $mech->get($value, ':content_file' => $image);
    }
}
