(defn parse-line 
    "parses line of input and returs key val pair"
    [line]
    (def splitend (string/split " => " line))
    (def splitendsplit (string/split " " (splitend 1)))
    (def key (splitendsplit 1))
    (def end_amount (splitendsplit 0))
    (def splitingr (string/split ", " (splitend 0)))
    (def ingredients (array/new (length splitingr)))
    (each ingr splitingr 
        (def ingrsplit (string/split " " ingr))
        (def ingrstruct {:amount (scan-number (ingrsplit 0)) :name (ingrsplit 1)})
        (array/push ingredients ingrstruct)
    )
    {:key key :amount (scan-number end_amount) :ingredients ingredients}

)

(defn create_chemical
    ""
    [chemical reactions leftovers counters]
    (each ingredient ((reactions chemical) :ingredients)
        (when (= (ingredient :name) "ORE")
            (put counters "ORE" (+ (counters "ORE") (ingredient :amount )))
        )
        (when (not (= (ingredient :name) "ORE"))
            (def res_amount ((reactions (ingredient :name)) :amount) )
            (var curr-counter (- (ingredient :amount) (leftovers(ingredient :name))))
            (while (> curr-counter 0)
                (create_chemical (ingredient :name) reactions leftovers counters)
                (-= curr-counter res_amount)
                (put counters (ingredient :name) (+ (counters (ingredient :name)) res_amount ))
            )
            (put leftovers (ingredient :name) (* curr-counter -1))
        )
    )
)



(defn gcd
""
[a b]
    (defn gcd_
        ""
        [a b]
        (if (= b 0) a (gcd_ b (% a b)))
        )

    (gcd_ (math/abs a) (math/abs b))
)

(defn lcm
""
[a b]
(math/abs (/ (* a b) (gcd a b)))
)


(defn add-ratios
    ""
    [a b]
    (def denominator (lcm (a :denominator) (b :denominator)))
    (def newa_num (* ( a :numerator) (/ denominator (a :denominator) )))
    (def newb_num (* ( b :numerator) (/ denominator (b :denominator) )))
    (def factor (gcd (+ newa_num newb_num) denominator))
    (def numerator (/ (+ newa_num newb_num) factor))
    (def denominator_reduced (/ denominator factor))
    {:numerator numerator :denominator denominator_reduced}
)

(defn multiply-ratios 
    ""
    [a b]
    (def numerator (* (a :numerator) (b :numerator)))
    (def denominator (* (a :denominator) (b :denominator)))
    (def factor (gcd numerator denominator))
    {:numerator (/ numerator factor) :denominator (/ denominator factor)}
)

(defn to-ratio
    ""
    [a]
    {:numerator a :denominator 1}
)

(defn calculate_ratio
    ""
    [chemical reactions ratios]
    (var total {:numerator 0 :denominator 1})
    (each ingredient ((reactions chemical) :ingredients)
        (when (nil? (ratios (ingredient :name))) 
            (calculate_ratio (ingredient :name) reactions ratios)
        )
        (def curr_ratio (multiply-ratios (ratios (ingredient :name)) (to-ratio (ingredient :amount))))
        (set total (add-ratios total curr_ratio))
    )
    (def res_ratio {:denominator ((reactions chemical) :amount) :numerator 1})
    (put ratios chemical (multiply-ratios total res_ratio))

)

(def file_in (file/open "day 14.txt" :r))
(def string_in (file/read file_in :all))
(file/close file_in)
(def split_in (string/split "\n" string_in))
(def recipes @{})
(def leftovers @{"ORE" 0})
(def counters @{"ORE" 0})
(each recipe split_in 
    (def curr_rec (parse-line recipe))
    (put recipes (curr_rec :key) curr_rec)
    (put leftovers (curr_rec :key) 0)
    (put counters (curr_rec :key) 0)
)

(create_chemical "FUEL" recipes leftovers counters)
(print (counters "ORE"))

(def ratios @{"ORE" {:numerator 1 :denominator 1}})
(each recipe split_in 
    (def curr_rec (parse-line recipe))
    (put recipes (curr_rec :key) curr_rec)
    (put leftovers (curr_rec :key) 0)
    (put counters (curr_rec :key) 0)
)
(def MAX_ORE 1000000000000)
(calculate_ratio "FUEL" recipes ratios)
#(put counters "ORE" (- MAX_ORE (% MAX_ORE ((ratios "FUEL") :numerator))))
(def cycles (/ MAX_ORE ((ratios "FUEL") :numerator)))
(var fuel (* cycles ((ratios "FUEL") :denominator)))
(printf "%f" (math/floor fuel))