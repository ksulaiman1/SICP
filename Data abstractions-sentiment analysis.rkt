#lang scheme
 (require csv-reading)
(require net/url)
(require data-science)
(require plot)
(require math)
(require json)


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
(define token (document->tokens "happy happy happy love is better than ugly ugly mean old hate"))
(list->sentiment token #:lexicon 'nrc)
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



;;;;; 2 Sentiment Analysis
;; Read in the entire tweet database
(define data
  (read-csv "Uganda_sampletweets.csv" #:header? #t))


;; Get only tweets text  by colum-indexing
;; Join them into one string
(define tweets
 (string-join ($ data 'text)))

;;Normalize case, remove URLs, remove punctuation, and remove spaces
;;from each tweet. This function takes a list of words and returns a
;;preprocessed subset of words/tokens as a list

(define (preprocess-text str)
  (remove-stopwords
   (document->tokens
    (remove-punctuation
     (remove-urls str) #:websafe? #t) #:sort? #t)))

(define tokens (preprocess-text tweets))
;(define tweet_string (remove-punctuation tweets #:websafe? #t))
;(define words (document->tokens tweet_string #:sort? #t))
;(define rsw (remove-stopwords words #:lexicon 'onix))
;(list data-text)



;($ (list data-text) 0)
 
;(preprocess-text tweets)

;(define bwords (sort (sorted-counts tokens)
 ;                    (λ (x y) (> (second x) (second y)))))

;bwords
(define (top-words words)
  (parameterize ([plot-width 500]
                 [plot-height 400])
    (plot (list
           (tick-grid)
           (discrete-histogram (reverse (take words 20))
                               #:invert? #t
                               #:color "OrangeRed"
                               #:line-color 2 
                               #:y-max 450))
          #:x-label "Occurrences"
          #:y-label "word")))
(top-words tokens)

;; Remove punctuations from the string
;;#hashtags and @usernames are also removed


;; Return list of pairs where each pair consistsof a unique
;; word and its frequency in the string


;; Return list of triplets of each word, its sentiment, and frequency
(define sentiment (list->sentiment tokens #:lexicon 'nrc))
             

;; sum the total number of words in each mood sentiment
;; we can visualize a barplot of each mood
 
(let ([counts (aggregate sum ($ sentiment 'sentiment) ($ sentiment 'freq))])
  (parameterize ((plot-width 850) (plot-height 400))
    (plot (list
           (tick-grid)
           (discrete-histogram
            (sort counts (λ (x y) (> (second x) (second y))))
            #:color "OrangeRed"
            #:line-color 2))
          #:x-label "Affective Label"
          #:y-label "Frequency")))

