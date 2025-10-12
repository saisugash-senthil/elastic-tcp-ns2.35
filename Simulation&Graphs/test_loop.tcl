set ns [new Simulator]


#set tf [open test.tr w]
#$ns trace-all $tf
#set nf [open out.nam w]
#$ns namtrace-all $nf

# set cwnd_file_vegas(0) [open "cwnd_vegas0.txt" w]
# set cwnd_file_vegas(1) [open "cwnd_vegas1.txt" w]
# set cwnd_file_vegas(2) [open "cwnd_vegas2.txt" w]
# set cwnd_file_vegas(3) [open "cwnd_vegas3.txt" w]

# set cwnd_file_reno(0) [open "cwnd_reno0.txt" w]
# set cwnd_file_reno(1) [open "cwnd_reno1.txt" w]
# set cwnd_file_reno(2) [open "cwnd_reno2.txt" w]
# set cwnd_file_reno(3) [open "cwnd_reno3.txt" w]

# set cwnd_file_cubic(0) [open "cwnd_cubic0.txt" w]
# set cwnd_file_cubic(1) [open "cwnd_cubic1.txt" w]
# set cwnd_file_cubic(2) [open "cwnd_cubic2.txt" w]
# set cwnd_file_cubic(3) [open "cwnd_cubic3.txt" w]

set cwnd_file_elastic(0) [open "cwnd_elastic0.txt" w]
set cwnd_file_elastic(1) [open "cwnd_elastic1.txt" w]
set cwnd_file_elastic(2) [open "cwnd_elastic2.txt" w]
set cwnd_file_elastic(3) [open "cwnd_elastic3.txt" w]

# aggregate
# set cwnd_file_aggr_vegas [open "cwnd_vegas_aggr.txt" w]
# set cwnd_file_aggr_reno  [open "cwnd_reno_aggr.txt" w]
# set cwnd_file_aggr_cubic  [open "cwnd_cubic_aggr.txt" w]
set cwnd_file_aggr_elastic [open "cwnd_elastic_aggr.txt" w]

# Create nodes
for {set i 0} {$i < 16} {incr i} {
    set sender($i) [$ns node]
}
for {set i 0} {$i < 16} {incr i} {
    set recv($i) [$ns node]
}

set r1 [$ns node]
set r2 [$ns node]


#links
for {set i 0} {$i < 16} {incr i} {
    $ns duplex-link $sender($i) $r1 1000Mb 1ms DropTail
    $ns queue-limit $r1 $sender($i) 67000
    $ns queue-limit $sender($i) $r1 67000
}
for {set i 0} {$i < 16} {incr i} {
    $ns duplex-link $r2 $recv($i) 1000Mb 1ms DropTail
    $ns queue-limit $r2 $recv($i) 67000
    $ns queue-limit $recv($i) $r2 67000
    
}


$ns duplex-link $r1 $r2 1000Mb 100ms DropTail
$ns queue-limit $r1 $r2 3200
$ns queue-limit $r2 $r1 3200

set em1 [new ErrorModel]
$em1 set rate_ 1e-5 ;
$em1 unit pkt       ;
$em1 ranvar [new RandomVariable/Uniform]  ;
$em1 drop-target [new Agent/Null]  ;


$ns link-lossmodel $em1 $r1 $r2  ;


# Create TCP agents and sinks.
# We use arrays to store the agents and sinks.
# Grouping:
#   Group 0: Vegas    flows 0-3
#   Group 1: Reno     flows 4-7
#   Group 2: Cubic    flows 8-11
#   Group 3: Elastic  flows 12-15

for {set i 0} {$i < 16} {incr i} {
    set tcp($i) [new Agent/TCP/Linux]
    $ns attach-agent $sender($i) $tcp($i)
    set sink($i) [new Agent/TCPSink/Sack1]
    $ns attach-agent $recv($i) $sink($i)
    $ns connect $tcp($i) $sink($i)
}
# unrolled loop ;(

