package UpstreamFilter; 
require Exporter;

@ISA = qw(Exporter);
@EXPORT = qw(&gen_filter_in &gen_filter_out &gen_filter_in_j &gen_filter_out_j);

sub gen_filter_in {
my ($filter_in, $hash_ref, $hr);
my ($id, $type, $peer_name, $aut_num, $as_set, $as_path_list_num, $nn);
my ($as_filter, $as_filter_char, $as_set, $n_bgpq);
my ($prefix_list, $prefix_list_char, $filter_in0, $filter_in1, $no_prefix_list);

$hash_ref = shift;
$hr = shift;

$peer_name = $hash_ref->{$hr}->{peer_name};
$aut_num = $hash_ref->{$hr}->{aut_num};
$nn = $hash_ref->{$hr}->{nn};


$filter_in0 = "route-map Upstream-BGP-".$peer_name."-AS".$aut_num."-IN permit 10
 match ip address prefix-list Receiving.BGP-".$peer_name."-AS".$aut_num."
 set local-preference 40
 set comm-list CommunityFlush-AS3333.BGP-UpstreamPeer-IN delete
 set community 3333:101".$nn." additive\n\n";

$filter_in1 = "ip prefix-list Receiving.BGP-".$peer_name."-AS".$aut_num." deny	0.0.0.0/0 ge 32
ip prefix-list Receiving.BGP-".$peer_name."-AS".$aut_num." deny	127.0.0.0/8 le 32
ip prefix-list Receiving.BGP-".$peer_name."-AS".$aut_num." deny	10.0.0.0/8 le 32
ip prefix-list Receiving.BGP-".$peer_name."-AS".$aut_num." deny	172.16.0.0/12 le 32
ip prefix-list Receiving.BGP-".$peer_name."-AS".$aut_num." deny	192.168.0.0/16 le 32
ip prefix-list Receiving.BGP-".$peer_name."-AS".$aut_num." deny	192.0.2.0/24 le 32
ip prefix-list Receiving.BGP-".$peer_name."-AS".$aut_num." deny	128.0.0.0/16 le 32
ip prefix-list Receiving.BGP-".$peer_name."-AS".$aut_num." deny	191.255.0.0/16 le 32
ip prefix-list Receiving.BGP-".$peer_name."-AS".$aut_num." deny	192.0.0.0/24 le 32
ip prefix-list Receiving.BGP-".$peer_name."-AS".$aut_num." deny	223.255.255.0/24 le 32
ip prefix-list Receiving.BGP-".$peer_name."-AS".$aut_num." deny	224.0.0.0/3 le 32
ip prefix-list Receiving.BGP-".$peer_name."-AS".$aut_num." deny	169.254.0.0/16 le 32
ip prefix-list Receiving.BGP-".$peer_name."-AS".$aut_num." permit 0.0.0.0/0
ip prefix-list Receiving.BGP-".$peer_name."-AS".$aut_num." permit 0.0.0.0/0 le 24

!ip community-list expanded CommunityFlush-AS3333.BGP-UpstreamPeer-IN permit 3333:.....\n";


if(defined($hash_ref->{$hr}->{n})) {$no_prefix_list = "no ip prefix-list Receiving.BGP-".$peer_name."-AS".$aut_num."\n"; $filter_in1 = $no_prefix_list.$filter_in1;}

$filter_in = $filter_in0.$filter_in1;

if(defined($hash_ref->{$hr}->{R})){
	$filter_in = $filter_in1;
}else{
	$filter_in = $filter_in0.$filter_in1;
}

if(defined($hash_ref->{$hr}->{n}) && !defined($hash_ref->{$hr}->{R})) {$no_route_map = "no route-map Upstream-BGP-".$peer_name."-AS".$aut_num."-IN\n"; $filter_in = $no_route_map.$filter_in;}

$hash_ref->{$hr}->{filter_in} = $filter_in;

}

