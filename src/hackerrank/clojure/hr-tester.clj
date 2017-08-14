
(macroexpand-1
  '(iterate-params param [foo 1 64 #(* 2 %)
                    bar 1 64 #(* 4 %)]
                  param))

(defn doit [{:keys [foo bar]}]
  (println "Test function got foo=" foo " bar=" bar))

(iterate-params param [foo 1 64 #(* 2 %)
                       bar 1 64 #(* 4 %)]
                (prn param))

(defmacro iterate-params [param params & body]
  `(doseq
     ~(apply vector
             (loop [[varname start end incr & xs :as xss] (eval params) bindings []]
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
     (let [~param ~(apply concat (map #(-> [(keyword %) %])
                                      (take-nth 4 (eval params))))]
       ~@body)))



(def ps ['N 1 256 #(* 2 %)
         'M 1 256 #(* 2 %)
         'pct1s 1 100 #(* 2 %)])
(macroexpand-1 '(iterate-params foo ps foo))
