require "facets/tuple"
class Intcode
    def initialize(memory)
        split_string = memory.split(',')
        i = 0
        @memory = Hash.new(0)
        for val in split_string do
            @memory[i] = val.to_i()
            i += 1
        end
        @ipointer = 0
        @relpointer = 0
    end
    def get_mode(modes, modenum)
        if modenum > modes.length 
            return 0
        else 
            return modes[modes.length - modenum].to_i
        end
    end

    def get_value_by_mode(modes, modenum)
        mode = get_mode(modes, modenum)
        if mode == 0
            return @memory[@memory[@ipointer + modenum]]
        elsif mode == 1
            return @memory[@ipointer + modenum]
        elsif mode == 2
            return @memory[@memory[@ipointer + modenum] + @relpointer]
        else 
            raise "Read mode not allowed: " + mode
        end
    end
    def set_value_by_mode(modes, modenum, to_write)
        mode = get_mode(modes, modenum)
        if mode == 0
            @memory[@memory[@ipointer + modenum]] = to_write
        elsif mode == 2
            @memory[@memory[@ipointer + modenum] + @relpointer] = to_write
        else
            raise "Write mode not allowed: " + mode
        end
    end
    def get_arguments(num_args, modes)
        args = Array.new(num_args)
        for i in 0..num_args-1
            args[i] = get_value_by_mode(modes, i+1)
        end
        return args
    end
    def run_program(inputs)
        while @memory[@ipointer] != 99
            instruction = @memory[@ipointer] % 100
            modes = (@memory[@ipointer] / 100).to_s
            if instruction == 1
                args = get_arguments(2, modes)
                set_value_by_mode(modes, 3, args[0] + args[1])
                @ipointer += 4
            elsif instruction == 2
                args = get_arguments(2, modes)
                set_value_by_mode(modes, 3, args[0] * args[1])
                @ipointer += 4
            elsif instruction == 3
                set_value_by_mode(modes, 1, inputs.shift)
                @ipointer += 2
            elsif instruction == 4
                arg = get_arguments(1, modes)
                @ipointer += 2
                return false, arg
            elsif instruction == 5
                args = get_arguments(2, modes)
                if args[0] != 0
                    @ipointer = args[1]
                else
                    @ipointer += 3
                end
            elsif instruction == 6
                args = get_arguments(2, modes)
                if args[0] == 0
                    @ipointer = args[1]
                else
                    @ipointer += 3
                end
            elsif instruction == 7
                args = get_arguments(2, modes)
                result = args[0] < args[1] ? 1 : 0
                set_value_by_mode(modes, 3, result)
                @ipointer += 4
            elsif instruction == 8
                args = get_arguments(2, modes)
                result = args[0] == args[1] ? 1 : 0
                set_value_by_mode(modes, 3, result)
                @ipointer += 4
            elsif instruction == 9
                args = get_arguments(1, modes)
                @relpointer += args[0]
                @ipointer += 2
            else
                raise "Instruction not allowed: " + instruction
            end
        end
        return true, []
    end
end


input_stirng = File.read("day 11.txt")
program = Intcode.new(input_stirng)
done = false
field = Hash.new(-1)
pos = Tuple[0,0]
direction = Tuple[0,1]
begin
    color_in = field[pos] == -1 ? 0 : field[pos]
    done, color  = program.run_program([color_in])
    if not done
        done, rotation = program.run_program([])
        field[pos] = color[0]
        direction = rotation[0] == 0 ? Tuple[(-direction[1]), direction[0]] : Tuple[direction[1], (-direction[0])]
        pos = Tuple[pos[0] + direction[0], pos[1] + direction[1]]
    end
end until done

puts field.length
program2 = Intcode.new(input_stirng)
done = false
field = Hash.new(-1)
pos = Tuple[0,0]
field[pos] = 1
direction = Tuple[0,1]
begin
    color_in = field[pos] == -1 ? 0 : field[pos]
    done, color  = program2.run_program([color_in])
    if not done
        done, rotation = program2.run_program([])
        field[pos] = color[0]
        direction = rotation[0] == 0 ? Tuple[(-direction[1]), direction[0]] : Tuple[direction[1], (-direction[0])]
        pos = Tuple[pos[0] + direction[0], pos[1] + direction[1]]
    end
end until done
field_keys = field.keys.select do |i| 
    field[i] == 1
end
keys_x = field_keys.collect do |i|
    i[0]
end
keys_y = field_keys.collect do |i|
    -i[1]
end
shifted_keys = field_keys.collect do |i|
    Tuple[i[0] - keys_x.min, -(i[1] - keys_y.min)]
end
output_matrix = Array.new(keys_y.max - keys_y.min + 1) do
    Array.new(keys_x.max - keys_x.min + 1) do " " end
end
for z in shifted_keys
    i = z[0]
    j = z[1]
    output_matrix[j][i] = "█"
end
for i in output_matrix
    for j in i
        print j
    end
    puts ""
end

