#lang racket

(require data/collection)
(define test-input '("RYGRBYB" "RGRGBY" "RBYG" "RRBB" "GBRYBGRY" "GBRGYBGY"))

; Make a collection filter predicate that passes only chars from the input pair.
(define (make-clr-filt clr) (λ (chr) (string-contains? clr (string chr))))

; Test a string against a single character pair (e.g., "RG" or "YB").
(define (is-clr-seq str clr)
  (not (for/fold
	 ([acc #f])
	 ([chr (filter (make-clr-filt clr) str)]
	  #:break (eqv? acc chr))
	 (if (not acc) chr #f))))

(printf "~n")

; Loop over the test strings.
(for ([s test-input])
  (let* ([fn (curry is-clr-seq s)]
	 [success (andmap fn '("RG" "YB"))])
    (printf "~s: ~a~n" (if success "Y" "N") s)))
