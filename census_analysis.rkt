#lang racket
(require csc151)
(require plot)


;This is the original dataset
(define original (read-csv-file "adult.csv"))


;------------------------------------------
;-------------DATA WRANGLING---------------
;------------------------------------------
;Changing categories
;;; Procedure:
;;;   change-age-single
;;; Parameters:
;;;   lst, a list
;;; Purpose:
;;;   converts the age (a number) into a range of ages (a string; one of: "17-22", "23-45", "46-65", "65+")
;;; Produces:
;;;  result, a list
;;; Pre-conditions:
;;;  (list-ref lst 0) must be a number
;;;  lst must have at least 2 elements
;;; Post-conditions:
;;;   (length result) = (length lst)
;;;   (list-ref result 0) is a string that is equal to one of: "17-22", "23-45", "46-65", "65+"
(define change-age-single
  (lambda (lst)
    (let ([age (list-ref lst 0)] ;Gets the age of the individual
          [-age (drop lst 1)]) ;Takes all characteristics of the individual besides age
      (cond
        [(<= age 22)
         (cons "17-22" -age)]
        [(<= age 45)
         (cons "23-45" -age)]
        [(<= age 65)
         (cons "46-65" -age)]
        [else
         (cons "65+" -age)]))))



;;;Procedure:
;;;   change-hours-single
;;;Parameters:
;;;   lst, a list
;;;Purpose:
;;;   Converts the hour section of the list (the 6th element of the list) into a range of hours
;;;Produces:
;;;   result, a list
;;;Pre-conditions:
;;;   (list-ref lst 5) has to be a number
;;;   lst must have at least 6 elements
;;;Post-conditions:
;;;   (length result) = (length lst)
;;;   (list-ref lst 5) is a string that is equal to one of: "1-10", "11-25", "26-45", "45+"
(define change-hours-single
  (lambda (lst)
    (let ([hours-per-week (list-ref lst 5)] ;Gets the number of hours per week the individual works
          [remove-hours-per-week (take (reverse lst) 1)] ;Removes the number of hours per week the individual works from the list
          [desc-up-to-hours (take lst 5)]);Takes the description of the individual up to the hours per week the individual works
      (cond
        [(<= hours-per-week 10)
         (append desc-up-to-hours (cons "1-10" remove-hours-per-week))]
        [(<= hours-per-week 25)
         (append desc-up-to-hours (cons "11-25" remove-hours-per-week))]
        [(<= hours-per-week 45)
         (append desc-up-to-hours (cons "26-45" remove-hours-per-week))]
        [else
         (append desc-up-to-hours (cons "45+" remove-hours-per-week))]))))

;;; Procedure:
;;;   remove-columns
;;; Parameters:
;;;   lst, a list
;;; Purpose:
;;;   removes columns that are unnecessary while keeping the ones that
;;;     are needed for our analysis; which are: (age, work-class, education level, race, sex, hours of work per week, income)
;;; Produces
;;;   result, a list
;;; Pre-conditions:
;;;  lst must have at least 15 elements
;;; Post-conditions:
;;;  (length lst) = 7
;;;  (and
;;;    (eq? (list-ref result 0) (list-ref lst 0))
;;;    (eq? (list-ref result 1) (list-ref lst 1))
;;;    (eq? (list-ref result 2) (list-ref lst 3))
;;;    (eq? (list-ref result 3) (list-ref lst 8))
;;;    (eq? (list-ref result 4) (list-ref lst 9))
;;;    (eq? (list-ref result 5) (list-ref lst 12))
;;;    (eq? (list-ref result 6) (list-ref lst 14))
;;;    ) = #t
(define remove-columns
  (lambda (lst)
    (append
     (list (list-ref lst 0)) ;Age
     (list (list-ref lst 1)) ;Work-class
     (list (list-ref lst 3)) ;Education level
     (list (list-ref lst 8)) ;Race
     (list (list-ref lst 9)) ;Sex
     (list (list-ref lst 12)) ;Hours of work per week
     (list (list-ref lst 14))))) ;Income

;;;Procedure:
;;;  remove-income-single
;;;Parameters: 
;;;  lst, a list
;;;Purpose:
;;;   to take the first 6 elements of a list, removing the rest
;;;Produces:
;;;   result, a list
;;;Pre-conditions:
;;;   (length lst) >= 6
;;;Post-conditions:
;;;   (length lst) = 6
(define remove-income-single
  (lambda (lst)
    (take lst 6)))


