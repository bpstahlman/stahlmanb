(ns user
  (:require [clojure.set :refer [difference intersection]]
            [clojure.string :refer [join split trim]]))

; Return linear offsets representing cell positions adjacent to input idx in
; grid with M cols.
; TODO: Look for clojure utility functions that would facilitate doing this
; more elegantly.
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


; Convert grid to set containing indices of 1-cells.
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
  (when-first [nucleus cset]
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

(defn read-ints
  "Convenience function to convert string -> vector of ints"
  []
  (map #(Integer/parseInt %) (split (read-line) #"\s")))

(defn bps-main []
  (let [[N] (read-ints)
        [M] (read-ints)
        ;; doall needed to force lazy-seq realization before we escape the with-in-str.
        grid (doall (take N (repeatedly read-ints)))]
    (println (-> grid
               (preprocess-grid)
               (find-max M)))))
;;
;; Test framework...
;;


(defn generate-grid [{:keys [N pct1s]}]
  (str N "\n" N "\n"
       (join "\n"
             (take N
                   (repeatedly
                     (fn []
                       (join " "
                             (take N
                                   (repeatedly
                                     #(if (< (rand-int 100) pct1s)
                                        1 0))))))))
       "\n"))


(defn test-one
  [fns {:keys [print-input generate-input]
          :or {print-input false}
          ; Both framework and user params collected in opts
          :as opts}]
  (let [test-input (generate-input (dissoc opts :print-grid))]
    (when print-input (println "-- Test Input --\n" test-input))
    (for [f fns]
      (with-in-str test-input
        (let [stdout (java.io.StringWriter.)]
          (binding [*out* stdout]
            (let [t1 (. java.time.Instant now)]
              ; Run function under test.
              (f)
              ; Return Duration and result as pair
              (let [t2 (. java.time.Instant now)]
                [(. java.time.Duration between t1 t2) (str stdout)]))))))))

(defmacro test-all [fns input-fn & params]
  `(iterate-params param# ~params
                   (print "Params: " param# "\n\t")
                   (print
                     (join "\n\t" (map (fn [fsym# [dur# res#]]
                                  (format "%.10s: [%04d.%06d s] => %s"
                                          (name fsym#)
                                          (.getSeconds dur#)
                                          (int (/ (.getNano dur#) 1000))
                                          (trim res#)))
                                ~fns
                                (test-one (map resolve ~fns)
                                          ; Pass test parameters as hashable seq.
                                          (apply hash-map
                                                 (apply conj
                                                        [:generate-input ~input-fn]
                                                        param#))))) "\n")))


(defmacro iterate-params [param params & body]
  `(doseq
     ~(apply vector
             (loop [[varname start end incr & xs :as xss] params bindings []]
               (if-not start
                 bindings
                 (recur xs
                        (conj bindings
                              varname
                              (list 'take-while
                                    (list 'partial '> end)
                                    (list 'iterate incr start)))))))
     ; Bind a seq of alternating key/vals.
     ; Rationale: Caller may wish to use as map, but may also require order.
     (let [~param ~(apply vector (apply concat (map #(-> [(keyword %) %])
                                                    (take-nth 4 params))))]
       ~@body)))

(comment (test-all ['bps-main 'bcs-main]
                   generate-grid
                   N 1 100 #(* 2 %)
                   pct1s 1 100 #(* 2 %)))

