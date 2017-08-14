; Note: Submitted this one on hackerrank on 18Jul2017. It passed all tests, and
; I think I like it best.
(defn number-of-transmitters [n k xs]
  (loop [nt 1
         [x0 x1 :as xs] (distinct (sort xs))
         lim (+ x0 k)
         cov false]
    (if x1
      (if (> x1 lim)
        (if cov
          (recur (inc nt) (rest xs) (+ x1 k) false)
          (recur nt xs (+ x0 k) true))
        (recur nt (rest xs) lim cov))
      nt)))

(defn number-of-transmitters2 [n k xs]
  (loop [nt 1
         [x0 x1 :as xs] (distinct (sort xs))
         lim (+ x0 k)
         cov false]
    (if x1
      (if (> x1 lim)
        (if cov
          (recur (inc nt) (rest xs) (+ x1 k) (not cov))
          (let [gap (> (- x1 x0) k)] 
            (recur (if gap (inc nt) nt) (rest xs) (+ (if gap x1 x0) k) cov)))
        (recur nt (rest xs) lim cov))
      nt)))

(defn number-of-transmitters3 [n k xs]
  (loop [nt 1
         [x0 x1 :as xs] (distinct (sort xs))
         lim (+ x0 k)
         cov false]
    (if x1
      (if (> x1 lim)
        (if cov
          (recur (inc nt) (rest xs) (+ x1 k) (not cov))
          (if (> (- x1 x0) k)
            (recur (inc nt) (rest xs) (+ x1 k) cov)
            (recur nt (rest xs) (+ x0 k) cov)))
        (recur nt (rest xs) lim cov))
      nt)))

(number-of-transmitters 5 1 [1 2 3 4 5])
(number-of-transmitters 8 2 [7 2 4 6 5 9 12 11])
(prn (number-of-transmitters 7 2 [9 5 4 2 6 15 12]))
