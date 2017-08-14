; Solved: 23 Jul 2017 (35 pts)
(use '[clojure.string :only (split triml trim)])

(println
  (let [n (Long/parseLong (trim (read-line)))
        [p0 & ps] (map #(Long/parseLong %) (split (read-line) #"\s+"))
        ts (java.util.TreeSet. #{p0})]
    (loop [loss nil [pi & ps] ps]
      (if-not pi
        loss 
        (do (.add ts pi)
          (if-let [higher (.higher ts pi)]
            (let [li (- higher pi)]
              (recur (if (or (nil? loss) (< li loss)) li loss) ps))
            (recur loss ps)))))))