# Flow 1
$ns at 0 "$tcp(12) set packetSize_ 1000"
$ns at 0 "$tcp(12) set timestamps_ 1"
$ns at 0 "$tcp(12) set window_ 67000"
$ns at 0 "$tcp(12) set overhead_ 0.000008"
$ns at 0 "$tcp(12) set max_ssthresh_ 1000"
$ns at 0 "$tcp(12) set maxburst_ 2"
$ns at 0 "$tcp(12) set low_window 0"
$ns at 0 "$tcp(12) set ssthresh_ 1000" 
$ns at 0 "$tcp(12) set maxrto_ 120"
$ns at 0 "$tcp(12) set ts_resetRTO_ true"
$ns at 0 "$tcp(12) set delay_growth_ false"

$ns at 0 "$tcp(12) select_ca elastic"

# Flow 2
$ns at 0 "$tcp(13) set packetSize_ 1000"
$ns at 0 "$tcp(13) set timestamps_ 1"
$ns at 0 "$tcp(13) set window_ 67000"
$ns at 0 "$tcp(13) set overhead_ 0.000008"
$ns at 0 "$tcp(13) set max_ssthresh_ 1000"
$ns at 0 "$tcp(13) set maxburst_ 2"
$ns at 0 "$tcp(13) set low_window 0"
$ns at 0 "$tcp(13) set ssthresh_ 1000" 
$ns at 0 "$tcp(13) set maxrto_ 120"
$ns at 0 "$tcp(13) set ts_resetRTO_ true"
$ns at 0 "$tcp(13) set delay_growth_ false"

$ns at 0 "$tcp(13) select_ca elastic"

# Flow 3
$ns at 0 "$tcp(14) set packetSize_ 1000"
$ns at 0 "$tcp(14) set timestamps_ 1"
$ns at 0 "$tcp(14) set window_ 67000"
$ns at 0 "$tcp(14) set overhead_ 0.000008"
$ns at 0 "$tcp(14) set max_ssthresh_ 1000"
$ns at 0 "$tcp(14) set maxburst_ 2"
$ns at 0 "$tcp(14) set low_window 0"
$ns at 0 "$tcp(14) set ssthresh_ 1000" 
$ns at 0 "$tcp(14) set maxrto_ 120"
$ns at 0 "$tcp(14) set ts_resetRTO_ true"
$ns at 0 "$tcp(14) set delay_growth_ false"

$ns at 0 "$tcp(14) select_ca elastic"

# Flow 4
$ns at 0 "$tcp(15) set packetSize_ 1000"
$ns at 0 "$tcp(15) set timestamps_ 1"
$ns at 0 "$tcp(15) set window_ 67000"
$ns at 0 "$tcp(15) set overhead_ 0.000008"
$ns at 0 "$tcp(15) set max_ssthresh_ 1000"
$ns at 0 "$tcp(15) set maxburst_ 2"
$ns at 0 "$tcp(15) set low_window 0"
$ns at 0 "$tcp(15) set ssthresh_ 1000" 
$ns at 0 "$tcp(15) set maxrto_ 120"
$ns at 0 "$tcp(15) set ts_resetRTO_ true"
$ns at 0 "$tcp(15) set delay_growth_ false"

$ns at 0 "$tcp(15) select_ca elastic"

for {set i 0} {$i < 16} {incr i} {
    set ftp($i) [new Application/FTP]
    $ftp($i) attach-agent $tcp($i)
}

# ----------------------------
# Procedures to record cwnd values.
# ----------------------------


proc record_cwnd {out tcp} {
    global ns
    set now [$ns now]
    set cwnd [$tcp set cwnd_]
    puts $out "$now $cwnd"
    $ns at [expr $now+0.1] "record_cwnd $out $tcp"
}

proc record_aggr_cwnd {out tcp_list} {
    global ns
    set now [$ns now]
    set sum 0
    foreach tcp $tcp_list {
        set sum [expr $sum + [$tcp set cwnd_]]
    }
    puts $out "$now $sum"
    $ns at [expr $now+0.1] "record_aggr_cwnd $out {$tcp_list}"
}

