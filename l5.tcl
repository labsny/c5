set ns [new Simulator -multicast on]
set tf [open l5.tr w]
$ns trace-all $tf
set fd [open l5.nam w]
$ns namtrace-all $fd

set n0 [$ns node]
set n1 [$ns node]
set n2 [$ns node]
set n3 [$ns node]
set n4 [$ns node]
set n5 [$ns node]
set n6 [$ns node]
set n7 [$ns node]

$ns duplex-link $n0 $n2 1.5Mb 10ms DropTail
$ns duplex-link $n1 $n2 1.5Mb 10ms DropTail
$ns duplex-link $n2 $n3 1.5Mb 10ms DropTail
$ns duplex-link $n3 $n4 1.5Mb 10ms DropTail
$ns duplex-link $n3 $n7 1.5Mb 10ms DropTail
$ns duplex-link $n4 $n5 1.5Mb 10ms DropTail
$ns duplex-link $n4 $n6 1.5Mb 10ms DropTail

set mproto DM
set mrthandle [$ns mrtproto $mproto {} ]

set group1 [Node allocaddr]
set group2 [Node allocaddr]

set udp0 [new Agent/UDP]
$ns attach-agent $n0 $udp0
$udp0 set dst_addr_ $group1
$udp0 set dst_port_ 0
set cbr1 [new Application/Traffic/CBR]
$cbr1 attach-agent $udp0

set udp1 [new Agent/UDP]
$ns attach-agent $n1 $udp1
$udp1 set dst_addr_ $group2
$udp1 set dst_port_ 0
set cbr2 [new Application/Traffic/CBR]
$cbr2 attach-agent $udp1

set rc1 [new Agent/Null]
$ns attach-agent $n5 $rc1
$ns at 1.0 "$n5 join-group $rc1 $group1"

set rc2 [new Agent/Null]
$ns attach-agent $n6 $rc2
$ns at 1.5 "$n6 join-group $rc2 $group1"

set rc3 [new Agent/Null]
$ns attach-agent $n7 $rc3
$ns at 2.0 "$n7 join-group $rc3 $group1"

set rc4 [new Agent/Null]
$ns attach-agent $n2 $rc4
$ns at 2.5 "$n2 join-group $rc4 $group2"

set rc5 [new Agent/Null]
$ns attach-agent $n3 $rc5
$ns at 3.0 "$n3 join-group $rc5 $group2"

set rc6 [new Agent/Null]
$ns attach-agent $n4 $rc6
$ns at 3.5 "$n4 join-group $rc6 $group2"

$ns at 4.0 "$n5 leave-group $rc1 $group1"
$ns at 4.5 "$n6 leave-group $rc2 $group1"
$ns at 5.0 "$n7 leave-group $rc3 $group1"
$ns at 5.5 "$n2 leave-group $rc4 $group2"
$ns at 6.0 "$n3 leave-group $rc5 $group2"
$ns at 6.5 "$n4 leave-group $rc6 $group2"

$ns at 0.5 "$cbr1 start"
$ns at 9.5 "$cbr1 stop"

$ns at 0.5 "$cbr2 start"
$ns at 9.5 "$cbr2 stop"

proc finish {} {
global ns tf fd
$ns flush-trace 
close $tf 
close $fd
exec nam l5.nam &
exit0
}

$udp0 set fid_ 1
$n0 color red
$n0 label "source 1"

$udp1 set fid_ 2
$n1 color green
$n1 label "source 2"

$n5 label "receiver 1"
$n5 color blue
$n6 label "receiver 2"
$n6 color blue
$n7 label "receiver 3"
$n7 color blue
$n2 label "receiver 4"
$n2 color orange
$n3 label "receiver 5"
$n3 color orange
$n4 label "receiver 6"
$n4 color orange

$ns at 10.0 "finish"
$ns run
