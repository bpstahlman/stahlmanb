#lang racket
(require racket/match)
(require data/collection)

; Slat consists of index and height
(struct slat (i h))

; Fully process the open slats above cutoff height to see whether any gives a
; new max-area. Slats are discarded after processing, but the earliest slat
; will be "trimmed" and added (retroactively) to the set of open slats if and
; only if the tallest preceding open slat is *lower* than the cutoff height.
; Rationale: A slat that juts above its predecessor by more than a single
; height unit could begin multiple rectangles. A naive approach would simply
; add all these potential rectangles at the index of the jutting slat. But this
; would be extremely wasteful. Consider that when multiple rectangles start and
; end at the same index, only the tallest matters. Since we don't yet know
; where each of the rectangles beginning with the jutting slat will be closed,
; we can't yet know which will be needed. By adding only the full slat
; (representing the tallest rectangle) proactively, we avoid adding *many*
; useless rectangles. Of course, this strategy requires that we add a potential
; rectangle retroactively when we notice that it extends past all taller
; rectangles that began where it did, *and* there's not already an open slat of
; the same height at an earlier index (rendering the trimmed one irrelevant).
; Precondition: Both slat height and index increase towards list head.
; Precondition: Descent guarantees existence of at least 1 element in os.
; Inputs:
;   i   index of cutoff slat
;   h   cutoff height
;   os  list of open slats
;   ma  current max area
; Return:
;   os  updated list of open slats
;   ma  updated max area
(define (close-rects i h os ma)
  (for/fold
    ([ma ma]
     [el #f] ; >=1 iterations guaranteed
     [os os]
     #:result (values
		ma
		(if (or (empty? os)
			(< (slat-h (car os)) h))
		  (cons (struct-copy slat el [h h]) os)
		  os)))
    ([el-n os]
     ; If we break here, os hasn't been updated: i.e., car in result clause
     ; will be the el-n that caused break.
     #:break (> h (slat-h el-n)))
    ; Deconstruct and process next slat, which will be either discarded (here)
    ; or trimmed/added retroactively (in result clause).
    (values (match el-n
	      [(struct slat (ii hh))
	       (let ([a (* (- i ii) hh)])
		 (if (> a ma) a ma))])
	    el-n
	    (cdr os))))

; Process a single slat. If a new rectangle is opening, add it to the ordered
; set; if rectangles are closing, iterate them, updating max-area as necessary.
; Upon return, any fully processed rectangles have been removed from the
; ordered set.
; Inputs:
;   os        list of open slats
;   ph        prev slat height
;   i         current slat index
;   h         current slat height
;   ma        current max area
; Return:
;   max-area  updated max area
;   os        updated list of open slats
(define (process-one-slat os ph i h ma)
  (cond
    [(> h ph) ; ascent - open rectangles
     [values ma (cons (slat i h) os)]]
    [(= h ph) ; flatline - nop
     (values ma os)]
    [else     ; descent - close rectangles
      (close-rects i h os ma)]))

; Find largest rectangle in input sequence of slat heights.
; Note: Though the "finger tree" ordered sets used in the original
; implementation have been replaced with simple lists, I've retained the
; nomenclature "os" because it's short, and the lists do represent ordered
; sets.
(define (find-largest-rec heights)
  ; Iterate slat heights.
  ; i=index, pi=prev-index, ph=prev-height ma=max-area os=ordered-set
  (let loop ([i 0] [pi -1] [ph -1] [heights heights] [ma 0] [os '()])
    ; Get current height (-1 if virtual slat just past end)
    (let ([h (if (empty? heights) -1 (first heights))]
	  [pma ma])
      ; Process current slat, updating both max-area and open slat list.
      (let-values ([(ma os) (process-one-slat os ph i h ma)])
	; Show max-area increases if debugging.
	(when (and (*debug*) (> ma pma)) (printf "i=~a ma=~a~n" i ma))
	(if (negative? h) ma (loop (add1 i) i h (rest heights) ma os))))))

; Define parameters representing program options.
(define *show-graph* (make-parameter null))
(define *max-height* (make-parameter 20))
(define *num-heights* (make-parameter 20))
(define *heights* (make-parameter null))
(define *debug* (make-parameter #f))

(define (process-options)
  (command-line
    #:program "Fence area maximizer"
    #:usage-help
    "Find the area of the largest rectangle that can be hidden behind a"
    "fence of non-uniform slat height."
    "...where fence is constructed from NUM-HEIGHTS random heights in 0..MAX-HEIGHT"
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
  (printf "  ~a~n" (make-string (*max-height*) #\=))
  ; Draw the fence slats sideways (i.e., rotated 90 deg c.w.)
  (for ([h heights] [i (*num-heights*)])
    (printf "~a|~a (~a)~n" (modulo i 10) (make-string h #\*) h))
  (printf "  ~a~n" (make-string (*max-height*) #\=)))

; Driver program
(define (main)
  (let* ([heights (take (*num-heights*) (randoms (add1 (*max-height*))))])
    ; Run and time the calcuation.
    (let-values ([(results cpu-time wall-time gc-time)
		  (time-apply find-largest-rec (list (*heights*)))])
      (when (*show-graph*) (horiz-graph (*heights*)))
      (printf "Max area: ~a~n" (car results))
      (printf "Times: cpu=~a wall=~a gc=~a~n" cpu-time wall-time gc-time))))

(process-options)
(main)