;;;Procedure:
;;;  remove-foreigners
;;;Parameters: 
;;;  lst, a list of lists
;;;Purpose:
;;;  to remove all instances of data where the individual is not from the United States.
;;;Produces:
;;;  result, a list of lists
;;;Pre-conditions:
;;;  For each list in lst, (list-ref lst 13) is a string equal to "United-States" or another string.
;;;Post-conditions:
;;;  (length result) <= (length result)
;;;  For each list in result, (list-ref lst 13) = "United-States"
(define remove-foreigners
  (lambda (lst)
    (letrec ([remove-foreigners-helper
              (lambda (lst lst-so-far)
                (cond
                  [(null? lst)
                   lst-so-far]
                  [(equal? (list-ref (car lst) 13) "United-States") ;Checks if the individual is from the United States
                   (remove-foreigners-helper (cdr lst) (cons (car lst) lst-so-far))]
                  [else
                   (remove-foreigners-helper (cdr lst) lst-so-far)]))])
      (remove-foreigners-helper lst null))))
       



;Wrangled dataset
(define wrangled-dataset
  (map change-hours-single (map change-age-single (map remove-columns (remove-foreigners original)))))


;Smaller dataset to test on
(define smaller (take wrangled-dataset 10))


;Table with wrangled data and also no income
(define no-income
  (map remove-income-single wrangled-dataset))

;Single line to test on
(define single-no-income (list-ref no-income 12))


;List of all education levels (used for combine*)
(define ed-list
  (list "Bachelors" "Some-college" "11th" "HS-grad" "Prof-school" "Assoc-acdm"
        "Assoc-voc" "9th" "7th-8th" "12th" "Masters" "1st-4th" "10th" "Doctorate"
        "5th-6th" "Preschool"))

;List of all races (used for combine*)
(define race-list
  (list "White" "Black"))

;List of all sexes (used for combine*)
(define sex-list
  (list "Male" "Female"))

;List of possible age categories
(define age-list
  (list "17-22" "23-45" "46-65" "65+"))

;List of possible hours-per-week
(define hrs-list
  (list "1-10" "11-25" "26-45" "45+"))

;List of possible work-classs categories
(define wc-list
  (list "Private" "Self-emp-not-inc" "Self-emp-inc" "Local-gov" "State-gov" "Without-pay" "Never-worked"))


;------------------------------------------
;-------------DATA ANALYSIS----------------
;------------------------------------------

;;; Procedure:
;;;   filter-table
;;; Parameters:
;;;   table, table in the format of wrangled-dataset
;;;   age, a string that is an element of age-list
;;;   wc, a string that is an element of wc-list
;;;   ed, a string that is an element of ed-list
;;;   r, a string that is an element of race-list
;;;   s, a string that is an element of sex-list
;;;   hrs, a string that is an element of hrs-list
;;; Purpose:
;;;   takes in a hypothetical person's age, work-class, education level, race, sex, and hours worked per week,
;;;     and creates a new table that shows all people in the original table who match the characteristics of the hypothetical person
;;; Produces:
;;;  result, a new table
;;; Pre-conditions:
;;;  Each lst in table must be in format '(age wc ed r s hrs) where each element in the lst is a string
;;; Post-conditions:
;;;  (length lst) of each element in result is greater than or equal to 6.

(define filter-table
  (lambda (table age wc ed r s hrs);Age is the age of the individual, wc is the work-class, ed is the education level, r is the race, s is the sex, hrs is hours of work per week the individual works
    (letrec [(filter-table-helper
              (lambda (table age wc ed r s hrs lst-so-far)
                (cond [(null? table)
                       lst-so-far]
                      [(and
                        (string-ci=? (caar table) age)
                        (string-ci=? (list-ref (car table) 1) wc)
                        (string-ci=? (list-ref (car table) 2) ed)
                        (string-ci=? (list-ref (car table) 3) r)
                        (string-ci=? (list-ref (car table) 4) s)
                        (string-ci=? (list-ref (car table) 5) hrs))
                       (filter-table-helper (cdr table) age wc ed r s hrs (cons (car table) lst-so-far))]
                      [else
                       (filter-table-helper (cdr table) age wc ed r s hrs lst-so-far)])))]
      (filter-table-helper table age wc ed r s hrs null))))


