package CustomerFilter; 
require Exporter;

@ISA = qw(Exporter);
@EXPORT = qw(&gen_filter_in &gen_filter_out &gen_filter_in_j &gen_filter_out_j);

sub gen_filter_in {

my ($filter_in, $hash_ref, $hr);
my ($id, $type, $peer_name, $aut_num, $as_set, $as_path_list_num, $nn);
my ($as_filter, $as_filter_char, $as_set, $n_bgpq);
my ($prefix_list, $prefix_list_char, $filter_in0, $filter_in1, $input_inner_filter);

$hash_ref = shift;
$hr = shift;

$peer_name = $hash_ref->{$hr}->{peer_name};
$aut_num = $hash_ref->{$hr}->{aut_num};
$aut_set = $hash_ref->{$hr}->{aut_set};
$as_path_list_num = $hash_ref->{$hr}->{as_path_list_num};
$as_set = $hash_ref->{$hr}->{as_set};
$nn = $hash_ref->{$hr}->{nn};

if(defined($as_set)){
	$as = $as_set;
}else{
	$as = "AS".$aut_num;
}

$n_bgpq = '-H';
if(defined($hash_ref->{$hr}->{n})){ $n_bgpq = ''; }

open(BGPQ, "bgpq ".$n_bgpq." -l".$as_path_list_num." -f ".$aut_num."  ".$as."|") or die "Error open bgpq\n";
while($as_filter_char = <BGPQ>){$as_filter .= $as_filter_char}
close(BGPQ);

open(BGPQ, "bgpq  ".$n_bgpq." -R 24 -qAPlReceiving.BGP-".$peer_name."-AS".$aut_num." ".$as."|") or die "Error open bgpq\n";
while($prefix_list_char = <BGPQ>){$prefix_list .= $prefix_list_char}
close(BGPQ);

$filter_in0 = "route-map Customer-BGP-".$peer_name."-AS".$aut_num."-IN permit 10
 match ip address prefix-list Receiving.BGP-".$peer_name."-AS".$aut_num."
 match as-path ".$as_path_list_num."
 match community LocalPref.10
 set local-preference 10
 set comm-list CommunityFlush-AS3333.BGP-Customer-IN delete
 set community 3333:10340 additive
!
route-map Customer-BGP-".$peer_name."-AS".$aut_num."-IN permit 20
 match ip address prefix-list Receiving.BGP-".$peer_name."-AS".$aut_num."
 match as-path ".$as_path_list_num."
 match community LocalPref.50
 set local-preference 50
 set comm-list CommunityFlush-AS3333.BGP-Customer-IN delete
 set community 3333:10340 additive
!
route-map Customer-BGP-".$peer_name."-AS".$aut_num."-IN permit 30
 match ip address prefix-list Receiving.BGP-".$peer_name."-AS".$aut_num."
 match as-path ".$as_path_list_num."
 match community LocalPref.90
 set local-preference 90
 set comm-list CommunityFlush-AS3333.BGP-Customer-IN delete
 set community 3333:10340 additive
!
route-map Customer-BGP-".$peer_name."-AS".$aut_num."-IN permit 40
 match ip address prefix-list Receiving.BGP-".$peer_name."-AS".$aut_num."
 match as-path ".$as_path_list_num."
 match community LocalPref.100
 set local-preference 100
 set comm-list CommunityFlush-AS3333.BGP-Customer-IN delete
 set community 3333:10340 additive
!
route-map Customer-BGP-".$peer_name."-AS".$aut_num."-IN permit 50
 match ip address prefix-list Receiving.BGP-".$peer_name."-AS".$aut_num."
 match as-path ".$as_path_list_num."
 set local-preference 110
 set comm-list CommunityFlush-AS3333.BGP-Customer-IN delete
 set community 3333:10340 additive\n\n";

$filter_in1 = $prefix_list."\n".$as_filter."\n

!ip community-list expanded CommunityFlush-AS3333.BGP-Customer-IN permit 3333:[014-9]....

!ip community-list standard LocalPref.10 permit 3333:20010
!ip community-list standard LocalPref.50 permit 3333:20050
!ip community-list standard LocalPref.90 permit 3333:20090
!ip community-list standard LocalPref.100 permit 3333:20100
!ip community-list standard LocalPref.110 permit 3333:20110\n";

$filter_in = $filter_in0.$filter_in1;
if(defined($hash_ref->{$hr}->{R})){
	$filter_in = $filter_in1;
}else{
	$filter_in = $filter_in0.$filter_in1;
}

if(defined($hash_ref->{$hr}->{n}) && !defined($hash_ref->{$hr}->{R})) {$no_route_map = "no route-map Customer-BGP-".$peer_name."-AS".$aut_num."-IN\n"; $filter_in = $no_route_map.$filter_in;}

$hash_ref->{$hr}->{filter_in} = $filter_in;

}

