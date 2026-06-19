# Authdog Common Lisp SDK

Official Common Lisp SDK for Authdog authentication and user management platform.

## Installation

### Quicklisp

```lisp
(ql:quickload :authdog)
```

### Manual Installation

1. Clone the repository
2. Add the path to your ASDF registry
3. Load the system:

```lisp
(asdf:load-system :authdog)
```

## Requirements

- Common Lisp implementation (SBCL, CCL, ECL, etc.)
- ASDF (usually included)
- Drakma HTTP client
- cl-json JSON library
- cl-ppcre regular expressions

## Quick Start

```lisp
(ql:quickload :authdog)
(use-package :authdog)

;; Initialize the client
(defvar *client* (make-authdog-client "https://api.authdog.com"))

;; Get user information
(handler-case
    (let ((user-info (get-user-info *client* "your-access-token")))
      (format t "User: ~A~%" (user-display-name (user-info-response-user user-info))))
  (authentication-error (e)
    (format t "Authentication failed: ~A~%" (authdog-error-message e)))
  (api-error (e)
    (format t "API error: ~A~%" (authdog-error-message e))))
```

## Configuration

### Basic Configuration

```lisp
(defvar *client* (make-authdog-client "https://api.authdog.com"))
```

### With API Key

```lisp
(defvar *client* (make-authdog-client "https://api.authdog.com" 
                                     :api-key "your-api-key"))
```

### Custom Timeout

```lisp
(defvar *client* (make-authdog-client "https://api.authdog.com" 
                                     :api-key "your-api-key"
                                     :timeout 30))
```

## API Reference

### make-authdog-client

```lisp
(make-authdog-client base-url &key api-key timeout)
```

Create a new Authdog client.

**Parameters:**
- `base-url`: The base URL of the Authdog API
- `api-key`: Optional API key for authentication
- `timeout`: Request timeout in seconds (default: 10)

### get-user-info

```lisp
(get-user-info client access-token)
```

Get user information using an access token.

**Parameters:**
- `client`: The Authdog client
- `access-token`: The access token for authentication

**Returns:** `user-info-response` object containing user information

**Signals:**
- `authentication-error`: When authentication fails (401 responses)
- `api-error`: When API request fails

## Data Types

### user-info-response

```lisp
(defclass user-info-response ()
  ((meta :initarg :meta :reader user-info-response-meta)
   (session :initarg :session :reader user-info-response-session)
   (user :initarg :user :reader user-info-response-user)))
```

### user

```lisp
(defclass user ()
  ((id :initarg :id :reader user-id)
   (external-id :initarg :external-id :reader user-external-id)
   (user-name :initarg :user-name :reader user-user-name)
   (display-name :initarg :display-name :reader user-display-name)
   (nick-name :initarg :nick-name :reader user-nick-name)
   (profile-url :initarg :profile-url :reader user-profile-url)
   (title :initarg :title :reader user-title)
   (user-type :initarg :user-type :reader user-user-type)
   (preferred-language :initarg :preferred-language :reader user-preferred-language)
   (locale :initarg :locale :reader user-locale)
   (timezone :initarg :timezone :reader user-timezone)
   (active :initarg :active :reader user-active)
   (names :initarg :names :reader user-names)
   (photos :initarg :photos :reader user-photos)
   (phone-numbers :initarg :phone-numbers :reader user-phone-numbers)
   (addresses :initarg :addresses :reader user-addresses)
   (emails :initarg :emails :reader user-emails)
   (verifications :initarg :verifications :reader user-verifications)
   (provider :initarg :provider :reader user-provider)
   (created-at :initarg :created-at :reader user-created-at)
   (updated-at :initarg :updated-at :reader user-updated-at)
   (environment-id :initarg :environment-id :reader user-environment-id)))
```

### names

```lisp
(defclass names ()
  ((id :initarg :id :reader names-id)
   (formatted :initarg :formatted :reader names-formatted)
   (family-name :initarg :family-name :reader names-family-name)
   (given-name :initarg :given-name :reader names-given-name)
   (middle-name :initarg :middle-name :reader names-middle-name)
   (honorific-prefix :initarg :honorific-prefix :reader names-honorific-prefix)
   (honorific-suffix :initarg :honorific-suffix :reader names-honorific-suffix)))
```

### email

```lisp
(defclass email ()
  ((id :initarg :id :reader email-id)
   (value :initarg :value :reader email-value)
   (type :initarg :type :reader email-type)))
```

### photo

```lisp
(defclass photo ()
  ((id :initarg :id :reader photo-id)
   (value :initarg :value :reader photo-value)
   (type :initarg :type :reader photo-type)))
```

### verification

```lisp
(defclass verification ()
  ((id :initarg :id :reader verification-id)
   (email :initarg :email :reader verification-email)
   (verified :initarg :verified :reader verification-verified)
   (created-at :initarg :created-at :reader verification-created-at)
   (updated-at :initarg :updated-at :reader verification-updated-at)))
```

## Error Handling

The SDK provides structured error handling with specific condition types:

### authentication-error

Signaled when authentication fails (401 responses).

```lisp
(handler-case
    (get-user-info client "invalid-token")
  (authentication-error (e)
    (format t "Authentication failed: ~A~%" (authdog-error-message e))))
```

### api-error

Signaled when API requests fail.

```lisp
(handler-case
    (get-user-info client "valid-token")
  (api-error (e)
    (format t "API error: ~A~%" (authdog-error-message e))))
```

### authdog-error

Base error condition for all SDK errors.

