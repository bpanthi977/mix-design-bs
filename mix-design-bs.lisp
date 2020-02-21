;;;; mix-design-bs.lisp

(in-package #:mix-design-bs)

(defparameter *table20.46*
  (make-instance 'table2d
				 :indices '((1 3 5) ;; cement type 
							(1 2))	;; 1 = Crushed , 2 = Uncrushed
				 ;; strength for w/c = 0.5
				 :data '((42 42)
						 (55 48) 
						 (49 nil))						 
				 :interpolation '(nil nil)))
(print "NOTE : For crushed agg, strength at w/c = 0.5 is assumed to be 42 (Table 20.46)")

(defparameter *graph20.10*
  (make-instance 'table2d 
				 :indices '((1 2 3 4 5 6 7 8 9) ;; curve number
							(0.3 0.4	0.5	0.6	0.7	0.8	0.9)) ;; w/c
				 ;; strengths
				 :data  '((15	10	7	3	2	3	3)
						  (25	17	11	8	6	5	5)
						  (37	25	15	11	9	7	6)
						  (45	32	21	14	11	9	7)
						  (60	45	30	22	18	13	10)
						  (70	58	40	30	23	18	13)
						  (79	68	50	39	30	24	19)
						  (90	78	60	48	38	31	26)
						  (99	89	71	57	47	39	33))))


(defparameter *table20.47-crushed*
  (make-instance 'table2d
				 :indices '((10 20 30) ;; max agg size
							(5 20 45 120)) ;; average slump
				 ;; water content
				 :data '((180 205 230 250) 
						 (170 190 210 225)
						 (155 175 190 205))))

(defparameter *table20.47-uncrushed*
  (make-instance 'table2d
				 :indices '((10 20 30) ;; max agg size
							(5 20 45 120)) ;; average slump
				 ;; water content
				 :data '((150 180 205 225)
						 (135 160 180 195)
						 (115 140 160 175))))

(defparameter *graph20.11*
  (make-instance 'table2d
				 :indices '((100 260) ;; free watercontent
							(2.4 2.5 2.6 2.7 2.8 2.9)) ;; bulk sp gr of aggregate
				 ;; wet density of concrete
				 :data '((2300 2380 2470 2550 2640 2720)
						 (2150 2220 2300 2350 2410 2480))))

(defparameter *graph-fa*
  (make-instance 'system-solver::tableN
				 :indices '((10 20 40) ;; max agg size
							(5 20 45 120) ;; avg slump
							(.2 .8) ;; free w/c
							(100 80 60 40 15)) ;; Grading zone
				 ;; percentage of fine aggregate
				 :data  '((;; 10 
						   (;; 5 
							(22 26 32 38 49) ;; 0.2
							(30 34 42 52 65)) ;; 0.8
						   (;; 20
							(25 28 34 39 50)
							(31 35 43 53 66))
						   (;; 45
							(25 30 38 42 55)
							(33 38 45 55 70))
						   (;; 120
							(29 33 40 49 60)
							(37 42 50 62 78)))
						  (;; 20
						   (;; 5
							(17 19 23 27 35)
							(24 28 34 40 51))
						   (;; 20
							(18 20 24 30 38)
							(25 30 35 43 54))
						   (;; 45
							(20 23 28 32 41)
							(28 31 28 46 58))
						   (;; 120
							(23 26 30 38 48)
							(30 36 43 51 64)))
						  (;; 40
						   (;; 5
							(13 15 18 22 29)
							(20 24 29 36 44))
						   (;; 20
							(15 17 20 24 30)
							(21 25 30 38 47))
						   (;; 45
							(17 20 23 29 35)
							(23 26 32 40 51))
						   (;; 120
							(20 23 27 33 40)
							(2 32 37 46 58))))))

(defclass concrete ()
  ((crushed-coarse-agg :type boolean :initarg :crushed-coarse-agg)
   (cement-type :type integer :initarg :cement-type
				:documentation
				"1 = Ordinary Portland Cement 
5 = Sulphate Resisting Cement
3 = Rapid Hardening Cement")
   (target-f :type float :initarg :target-f)
   (max-agg-size :type float :initarg :max-agg-size)
   (average-slump :type float :initarg :average-slump)
   (agg-spg :type float :initform nil :initarg :agg-spg :documentation "Avg. sp. gravity of aggregates")
   (w/c :type float)
   (wet-density :type float)
   (water-content :type float)
   (grading% :type float :initarg :grading%)
   (%fa :type float)
   (cement :type float)
   (coarse :type float)
   (fine :type float)
   (ratio :type list)))

(defun find-w/c (s-target s0.5 table)
  (with-slots ((n index1) (w/c index2) (s table-param)) table
	(setf (value w/c) 0.5
		  (value s) s0.5)
	(solve-relation n table)
	(setf (value s) s-target)
	(solve-relation w/c table)))

(defun design (concrete)
  (with-slots (w/c cement-type
			   target-f crushed-coarse-agg max-agg-size
			   average-slump water-content wet-density
			   agg-spg ratio
			   %fa grading% cement coarse fine)
	  concrete
	;;find w/c

	(setf w/c 
		  (find-w/c target-f
					;; strength at 0.5 w/c 
					(interpolate-table2d cement-type
										 (if crushed-coarse-agg 1 2)
										 *table20.46*)
					*graph20.10*))
	;; find watercontent
	(setf water-content
		  (interpolate-table2d max-agg-size average-slump
							   (if crushed-coarse-agg
								   *table20.47-crushed*
								   *table20.47-uncrushed*)))
	;; durability checks
	;; none
	(print "NOTE: For durability max w/c is set to 0.55")
	(setf w/c (min w/c 0.55))
	;; cement content
	(setf cement (/ water-content w/c))

	;; wet density of concrete
	(setf agg-spg (if agg-spg
					  agg-spg
					  (if crushed-coarse-agg
						  2.7 2.6)))
	(setf wet-density
		  (interpolate-table2d water-content
							  agg-spg
							  *graph20.11*))

	;; Percentage of fine in total aggregate content
	(setf %fa
		  (interpolate-tablen (list max-agg-size average-slump w/c grading%)
							  *graph-fa*))
	;; Fine and Coarse agg content 
	(let ((aggregate (- wet-density cement water-content)))
	  (setf fine (* aggregate %fa 1/100)
			coarse (- aggregate fine)))
	;; Design Mix Ratio
	(setf ratio
		  (list  1
				 (/ fine cement)
				 (/ coarse cement)
				 w/c))
	concrete))
   
(defun tt ()
   (let ((c (make-instance 'concrete
						  :crushed-coarse-agg t
						  :cement-type 1
						  :target-f 26.6
						  :max-agg-size 20
						  :average-slump 20
						  :grading% 58.29
						  :agg-spg 2.576)))
	 (design c)
	 c))
