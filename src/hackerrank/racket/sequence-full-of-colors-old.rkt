
(define test-input '("RYGRBYB" "RGRGBY" "RBYG" "RRBB"))

(define (is-clr-seq str)
  (let-values ([(rg yb) (partition (curry set-member? (set #\R #\G))
				   (sequence->list str))])
    (andmap is-clr-seq1 (list rg yb))))

(define (is-clr-seq1 str)
  (not (for/fold
	 ([acc #f])
	 ([chr str]
	  #:break (eqv? acc chr))
	 (if (not acc) chr #f))))

(for ([s test-input])
  (let ([success (is-clr-seq s)])
    (printf "~s: ~a~n" (if success "Y" "N") s)))
