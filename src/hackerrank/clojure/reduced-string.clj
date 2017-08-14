
(defn reduced-string [s]
  (clojure.string/join
    (reverse (reduce (fn [[x & xs :as xxs] y]
                       (if (= x y)
                         xs
                         (cons y xxs)))
                     () s))))

; Test
(doseq [x ["abbccad" "abccbdeedf" "aa" "b" "aabbccddee"]]
  (println x "==>" (reduced-string x)))
