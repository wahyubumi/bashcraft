#!/usr/bin/perl

# --------------------------------------------------
# Script Explanation:
# This script, a modified version of DeUa Meter v0.2e by Sridewa, monitors 
# and displays the network traffic on a Linux system in real-time.
# It reads from the /proc/net/dev file every second and computes 
# the receive (RX) and transmit (TX) speed for each network interface 
# in kilobytes per second (kB/s). 
# 
# Note: This script should ideally be run with privileges 
# that can read the /proc/net/dev file.
# --------------------------------------------------
#                    CREDITS                        
# --------------------------------------------------
#
# Original Author: Sridewa (Deceased)
# Modified By: Wahyu Wijanarko
# Email: wahyu@wahyu.com
# Date: 26 September 2023
# License: GPLv3
#
# --------------------------------------------------

use strict;
use warnings;

print "DU Meter v0.3:\nSimply count bytes (in kBytes/sec)\n--------------------------------------\n\n";

my @last_RX;
my @last_TX;

while (1) {
    open my $fh, '<', "/proc/net/dev" or die "Cannot open /proc/net/dev: $!";
    my @lines = <$fh>;
    close $fh;

    my $idx = 0; # Initialize a separate counter for index

    foreach my $line (@lines[2..$#lines]) {
        my ($if, $stats) = split(":", $line);
        my ($rx_bytes, $tx_bytes) = (split(" ", $stats))[0, 8];

        my $rx_spd = (defined $last_RX[$idx]) ? ($rx_bytes - $last_RX[$idx]) : 0;
        my $tx_spd = (defined $last_TX[$idx]) ? ($tx_bytes - $last_TX[$idx]) : 0;

        $last_RX[$idx] = $rx_bytes;
        $last_TX[$idx] = $tx_bytes;

        printf "~%.6s: (%8.2f/%8.2f) ", $if, $rx_spd / 1024, $tx_spd / 1024;

        $idx++; # Increment the counter after each iteration
    }

    sleep 1;
    print "\n";
}