sub gen_filter_out {

my ($filter_out, $filter_out_head, $filter_out_head1, $filter_out_head2, $hash_ref, $hr);
my ($id, $type, $peer_name, $aut_num, $as_path_list_num, $nn, $filter_out0, $filter_out1);

$hash_ref = shift;
$hr = shift;

$peer_name = $hash_ref->{$hr}->{peer_name};
$aut_num = $hash_ref->{$hr}->{aut_num};
$nn = $hash_ref->{$hr}->{nn};

$filter_out_head1 = "route-map Customer-BGP-FR-OUT permit 10
 match ip address prefix-list Advertise.BGP-Customer-FR
 set comm-list CommunityFlush-AS3333.BGP-Customer-OUT delete";

$filter_out_head2 = "route-map Customer-BGP-CR_DFR-OUT permit 10
 match ip address prefix-list Advertise.BGP-Customer-DFR

route-map Customer-BGP-CR_DFR-OUT deny 20
 match community Not.Advertisement.BGP-UpstreamPeer-OUT

route-map Customer-BGP-CR_DFR-OUT permit 30
 match ip address prefix-list Advertise.BGP-Customer-FR
 set comm-list CommunityFlush-AS3333.BGP-Customer-OUT delete";

if($hash_ref->{$hr}->{route_type} eq "FR"){
	$filter_out_head = $filter_out_head1;
}elsif($hash_ref->{$hr}->{route_type} eq "DFR"){
	$filter_out_head = $filter_out_head2;
}

$filter_out0 = "

!ip prefix-list Advertise.BGP-Customer-DFR permit  0.0.0.0/0

!ip prefix-list Advertise.BGP-Customer-FR deny    0.0.0.0/0 ge 32
!ip prefix-list Advertise.BGP-Customer-FR deny    127.0.0.0/8 le 32
!ip prefix-list Advertise.BGP-Customer-FR deny    10.0.0.0/8 le 32
!ip prefix-list Advertise.BGP-Customer-FR deny    172.16.0.0/12 le 32
!ip prefix-list Advertise.BGP-Customer-FR deny    192.168.0.0/16 le 32
!ip prefix-list Advertise.BGP-Customer-FR deny    192.0.2.0/24 le 32
!ip prefix-list Advertise.BGP-Customer-FR deny    128.0.0.0/16 le 32
!ip prefix-list Advertise.BGP-Customer-FR deny    191.255.0.0/16 le 32
!ip prefix-list Advertise.BGP-Customer-FR deny    192.0.0.0/24 le 32
!ip prefix-list Advertise.BGP-Customer-FR deny    223.255.255.0/24 le 32
!ip prefix-list Advertise.BGP-Customer-FR deny    224.0.0.0/3 le 32
!ip prefix-list Advertise.BGP-Customer-FR deny    169.254.0.0/16 le 32
!ip prefix-list Advertise.BGP-Customer-FR permit  81.90.208.0/20
!ip prefix-list Advertise.BGP-Customer-FR permit  62.192.32.0/19
!ip prefix-list Advertise.BGP-Customer-FR deny    81.90.208.0/20 le 32
!ip prefix-list Advertise.BGP-Customer-FR deny    62.192.32.0/19 le 32
!ip prefix-list Advertise.BGP-Customer-FR permit  0.0.0.0/0
!ip prefix-list Advertise.BGP-Customer-FR permit  0.0.0.0/0 le 24

!ip community-list expanded CommunityFlush-AS3333.BGP-Customer-OUT permit 3333:[23]....
!ip community-list expanded Not.Advertisement.BGP-UpstreamPeer-OUT permit 3333:10[124]..\n";

if(defined($hash_ref->{$hr}->{R})){
	$filter_out = $filter_out0;
}else{
	$filter_out = $filter_out_head.$filter_out0; 
}

if(defined($hash_ref->{$hr}->{n}) && !defined($hash_ref->{$hr}->{R})){
	$no_route_map = "no route-map Peer-BGP-".$peer_name."-AS".$aut_num."-OUT\n"; 
	$filter_out = $no_route_map.$filter_out;
}

$hash_ref->{$hr}->{filter_out} = $filter_out;

}

