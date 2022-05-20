#lang scheme
 (require csv-reading)
(require net/url)
(require data-science)
(require plot)
(require math)



; a) linear-model
(define (linear-model xs y)
  (let ([X (list*->matrix
	    (map (λ (x y) (flatten (list x y)))
		 (build-list (length xs) (const 1)) xs))]
	[Y (->col-matrix y)])
    
    (matrix->list (matrix*
		   (matrix-inverse (matrix* (matrix-transpose X) X))
		   (matrix* (matrix-transpose X) Y)))))

(define x1 '(52 59 67 73 64 74 54 61 65 46 72))
;;; Second independent variable
(define x2 '(173 184 194 211 196 220 188 188 207 167 217))
;;; Dependent variable
(define y '(132 143 153 162 154 168 137 149 159 128 166))
;;; Fit the model

(linear-model (map list x1 x2) y)

; b) list->sentiment
(define (list->sentiment lst #:lexicon [lexicon 'nrc])
  (define (pack-sentiment lst lexicon)
    (apply append (list '("word" "sentiment" "freq"))
	   (map (λ (x) 
		  (let ([result   (token->sentiment (first x) #:lexicon lexicon)])
		    (map (λ (y) (append y (list (second x)))) result)))
		lst)))
  (let ([sentiment (pack-sentiment lst lexicon)])
    (if (> (length sentiment) 1)
	sentiment
	'())))
(define tokens (document->tokens "happy happy happy love is better than ugly ugly mean old hate"))
(list->sentiment tokens #:lexicon 'nrc)
;; c) read-csv
(define (read-csv file-path
		  #:->number? [->number? #f]
		  #:header? [header? #t])
  (let ((csv-reader (make-csv-reader-maker
		     '((comment-chars #\#))))) 
    (with-input-from-file file-path
      (lambda ()
	(let* ((tmp (csv->list (csv-reader (current-input-port)))))
	  (if ->number?
	      ;; try to convert everything to numbers rather than
	      ;; strings. This should be made smarter, converting only
	      ;; those columns which are actually numbers
	      (if header?
		  (cons (car tmp) (map (lambda (x) (map string->number x)) (cdr tmp)))
		  (map (lambda (x) (map string->number x)) tmp))
	      ;; Else, leave everything as strings
	      tmp))))))

;; d)qq-plot*
(define (qq-plot* lst #:scale? [scale? #t])
  (plot (qq-plot lst #:scale? scale?)
	#:x-label "Theoretical Normal Quantiles"
	#:y-label "Sample Quantiles"))

(qq-plot* (sample (normal-dist 0 1) 500))

;; e) hist
(define (hist lst)
  (discrete-histogram (sorted-counts lst)))

(define die-1 (build-list 500 (λ (n) (random 1 7))))
(define die-2 (build-list 500 (λ (n) (random 1 7))))
(define total-roll (map + die-1 die-2))

(parameterize ([rectangle-color "lightgreen"]) 
  (plot (hist total-roll)
        #:x-label "Dice Roll"
        #:y-label "Frequency"))
