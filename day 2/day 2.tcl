set in_f [open "day 2.txt" "r"]
set in_s [read $in_f]

set parsed_template [regexp -all -inline {[0-9]+} $in_s]

for {set i 0} {$i < 100} {incr i} {
    for {set j 0} {$j < 100} {incr j} {
        set curr_index 0
        set parsed $parsed_template
        lset {parsed} 1 $i
        lset {parsed} 2 $j
        while {[lindex $parsed $curr_index] != 99} {
            if {[lindex $parsed $curr_index] == 1} {
                set result [expr { [lindex $parsed [lindex $parsed [expr {($curr_index + 1)}]]] + [lindex $parsed [lindex $parsed [expr {($curr_index + 2)}]]] }]
            }
            if {[lindex $parsed $curr_index] == 2} {
                set result [expr { [lindex $parsed [lindex $parsed [expr {($curr_index + 1)}]]] * [lindex $parsed [lindex $parsed [expr {($curr_index + 2)}]]] }]
            }
                lset {parsed} [lindex $parsed [expr {$curr_index + 3}]] $result
                set curr_index [expr {$curr_index + 4}]
        }
        if {[lindex $parsed 0] == 19690720} {
            puts [expr {100 * $i + $j}]
            close $in_f
            exit
        }
    }
}
puts "ERROR"
close $in_f