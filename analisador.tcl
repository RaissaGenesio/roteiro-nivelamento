set fp [open "netlist.v" r]
set count_and 0
set count_xor 0
set count_ff  0

while {[gets $fp line] >= 0} {
    if {[regexp {AND2} $line]} { incr count_and }
    if {[regexp {XOR2} $line]} { incr count_xor }
    if {[regexp {flipflop_D} $line]} { incr count_ff }
}
close $fp

set total [expr $count_and + $count_xor + $count_ff]

puts "--- RELATÓRIO DE CÉLULAS ---"
puts "AND2: $count_and instâncias"
puts "XOR2: $count_xor instâncias"
puts "flipflop_D: $count_ff instâncias"
puts "----------------------------"
puts "TOTAL: $total instâncias"
