(require '[clojure.string :as s])

; Function that takes 2 strings and permutes them.
(defn permute [xs ys]
  (s/join
    (reverse (reduce (fn [acc [x y]] (conj acc x y))
                     ()
                     (map vector xs ys)))))
                   
; Function that takes any number of strings and permutes them.
(def permute-all (comp s/join
                       reverse
                       (partial reduce #(apply conj %1 %2) ())
                       (partial map list)))

(permute "foo" "bar")
(permute-all "foo" "bar" "baz" "bam")
