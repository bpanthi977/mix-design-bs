;;;; mix-design-bs.asd

(asdf:defsystem #:mix-design-bs
  :description "Describe mix-design-bs here"
  :author "Your Name <your.name@example.com>"
  :license  "Specify license here"
  :version "0.0.1"
  :serial t
  :depends-on (#:system-solver #:alexandria #:ningle #:cl-json #:clack)
  :components ((:file "package")
               (:file "mix-design-bs")
			   (:file "web-ui")))
