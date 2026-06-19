(defsystem "authdog"
  :version "0.1.0"
  :author "Authdog Team"
  :license "MIT"
  :description "Official Common Lisp SDK for Authdog authentication and user management platform"
  :depends-on ("drakma" "cl-json" "cl-ppcre")
  :components ((:file "package")
               (:file "errors" :depends-on ("package"))
               (:file "types" :depends-on ("package"))
               (:file "client" :depends-on ("package" "errors" "types")))
  :in-order-to ((test-op (test-op "authdog/tests"))))

(defsystem "authdog/tests"
  :depends-on ("authdog" "fiveam")
  :components ((:file "tests"))
  :perform (test-op (o c) (symbol-call :fiveam :run! :authdog)))
