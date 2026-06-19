(in-package :authdog)

(def-suite authdog)
(in-suite authdog)

;;; Client tests
(test make-authdog-client-with-base-url
  (let ((client (make-authdog-client "https://api.authdog.com")))
    (is (string= (authdog-client-base-url client) "https://api.authdog.com"))
    (is (null (authdog-client-api-key client)))
    (is (= (authdog-client-timeout client) 10))))

(test make-authdog-client-with-options
  (let ((client (make-authdog-client "https://api.authdog.com" 
                                     :api-key "test-key"
                                     :timeout 5)))
    (is (string= (authdog-client-base-url client) "https://api.authdog.com"))
    (is (string= (authdog-client-api-key client) "test-key"))
    (is (= (authdog-client-timeout client) 5))))

(test make-authdog-client-trims-trailing-slash
  (let ((client (make-authdog-client "https://api.authdog.com/")))
    (is (string= (authdog-client-base-url client) "https://api.authdog.com"))))

;;; Type parsing tests
(test parse-meta
  (let* ((data '((:code . 200) (:message . "Success")))
         (meta-data (cons :meta data))
         (meta (parse-meta meta-data)))
    (is (= (meta-code meta) 200))
    (is (string= (meta-message meta) "Success"))))

(test parse-session
  (let* ((data '((:remaining-seconds . 3600)))
         (session-data (cons :session data))
         (session (parse-session session-data)))
    (is (= (session-remaining-seconds session) 3600))))

(test parse-names
  (let* ((data '((:id . "name_123")
                 (:formatted . "John Doe")
                 (:family-name . "Doe")
                 (:given-name . "John")
                 (:middle-name . "William")
                 (:honorific-prefix . "Mr.")
                 (:honorific-suffix . "Jr.")))
         (names-data (cons :names data))
         (names (parse-names names-data)))
    (is (string= (names-id names) "name_123"))
    (is (string= (names-formatted names) "John Doe"))
    (is (string= (names-family-name names) "Doe"))
    (is (string= (names-given-name names) "John"))
    (is (string= (names-middle-name names) "William"))
    (is (string= (names-honorific-prefix names) "Mr."))
    (is (string= (names-honorific-suffix names) "Jr."))))

(test parse-email
  (let* ((data '((:id . "email_123")
                 (:value . "john@example.com")
                 (:type . "work")))
         (email (parse-email data)))
    (is (string= (email-id email) "email_123"))
    (is (string= (email-value email) "john@example.com"))
    (is (string= (email-type email) "work"))))

(test parse-verification
  (let* ((data '((:id . "verification_123")
                 (:email . "john@example.com")
                 (:verified . t)
                 (:created-at . "2023-01-01T00:00:00Z")
                 (:updated-at . "2023-01-02T00:00:00Z")))
         (verification (parse-verification data)))
    (is (string= (verification-id verification) "verification_123"))
    (is (string= (verification-email verification) "john@example.com"))
    (is (verification-verified verification))
    (is (string= (verification-created-at verification) "2023-01-01T00:00:00Z"))
    (is (string= (verification-updated-at verification) "2023-01-02T00:00:00Z"))))

(test parse-user-basic
  (let* ((data '((:id . "user_123")
                 (:external-id . "ext_123")
                 (:user-name . "johndoe")
                 (:display-name . "John Doe")
                 (:provider . "authdog")
                 (:locale . "en_US")
                 (:active . t)
                 (:names . ((:id . "name_123")
                           (:formatted . "John Doe")
                           (:family-name . "Doe")
                           (:given-name . "John")))
                 (:emails . ((:id . "email_123")
                            (:value . "john@example.com")
                            (:type . "work")))
                 (:photos . nil)
                 (:phone-numbers . nil)
                 (:addresses . nil)
                 (:verifications . nil)
                 (:created-at . "2023-01-01T00:00:00Z")
                 (:updated-at . "2023-01-02T00:00:00Z")
                 (:environment-id . "env_123")))
         (user-data (cons :user data))
         (user (parse-user user-data)))
    (is (string= (user-id user) "user_123"))
    (is (string= (user-external-id user) "ext_123"))
    (is (string= (user-user-name user) "johndoe"))
    (is (string= (user-display-name user) "John Doe"))
    (is (string= (user-provider user) "authdog"))
    (is (user-active user))
    (is (= (length (user-emails user)) 1))))

;;; Error condition tests
(test authentication-error-condition
  (signals authentication-error
    (error 'authentication-error :message "Unauthorized")))

(test api-error-condition
  (signals api-error
    (error 'api-error :message "API Error")))

(test authdog-error-message
  (let ((error (make-condition 'api-error :message "Test message")))
    (is (string= (authdog-error-message error) "Test message"))))
