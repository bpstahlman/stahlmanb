(ns user
  (:require [clojure.set :refer [difference intersection]]
            [clojure.string :refer [join split]]))

; Return linear offsets representing cell positions adjacent to input idx in grid with M cols.
; TODO: Look for clojure utility functions that would facilitate doing this more elegantly.

(defn get-adj-offs [idx M]
  (let [col (mod idx M)
        lt-edge (= col 0)
        rt-edge (= col (dec M)) 
        e (inc idx) w (dec idx)
        s (+ idx M) n (- idx M)]
    (as-> [(- idx M) (+ idx M)] offs
          (if lt-edge offs
            (let [w (dec idx)] (into offs [w (- w M) (+ w M)])))
          (if rt-edge offs
            (let [e (inc idx)] (into offs [e (- e M) (+ e M)]))))))

(defn get-adj-cells [cset idx M]
  (intersection cset (set (get-adj-offs idx M))))


; Convert grid to linear sequence of indices of 1 cells, along with a set of them.
(defn preprocess-grid [grid]
  (:cset
    (reduce
      (fn [{:keys [cset idx] :as acc} c]
        (assoc (if (= c 1)
                 (assoc acc :cset (conj cset idx))
                 acc)
               :idx (inc idx)))
      {:cset #{} :idx 0}
      (flatten grid))))

(defn get-group [cset M]
  ; TODO: Consider use of if-first or whatever it is...
  (if-let [nucleus (first cset)]
    (loop [cnt 1 fifo (into clojure.lang.PersistentQueue/EMPTY [nucleus])
           cset (disj cset nucleus)]
      (if (empty? fifo)
        ; Done with this group. Return both the cnt and the remaining cset.
        [cnt cset]
        (let [idx (peek fifo) adj-cells (get-adj-cells cset idx M)]
          (recur (+ cnt (count adj-cells))
                 (apply conj (pop fifo) adj-cells)
                 ; Note: idx has already been removed.
                 (difference cset adj-cells)))))))

(defn find-max [cset M]
  (loop [max-cnt 0 cset cset]
    (if-let [[cnt cset] (get-group cset M)]
      (recur (max max-cnt cnt) cset)
      max-cnt)))

(defn bps-main [grid M]
  (-> grid
    (preprocess-grid)
    (find-max M)))

(defn test-driver [f N M & {:keys [print cell-fn]
                            :or {print false
                                 cell-fn #(rand-int 2)}}]
  (with-in-str (generate-test-input N M cell-fn)
    ;; Note: From here in can be used with real stdin.
    (let [[N] (read-ints)
          [M] (read-ints)
          ;; doall needed to force lazy-seq realization before we escape the with-in-str.
          grid (doall (take N (repeatedly read-ints)))]
      (println "Grid:")
      (prn grid)
      (println (time (f grid M))))))


;;
;; Test framework...
;;
(defn read-ints []
  "Convenience function to convert string -> vector of ints"
  (map #(Integer/parseInt %) (split (read-line) #"\s")))

(defn generate-test-input [N M cell-fn]
  (str N "\n" M "\n"
       (join "\n"
             (take N
                   (repeatedly
                     (fn []
                       (join " " (take M (repeatedly cell-fn)))))))))