sub gen_filter_in_j {

my ($filter_in, $hash_ref, $hr);
my ($id, $type, $peer_name, $aut_num, $as_set, $as_path_list_num, $nn);
my ($as_filter, $as_filter_char, $as_set, $n_bgpq);
my ($prefix_list, $prefix_list_char, $filter_in0, $filter_in1, $no_prefix_list);

$hash_ref = shift;
$hr = shift;

$peer_name = $hash_ref->{$hr}->{peer_name};
$aut_num = $hash_ref->{$hr}->{aut_num};
$nn = $hash_ref->{$hr}->{nn};


$filter_in0 = "";

$filter_in1 = "
policy-options {
replace:
policy-statement Receiving.BGP-".$peer_name." {
 term Receiving.BGP-".$peer_name."-100 {
    from {
        route-filter 127.0.0.0/8 orlonger;
        route-filter 10.0.0.0/8 orlonger;
        route-filter 172.16.0.0/12 orlonger;
        route-filter 192.168.0.0/16 orlonger;
        route-filter 192.0.2.0/24 orlonger;
        route-filter 128.0.0.0/16 orlonger;
        route-filter 191.255.0.0/16 orlonger;
        route-filter 192.0.0.0/24 orlonger;
        route-filter 223.255.255.0/24 orlonger;
        route-filter 224.0.0.0/3 orlonger;
        route-filter 169.254.0.0/16 orlonger;
	route-filter 0.0.0.0/0 prefix-length-range /25-/32
    }
    then accept;
 }
 term Receiving.BGP-".$peer_name."-110 {
    then reject;
 }
}

community CommunitySet-AS3333.BGP-".$peer_name."-IN members 3333:101".$nn.";
community CommunityFlush-AS3333.BGP-UpstreamPeer-IN members 39775:.....;

policy-statement Upstream-BGP-".$peer_name."-AS".$aut_num."-IN {
 term BGP-".$peer_name."-IN-100 {
    from policy Receiving.BGP-".$peer_name.";
    then reject;
 }
 term BGP-".$peer_name."-IN-110 {
    then {
        local-preference 40;
        community delete CommunityFlush-AS3333.BGP-UpstreamPeer-IN;
        community add CommunitySet-AS3333.BGP-".$peer_name."-IN;
        accept;
    }
 }
 term BGP-".$peer_name."-IN-120 {
    then reject;
 }
}
}\n";



if(defined($hash_ref->{$hr}->{n})) {$no_prefix_list = "no ip prefix-list Receiving.BGP-".$peer_name."-AS".$aut_num."\n"; $filter_in1 = $no_prefix_list.$filter_in1;}

$filter_in = $filter_in0.$filter_in1;

if(defined($hash_ref->{$hr}->{R})){
	$filter_in = $filter_in1;
}else{
	$filter_in = $filter_in0.$filter_in1;
}

if(defined($hash_ref->{$hr}->{n}) && !defined($hash_ref->{$hr}->{R})) {$no_route_map = "no route-map Upstream-BGP-".$peer_name."-AS".$aut_num."-IN\n"; $filter_in = $no_route_map.$filter_in;}

$hash_ref->{$hr}->{filter_in} = $filter_in;

}

