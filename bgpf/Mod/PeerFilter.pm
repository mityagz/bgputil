package PeerFilter; 
require Exporter;

@ISA = qw(Exporter);
@EXPORT = qw(&gen_filter_in &gen_filter_out);
#@EXPORT = qw();

sub gen_filter_in {
my ($filter_in, $hash_ref, $hr, $filter_in0, $filter_in1);
my ($id, $type, $peer_name, $aut_num, $as_set, $as_path_list_num, $nn);
my ($as_filter, $as_filter_char, $as_set, $n_bgpq);
my ($prefix_list, $prefix_list_char, $no_route_map);

$hash_ref = shift;
$hr = shift; 

$peer_name = $hash_ref->{$hr}->{peer_name};
$aut_num = $hash_ref->{$hr}->{aut_num};
$aut_set = $hash_ref->{$hr}->{aut_set};
$as_path_list_num = $hash_ref->{$hr}->{as_path_list_num};
$as_set = $hash_ref->{$hr}->{as_set};
$nn = $hash_ref->{$hr}->{nn};


#ip prefix-list Receiving.BGP-NamePeer-ASnum (auto-generate: bgpq -qAPlReceiving.BGP-NamePeer-ASnum  ASnum)
#ip as-path access-list 2NN      (auto-generate: bgpq -l2NN -f ASnum  ASMacro)

#ip as-path access-list ".$as_path_list_num." ".$as_filter."
#ip prefix-list Receiving.BGP-NamePeer-ASnum".$nn."

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



$filter_in0 = "route-map Peer-BGP-".$peer_name."-AS".$aut_num."-IN permit 10
 match ip address prefix-list Receiving.BGP-".$peer_name."-AS".$aut_num."
 match as-path ".$as_path_list_num."
 set local-preference 80
 set comm-list CommunityFlush-AS3333.BGP-UpstreamPeer-IN delete
 set community 3333:102".$nn." additive\n\n";

$filter_in1 = $prefix_list."\n".$as_filter."\n
!ip community-list expanded CommunityFlush-AS3333.BGP-UpstreamPeer-IN permit 3333:.....\n\n";

$filter_in = $filter_in0.$filter_in1;
if(defined($hash_ref->{$hr}->{R})){
	$filter_in = $filter_in1;
}else{
	$filter_in = $filter_in0.$filter_in1;
}

if(defined($hash_ref->{$hr}->{n}) && !defined($hash_ref->{$hr}->{R})) {$no_route_map = "no route-map Peer-BGP-".$peer_name."-AS".$aut_num."-IN\n"; $filter_in = $no_route_map.$filter_in;}

$hash_ref->{$hr}->{filter_in} = $filter_in;

}

