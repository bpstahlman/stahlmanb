#lang racket

(require data/collection)
(require memoize)

(define test-boards '("OXOOXOOXO" "OXOXXOXXO" "XOXOXOXOX" "OOXXOOXXO"))

; Convert a single char (e.g. #\3) to number (e.g., 3)
(define char->num (compose1 string->number string))

; Create memoized thunk, which returns a hash of the following format:
;   key:   board position 0-8
;   value: list of winning sequences involving key's board position
;          Note: Each sequence is a list of 3 position indices: e.g.,
;          '(0 1 2) for a win across the top row
(define/memo (ways-to-win)
	     (for*/fold
	       ([h (hash)])
	       ([w  '("012" "345" "678" "036" "147" "258" "048" "246")]
		[i (map char->num w)])
	       (hash-set h i (cons (map char->num w) (hash-ref h i empty)))))

; Return #t if board position given by pos is part of a win.
(define (is-win? brd pos)
  (define get-at (curry string-ref brd))
  (ormap (λ (posns)
	    (andmap (curry eq? (get-at pos))
		    (map get-at posns)))
	 (hash-ref (ways-to-win) pos)))

(printf "~n")
; Loop over the test boards, checking whether each square is part of a win.
(for* ([s test-boards]
       [i (range 9)])
  (when (zero? i) (printf "Board: ~s~n" s))
  (printf "\tSquare ~s: ~s~n" i (is-win? s i)))
