(defpackage #:mix-design-bs/qt-ui
  (:use #:cl+qt)
  (:export #:main))

(in-package #:mix-design-bs/qt-ui)
(in-readtable :qtools)

(define-widget main-window (QWidget)
  ())


;; Target Strength 
(define-subwidget (main-window target-strength)
	(q+:make-qlineedit main-window)
  (setf (q+:placeholder-text target-strength) "Target Compressive Strength")
  (setf (q+:validator target-strength) (q+:make-qdoublevalidator 5.0d0 50.0d0 4 main-window)))

;; (define-slot (main-window target-strength) ((name string))
;;   (declare (connected target-strength (text-edited string)))
;;   (q+:qmessagebox-information main-window "Greetings" (format NIL "Good s to you, ~a!" name)))


;;; Max Aggregate Size
(define-subwidget (main-window max-aggregate-size-slider)
	(q+:make-qslider main-window)
  (setf (q+::maximum max-aggregate-size-slider) 50)
  (setf (q+::minimum max-aggregate-size-slider) 5)

  (connect max-aggregate-size-slider "sliderMoved(int)"
  		   (lambda (int)
  				   (setf (q+:text max-aggregate-size)
  			 		 (format nil "~d" int)))))


(define-subwidget (main-window max-aggregate-size)
	(q+:make-qlineedit main-window)
  (setf (q+::placeholder-text max-aggregate-size) "Maximum Aggregate Size")
  (setf (q+:validator max-aggregate-size) (q+:make-qdoublevalidator 5.0d0 50.0d0 4 main-window))
  (connect max-aggregate-size "editingFinished()"
		   (lambda ()
			 (setf (q+::value max-aggregate-size-slider)
				   (or (parse-integer (q+:text max-aggregate-size) :junk-allowed t)
					   5)))))


;;; Calculate Button 
(define-subwidget (main-window go) (q+:make-qpushbutton "Go!" main-window))

(define-slot (main-window go) ()
  (declare (connected go (pressed)))
  (declare (connected target-strength (return-pressed)))
  )

(define-subwidget (main-window layout)
	(q+:make-qgridlayout main-window)
  (q+:add-widget layout target-strength 0 0 0)
  (q+:add-widget layout max-aggregate-size 1 0 0)
  (q+:add-widget layout max-aggregate-size-slider 1 1 0)
  (q+:add-widget layout go 2 0 0))

(defun main()
  (with-main-window (window 'main-window :name "Mix Design BS")
	))