;;;Procedure:
;;;  percentage
;;;Parameters:
;;;  lst, a list of lists
;;;Purpose:
;;;  calculates the percentage of individuals in lst that have an income of over 50k.
;;;Produces:
;;;  result, a number
;;;Preconditions:
;;;  each list in lst should be in the format of '(age wc ed r s hrs income) where:
;;;   age, a string that is an element of age-list
;;;   wc, a string that is an element of wc-list
;;;   ed, a string that is an element of ed-list
;;;   r, a string that is an element of race-list
;;;   s, a string that is an element of sex-list
;;;   hrs, a string that is an element of hrs-list
;;;  for each list in the table, (list-ref lst 6) is either ">50k" or "<=50k"
;;;  table must not be empty
;;;Postconditions:
;;;  0 <= result <= 100
(define percentage
  (lambda (lst)
    (letrec ([over-50k-tally ;takes a tally of the number of people in the table making over 50k
              (lambda (lst)
                (cond
                  [(null? lst)
                   0]
                  [(string-ci=? (list-ref (car lst) 6) ">50K")
                   (+ 1 (over-50k-tally (cdr lst)))]
                  [else
                   (over-50k-tally (cdr lst))]))])
      (* (/ (over-50k-tally lst) (length lst)) 100))))


;Following procedure:
;https://stackoverflow.com/questions/5546552/scheme-recursive-function-to-compute-all-possible-combinations-of-some-lists
;We were told by the instructor that we didn't need to document this procedure but should explain what it does:
; combine* takes in an unlimited number of lists and creates a list of lists showing how each item in each of the inputted lists
;    can be arranged (essentially combinations)
;For the purposes of our data analysis, the combinations of education-level, race, and sex were made: (combine* ed-llist race-list sex-list)
(define combine*
  (letrec ([concat/map
            (lambda (ls f)
              (cond
                [(null? ls) '()]
                [else (append (f (car ls)) (concat/map (cdr ls) f))]))])
    (letrec ([combine
              (lambda (xs ys)
                (concat/map xs
                            (lambda (x)
                              (map (lambda (y) (list x y)) ys))))])
      (lambda (xs . ys*)
        (cond
          [(null? ys*) (map list xs)]
          [(null? (cdr ys*)) (combine xs (car ys*))]
          [else (concat/map xs
                            (lambda (x)
                              (map (lambda (y)
                                     (cons x y))
                                   (apply combine* ys*))))])))))


;List of all possible combinations of education, race, and sex.
(define combs (combine* ed-list race-list sex-list))


 
;List of combinations in the correct format for filter-table to work.
(define correct-format-combs
  (let ([proper-format ;Proper-format takes in a list and rearranges it so that it is of the correct format for
         (lambda (lst) ;   filter-table to work (described in documentation for filter-table)
           (append (list "46-65" "Private") lst (list "26-45")))])
    (map proper-format combs)))


;;; Procedure:
;;;   find-pos
;;; Parameters:
;;;   dataset, a list of lists
;;;   lst, a list
;;; Purpose:
;;;   to create a new list consisting of all the positions where lst appears in dataset
;;; Produces:
;;;  result, a list
;;; Pre-conditions:
;;;  [No additional]
;;; Post-conditions:
;;;  result is either null or a list of one number, or a list of multiple numbers
(define find-pos
  (lambda (dataset lst)
    (letrec ([find-pos-helper
              (lambda (dataset lst index indices-so-far)
                (cond
                  [(null? dataset)
                   indices-so-far]
                  [(equal? (car dataset) lst)
                   (find-pos-helper (cdr dataset) lst (+ index 1) (cons index indices-so-far))]
                  [else
                   (find-pos-helper (cdr dataset) lst (+ index 1) indices-so-far)]))])
      (find-pos-helper dataset lst 0 null))))



;;; Procedure:
;;;  chance-of-over-50k
;;; Parameters:
;;;  lst, a list of lists
;;; Purpose:
;;;  Produces a number that represents the percentage of individuals in lst that earn over 50k
;;; Produces:
;;;  result, a number
;;; Pre-conditions:
;;;  Each list in lst must also be present in wrangled-dataset. In other words, for each list in list (let's call this this-lst), (null? (find-pos wrangled-dataset this-lst)) must be #f.
;;; Post-conditions:
;;;  0<= result <= 100
(define chance-of-over-50k
  (lambda (lst)
    (letrec ([perc-helper ;Uses the indices from find-pos, finds the list(s) associated with that index from the wrangled dataset.
              (lambda (tbl lst-so-far) ;Creates a new list of all such lists.
                (if (null? tbl)
                    lst-so-far
                    (perc-helper (cdr tbl) (cons (list-ref wrangled-dataset (car tbl)) lst-so-far))))])
      (percentage (perc-helper (find-pos no-income lst) null)))))

;;; Procedure:
;;;  get-desc
;;; Parameters:
;;;  lst, a list
;;; Purpose:
;;;  gives the description of education level, race, sex of the individual
;;; Produces:
;;;  result, a string
;;; Pre-conditions:
;;;  lst must be in the format '(age wc ed r s hrs income) where each element is a string, and:
;;;    age is an element of age-list 
;;;    wc is an element of wc-list
;;;    ed is an element of ed-list
;;;    r is an element of race-list
;;;    s is an element of sex-list
;;;    hrs is an element of hrs-list
;;;    income is either ">50k" or "<=50k"
;;; Post-conditions:
;;;  result should have three words in the string where:
;;;    the first word is an element of ed-list
;;;    the second word is an element of race-list
;;;    the third word is an element of sex-list
(define get-desc
  (lambda (lst)
    (reduce string-append
            (append
             (list (list-ref lst 2) " ")
             (list (list-ref lst 3) " ")
             (list (list-ref lst 4))))))

;;; Procedure:
;;;  filter-combs
;;; Parameters:
;;;  combs, a list of lists
;;; Purpose:
;;;  Takes in a list of combinations of education, race, sex, then filters out the combinations
;;;     that are not present in our wrangled dataset.
;;; Produces:
;;;  result, a list of lists
;;; Pre-conditions:
;;;  Each list in combs must be in the format '(age wc ed r s hrs income) where each element is a string, and:
;;;    age is an element of age-list 
;;;    wc is an element of wc-list
;;;    ed is an element of ed-list
;;;    r is an element of race-list
;;;    s is an element of sex-list
;;;    hrs is an element of hrs-list
;;;    income is either ">50k" or "<=50k"
;;; Post-conditions:
;;;  For each list in result, (null? (find-pos wrangled-dataset lst)) is #f.
;;;  (length result) <= (length combs)
;;;  Each list in result is of the same format as the original inputted lists
(define filter-combs
  (lambda (combs)
    (letrec ([filter-combs-helper
              (lambda (combs lst-so-far)
                (cond [(null? combs)
                       lst-so-far]
                      [(null? (find-pos no-income (car combs)))
                       (filter-combs-helper (cdr combs) lst-so-far)]
                      [else
                       (filter-combs-helper (cdr combs) (cons (car combs) lst-so-far))]))])
      (filter-combs-helper combs null))))

;List of possible combinations of education, race, and  that match at least one person in the database
(define filtered-combs (filter-combs correct-format-combs))




;------------------------------------------
;-------------DATA VISUALIZATION-----------
;------------------------------------------

;;; Procedure:
;;;  plot-lst-helper
;;; Parameters:
;;;  individuals, a list of lists
;;;  lst-so-far, a list
;;; Purpose:
;;;  Takes in a list that has characteristics of an individual, creates a list
;;;     where the first element is the description of the individual's education level, race, and sex
;;;     and the second element is the percentage of individuals with such characteristics earning over 50k.
;;;  This list provides the correct format for plotting a discrete histogram.   
;;; Produces:
;;;  result, a list of lists
;;; Pre-conditions:
;;;  Each list in individual must be in the format '(age wc ed r s hrs income) where each element is a string, and:
;;;    age is an element of age-list 
;;;    wc is an element of wc-list
;;;    ed is an element of ed-list
;;;    r is an element of race-list
;;;    s is an element of sex-list
;;;    hrs is an element of hrs-list
;;;    income is either ">50k" or "<=50k"
;;; Post-conditions:
;;;  each list in result is in the format: '(desc probability) where:
;;;    desc is a string that contains three words
;;;    0 <= prob <= 100
(define plot-lst-helper
  (lambda (individuals lst-so-far)
    (if (null? individuals)
        lst-so-far
        (plot-lst-helper
         (cdr individuals)
         (cons (list (get-desc (car individuals)) (chance-of-over-50k (car individuals))) lst-so-far)))))


;Shows our final results after the wrangling and analysis
(define final-plot
  (plot (discrete-histogram (plot-lst-helper filtered-combs null))
        #:x-label "Education level, Race, and Sex"
        #:y-label "Percentage in dataset that earn >$50k"
        #:width 15000))
        
      


