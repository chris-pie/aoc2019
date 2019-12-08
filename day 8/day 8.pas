{$MODE DELPHI}
program day_8;
uses 
    sysutils;
const
    x = 25;
    y = 6;

type
   layer = array[0..y-1, 0..x-1] of integer;
var
   m: String;
   f: text;
   l, i, num_layers, curr_x, curr_y, curr_l, min_0, min_r, t: Integer;
   layers: array of layer;
   counter : array[0..2] of Integer;
   result: layer;



begin
    min_0 := 0;
    min_r := 0;
    assign(f, '../day 8.txt');
    reset(f); 
    readln(f,m);
    l := length(m);
    num_layers := l div (x*y);
    setlength(layers, num_layers);
    curr_x := 0;
    curr_y := 0;
    curr_l := 0;
    for i:= 1 to l do 
    begin
        layers[curr_l][curr_y][curr_x] := ord(m[i]) - ord('0');
        curr_x := (curr_x + 1) mod x;
        if curr_x = 0 then
        begin
            curr_y := (curr_y + 1) mod y;
            if curr_y = 0 then curr_l := curr_l + 1;
        end;
    end;
    for curr_y := 0 to y-1 do
        for curr_x := 0 to x-1 do
            result[curr_y][curr_x] := 2;

    for curr_l := 0 to num_layers-1 do
    begin
        counter[0] := 0;
        counter[1] := 0;
        counter[2] := 0;
        for curr_y := 0 to y-1 do
        begin
            for curr_x := 0 to x-1 do
            begin
                t := layers[curr_l][curr_y][curr_x];
                counter[t] := counter[t] + 1;
                if (result[curr_y][curr_x] = 2) then result[curr_y][curr_x] := layers[curr_l][curr_y][curr_x];
            end;
        end;
        if (counter[0] < min_0) or (min_0 = 0)  then
        begin
            min_0 := counter[0];
            min_r := counter[1] * counter[2];
        end;
    end;
    writeln(min_r);
    writeln('');
    for curr_y := 0 to y-1 do
    begin
        for curr_x := 0 to x-1 do
        begin
            if result[curr_y][curr_x] = 1 then write('█') else write(' ');
        end;
    writeln('');
    end;


   close(f);
end.