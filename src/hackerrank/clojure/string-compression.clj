(defn compress [[c1 c2 :as s]]
  (if (nil? c2)
    s
    (clojure.string/join
      (reduce (fn [xs [x n]]
                (if (> n 1)
                  (cons x (apply conj xs (clojure.core/reverse (str n))))
                  (cons x xs)))
              ()
              (reduce (fn [[[x n] & xsr :as xs] xn]
                        (if (= x xn)
                          (cons [x (inc n)] xsr)
                          (cons [xn 1] xs)))
                      (list [(first s) 1])
                      (rest s))))))
(compress "fffooooooooooooooooooooobarrrrrrr")
(compress "")
(compress "a")
(compress "ab")
(compress "zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz")