```lisp
(handler-case
    (get-user-info client "token")
  (authdog-error (e)
    (format t "Authdog error: ~A~%" (authdog-error-message e))))
```

## Examples

### Basic Usage

```lisp
(ql:quickload :authdog)
(use-package :authdog)

(defun main ()
  (let ((client (make-authdog-client "https://api.authdog.com")))
    (handler-case
        (let ((user-info (get-user-info client "your-access-token")))
          (let ((user (user-info-response-user user-info)))
            (format t "User ID: ~A~%" (user-id user))
            (format t "Display Name: ~A~%" (user-display-name user))
            (format t "Provider: ~A~%" (user-provider user))
            
            (when (user-emails user)
              (format t "Email: ~A~%" (email-value (first (user-emails user)))))))
      (authentication-error (e)
        (format t "Authentication failed: ~A~%" (authdog-error-message e)))
      (api-error (e)
        (format t "API error: ~A~%" (authdog-error-message e))))))

(main)
```

### Error Handling

```lisp
(defun get-user-with-error-handling (client access-token)
  (handler-case
      (get-user-info client access-token)
    (authentication-error (e)
      (format t "Authentication failed: ~A~%" (authdog-error-message e))
      nil)
    (api-error (e)
      (format t "API error: ~A~%" (authdog-error-message e))
      nil)))
```

### Service Class Example

```lisp
(defclass user-service ()
  ((client :initarg :client :reader user-service-client)))

(defun make-user-service (base-url &key api-key timeout)
  (make-instance 'user-service
                 :client (make-authdog-client base-url 
                                             :api-key api-key 
                                             :timeout timeout)))

(defun get-user-data (service access-token)
  (handler-case
      (let ((user-info (get-user-info (user-service-client service) access-token)))
        (let ((user (user-info-response-user user-info)))
          (list :id (user-id user)
                :display-name (user-display-name user)
                :email (when (user-emails user)
                         (email-value (first (user-emails user))))
                :provider (user-provider user)
                :active (user-active user))))
    (authentication-error (e)
      (error "Authentication failed: ~A" (authdog-error-message e)))
    (api-error (e)
      (error "API error: ~A" (authdog-error-message e)))))

;; Usage
(defvar *service* (make-user-service "https://api.authdog.com"))
(defvar *user-data* (get-user-data *service* "your-access-token"))
```

### Hunchentoot Integration

```lisp
(defpackage :my-web-app
  (:use :cl :hunchentoot :authdog))

(in-package :my-web-app)

(defvar *authdog-client* (make-authdog-client "https://api.authdog.com"))

(define-easy-handler (user-info :uri "/user/info") (access-token)
  (setf (content-type*) "application/json")
  (handler-case
      (let ((user-info (get-user-info *authdog-client* access-token)))
        (let ((user (user-info-response-user user-info)))
          (json:encode-json-to-string
           (list :id (user-id user)
                 :display-name (user-display-name user)
                 :email (when (user-emails user)
                          (email-value (first (user-emails user))))
                 :provider (user-provider user)))))
    (authentication-error (e)
      (setf (return-code*) 401)
      (json:encode-json-to-string (list :error "Authentication failed")))
    (api-error (e)
      (setf (return-code*) 400)
      (json:encode-json-to-string (list :error (authdog-error-message e))))))

;; Start server
(defvar *server* (start (make-instance 'easy-acceptor :port 8080)))
```

### Clack Integration

```lisp
(defpackage :my-clack-app
  (:use :cl :clack :authdog))

(in-package :my-clack-app)

(defvar *authdog-client* (make-authdog-client "https://api.authdog.com"))

(defun app (env)
  (let ((path-info (getf env :path-info)))
    (cond
      ((string= path-info "/user/info")
       (let ((access-token (getf (getf env :query) "access_token")))
         (handler-case
             (let ((user-info (get-user-info *authdog-client* access-token)))
               (let ((user (user-info-response-user user-info)))
                 `(200 (:content-type "application/json")
                       (,(json:encode-json-to-string
                          (list :id (user-id user)
                                :display-name (user-display-name user)
                                :email (when (user-emails user)
                                         (email-value (first (user-emails user))))
                                :provider (user-provider user)))))))
           (authentication-error (e)
             `(401 (:content-type "application/json")
                   (,(json:encode-json-to-string (list :error "Authentication failed")))))
           (api-error (e)
             `(400 (:content-type "application/json")
                   (,(json:encode-json-to-string (list :error (authdog-error-message e)))))))))
      (t `(404 (:content-type "text/plain") ("Not Found"))))))

;; Start server
(clackup #'app :port 8080)
```

## Building and Testing

### Load the System

```lisp
(ql:quickload :authdog)
```

### Run Tests

```lisp
(ql:quickload :authdog/tests)
(asdf:test-system :authdog)
```

### Build Documentation

```lisp
(ql:quickload :authdog)
(documentation 'authdog-client 'type)
```

## Development

### Requirements

- Common Lisp implementation (SBCL recommended)
- ASDF
- Drakma HTTP client
- cl-json JSON library
- cl-ppcre regular expressions
- FiveAM (for testing)

### Code Style

- Follow Common Lisp Style Guide
- Use `cl-format` for formatting
- Use meaningful variable and function names
- Use `defclass` for data structures
- Use `handler-case` for error handling
- Prefer `let` over `setf` for local bindings

### Running Tests

```lisp
# Load test system
(ql:quickload :authdog/tests)

# Run all tests
(asdf:test-system :authdog)

# Run specific test
(fiveam:run! :authdog)
```

## License

MIT License - see [LICENSE](../LICENSE) for details.
