package main

import (
	"fmt"
	"io/ioutil"
	"sort"
	"strconv"
	"strings"
)

// Not a true permutations generator but close enough

func get_permutations(base []int) [][]int {
	base_sort := make([]int, len(base))
	copy(base_sort, base)
	sort.Ints(base_sort)
	tmp := make([]int, len(base))
	copy(tmp, base_sort)
	result := [][]int{tmp}
	for {
		i, j, k := len(base_sort)-1, len(base_sort)-1, len(base_sort)-1
		for (i > 0) && (base_sort[i-1] >= base_sort[i]) {
			i--
		}
		if i <= 0 {
			break
		}
		for base_sort[j] <= base_sort[i-1] {
			j--
		}
		base_sort[i-1], base_sort[j] = base_sort[j], base_sort[i-1]
		for i < k {
			base_sort[i], base_sort[k] = base_sort[k], base_sort[i]
			i++
			k--
		}
		new_perm := make([]int, len(base))
		copy(new_perm, base_sort)
		result = append(result, new_perm)
	}
	return result
}

type IOSimulator struct {
	get_from    int
	send_to     int
	channels    []chan int
	end_channel chan bool
}

func (i *IOSimulator) get_input() int {
	res := <-i.channels[i.get_from]
	return res
}

func (i *IOSimulator) put_output(output int) {
	i.channels[i.send_to] <- output
}

func (i *IOSimulator) end() {
	i.end_channel <- true
}

func get_mode(modes string, num int) int {
	if num > len(modes) {
		return 0
	}
	ret, _ := strconv.Atoi(string(modes[len(modes)-num]))
	return ret
}

func get_value_by_mode(memory []int, mode int, value int) int {
	if mode == 0 {
		return memory[value]
	}
	return value
}

func run_program(memory []int, ios *IOSimulator) {
	ipointer := 0
	for (memory[ipointer] % 100) != 99 {
		instruction := memory[ipointer] % 100
		modes := strconv.Itoa(memory[ipointer] / 100)
		switch instruction {
		case 1:
			arg1 := get_value_by_mode(memory, get_mode(modes, 1), memory[ipointer+1])
			arg2 := get_value_by_mode(memory, get_mode(modes, 2), memory[ipointer+2])
			result := arg1 + arg2
			memory[memory[ipointer+3]] = result
			ipointer += 4
		case 2:
			arg1 := get_value_by_mode(memory, get_mode(modes, 1), memory[ipointer+1])
			arg2 := get_value_by_mode(memory, get_mode(modes, 2), memory[ipointer+2])
			result := arg1 * arg2
			memory[memory[ipointer+3]] = result
			ipointer += 4
		case 3:
			result := ios.get_input()
			memory[memory[ipointer+1]] = result
			ipointer += 2
		case 4:
			ios.put_output(memory[memory[ipointer+1]])
			ipointer += 2
		case 5:
			arg1 := get_value_by_mode(memory, get_mode(modes, 1), memory[ipointer+1])
			arg2 := get_value_by_mode(memory, get_mode(modes, 2), memory[ipointer+2])
			if arg1 != 0 {
				ipointer = arg2
			} else {
				ipointer += 3
			}
		case 6:
			arg1 := get_value_by_mode(memory, get_mode(modes, 1), memory[ipointer+1])
			arg2 := get_value_by_mode(memory, get_mode(modes, 2), memory[ipointer+2])
			if arg1 == 0 {
				ipointer = arg2
			} else {
				ipointer += 3
			}
		case 7:
			var result int
			arg1 := get_value_by_mode(memory, get_mode(modes, 1), memory[ipointer+1])
			arg2 := get_value_by_mode(memory, get_mode(modes, 2), memory[ipointer+2])
			if arg1 < arg2 {
				result = 1
			} else {
				result = 0
			}
			memory[memory[ipointer+3]] = result
			ipointer += 4
		case 8:
			var result int
			arg1 := get_value_by_mode(memory, get_mode(modes, 1), memory[ipointer+1])
			arg2 := get_value_by_mode(memory, get_mode(modes, 2), memory[ipointer+2])
			if arg1 == arg2 {
				result = 1
			} else {
				result = 0
			}
			memory[memory[ipointer+3]] = result
			ipointer += 4
		default:
			fmt.Print("ERROR")
			panic("ERROR")
		}

	}
	ios.end()
}

func main() {

	dat, _ := ioutil.ReadFile("Day 7.txt")
	strsplit := strings.Split(string(dat), ",")
	memory := make([]int, len(strsplit))
	for i, str := range strsplit {
		memory[i], _ = strconv.Atoi(str)
	}
	perms := get_permutations([]int{5, 6, 7, 8, 9})
	var best_perm []int
	best_power := 0
	for _, perm := range perms {
		channels := make([]chan int, len(perm))
		end_channels := make([]chan bool, len(perm))
		for i := range channels {
			channels[i] = make(chan int, 1)
			end_channels[i] = make(chan bool)
		}
		for i, phase := range perm {
			tmp_mem := make([]int, len(memory))
			copy(tmp_mem, memory)
			ios := IOSimulator{
				send_to:     (i + 1) % len(perm),
				get_from:    i,
				channels:    channels,
				end_channel: end_channels[i]}
			go run_program(tmp_mem, &ios)
			channels[i] <- phase
		}
		channels[0] <- 0
		<-end_channels[len(perm)-1]
		power := <-channels[0]
		if power > best_power {
			best_power = power
			best_perm = perm
		}
	}
	fmt.Print(best_perm)
	fmt.Print(best_power)

}
