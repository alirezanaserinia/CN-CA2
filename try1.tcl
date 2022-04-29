##################################################################
#		Setting RED Parameters				 #
##################################################################

Queue/RED set thresh_ 5
Queue/RED set maxthresh_ 15
Queue/RED set q_weight_ 0.001
Queue/RED set bytes_ false
Queue/RED set queue_in_bytes_ false
Queue/RED set gentle_ false
Queue/RED set mean_pktsize_ 1000
Queue/RED set setbit_ true
Queue/RED set old_ecn_ true
#Queue/RED set use_mark_p_ true

##################################################################
#	    Setting the Default Parameters			 #
##################################################################

set val(chan)		Channel/WirelessChannel
set val(prop)		Propagation/TwoRayGround
set val(netif)		Phy/WirelessPhy
set val(mac)            Mac/802_11

set val(ifq)		Queue/DropTail/PriQueue
#set val(ifq)		Queue/RED
#set val(ifq) 		CMUPriQueue; 
# Wired Interface queue type DropTail, RED, CBQ, FQ, SFQ, DRR, diffserv RED queues
# Wireless Interface queue type Queue/DropTail/PriQueue, CMUPriQueue

set val(ll)		LL
set val(ant)            Antenna/OmniAntenna
set val(x)		800	
set val(y)		800	
set val(ifqlen)		50		
set val(nn)		9		
set val(stop)		102.0		
set val(rp)             AODV       

##################################################################
#	    Creating New Instance of a Scheduler		 #
##################################################################

set ns_		[new Simulator]

##################################################################
#		Creating Trace files				 #
##################################################################

set tracefd	[open try1.tr w]
$ns_ trace-all $tracefd

##################################################################
#	        Creating NAM Trace files			 #
##################################################################

set namtrace [open try1.nam w]
$ns_ namtrace-all-wireless $namtrace $val(x) $val(y)

set prop	[new $val(prop)]

set topo	[new Topography]
$topo load_flatgrid $val(x) $val(y)

create-god $val(nn)

##################################################################
#	                 802.11b Settings			 #
##################################################################

#Phy/WirelessPhy set freq_ 2.4e+9
#Mac/802_11 set dataRate_ 11.0e6 

##################################################################
#	                 802.11g Settings			 #
##################################################################

Phy/WirelessPhy set freq_ 2.4e+9


Mac/802_11 set dataRate_ 54.0e6 
#54Mbps

Mac/802_11 set basicRate_ 6e6
Mac/802_11 set RTSThreshold_ 3000                  
        
##################################################################
#		Node Configuration				 #
##################################################################
proc UniformErr {} {
set err [new ErrorModel]
$err unit packet
$err set rate_ 0.000001
$err ranvar [new RandomVariable/Uniform]
$err drop-target [new Agent/Null]
return $err
}

$ns_ node-config -adhocRouting $val(rp) \
		-llType $val(ll) \
		-macType $val(mac) \
		-ifqType $val(ifq) \
		-ifqLen $val(ifqlen) \
		-antType $val(ant) \
		-propType $val(prop) \
		-phyType $val(netif) \
		-channelType $val(chan) \
		-topoInstance $topo \
		-agentTrace ON \
		-routerTrace ON \
		-macTrace ON \
		-IncomingErrProc UniformErr


##################################################################
#		Creating Nodes					 #
##################################################################

for {set i 0} {$i < $val(nn) } {incr i} {
     set node_($i) [$ns_ node]

     $node_($i) random-motion 0	
}

# set labels on nodes

$node_(0) label "A" ;
$node_(1) label "B" ;
$node_(2) label "C" ;
$node_(3) label "D" ;
$node_(4) label "E" ;
$node_(5) label "F" ;
$node_(6) label "G" ;
$node_(7) label "H" ;
$node_(8) label "L" ;

# set color index
$ns_ color 0 blue
$ns_ color 1 red
$ns_ color 2 green
$ns_ color 3 chocolate
$ns_ color 4 brown
$ns_ color 5 tan
$ns_ color 6 gold
$ns_ color 7 black
$ns_ color 8 pink


##################################################################
#		Initial Positions of Nodes			 #
##################################################################

