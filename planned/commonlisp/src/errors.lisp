(in-package :authdog)

(define-condition authdog-error (error)
  ((message :initarg :message :reader authdog-error-message))
  (:documentation "Base error condition for all Authdog SDK errors")
  (:report (lambda (condition stream)
             (format stream "Authdog error: ~A" (authdog-error-message condition)))))

(define-condition authentication-error (authdog-error)
  ()
  (:documentation "Error condition for authentication failures")
  (:report (lambda (condition stream)
             (format stream "Authentication failed: ~A" (authdog-error-message condition)))))

(define-condition api-error (authdog-error)
  ()
  (:documentation "Error condition for API request failures")
  (:report (lambda (condition stream)
             (format stream "API error: ~A" (authdog-error-message condition)))))
