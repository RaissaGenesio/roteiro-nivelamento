set fp [open "netlist.v" r]

array set fanout {}
set wires {}


while {[gets $fp linha] >= 0} {

    if {[regexp {wire\s+([^;]+);} $linha -> lista]} {
        foreach w [split $lista ","] {
            lappend wires [string trim $w]
        }
    }

    set conexoes [regexp -all -inline {\.(?:a|b|D|clk|rst)\(([^)]+)\)} $linha]

    foreach {match net} $conexoes {
        if {[info exists fanout($net)]} {
            incr fanout($net)
        } else {
            set fanout($net) 1
        }
    }
}

close $fp

set lista_ordenada {}

foreach net [array names fanout] {
    lappend lista_ordenada [list $net $fanout($net)]
}

set lista_ordenada [lsort -integer -decreasing -index 1 $lista_ordenada]

puts "=== TOP 10 NETS POR FANOUT ==="

set i 0
foreach item $lista_ordenada {
    if {$i >= 10} break
    puts "[lindex $item 0]: fanout = [lindex $item 1]"
    incr i
}

puts ""
puts "--- NETS COM FANOUT ZERO (POSSÍVEIS ERROS) ---"

foreach w $wires {
    if {![info exists fanout($w)]} {
        puts $w
    }
}

