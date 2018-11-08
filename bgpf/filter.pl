#!/usr/bin/perl
#===============================================================================
#
#         FILE:  filter.pl
#
#        USAGE:  ./filter.pl  
#
#  DESCRIPTION:  Generate BGP filter. bgpq3 based, https://github.com/snar/bgpq3, Alexandre Snarskii snar@snar.spb.ru
#
#      OPTIONS:  ---
# REQUIREMENTS:  ---
#         BUGS:  ---
#        NOTES:  ---
#       AUTHOR:  Mitya (c)
#      COMPANY:  NH
#      VERSION:  0.1
#      CREATED:  17.06.2010 14:55:46
#     REVISION:  ---
#===============================================================================

use strict;
use warnings;
use POSIX;
use locale;
setlocale(LC_ALL,"ru_SU");
use lib "/home/python/tmp/bgpf/Mod";
use DBI;
use Getopt::Std;
use vars qw/ %opt /;

use UpstreamFilter;
use PeerFilter;
use CustomerFilter;

my ($row, $arrayr, @row,  @arrayr, $hash_ref, $hr, %hash_ref);
my ($id, $type, $peer_name, $aut_num, $as_set, $as_path_list_num, $nn);
my ($arg, $query, $querytmp, $i);
my ($dbh, $sth);
my (%opt, $peerarg, @peerarg, $j);


my $opt_string = 'hinRjl:';
getopts( "$opt_string", \%opt ) or usage();
usage() if $opt{h};

$querytmp='';

if(defined($opt{l})){
@peerarg = split(/\s+/, $opt{l});

if(($#peerarg + 1 > 0) ) {
$querytmp = " and ( filter.peer_name='";
	for($i=0; ($#peerarg + 1) > $i; $i++){
		if($i < $#peerarg){
			$querytmp = $querytmp.$peerarg[$i]."' or filter.peer_name='";	
		}else{
			$querytmp = $querytmp.$peerarg[$i]."')";
		}
	}
}
}

$query = "select filter.id, type.type, filter.peer_name, filter.aut_num, filter.as_set, filter.as_path_list_num, filter.nn, route.route_type
		 from bgp_p filter, bgp_type type, bgp_af af,bgp_hn_router router, bgp_route_type route
		 where filter.type_id=type.id and filter.af_id=af.id and filter.hn_router_id=router.id and filter.route_type_id=route.id";

$query = $query.$querytmp;

#print "$query\n";

$dbh = DBI->connect( "dbi:Pg:dbname=bgpf;host=127.0.0.1;port=5432",'bgpf', 'bgpf') or die $DBI::errstr;

		$sth=$dbh->prepare($query); 
		$sth->execute;
		#$arrayr = $sth->fetchall_arrayref();
		$hash_ref = $sth->fetchall_hashref('peer_name');
		
		foreach $hr (keys %$hash_ref){
			if(defined$opt{n}){ $hash_ref->{$hr}->{n} = 1; }
			if(defined$opt{R}){ $hash_ref->{$hr}->{R} = 0; }
			if(defined$opt{j}){ $j = 1; }
			if($hash_ref->{$hr}->{type} eq "Upstream"){
				if(!$j) {
				   UpstreamFilter::gen_filter_in($hash_ref, $hr);
				   if(!$opt{i}){
				     UpstreamFilter::gen_filter_out($hash_ref, $hr);
				   }
				} else {
				   UpstreamFilter::gen_filter_in_j($hash_ref, $hr);
				   if(!$opt{i}){
				     UpstreamFilter::gen_filter_out_j($hash_ref, $hr);
				   }
				}
			}elsif($hash_ref->{$hr}->{type} eq "Peer"){
				if(!$j) {
				  PeerFilter::gen_filter_in($hash_ref, $hr);
				  if(!$opt{i}){
					PeerFilter::gen_filter_out($hash_ref, $hr);
				  }
				} else {
				  PeerFilter::gen_filter_in_j($hash_ref, $hr);
				  if(!$opt{i}){
					PeerFilter::gen_filter_out_j($hash_ref, $hr);
				  }
				}
			}elsif($hash_ref->{$hr}->{type} eq "Customer"){
				if(!$j) {
				   CustomerFilter::gen_filter_in($hash_ref, $hr);
				   if(!$opt{i}){
					CustomerFilter::gen_filter_out($hash_ref, $hr);
				   }
				} else {
				   CustomerFilter::gen_filter_in_j($hash_ref, $hr);
				   if(!$opt{i}){
					CustomerFilter::gen_filter_out_j($hash_ref, $hr);
				   }
				}
			}
			print "!-------------$hash_ref->{$hr}->{'peer_name'}-----BEGIN-------------------\n";
			print "$hash_ref->{$hr}->{filter_in}\n";
			print "$hash_ref->{$hr}->{filter_out}\n" if !$opt{i};
			print "!-------------$hash_ref->{$hr}->{'peer_name'}------END--------------------\n";
		}


$sth->finish();
$dbh->disconnect;


sub usage {
print STDERR << "EOF";
This program does...
usage: $0 [-hin] [-l "list peer"]
     -h				: this (help) message
     -i				: generate only input filter
     -n 			: generate no condition
	 -R				: don't generate route-map
     -l "Peer0 [Peer1] ..."	: list peers
     -j 			: generate juniper filter, default cisco

example: $0 -i -l "SomePeer0 SomePeer1"

EOF
exit;
}
