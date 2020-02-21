(in-package :mix-design-bs)

(defparameter *base-dir* *load-truename*)
(defparameter *app* (make-instance 'ningle:<app>))
(defvar *server* nil)

(defun static-file (file)
  (merge-pathnames file *base-dir*))

(setf (ningle:route *app* "/")
	  (static-file "static/index.html"))

;; Route the files in static folder 
(setf (ningle:route *app* "/static/*")
	  (lambda (params)
		(let ((file (first (cdr (assoc :splat params)))))
		  (static-file (format nil "static/~a" file)))))

(defun json-response (json-string) 
  (setf (lack.response:response-headers ningle:*response*)
		(append (lack.response:response-headers ningle:*response*)
				(list :content-type "application/json")))
  json-string)

(setf (ningle:route *app* "/api/compute" :method :post)
	  (lambda (params)
		(compute params)))

(defun compute (params)
  (macrolet ((get-param (name)
			   `(cdr (assoc ,name params :test #'string-equal))))
	(print params)
	(let ((c (make-instance 'concrete
							:crushed-coarse-agg  (get-param "crushedCoarseAgg")
							:cement-type (get-param "cementType")
							:target-f (get-param "targetF")
							:max-agg-size (get-param "maxAggSize")
							:average-slump (get-param "averageSlump")
							:grading% (get-param "grading")
							:agg-spg (get-param "aggSpg"))))
	  (ignore-errors (design c))
	  (cl-json:encode-json-to-string c))))

(defun start ()
  (unless *server*  
	(setf *server* (clack:clackup *app* :port 5678))))

(defun stop ()
  (when *server*
	(clack:stop *server*)
	(setf *server* nil)))

(start)


