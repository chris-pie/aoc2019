module Main where

stringWrap :: Char -> String
stringWrap a = [a]

get_pattern_value :: Int -> [Int] -> (Int,Int) -> Int
get_pattern_value multiplier pattern (position,value) = (pattern!!((position `div` multiplier) `mod` length pattern)) * value

calc_digit :: [Int] -> [Int] -> Int -> Int
calc_digit pattern digit_list no = mod (abs . sum $ map (get_pattern_value no pattern) $ zip [no..] $ drop (no-1) digit_list) 10
    

calculatePhase :: [Int] -> Int -> [Int] -> [Int]
calculatePhase a 0 _ = a
calculatePhase init_list phases_remaining pattern = calculatePhase changed_list (phases_remaining - 1) pattern
    where
        changed_list = map (calc_digit pattern init_list) [1..(length init_list)]

modadd :: Int -> Int -> Int
modadd a b = mod (a + b) 10
calculatePhase' :: [Int] -> Int -> [Int]
calculatePhase' a 0 = a
calculatePhase' init_list phases_remaining = calculatePhase' (scanr1 modadd init_list) (phases_remaining - 1)

main :: IO ()
main = do
    let readi = read :: String -> Int
    input <- readFile $ "day 16.txt"
    let in_list = map (read . stringWrap) input :: [Int]
    let pattern = [0, 1, 0, -1] 
    let out_list = calculatePhase in_list 100 pattern
    putStrLn $ concat $ map show (take 8 out_list)
    let offset = read . concat $ map show (take 7 in_list) :: Int
    let in_list2 = drop offset (concat $ replicate 10000 in_list)
    let out_list2 = calculatePhase' in_list2 100
    putStrLn $ concat $ map show $ take 8 out_list2
