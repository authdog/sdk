(in-package :authdog)

(defclass authdog-client ()
  ((base-url :initarg :base-url :reader authdog-client-base-url)
   (api-key :initarg :api-key :reader authdog-client-api-key)
   (timeout :initarg :timeout :reader authdog-client-timeout))
  (:documentation "Main client for interacting with Authdog API"))

(defun make-authdog-client (base-url &key api-key timeout)
  "Create a new Authdog client"
  (make-instance 'authdog-client
                 :base-url (string-right-trim "/" base-url)
                 :api-key api-key
                 :timeout (or timeout 10)))

(defun get-user-info (client access-token)
  "Get user information using an access token"
  (let* ((url (format nil "~A/v1/userinfo" (authdog-client-base-url client)))
         (headers (list (cons "Content-Type" "application/json")
                        (cons "User-Agent" "authdog-commonlisp-sdk/0.1.0")
                        (cons "Authorization" (format nil "Bearer ~A" access-token))))
         (response (drakma:http-request url
                                        :method :get
                                        :additional-headers headers
                                        :timeout (authdog-client-timeout client))))
    (handler-case
        (let ((status (first response))
              (body (second response)))
          (cond
            ((= status 200)
             (parse-user-info-response body))
            ((= status 401)
             (error 'authentication-error :message "Unauthorized - invalid or expired token"))
            ((= status 500)
             (let ((error-data (ignore-errors (json:decode-json-from-string body))))
               (if (and error-data (assoc :error error-data))
                   (let ((error-message (cdr (assoc :error error-data))))
                     (cond
                       ((string= error-message "GraphQL query failed")
                        (error 'api-error :message "GraphQL query failed"))
                       ((string= error-message "Failed to fetch user info")
                        (error 'api-error :message "Failed to fetch user info"))
                       (t (error 'api-error :message (format nil "HTTP error 500: ~A" body)))))
                   (error 'api-error :message (format nil "HTTP error 500: ~A" body)))))
            (t (error 'api-error :message (format nil "HTTP error ~A: ~A" status body)))))
      (error (e)
        (error 'api-error :message (format nil "Request failed: ~A" e))))))

(defun parse-user-info-response (json-string)
  "Parse JSON response into user-info-response object"
  (let ((data (json:decode-json-from-string json-string)))
    (make-instance 'user-info-response
                   :meta (parse-meta (assoc :meta data))
                   :session (parse-session (assoc :session data))
                   :user (parse-user (assoc :user data)))))

(defun parse-meta (meta-data)
  "Parse meta data from JSON"
  (let ((meta (cdr meta-data)))
    (make-instance 'meta
                   :code (cdr (assoc :code meta))
                   :message (cdr (assoc :message meta)))))

(defun parse-session (session-data)
  "Parse session data from JSON"
  (let ((session (cdr session-data)))
    (make-instance 'session
                   :remaining-seconds (cdr (assoc :remaining-seconds session)))))

(defun parse-names (names-data)
  "Parse names data from JSON"
  (let ((names (cdr names-data)))
    (make-instance 'names
                   :id (cdr (assoc :id names))
                   :formatted (cdr (assoc :formatted names))
                   :family-name (cdr (assoc :family-name names))
                   :given-name (cdr (assoc :given-name names))
                   :middle-name (cdr (assoc :middle-name names))
                   :honorific-prefix (cdr (assoc :honorific-prefix names))
                   :honorific-suffix (cdr (assoc :honorific-suffix names)))))

(defun parse-photo (photo-data)
  "Parse photo data from JSON"
  (make-instance 'photo
                 :id (cdr (assoc :id photo-data))
                 :value (cdr (assoc :value photo-data))
                 :type (cdr (assoc :type photo-data))))

(defun parse-email (email-data)
  "Parse email data from JSON"
  (make-instance 'email
                 :id (cdr (assoc :id email-data))
                 :value (cdr (assoc :value email-data))
                 :type (cdr (assoc :type email-data))))

(defun parse-verification (verification-data)
  "Parse verification data from JSON"
  (make-instance 'verification
                 :id (cdr (assoc :id verification-data))
                 :email (cdr (assoc :email verification-data))
                 :verified (cdr (assoc :verified verification-data))
                 :created-at (cdr (assoc :created-at verification-data))
                 :updated-at (cdr (assoc :updated-at verification-data))))

(defun parse-user (user-data)
  "Parse user data from JSON"
  (let ((user (cdr user-data)))
    (make-instance 'user
                   :id (cdr (assoc :id user))
                   :external-id (cdr (assoc :external-id user))
                   :user-name (cdr (assoc :user-name user))
                   :display-name (cdr (assoc :display-name user))
                   :nick-name (cdr (assoc :nick-name user))
                   :profile-url (cdr (assoc :profile-url user))
                   :title (cdr (assoc :title user))
                   :user-type (cdr (assoc :user-type user))
                   :preferred-language (cdr (assoc :preferred-language user))
                   :locale (cdr (assoc :locale user))
                   :timezone (cdr (assoc :timezone user))
                   :active (cdr (assoc :active user))
                   :names (parse-names (assoc :names user))
                   :photos (mapcar #'parse-photo (cdr (assoc :photos user)))
                   :phone-numbers (cdr (assoc :phone-numbers user))
                   :addresses (cdr (assoc :addresses user))
                   :emails (mapcar #'parse-email (cdr (assoc :emails user)))
                   :verifications (mapcar #'parse-verification (cdr (assoc :verifications user)))
                   :provider (cdr (assoc :provider user))
                   :created-at (cdr (assoc :created-at user))
                   :updated-at (cdr (assoc :updated-at user))
                   :environment-id (cdr (assoc :environment-id user)))))
