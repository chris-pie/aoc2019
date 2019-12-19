
class IOSimulator {
    has @.inputs;
    has @.outputs;
    method get-input {
        @.inputs.pop;
    };
    method put-output($output) {
        @.inputs.push($output);
    };
}


sub get-mode(@modes, int $modenum)
{
    if $modenum > @modes.elems {
        return 0;
    }
    return Int(@modes[@modes.elems - $modenum]);
}
sub get-value-by-mode(%memory, @modes, int $modenum, int $value, int $pospointer)
{
    given get-mode(@modes, $modenum) {
        when 0
            {return %memory{$value}}
        when 1
            {return $value}
        when 2
            {return %memory{$value + $pospointer}}
    }
}
sub set-value-by-mode(%memory, @modes, int $modenum, int $value, int $pospointer, $to_write)
{

    given get-mode(@modes, $modenum) {
        when 0
            {%memory{$value} = $to_write}
        when 2
            {%memory{$value + $pospointer} = $to_write}
    }
}


sub run-program(%memory, IOSimulator $ios) {
    my Int $pospointer = 0;
    my Int $ipointer = 0;
    loop (;%memory{$ipointer} != 99;) {
        my $instruction = %memory{$ipointer} % 100;
        my @modes = Str(%memory{$ipointer} div 100).split("",:skip-empty);
        given $instruction {
            when 1 {
                my $arg1 = get-value-by-mode(%memory, @modes, 1, %memory{$ipointer+1}, $pospointer);
                my $arg2 = get-value-by-mode(%memory, @modes, 2, %memory{$ipointer+2}, $pospointer);
                my $result = $arg1 + $arg2;
                set-value-by-mode(%memory, @modes, 3, %memory{$ipointer+3}, $pospointer, $result);
                $ipointer += 4;
            }
            when 2 {
                my $arg1 = get-value-by-mode(%memory, @modes, 1, %memory{$ipointer+1}, $pospointer);
                my $arg2 = get-value-by-mode(%memory, @modes, 2, %memory{$ipointer+2}, $pospointer);
                my $result = $arg1 * $arg2;
                set-value-by-mode(%memory, @modes, 3, %memory{$ipointer+3}, $pospointer, $result);
                $ipointer += 4;
            }
            when 3 {
                my $result = $ios.get-input;
                set-value-by-mode(%memory, @modes, 1, %memory{$ipointer+1}, $pospointer, $result);
                $ipointer += 2;
            }
            when 4 {
                $ios.put-output(get-value-by-mode(%memory, @modes, 1, %memory{$ipointer+1}, $pospointer));
                $ipointer += 2;
            };
            when 5 {
                my $arg1 = get-value-by-mode(%memory, @modes, 1, %memory{$ipointer+1}, $pospointer);
                my $arg2 = get-value-by-mode(%memory, @modes, 2, %memory{$ipointer+2}, $pospointer);
                if $arg1 != 0 {
                    $ipointer = $arg2
                } else {
                    $ipointer += 3
                }
            }
             when 6 {
                my $arg1 = get-value-by-mode(%memory, @modes, 1, %memory{$ipointer+1}, $pospointer);
                my $arg2 = get-value-by-mode(%memory, @modes, 2, %memory{$ipointer+2}, $pospointer);
                if $arg1 == 0 {
                    $ipointer = $arg2
                } else {
                    $ipointer += 3
                }
            }
             when 7 {
                my $arg1 = get-value-by-mode(%memory, @modes, 1, %memory{$ipointer+1}, $pospointer);
                my $arg2 = get-value-by-mode(%memory, @modes, 2, %memory{$ipointer+2}, $pospointer);
                my $result = 0;
                if $arg1 < $arg2 {
                    $result = 1
                }
                set-value-by-mode(%memory, @modes, 3, %memory{$ipointer+3}, $pospointer, $result);
                $ipointer += 4;
            }
             when 8 {
                my $arg1 = get-value-by-mode(%memory, @modes, 1, %memory{$ipointer+1}, $pospointer);
                my $arg2 = get-value-by-mode(%memory, @modes, 2, %memory{$ipointer+2}, $pospointer);
                my $result = 0;
                if $arg1 == $arg2 {
                    $result = 1
                }
                set-value-by-mode(%memory, @modes, 3, %memory{$ipointer+3}, $pospointer, $result);
                $ipointer += 4;
            }
            when 9 {
                my $arg1 = get-value-by-mode(%memory, @modes, 1, %memory{$ipointer+1}, $pospointer);
                $pospointer += $arg1;
                $ipointer += 2;
            }
            default {say "ERROR"}
        }
    }
}

my $inFile = slurp "day 9.txt";
my @splitInput = split(",",$inFile);
my Int %memory is default(Int(0));
my Int $i = 0;
for @splitInput -> $item {
    %memory.push($i => Int($item));
    $i++;
}
my $ios = IOSimulator.new(inputs => [2], outputs => []);
run-program(%memory, $ios);
say $ios.inputs