sub gen_filter_out {

my ($filter_out, $hash_ref, $hr);
my ($id, $type, $peer_name, $aut_num, $as_path_list_num, $nn);
my ($no_route_map, $filter_out0, $filter_out1, $filter_out2, $filter_out3, $filter_out4, $filter_out5);

$hash_ref = shift;
$hr = shift;

$peer_name = $hash_ref->{$hr}->{peer_name};
$aut_num = $hash_ref->{$hr}->{aut_num};
$nn = $hash_ref->{$hr}->{nn};

$filter_out0 =  "route-map Upstream-".$peer_name."-AS".$aut_num."-OUT deny 10
 match community Not.Advertisement.".$peer_name."-AS".$aut_num."
!
route-map Upstream-".$peer_name."-AS".$aut_num."-OUT permit 20
 match ip address prefix-list Advertise.BGP-".$peer_name."-AS".$aut_num."
 match community Advertisement.prepend.1.".$peer_name."-AS".$aut_num."
 set comm-list CommunityFlush-AS3333.BGP-UpstreamPeer-OUT delete
 set as-path prepend 3333
!
route-map Upstream-".$peer_name."-AS".$aut_num."-OUT permit 30
 match ip address prefix-list Advertise.BGP-".$peer_name."-AS".$aut_num."
 match community Advertisement.prepend.2.".$peer_name."-AS".$aut_num."
 set comm-list CommunityFlush-AS3333.BGP-UpstreamPeer-OUT delete
 set as-path prepend 3333 3333
!
route-map Upstream-".$peer_name."-AS".$aut_num."-OUT permit 40
 match ip address prefix-list Advertise.BGP-".$peer_name."-AS".$aut_num."
 match community Advertisement.prepend.3.".$peer_name."-AS".$aut_num."
 set comm-list CommunityFlush-AS3333.BGP-UpstreamPeer-OUT delete
 set as-path prepend 3333 3333 3333
!
route-map Upstream-".$peer_name."-AS".$aut_num."-OUT permit 50
 match ip address prefix-list Advertise.BGP-".$peer_name."-AS".$aut_num."
 set comm-list CommunityFlush-AS3333.BGP-UpstreamPeer-OUT delete\n\n";

$filter_out1 = "ip prefix-list Advertise.BGP-".$peer_name."-AS".$aut_num." deny    0.0.0.0/0 ge 32
ip prefix-list Advertise.BGP-".$peer_name."-AS".$aut_num." deny    127.0.0.0/8 le 32
ip prefix-list Advertise.BGP-".$peer_name."-AS".$aut_num." deny    10.0.0.0/8 le 32
ip prefix-list Advertise.BGP-".$peer_name."-AS".$aut_num." deny    172.16.0.0/12 le 32
ip prefix-list Advertise.BGP-".$peer_name."-AS".$aut_num." deny    192.168.0.0/16 le 32
ip prefix-list Advertise.BGP-".$peer_name."-AS".$aut_num." deny    192.0.2.0/24 le 32
ip prefix-list Advertise.BGP-".$peer_name."-AS".$aut_num." deny    128.0.0.0/16 le 32
ip prefix-list Advertise.BGP-".$peer_name."-AS".$aut_num." deny    191.255.0.0/16 le 32
ip prefix-list Advertise.BGP-".$peer_name."-AS".$aut_num." deny    192.0.0.0/24 le 32
ip prefix-list Advertise.BGP-".$peer_name."-AS".$aut_num." deny    223.255.255.0/24 le 32
ip prefix-list Advertise.BGP-".$peer_name."-AS".$aut_num." deny    224.0.0.0/3 le 32
ip prefix-list Advertise.BGP-".$peer_name."-AS".$aut_num." deny    169.254.0.0/16 le 32
ip prefix-list Advertise.BGP-".$peer_name."-AS".$aut_num." permit  xx.xx.xx.xx/20
ip prefix-list Advertise.BGP-".$peer_name."-AS".$aut_num." permit  xx.xx.xx.xx/19
ip prefix-list Advertise.BGP-".$peer_name."-AS".$aut_num." deny    xx.xx.xx.xx/20 le 32
ip prefix-list Advertise.BGP-".$peer_name."-AS".$aut_num." deny    xx.xx.xx.xx/19 le 32
ip prefix-list Advertise.BGP-".$peer_name."-AS".$aut_num." permit 0.0.0.0/0 le 24\n\n";


$filter_out2 = "ip community-list expanded Not.Advertisement.BGP-".$peer_name." permit 3333:10[124]..
ip community-list expanded Not.Advertisement.BGP-".$peer_name." permit 3333:31".$nn."0
ip community-list expanded Not.Advertisement.BGP-".$peer_name." permit 3333:31990\n\n";

$filter_out3 = "ip community-list standard Advertisement.prepend.1.BGP-".$peer_name." permit 3333:31".$nn."1
ip community-list standard Advertisement.prepend.1.BGP-".$peer_name." permit 3333:31991\n\n";

$filter_out4 = "ip community-list standard Advertisement.prepend.2.BGP-".$peer_name." permit 3333:31".$nn."2
ip community-list standard Advertisement.prepend.2.BGP-".$peer_name." permit 3333:31992\n\n";

$filter_out5 = "ip community-list standard Advertisement.prepend.3.BGP-".$peer_name." permit 3333:31".$nn."3
ip community-list standard Advertisement.prepend.3.BGP-".$peer_name." permit 3333:31993
!ip community-list expanded CommunityFlush-AS3333.BGP-UpstreamPeer-OUT permit 3333:.....\n";

if(defined($hash_ref->{$hr}->{n})){ 
	$filter_out1 = "no ip prefix-list Advertise.BGP-".$peer_name."-AS".$aut_num."\n".$filter_out1;
	$filter_out2 = "no ip community-list expanded Not.Advertisement.BGP-".$peer_name."\n".$filter_out2;
	$filter_out3 = "no ip community-list standard Advertisement.prepend.1.BGP-".$peer_name."\n".$filter_out3;
	$filter_out4 = "no ip community-list standard Advertisement.prepend.2.BGP-".$peer_name."\n".$filter_out4;
	$filter_out5 = "no ip community-list standard Advertisement.prepend.3.BGP-".$peer_name."\n".$filter_out5;
}
	$filter_out = $filter_out0.$filter_out1.$filter_out2.$filter_out3.$filter_out4.$filter_out5;
	if(defined($hash_ref->{$hr}->{R})){
		$filter_out = $filter_out1.$filter_out2.$filter_out3.$filter_out4.$filter_out5;
	}
	if(defined($hash_ref->{$hr}->{n}) && !defined($hash_ref->{$hr}->{R})) {$no_route_map = "no route-map Peer-BGP-".$peer_name."-AS".$aut_num."-OUT\n"; $filter_out = $no_route_map.$filter_out;}


$hash_ref->{$hr}->{filter_out} = $filter_out;

}

