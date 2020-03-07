;;;; mix-design-bs.asd

(asdf:defsystem #:mix-design-bs
  :description "Describe mix-design-bs here"
  :author "Your Name <your.name@example.com>"
  :license  "Specify license here"
  :version "0.0.1"
  :serial t
  :depends-on (#:system-solver #:alexandria)
  :components ((:file "package")
               (:file "mix-design-bs")))


(asdf:defsystem #:mix-design-bs/web-ui
  :depends-on (#:mix-design-bs #:ningle #:cl-json #:clack)
  :components ((:file "web-ui")))



(asdf:defsystem #:mix-design-bs/qt-ui
  :depends-on (#:mix-design-bs #:qtools #:qtcore #:qtgui)
  :components ((:file "qt-gui")))

