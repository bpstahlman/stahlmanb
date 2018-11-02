#lang racket
; TODO: Something wonky about the ftree require paths...
(require ftree/ftree/ftree)
(require ftree/orderedseq/orderedseq)
(require racket/match)
(require data/collection)

; Slat consists of index and height
(struct slat (i h))

; Comparator function to sort slats by height (increasing)
(define (cmp-slats a b)
  (< (slat-h a) (slat-h b)))

; Return: (values max-area open-rectangles-ordered-set)
(define (process-one-slat os ph i h ma)
  (cond
    [(> h ph) ; open rectangles
     [values ma (os-insert (slat i h) os)]]
    [(= h ph) ; nop
     (values ma os)]
    [else     ; close rectangles
      (let*-values
	([(os-o os-c) (os-partition (slat i (add1 h)) os)]
	 [(ma i-low)
	  ; Process closed slats to see whether any gives a new max-area.
	  ; Also, keep track of low index, since if cutoff height is greater
	  ; than largest in open slats, we'll need to add a new open slat
	  ; consisting of the earlist index with the cutoff height.
	  ; Rationale: Obviates need to open many rectangles proactively when a
	  ; slat that juts far above its predecessor is encountered. Adding
	  ; retroactively allows us to add only the ones that are ultimately
	  ; needed.
	  ; TODO: Consider factoring this into a function. Actually, might
	  ; refactor higher levels of this function into caller.
	  (let loop ([ma ma] [i-low #f] [os-c os-c])
	    (if (ft-empty? os-c)
	      (values ma i-low)
	      (let-values
		([(ma i-low)
		  (match (ft-hdL os-c)
		    [(struct slat (ii hh))
		     (let ([a (* (- i ii) hh)])
		       (values (if (> a ma) a ma)
			       (if (or (not i-low) (< ii i-low)) ii i-low)))])])
		(loop ma i-low (ft-tlL os-c)))))])
	(values
	  ma
	  ; Retroactively open a rectangle partway up a slat, but only if the
	  ; slat's predecessor is lower than it (or doesn't exist, in the case
	  ; of first slat)
	  (if (and i-low (or (os-empty? os-o)
			     (< (slat-h (os-top os-o)) h)))
	    (os-insert (slat i-low h) os-o)
	    os-o)))]))

; Find largest rectangle in input sequence of slat heights.
(define (find-largest-rec heights)
  (let loop ([i 0] [pi -1] [ph -1] [heights heights] [ma 0] [os (mk-oseq cmp-slats)])
    (let ([h (if (empty? heights) -1 (first heights))])
      (let-values ([(ma os) (process-one-slat os ph i h ma)])
	 (when (*debug*) (printf "i=~a ma=~a~n" i ma))
	 (if (negative? h) ma (loop (add1 i) i h (rest heights) ma os))))))

(define *show-graph* (make-parameter null))
(define *max-height* (make-parameter 20))
(define *num-heights* (make-parameter 20))
(define *heights* (make-parameter null))
(define *debug* (make-parameter #f))

(define (process-options)
  (command-line
    #:program "Fence area maximizer"
    #:usage-help
    "Find the area of the largest rectangle that can be hidden behind a fence of non-uniform slat height."
    "...where fence is constructed from NUM-HEIGHTS random heights between 0 and MAX-HEIGHT..."
    "...unless explicit list of heights is provided in HEIGHTS option"
    #:once-each
    [("-m" "--max-height") MAX-HEIGHT
			   "Maximum slat height (default 20)"
			   (*max-height* (round (string->number MAX-HEIGHT)))]
    [("-n" "--num-heights") NUM-HEIGHTS
			    "Desired # of slats in fence (default 20)"
			    (*num-heights* (round (string->number NUM-HEIGHTS)))]
    [("-g" "--show-graph")
     ("Show graph of output"
      "enabled by default for small values of --num-heights and --max-height"
      "...unless explicitly disabled with --hide-graph")
     (*show-graph* #t)]
    [("-G" "--hide-graph")
     "Hide graph of output regardless of input sizes"
     (*show-graph* #f)]
    [("-d" "--debug")
     "Output helpful (but potentially voluminous) debug information"
     (*debug* #t)]
    [("-l" "--heights") HEIGHTS
			"Space-separated list of non-negative integer slat heights"
			"MAX-HEIGHT and NUM-HEIGHTS are ignored when this list is provided."
			; TODO: Read the list...
			(*heights* (map (compose round string->number) (string-split HEIGHTS)))]
    #:args () (void))

  ; Default determined from inputs when neither --show-graph nor --hide-graph provided.
  (when (null? (*show-graph*))
    (*show-graph* (and (<= (*max-height*) 70) (<= (*num-heights*) 50))))
  ; If height list not provided, generate a random one, subject to constraints.
  (when (null? (*heights*)) (*heights* (take (*num-heights*) (randoms (*max-height*))))))

; Function to graph the slats horizontally
(define (horiz-graph heights)
  (printf "Heights: ~a~n" (sequence->list (*heights*)))
  (printf "~a~n" (make-string (*max-height*) #\=))
  (for ([h heights])
    (printf "|~a (~a)~n" (make-string h #\*) h))
  (printf "~a~n" (make-string (*max-height*) #\=)))

; Driver program
(define (main)
  (let* ([heights (take (*num-heights*) (randoms (*max-height*)))])
    ; Run and time the calcuation.
    (let-values ([(results cpu-time wall-time gc-time)
		  (time-apply find-largest-rec (list (*heights*)))])
      (when (*show-graph*) (horiz-graph (*heights*)))
      (printf "Max area: ~a~n" (car results))
      (printf "Times: cpu=~a wall=~a gc=~a~n" cpu-time wall-time gc-time))))

(process-options)
(main)