# set vegas_list [list $tcp(0) $tcp(1) $tcp(2) $tcp(3)]
# set reno_list  [list $tcp(4) $tcp(5) $tcp(6) $tcp(7)]
# set cubic_list [list $tcp(8) $tcp(9) $tcp(10) $tcp(11)]
set elastic_list [list $tcp(12) $tcp(13) $tcp(14) $tcp(15)]

# Schedule individual cwnd recordings.
# For each connection, choose its corresponding output file.

# for {set i 0} {$i < 4} {incr i} {
#     $ns at 0.1 "record_cwnd \$cwnd_file_vegas($i) \$tcp($i)"
# }
# for {set i 4} {$i < 8} {incr i} {
#     set j [expr $i - 4]
#     $ns at 0.1 "record_cwnd \$cwnd_file_reno($j) \$tcp($i)"
# }
# for {set i 8} {$i < 12} {incr i} {
#     set j [expr $i - 8]
#     $ns at 0.1 "record_cwnd \$cwnd_file_cubic($j) \$tcp($i)"
# }
for {set i 12} {$i < 16} {incr i} {
    set j [expr $i - 12]
    $ns at 0.1 "record_cwnd \$cwnd_file_elastic($j) \$tcp($i)"
}

# Schedule aggregate cwnd recordings for each TCP type.
#$ns at 0.1 "record_aggr_cwnd \$cwnd_file_aggr_vegas {$tcp(0) $tcp(1) $tcp(2) $tcp(3)}"
#$ns at 0.1 "record_aggr_cwnd \$cwnd_file_aggr_reno  {$tcp(4) $tcp(5) $tcp(6) $tcp(7)}"
#$ns at 0.1 "record_aggr_cwnd \$cwnd_file_aggr_cubic  {$tcp(8) $tcp(9) $tcp(10) $tcp(11)}"
$ns at 0.1 "record_aggr_cwnd \$cwnd_file_aggr_elastic {$tcp(12) $tcp(13) $tcp(14) $tcp(15)}"

# ----------------------------
# Start the FTP flows.
#for {set i 0} {$i < 16} {incr i} {
#    $ns at 0 "$ftp($i) start"
#}

#$ns at 0 "$ftp(0) start"
#$ns at 0 "$ftp(4) start"
#$ns at 0 "$ftp(8) start"
$ns at 0 "$ftp(12) start"


#$ns at 5 "$ftp(1) start"
#$ns at 5 "$ftp(5) start"
#$ns at 5 "$ftp(9) start"
$ns at 5 "$ftp(13) start"

#$ns at 10 "$ftp(2) start"
#$ns at 10 "$ftp(6) start"
#$ns at 10 "$ftp(10) start"
$ns at 10 "$ftp(14) start"

#Agent/TCPSink/Sack1 set maxSackBlocks_ 1

#$ns at 15 "$ftp(3) start"
#$ns at 15 "$ftp(7) start"
#$ns at 15 "$ftp(11) start"
$ns at 15 "$ftp(15) start"



# Finish procedure
proc finish {} {
    global ns 
    #tf nf
    #global cwnd_file_vegas cwnd_file_reno cwnd_file_cubic 
    global cwnd_file_elastic
    #global cwnd_file_aggr_vegas cwnd_file_aggr_reno cwnd_file_aggr_cubic 
    global cwnd_file_aggr_elastic
    #$ns flush-trace
    #close $tf
    #close $nf
    # foreach file [array names cwnd_file_vegas] {
    #     close $cwnd_file_vegas($file)
    # }
    # foreach file [array names cwnd_file_reno] {
    #     close $cwnd_file_reno($file)
    # }
    # foreach file [array names cwnd_file_cubic] {
    #     close $cwnd_file_cubic($file)
    # }
    foreach file [array names cwnd_file_elastic] {
        close $cwnd_file_elastic($file)
    }
    # close $cwnd_file_aggr_vegas
    # close $cwnd_file_aggr_reno
    # close $cwnd_file_aggr_cubic
    close $cwnd_file_aggr_elastic
    exec gnuplot aggregate_graph.gp
    exec gnuplot elastic_graph.gp
    exit 0
}

$ns at 100.0 "finish"
$ns run

