
(defn find-min-sep [xs]
  (loop [[x & xs :as xss] xs idx 0 m {} dmin nil]
    (if-not x dmin
      (if-let [pidx (m x)]
        (let [d (- idx pidx)]
          (recur xs (inc idx) (assoc m x idx) (if dmin (min dmin d) d)))
        (recur xs (inc idx) (assoc m x idx) dmin)))))

;; *** Testing ***
(let [N 20
      M 100
      xs (take N (repeatedly (partial rand-int 100)))]
  (prn "N=" N " M=" M)
  (prn "xs=" xs)
  (prn "min distance:" (find-min-sep xs)))
