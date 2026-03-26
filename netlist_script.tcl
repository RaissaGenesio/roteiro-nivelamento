set and2 0
set xor2 0
set flipflop 0

set file [open "netlist.v" r]

while {[gets $file line] >= 0} {

    if {[string match "*AND2*" $line]} {
        incr and2
    }

    if {[string match "*XOR2*" $line]} {
        incr xor2
    }

    if {[string match "*flipflop_D*" $line]} {
        incr flipflop
    }
}

close $file

set total [expr $and2 + $xor2 + $flipflop]

puts "=== RELATÓRIO DE CÉLULAS ==="
puts "AND2: $and2 instâncias"
puts "XOR2: $xor2 instâncias"
puts "flipflop_D: $flipflop instâncias"
puts "TOTAL: $total instâncias"
