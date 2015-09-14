#!/bin/env perl

use strict;
use warnings;
use List::Util ();

@ARGV or die "usage: %0 [pid ...]";

my @output;

for my $pid (@ARGV) {
   die "invalid pid '$pid'" if $pid =~ /\D/;
   my @smaps = `cat /proc/$pid/smaps`;
   die if $? != 0;
   my @shared = map { /(\d+)\s+kB/; $1 } grep { /^Shared_(Clean|Dirty)/ } @smaps;
   my $shared_total = List::Util::sum(@shared);
   my @rss = map { /(\d+)\s+kB/; $1 } grep { /^Rss/ } @smaps;
   my $rss_total = List::Util::sum(@rss);
   my $parcent = sprintf '(%d %%)', int(($shared_total / $rss_total) * 100);
   push @output, [$pid, $rss_total, $parcent];
}

unshift @output, [qw(PID RSS SHARED)];

for my $out (@output) {
    print join "\t", @$out;
    print "\n";
}