for {set i 0} {$i < $val(nn)} {incr i} {
	$ns_ initial_node_pos $node_($i) 100

}

##################################################################
#		Topology Design				 	 #
##################################################################

#A
$ns_ at 0.2 "$node_(0) setdest 100.0 460.0 155.0"  
#B
$ns_ at 0.2 "$node_(1) setdest 10.0 235.0 130.0"
#C
$ns_ at 0.2 "$node_(2) setdest 250.0 347.0 140.0"
#D
$ns_ at 0.2 "$node_(3) setdest 100.0 10.0 130.0"
#E
$ns_ at 0.2 "$node_(4) setdest 250.0 122.0 100.0"
#F
$ns_ at 0.2 "$node_(5) setdest 500.0 122.0 165.0"
#G
$ns_ at 0.2 "$node_(6) setdest 500.0 347.0 190.0"
#H
$ns_ at 0.2 "$node_(7) setdest 750.0 347.0 255.0"  
#L
$ns_ at 0.2 "$node_(8) setdest 750.0 122.0 240.0"  

##################################################################
#		Generating Traffic				 #
##################################################################

#		set tcp0 [new Agent/TCP]
#		set sink0 [new Agent/TCPSink]
#		$ns_ attach-agent $node_(0) $tcp0
#		$ns_ attach-agent $node_(8) $sink0
#		$ns_ connect $tcp0 $sink0

#		set ftp0 [new Application/FTP]
#		$ftp0 attach-agent $tcp0
#		$ns_ at 5.0 "$ftp0 start" 
#		$ns_ at 15.0 "$ftp0 stop"


set sink0 [new Agent/LossMonitor]
set sink1 [new Agent/LossMonitor]
$ns_ attach-agent $node_(7) $sink0
$ns_ attach-agent $node_(8) $sink1
set tcp0 [new Agent/TCP]
$ns_ attach-agent $node_(0) $tcp0
set tcp1 [new Agent/TCP]
$ns_ attach-agent $node_(3) $tcp1

proc attach-CBR-traffic { node sink size interval } {
#Get an instance of the simulator
set ns [Simulator instance]
#Create a CBR agent and attach it to the node
set cbr [new Agent/CBR]
$ns attach-agent $node $cbr
$cbr set packetSize_ $size
$cbr set interval_ $interval
#Attach CBR source to sink;
$ns connect $cbr $sink
return $cbr
}

#src bitrate: 500*8/0.015=26.666 Kbps
set cbr0 [attach-CBR-traffic $node_(0) $sink0 500 .015]
set cbr1 [attach-CBR-traffic $node_(0) $sink1 500 .015]
set cbr2 [attach-CBR-traffic $node_(1) $sink0 500 .015]
set cbr3 [attach-CBR-traffic $node_(1) $sink1 500 .015]

$ns_ at 5.0 "$cbr0 start"
$ns_ at 5.3 "$cbr1 start"
$ns_ at 5.6 "$cbr2 start"
$ns_ at 5.9 "$cbr3 start"

$ns_ at 12.0 "$cbr0 stop"
$ns_ at 12.2 "$cbr1 stop"
$ns_ at 12.4 "$cbr2 stop"
$ns_ at 12.7 "$cbr3 stop"

#$ns_ at 15.0 "finish"


$ns_ node-config -ifqType Queue/RED

#	set tcp6 [new Agent/TCP]
#	set sink6 [new Agent/TCPSink]
#	$ns_ attach-agent $node_(6) $tcp6
#	$ns_ attach-agent $node_(5) $sink6
#	$ns_ connect $tcp6 $sink6
#	set ftp6 [new Application/FTP]
#	$ftp6 attach-agent $tcp6
#	$ns_ at 100.0 "$ftp6 produce 3" 

##################################################################
#		Simulation Termination				 #
##################################################################


#Define a 'finish' procedure
proc finish {} {
        global ns nf f
        $ns flush-trace	
        close $nf		
        close $f
        exit 0
}

for {set i 0} {$i < $val(nn) } {incr i} {
    $ns_ at $val(stop) "$node_($i) reset";
}
$ns_ at $val(stop) "puts \"NS EXITING...\" ; $ns_ halt"

puts "Starting Simulation..."

#$ns_ at 15.0 finish

$ns_ run
