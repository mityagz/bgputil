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
use lib "/home/bgpf/bgputil/bgpf/Mod";
use DBI;
use Getopt::Std;
use vars qw/ %opt /;
$Getopt::Std::STANDARD_HELP_VERSION = 1;
our $VERSION = 0.1;

# for netconf
use Carp;
use Getopt::Std;
use Term::ReadKey;
use Net::Netconf::Manager;

# query execution status constants
use constant REPORT_SUCCESS => 1;
use constant REPORT_FAILURE => 0;
use constant STATE_CONNECTED => 1;
use constant STATE_LOCKED => 2;
use constant STATE_CONFIG_LOADED => 3;
 
#

use UpstreamFilter;
use PeerFilter;
use CustomerFilter;

my ($row, $arrayr, @row,  @arrayr, $hash_ref, $hr, %hash_ref);
my ($id, $type, $peer_name, $aut_num, $as_set, $as_path_list_num, $nn);
my ($arg, $query, $querytmp, $i);
my ($dbh, $sth);
my (%opt, $peerarg, @peerarg, $j);


my $opt_string = 'sinRjl:h:';
getopts( "$opt_string", \%opt ) or usage();
usage() if (keys %opt) == 0;


sub graceful_shutdown {
   my ($jnx, $state, $success) = @_;
   if ($state >= STATE_CONFIG_LOADED) {
       # We have already done an <edit-config> operation
       # - Discard the changes
       print "Discarding the changes made ...\n";
       $jnx->discard_changes();
       if ($jnx->has_error) {
           print "Unable to discard <edit-config> changes\n";
       }
   }

   if ($state >= STATE_LOCKED) {
       # Unlock the configuration database
       $jnx->unlock_config();
       if ($jnx->has_error) {
           print "Unable to unlock the candidate configuration\n";
       }
   }

   if ($state >= STATE_CONNECTED) {
       # Disconnect from the Netconf server
       $jnx->disconnect();
   }

   if ($success) {
       print "REQUEST succeeded !!\n";
   } else {
       print "REQUEST failed !!\n";
   }

   exit;
}

sub get_error_info {
    my %error = @_;

    print "\nERROR: Printing the server request error ...\n";

    # Print 'error-severity' if present
    if ($error{'error_severity'}) {
        print "ERROR SEVERITY: $error{'error_severity'}\n";
    }
    # Print 'error-message' if present
    if ($error{'error_message'}) {
        print "ERROR MESSAGE: $error{'error_message'}\n";
    }

    # Print 'bad-element' if present
    if ($error{'bad_element'}) {
        print "BAD ELEMENT: $error{'bad_element'}\n\n";
    }
}

my $login = "cisco";
my $password = "ciscocisco123";
my $hostname;
my $access = "ssh";

my (@host);
if(defined($opt{h})) {
 @host = split(/\s+/, $opt{h});
 $hostname =  $host[0];
} else {
 usage();
}

my %deviceinfo = ( 
        'access' => $access,
        'login' => $login,
        'password' => $password,
        'hostname' => $hostname,
);


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

			if(defined($opt{s})){
			 print "!-------------$hash_ref->{$hr}->{'peer_name'}-----BEGIN-------------------\n";
			 print "$hash_ref->{$hr}->{filter_in}\n";
			 print "$hash_ref->{$hr}->{filter_out}\n" if !$opt{i};
			 print "!-------------$hash_ref->{$hr}->{'peer_name'}------END--------------------\n";
                         exit;
                        }

			my $res; # Netconf server response

			# connect to the Netconf server
			my $jnx = new Net::Netconf::Manager(%deviceinfo);
			unless (ref $jnx) {
    				croak "ERROR: $deviceinfo{hostname}: failed to connect.\n";
			}

			# Lock the configuration database before making any changes
			print "Locking configuration database for host $hostname ...\n";
			my %queryargs = ( 'target' => 'candidate' );
			$res = $jnx->lock_config(%queryargs);
			
			if ($jnx->has_error) {
			    print "ERROR: in processing request \n $jnx->{'request'} \n";
    			    graceful_shutdown($jnx, STATE_CONNECTED, REPORT_FAILURE);
			}

			my $config = $hash_ref->{$hr}->{filter_in};
			$queryargs{'config-text'} = '<configuration-text>' . $config. '</configuration-text>';

			$res = $jnx->edit_config(%queryargs);

			# See if you got an error
			if ($jnx->has_error) {
    				print "ERROR: in processing request \n $jnx->{'request'} \n";
    				# Get the error
    				my $error = $jnx->get_first_error();
    				get_error_info(%$error);
    				# Disconnect
    				graceful_shutdown($jnx, STATE_LOCKED, REPORT_FAILURE);
			}

			# Commit the changes
			print "Committing the <edit-config> changes ...\n";
			$jnx->commit();
			if ($jnx->has_error) {
    				print "ERROR: Failed to commit the configuration.\n";
    				graceful_shutdown($jnx, STATE_CONFIG_LOADED, REPORT_FAILURE);
			}
		}


$sth->finish();
$dbh->disconnect;


sub usage {
print STDERR << "EOF";
This program does...
usage: $0 [-hin] [-l "list peer"]
     --help			: this (help) message
     --version			: version show
     -h				: host
     -s 			: show generate filter, and exit
     -i				: generate only input filter
     -n 			: generate no condition
     -R				: don't generate route-map
     -l "Peer0 [Peer1] ..."	: list peers
     -j 			: generate juniper filter, default cisco

example: $0 -i -l "SomePeer0 SomePeer1"

EOF
exit;
}

sub HELP_MESSAGE {
 usage();
}