sub gen_filter_out_j {

my ($filter_out, $hash_ref, $hr);
my ($id, $type, $peer_name, $aut_num, $as_path_list_num, $nn);
my ($no_route_map, $filter_out0, $filter_out1, $filter_out2, $filter_out3, $filter_out4, $filter_out5);

$hash_ref = shift;
$hr = shift;

$peer_name = $hash_ref->{$hr}->{peer_name};
$aut_num = $hash_ref->{$hr}->{aut_num};
$nn = $hash_ref->{$hr}->{nn};

$filter_out0 =  "";

$filter_out1 = "";


$filter_out2 = "";

$filter_out3 = "";

$filter_out4 = "";

$filter_out5 = "
policy-options {
replace:
community Advertisement.1.BGP-".$peer_name." members [ \"3333:31".$nn."1|3333:31991\" 3333:10340 ];
community Advertisement.2.BGP-".$peer_name." members [ \"3333:31".$nn."2|3333:31992\" 3333:10340 ];
community Advertisement.3.BGP-".$peer_name." members [ \"3333:31".$nn."3|3333:31993\" 3333:10340 ];
community Advertisement.prepend.1.BGP-".$peer_name." members 3333:31".$nn."1;
community Advertisement.prepend.2.BGP-".$peer_name." members \"3333:31".$nn."2|3333:31992\";
community Advertisement.prepend.3.BGP-".$peer_name." members \"3333:31".$nn."3|3333:31993\";
community CommunitySet-AS3333.BGP-".$peer_name."-IN members 3333:101".$nn.";
community Not.Advertisement.BGP-".$peer_name." members \"3333:10[124]..|3333:31".$nn."0|3333:31990\";
community CommunityMatch-AS3333.BGP-Customer-OUT members 3333:10340;


policy-statement Upstream-BGP-".$peer_name."-AS".$aut_num."-OUT {
term BGP-".$peer_name."-OUT-90 {
    from {
        protocol aggregate;
        prefix-list Customer-BGP-OUT;
    }
    then accept;
}
term BGP-".$peer_name."-OUT-100 {
    from community Not.Advertisement.BGP-".$peer_name.";
    then reject;
}
term BGP-".$peer_name."-OUT-110 {
    from community Advertisement.1.BGP-".$peer_name.";
    then {
        as-path-prepend 3333;
        accept;
    }
}
term BGP-".$peer_name."-OUT-120 {
    from community Advertisement.2.BGP-".$peer_name.";
    then {
        as-path-prepend \"3333 3333\";
        accept;
    }
}
term BGP-".$peer_name."-OUT-130 {
    from community Advertisement.3.BGP-".$peer_name.";
    then {
        as-path-prepend \"3333 3333 3333\";
        accept;
    }
}
term BGP-".$peer_name."-OUT-140 {
    from community CommunityMatch-AS3333.BGP-Customer-OUT;
    then accept;
}
term BGP-".$peer_name."-OUT-150 {
    then reject;
}
}}\n";

$filter_out = $filter_out5;

$hash_ref->{$hr}->{filter_out} = $filter_out;

}

1;
