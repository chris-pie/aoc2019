// Learn more about F# at http://fsharp.org
open System
open System.IO
open System.Text.RegularExpressions
let bigint (x:int)= bigint x

let rec gcd (x:bigint) (y:bigint) = if y = bigint(0) then abs x else gcd y (x % y)
let lcm (x:bigint) (y:bigint) = x * y / (gcd x y)

let tl a = Seq.toList (Seq.map Seq.toList a)

let add_abs a b = abs(a) + abs(b)


let get_axes (l:list<list<int>>) = 
    let num_axes = List.length l.[0]
    let app_ind t (s:list<int>) (l:list<int>) =
        List.append s [l.[t]]
    let axis_fold l a = 
        List.fold (app_ind a) [] l
    List.map (axis_fold l) [0 .. (num_axes-1)]

let vars_from_line line =
    Seq.map (fun (m:Match) -> int(m.Groups.[1].Value)) (Regex.Matches(line, "[a-z]=(-?[0-9]*)(?:,|\>)"))

let next_step (positions:list<list<int>>) (velocities:list<list<int>>) =
    let update_axis_velocity (body_axis:int) (other_axis:int) = 
        -sign(body_axis - other_axis)
    let vel_change_pair curr_pos other_pos = 
        List.map2 update_axis_velocity curr_pos other_pos
    let vel_change_body positions curr_pos curr_vel =
        List.fold (fun s pos -> List.map2 (+) s (vel_change_pair curr_pos pos)) curr_vel positions
    let new_velocities = List.map2 (vel_change_body positions) positions velocities
    let new_positions = List.map2 (fun pos vel -> List.map2 (+) pos vel) positions new_velocities
    (new_positions, new_velocities)

let rec compute_steps (positions:list<list<int>>) (velocities:list<list<int>>) steps_left = 
    match steps_left with
    | 0 -> (positions, velocities)
    | _ ->
        let new_positions, new_velocities = next_step positions velocities
        compute_steps (tl new_positions) (tl new_velocities) (steps_left-1)


let find_repeat pos vel = 
    let rec find_repeat' (initpos:list<int>) (initvel:list<int>) (pos:list<int>) (vel:list<int>) counter=
        let newpos_l, newvel_l = next_step (List.map (fun x -> [x]) pos) (List.map (fun x -> [x]) vel)
        let newpos = (get_axes newpos_l).[0]
        let newvel = (get_axes newvel_l).[0]
        if ((initpos = newpos) && (initvel = newvel)) 
        then counter+1
        else find_repeat' initpos initvel newpos newvel (counter+1)
    find_repeat' pos vel pos vel 0

[<EntryPoint>]
let main argv =
    let lines = File.ReadAllLines("Day 12.txt")
    let positions = Seq.map vars_from_line lines
    let velocities = Seq.map (fun a -> Seq.map (fun _ -> 0) a) positions
    let res_pos, res_vel = compute_steps (tl positions) (tl velocities) 1000
    let energy = Seq.fold2 (fun t pos vel -> t + (Seq.fold add_abs 0 pos) * (Seq.fold add_abs 0 vel)) 0 res_pos res_vel
    printfn "%i" energy
    let axes_p = get_axes (tl positions)
    let axes_v = get_axes (tl velocities)
    let repeats = List.map2 (find_repeat) axes_p axes_v
    let repeats_b = List.map bigint repeats
    let lcm_repeats = List.fold (lcm) (bigint 1) repeats_b
    printfn "%A" lcm_repeats
    0 // return an integer exit code