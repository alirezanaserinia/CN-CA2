##################################################################
#	    Setting the Default Parameters			 #
##################################################################
set val(chan)		Channel/WirelessChannel	;	# channel type 	
set val(prop)		Propagation/TwoRayGround;	# radio-propagation model
set val(netif)		Phy/WirelessPhy			;	# network interface type
set val(mac)       	Mac/802_11				;	# MAC type
set val(ifq)		Queue/DropTail/PriQueue	;	# interface queue type
set val(ifqlen)		50						;	# max packet in ifq	
set val(ll)			LL						;	# link layer type
set val(ant)		Antenna/OmniAntenna 	;	# antenna model
set val(rp)    		AODV  					;	# Ad Hoc On-Demand Distance Vector routing protocol
set val(x)			800						;	# X dimension of topography
set val(y)			800						;	# Y dimension of topography
set val(nn)			9						;	# number of mobilenodes	
set val(stop)		102.0					;	# simulation time
     

##################################################################
#	    Creating New Instance of a Scheduler		 #
##################################################################

set ns_		[new Simulator]

##################################################################
#		Creating Trace files				 #
##################################################################

set tracefd	[open Main.tr w]
#$ns_ use-newtrace
$ns_ trace-all $tracefd

##################################################################
#	        Creating NAM Trace files			 #
##################################################################
#Nam File Creation nam – network animator
set namtrace [open Main.nam w]
$ns_ namtrace-all-wireless $namtrace $val(x) $val(y)

set prop	[new $val(prop)]

set topo	[new Topography]
$topo load_flatgrid $val(x) $val(y)

# general operational descriptor - storing the hop details in the network
create-god $val(nn)

##################################################################
#	                 802.11 Settings			 #
##################################################################

Phy/WirelessPhy set freq_ 	2.4e+9

Mac/802_11 set basicRate_ 	0
Mac/802_11 set dataRate_ 	0 

Mac/802_11 set bandwidth_ 	1.5Mb
#1.5   Mbps
#55.0  Mbps
#155.0 Mbps

Mac/802_11 set RTSThreshold_ 3000                  
        
##################################################################
#		Node Configuration				 #
##################################################################
proc UniformErr {} {
set err [new ErrorModel]
$err unit packet
$err set rate_ 0.00001
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
		-wiredRouting OFF \
		-agentTrace ON \
		-routerTrace ON \
		-macTrace OFF \
		-IncomingErrProc UniformErr


##################################################################
#		Creating Nodes					 #
##################################################################

for {set i 0} {$i < $val(nn) } {incr i} {
     set node_($i) [$ns_ node]

     $node_($i) random-motion 0	
}

# set labels on nodes
$node_(0) label "A" 
$node_(1) label "B" 
$node_(2) label "C" 
$node_(3) label "D" 
$node_(4) label "E" 
$node_(5) label "F" 
$node_(6) label "G" 
$node_(7) label "H" 
$node_(8) label "L"

# set color index
$ns_ color 0 blue
$ns_ color 1 red


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

	set tcp0 [new Agent/TCP]
	set tcp1 [new Agent/TCP]
	set sink0 [new Agent/TCPSink]
	set sink1 [new Agent/TCPSink]

	$ns_ attach-agent $node_(0) $tcp0
	$ns_ attach-agent $node_(3) $tcp1
	$ns_ attach-agent $node_(7) $sink0
	$ns_ attach-agent $node_(8) $sink1
	
	set ftp0 [new Application/FTP]
	$ftp0 attach-agent $tcp0
	set ftp1 [new Application/FTP]
	$ftp1 attach-agent $tcp1
	
	$ns_ connect $tcp0 $sink0
#	$ns_ connect $tcp0 $sink1
#	$ns_ connect $tcp1 $sink0
	$ns_ connect $tcp1 $sink1
	
	$ns_ at 5.0 "$ftp0 start" 
#	$ns_ at 7.5 "$ftp1 start"
#	$ns_ at 8.5 "$ftp1 stop"
	$ns_ at 12.5 "$ftp1 start"
	$ns_ at 100.0 "$ftp0 stop"	
	$ns_ at 96.0 "$ftp1 stop"

##################################################################
#		Simulation Termination				 #
##################################################################

#Define a 'finish' procedure
proc finish {} {
        global ns_ namtrace tracefd
        $ns_ flush-trace	
        close $namtrace		
        close $tracefd
        exit 0
}

for {set i 0} {$i < $val(nn) } {incr i} {
    $ns_ at $val(stop) "$node_($i) reset";
}
$ns_ at $val(stop) "puts \"NS EXITING...\" ; $ns_ halt"

puts "Starting Simulation..."

$ns_ at 100.0 "finish"

$ns_ run
