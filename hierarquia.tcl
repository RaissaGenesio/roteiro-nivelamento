set fp [open "netlist.v" r]

set modulos {}

array set hierarquia {}

array set instancias {}

while {[gets $fp linha] >= 0} {
    if {[regexp {module\s+(\w+)} $linha -> nome]} {
        lappend modulos $nome
        set hierarquia($nome) {}
    }
}

seek $fp 0

set modulo_pai ""

while {[gets $fp linha] >= 0} {

    if {[regexp {module\s+(\w+)} $linha -> nome]} {
        set modulo_pai $nome
        continue
    }

    if {[regexp {endmodule} $linha]} {
        set modulo_pai ""
        continue
    }

    if {$modulo_pai ne ""} {

        foreach sub $modulos {

            if {$sub ne $modulo_pai} {

                if {[regexp "^\\s*$sub\\s+\\w+" $linha]} {

                    if {[lsearch $hierarquia($modulo_pai) $sub] == -1} {
                        lappend hierarquia($modulo_pai) $sub
                    }

                    if {![info exists instancias($modulo_pai,$sub)]} {
                        set instancias($modulo_pai,$sub) 0
                    }

                    incr instancias($modulo_pai,$sub)
                }
            }
        }
    }
}

close $fp

puts "=== HIERARQUIA DO DESIGN ==="

foreach mod $modulos {

    puts "\n$mod"

    set filhos $hierarquia($mod)

    if {[llength $filhos] == 0} {

        puts "└── (módulo primitivo – sem submódulos)"

    } else {

        set total [llength $filhos]
        set i 0

        foreach sub $filhos {

            incr i

            if {$i < $total} {
                set prefix "├──"
            } else {
                set prefix "└──"
            }

            puts "$prefix $sub ($instancias($mod,$sub) instâncias)"
        }

        if {$mod eq "somador_4bits"} {
            puts "└── (apenas células primitivas)"
        }

        if {$mod eq "contador_4bits"} {
            puts "└── (células primitivas)"
        }
    }
}

