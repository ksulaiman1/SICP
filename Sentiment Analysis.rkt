#lang scheme

(require net/url)
(require data-science)
(require plot)
(require math)
(require json)

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
