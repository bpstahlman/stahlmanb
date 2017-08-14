(use '[clojure.string :only (split triml trim)])

(dotimes [i (Long/parseLong (trim (read-line)))]
  (let [[n m] (map #(Long/parseLong %) (split (read-line) #"\s+"))
        xs (filter #(not (= m %))
                   (map #(Long/parseLong %) (split (read-line) #"\s+")))]
    (println
      (loop [max 0 [_ & xss :as xs] xs]
        (let [max
              (loop [sum 0 max max [x & xss :as xs] xs]
                (let [sum (mod (+ sum x) m)
                      max (if (> sum max) sum max)]
                  (if (seq xss) (recur sum max xss) max)))]
          (if (seq xss) (recur max xss) max))))))

; More efficient approach
(dotimes [i (Long/parseLong (trim (read-line)))]
  (let [[n m] (map #(Long/parseLong %) (split (read-line) #"\s+"))
        xs (filter #(not (= m %))
                   (map #(Long/parseLong %) (split (read-line) #"\s+")))]
    (println
      (let [[max sums]
            (loop [sum 0
                   max max [x & xss :as xs] xs
                   sums ()]
              (let [sum (mod (+ sum x) m)
                    max (if (> sum max) sum max)]
                (if (seq xss) (recur sum max xss (conj sums sum)) max)))]
          ;(if (seq xss) (recur max xss) [max (reverse sums)])
        ;
        (loop [sum 0 max max
               [x & xss :as xs] xs
               [s & sss :as ss] sums]
          )))))