sub gen_filter_in_j {
my ($filter_in, $hash_ref, $hr);
my ($id, $type, $peer_name, $aut_num, $as_set, $as_path_list_num, $nn);
my ($as_filter, $as_filter_char, $as_set, $n_bgpq);
my ($prefix_list, $prefix_list_char, $filter_in0, $filter_in1);

$hash_ref = shift;
$hr = shift;

$peer_name = $hash_ref->{$hr}->{peer_name};
$aut_num = $hash_ref->{$hr}->{aut_num};
$aut_set = $hash_ref->{$hr}->{aut_set};
$as_path_list_num = $hash_ref->{$hr}->{as_path_list_num};
$as_set = $hash_ref->{$hr}->{as_set};
$nn = $hash_ref->{$hr}->{nn};

if(defined($as_set)){
	$as = $as_set;
}else{
	$as = "AS".$aut_num;
}

#$n_bgpq = '-H';
$n_bgpq = '';
if(defined($hash_ref->{$hr}->{n})){ $n_bgpq = ''; }

#-JE -R24

open(BGPQ, "bgpq -j ".$n_bgpq." -l".$as_path_list_num." -f ".$aut_num."  ".$as."|") or die "Error open bgpq\n";
while($as_filter_char = <BGPQ>){$as_filter .= $as_filter_char}
close(BGPQ);

open(BGPQ, "bgpq3 -JEA -R24  ".$n_bgpq." -lReceiving.BGP-".$peer_name."-AS".$aut_num." ".$as."| grep route-filter |") or die "Error open bgpq\n";
while($prefix_list_char = <BGPQ>){$prefix_list .= $prefix_list_char}

close(BGPQ);

$filter_in0 = "policy-statement Customer-BGP-".$peer_name."-AS".$aut_num."-IN {
     term Customer-BGP-".$peer_name."-AS".$aut_num."-IN-100 {
         from {
 	     as-path-group ".$as_path_list_num.";
 	     community LocalPref.10;
 	     policy Receiving.BGP-".$peer_name."-AS".$aut_num.";
         }
         then {
	     local-preference 10;
	     community delete CommunityFlush-AS3333.BGP-Customer-IN;
	     community set CommunitySet-AS3333.BGP-Customer-IN;
	     accept;
	}
     }
     term Customer-BGP-".$peer_name."-AS".$aut_num."-IN-110 {
         from {
 	     as-path-group ".$as_path_list_num.";
 	     community LocalPref.50;
 	     policy Receiving.BGP-".$peer_name."-AS".$aut_num.";
         }
         then {
	     local-preference 50;
	     community delete CommunityFlush-AS3333.BGP-Customer-IN;
	     community set CommunitySet-AS3333.BGP-Customer-IN;
	     accept;
	}
     }
     term Customer-BGP-".$peer_name."-AS".$aut_num."-IN-120 {
         from {
 	     as-path-group ".$as_path_list_num.";
 	     community LocalPref.90;
 	     policy Receiving.BGP-".$peer_name."-AS".$aut_num.";
         }
         then {
	     local-preference 90;
	     community delete CommunityFlush-AS3333.BGP-Customer-IN;
	     community set CommunitySet-AS3333.BGP-Customer-IN;
	     accept;
	}
     }
     term Customer-BGP-".$peer_name."-AS".$aut_num."-IN-130 {
         from {
 	     as-path-group ".$as_path_list_num.";
 	     community LocalPref.100;
 	     policy Receiving.BGP-".$peer_name."-AS".$aut_num.";
         }
         then {
	     local-preference 100;
	     community delete CommunityFlush-AS3333.BGP-Customer-IN;
	     community set CommunitySet-AS3333.BGP-Customer-IN;
	     accept;
	}
     }
     term Customer-BGP-".$peer_name."-AS".$aut_num."-IN-140 {
         from {
 	     as-path-group ".$as_path_list_num.";
 	     community LocalPref.110;
 	     policy Receiving.BGP-".$peer_name."-AS".$aut_num.";
         }
         then {
	     local-preference 110;
	     community delete CommunityFlush-AS3333.BGP-Customer-IN;
	     community set CommunitySet-AS3333.BGP-Customer-IN;
	     accept;
	}
     }
     term Customer-BGP-".$peer_name."-AS".$aut_num."-IN-140 {
	 then reject;
     }
}

 \n\n";

