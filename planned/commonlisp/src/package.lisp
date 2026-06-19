(defpackage :authdog
  (:use :cl)
  (:export
   ;; Client
   :make-authdog-client
   :authdog-client
   :get-user-info
   
   ;; Types
   :user-info-response
   :meta
   :session
   :user
   :names
   :photo
   :email
   :verification
   
   ;; Errors
   :authdog-error
   :authentication-error
   :api-error))
