#!/usr/bin/env swipl
:- use_module(library(clpfd)).
 
main([LD,LU]) :-
    ans(LD, LU, A1, A2),
    write(A1), write(" "), write(A2),
    halt.
 
 
head([H|_], H).
 
stringTokenizer([], []).
stringTokenizer([N|Ns], [Digit|Rest]):-
    48 =< N, N =< 57,
    Digit is N - 48,
    stringTokenizer(Ns, Rest).
 
getList(A, List) :-
    string_codes(A, Codes),
    stringTokenizer(Codes, List).
 
satisfiesCriteria([_|_], _, [], _, [], _):-
    fail.
 
satisfiesCriteria([], _, [_|_], _, [_|_], _):-
    fail.
 
satisfiesCriteria([D|[]], R, [_|[]], _, [_|[]], _):-
    D #< 10,
    D #>= 0,
    R.
 
satisfiesCriteria([D|T], R, [U|LU], UC, [DD|LD], LC):-
  
    (
        UC,!, UCN = UC;
        U #> D, UCN = true;
        U #= D, UCN = UC       
    ),
    (
        LC,!, LCN = LC;
        DD #< D, LCN = true;
        DD #= D, LCN = LC     
    ),
    head(T, N),
    D #=< N,
    (
        (D #= N, R2 = true);
        R2 = R
    ),
D #< 10,
    D #>= 0,
    satisfiesCriteria(T, R2, LU, UCN, LD, LCN).
passwordCorrect(LP, LimitDown, LimitUp):-
    getList(LimitUp, LU),
    getList(LimitDown, LD),
    satisfiesCriteria(LP, false, LU, false, LD, false).
 
hlp(P, LU, LD):-
    passwordCorrect(P, LU, LD),
    label(P).
    
set1(LU, LD, S):-
    setof(P, hlp(P, LU, LD), S).
 
ans2_check([D1,D2,D3,D4|T]):-
    D2 #= D3, D1 #\= D2, D3 #\= D4;
    ans2_check([D2,D3,D4|T]).
    
ans2_filter(L):-
    append([-1|L], [-1], Z),
    ans2_check(Z).
 
ans(LU, LD, A1, A2):-
    set1(LU, LD, T),
    include(ans2_filter, T, L),
    length(L, A2),
    length(T, A1).
    