sub gen_filter_out {

my ($filter_out, $hash_ref, $hr);
my ($id, $type, $peer_name, $aut_num, $as_path_list_num, $nn, $n_bgpq);
my ($no_route_map, $filter_out0, $filter_out1, $filter_out2, $filter_out3, $filter_out4, $filter_out5);

$hash_ref = shift;
$hr = shift;

$peer_name = $hash_ref->{$hr}->{peer_name};
$aut_num = $hash_ref->{$hr}->{aut_num};
$nn = $hash_ref->{$hr}->{nn};


$filter_out0 = "route-map Peer-BGP-".$peer_name."-AS".$aut_num."-OUT deny 10
 match community Not.Advertisement.BGP-".$peer_name."-AS".$aut_num."
!
route-map Peer-BGP-".$peer_name."-AS".$aut_num."-OUT permit 20
 match ip address prefix-list Advertise.BGP-".$peer_name."-AS".$aut_num."
 match community Advertisement.prepend.1.BGP-".$peer_name."-AS".$aut_num."
 set comm-list CommunityFlush-AS3333.BGP-UpstreamPeer-OUT delete
 set as-path prepend 3333
!
route-map Peer-BGP-".$peer_name."-AS".$aut_num."-OUT permit 30
 match ip address prefix-list Advertise.BGP-".$peer_name."-AS".$aut_num."
 match community Advertisement.prepend.2.BGP-".$peer_name."-AS".$aut_num."
 set comm-list CommunityFlush-AS3333.BGP-UpstreamPeer-OUT delete
 set as-path prepend 3333 3333
!
route-map Peer-BGP-".$peer_name."-AS".$aut_num."-OUT permit 40
 match ip address prefix-list Advertise.BGP-".$peer_name."-AS".$aut_num."
 match community Advertisement.prepend.3.BGP-".$peer_name."-AS".$aut_num."
 set comm-list CommunityFlush-AS3333.BGP-UpstreamPeer-OUT delete
 set as-path prepend 3333 3333 3333
!
route-map Peer-BGP-".$peer_name."-AS".$aut_num."-OUT permit 50
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
ip prefix-list Advertise.BGP-".$peer_name."-AS".$aut_num." permit  xx.xx.xx.0/20
ip prefix-list Advertise.BGP-".$peer_name."-AS".$aut_num." permit  xx.xx.xx.0/19
ip prefix-list Advertise.BGP-".$peer_name."-AS".$aut_num." deny    xx.xx.xx.0/20 le 32
ip prefix-list Advertise.BGP-".$peer_name."-AS".$aut_num." deny    xx.xx.xx.0/19 le 32
ip prefix-list Advertise.BGP-".$peer_name."-AS".$aut_num." permit  0.0.0.0/0 le 24\n\n";


$filter_out2 = "ip community-list expanded Not.Advertisement.BGP-".$peer_name."-AS".$aut_num." permit 3333:10[12]..
ip community-list expanded Not.Advertisement.BGP-".$peer_name."-AS".$aut_num." permit 3333:32".$nn."0
ip community-list expanded Not.Advertisement.BGP-".$peer_name."-AS".$aut_num." permit 3333:32990\n\n";

$filter_out3 = "ip community-list standard Advertisement.prepend.1.BGP-".$peer_name."-AS".$aut_num." permit 3333:32".$nn."1
ip community-list standard Advertisement.prepend.1.BGP-".$peer_name."-AS".$aut_num." permit 3333:32991\n\n";

$filter_out4 = "ip community-list standard Advertisement.prepend.2.BGP-".$peer_name."-AS".$aut_num." permit 3333:32".$nn."2
ip community-list standard Advertisement.prepend.2.BGP-".$peer_name."-AS".$aut_num." permit 3333:32992\n\n";

$filter_out5 = "ip community-list standard Advertisement.prepend.3.BGP-".$peer_name."-AS".$aut_num." permit 3333:32".$nn."3
ip community-list standard Advertisement.prepend.3.BGP-".$peer_name."-AS".$aut_num." permit 3333:32993

!ip community-list expanded CommunityFlush-AS3333.BGP-UpstreamPeer-OUT permit 3333:.....\n\n";

if(defined($hash_ref->{$hr}->{n})){ 
	$filter_out1 = "no ip prefix-list Advertise.BGP-".$peer_name."-AS".$aut_num."\n".$filter_out1;
	$filter_out2 = "no ip community-list expanded Not.Advertisement.BGP-".$peer_name."\n".$filter_out2;
	$filter_out3 = "no ip community-list standard Advertisement.prepend.1.BGP-".$peer_name."-AS".$aut_num."\n".$filter_out3;
	$filter_out4 = "no ip community-list standard Advertisement.prepend.2.BGP-".$peer_name."-AS".$aut_num."\n".$filter_out4;
	$filter_out5 = "no ip community-list standard Advertisement.prepend.3.BGP-".$peer_name."-AS".$aut_num."\n".$filter_out5;
}

	$filter_out = $filter_out0.$filter_out1.$filter_out2.$filter_out3.$filter_out4.$filter_out5;

if(defined($hash_ref->{$hr}->{R})){
	$filter_out = $filter_out1.$filter_out2.$filter_out3.$filter_out4.$filter_out5;
}

if(defined($hash_ref->{$hr}->{n}) && !defined($hash_ref->{$hr}->{R})) {$no_route_map = "no route-map Peer-BGP-".$peer_name."-AS".$aut_num."-OUT\n"; $filter_out = $no_route_map.$filter_out;}
	$hash_ref->{$hr}->{filter_out} = $filter_out;
}

1;