$input_inner_filter=" policy-statement Receiving.BGP-".$peer_name."-AS".$aut_num." {
	term  Receiving.BGP-".$peer_name."-AS".$aut_num."-100 {
	    from {
		".$prefix_list."
	    }
	    then accept;
	   }
	term Receiving.BGP-".$peer_name."-AS".$aut_num."-110 {
	    then reject;
      }
 }";

#$filter_in1 = $prefix_list."\n".$as_filter."\n".$input_inner_filter."
$filter_in1 = $as_filter."\n".$input_inner_filter."


!set policy-options community CommunityFlush-AS3333.BGP-Customer-IN members \"3333:[014-9]....\"
!set policy-options community CommunitySet-AS3333.BGP-Customer-IN members 3333:10340

!set policy-options community LocalPref.10 members 3333:20010
!set policy-options community LocalPref.100 members 3333:20100
!set policy-options community LocalPref.110 members 3333:20110
!set policy-options community LocalPref.50 members 3333:20050
!set policy-options community LocalPref.90 members 3333:20090\n";


$filter_in = $filter_in0.$filter_in1;
if(defined($hash_ref->{$hr}->{R})){
	$filter_in = $filter_in1;
}else{
	$filter_in = $filter_in0.$filter_in1;
}

if(defined($hash_ref->{$hr}->{n}) && !defined($hash_ref->{$hr}->{R})) {$no_route_map = "no route-map Customer-BGP-".$peer_name."-AS".$aut_num."-IN\n"; $filter_in = $no_route_map.$filter_in;}
 $hash_ref->{$hr}->{filter_in} = $filter_in;
 #$hash_ref->{$hr}->{filter_in} = "Stub";
}

sub gen_filter_out_j {
my ($filter_out, $filter_out_head, $filter_out_head1, $filter_out_head2, $hash_ref, $hr);
my ($id, $type, $peer_name, $aut_num, $as_path_list_num, $nn, $filter_out0, $filter_out1);

$hash_ref = shift;
$hr = shift;

$peer_name = $hash_ref->{$hr}->{peer_name};
$aut_num = $hash_ref->{$hr}->{aut_num};
$nn = $hash_ref->{$hr}->{nn};

#$hash_ref->{$hr}->{filter_out} = $filter_out;
$hash_ref->{$hr}->{filter_out} = "Stub";

}

1;
