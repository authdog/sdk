# Authdog Clojure SDK

Official Clojure SDK for Authdog authentication and user management platform.

## Installation

### Leiningen

Add the following dependency to your `project.clj`:

```clojure
[authdog "0.1.0"]
```

### Clojure CLI

Add the following dependency to your `deps.edn`:

```clojure
{authdog {:mvn/version "0.1.0"}}
```

## Requirements

- Clojure 1.11 or higher
- clj-http HTTP client
- Cheshire JSON library

## Quick Start

```clojure
(require '[authdog.core :as authdog]
         '[authdog.exceptions :as ex])

;; Initialize the client
(def client (authdog/make-client "https://api.authdog.com"))

;; Get user information
(try
  (let [user-info (authdog/get-user-info client "your-access-token")]
    (println "User:" (:display-name (:user user-info))))
  (catch clojure.lang.ExceptionInfo e
    (cond
      (ex/authentication-error? e)
      (println "Authentication failed:" (.getMessage e))
      
      (ex/api-error? e)
      (println "API error:" (.getMessage e)))))
```

## Configuration

### Basic Configuration

```clojure
(def client (authdog/make-client "https://api.authdog.com"))
```

### With API Key

```clojure
(def client (authdog/make-client "https://api.authdog.com" 
                                 {:api-key "your-api-key"}))
```

### Custom Timeout

```clojure
(def client (authdog/make-client "https://api.authdog.com" 
                                 {:api-key "your-api-key"
                                  :timeout 30000}))
```

## API Reference

### make-client

```clojure
(make-client base-url)
(make-client base-url options)
```

Create a new Authdog client.

**Parameters:**
- `base-url`: The base URL of the Authdog API
- `options`: Optional configuration map with keys:
  - `:api-key` - Optional API key for authentication
  - `:timeout` - Request timeout in milliseconds (default: 10000)

### get-user-info

```clojure
(get-user-info client access-token)
```

Get user information using an access token.

**Parameters:**
- `client`: The Authdog client
- `access-token`: The access token for authentication

**Returns:** Map containing user information

**Throws:**
- `clojure.lang.ExceptionInfo` with `:authentication-error` type when authentication fails
- `clojure.lang.ExceptionInfo` with `:api-error` type when API request fails

## Data Types

### User Info Response

```clojure
{:meta {:code 200
        :message "Success"}
 :session {:remaining-seconds 56229}
 :user {:id "user-id"
        :external-id "external-id"
        :user-name "username"
        :display-name "Display Name"
        :nick-name nil
        :profile-url nil
        :title nil
        :user-type nil
        :preferred-language nil
        :locale "en"
        :timezone nil
        :active true
        :names {:id "name-id"
                :formatted nil
                :family-name "Last"
                :given-name "First"
                :middle-name nil
                :honorific-prefix nil
                :honorific-suffix nil}
        :photos [{:id "photo-id"
                  :value "https://example.com/photo.jpg"
                  :type "photo"}]
        :phone-numbers []
        :addresses []
        :emails [{:id "email-id"
                  :value "email@example.com"
                  :type nil}]
        :verifications [{:id "verification-id"
                         :email "email@example.com"
                         :verified true
                         :created-at "2024-01-01T00:00:00Z"
                         :updated-at "2024-01-01T00:00:00Z"}]
        :provider "google-oauth20"
        :created-at "2024-01-01T00:00:00Z"
        :updated-at "2024-01-01T00:00:00Z"
        :environment-id "env-id"}}
```

## Error Handling

The SDK provides structured error handling with specific exception types:

### Authentication Error

```clojure
(try
  (authdog/get-user-info client "invalid-token")
  (catch clojure.lang.ExceptionInfo e
    (when (ex/authentication-error? e)
      (println "Authentication failed:" (.getMessage e)))))
```

### API Error

```clojure
(try
  (authdog/get-user-info client "valid-token")
  (catch clojure.lang.ExceptionInfo e
    (when (ex/api-error? e)
      (println "API error:" (.getMessage e)))))
```

### General Error Handling

```clojure
(try
  (authdog/get-user-info client "token")
  (catch clojure.lang.ExceptionInfo e
    (when (ex/authdog-error? e)
      (println "Authdog error:" (.getMessage e)))))
```

## Examples

### Basic Usage

```clojure
(require '[authdog.core :as authdog]
         '[authdog.exceptions :as ex])

(defn main []
  (let [client (authdog/make-client "https://api.authdog.com")]
    (try
      (let [user-info (authdog/get-user-info client "your-access-token")
            user (:user user-info)]
        (println "User ID:" (:id user))
        (println "Display Name:" (:display-name user))
        (println "Provider:" (:provider user))
        
        (when-let [email (first (:emails user))]
          (println "Email:" (:value email))))
      (catch clojure.lang.ExceptionInfo e
        (cond
          (ex/authentication-error? e)
          (println "Authentication failed:" (.getMessage e))
          
          (ex/api-error? e)
          (println "API error:" (.getMessage e)))))))

(main)
```

### Error Handling

```clojure
(defn get-user-with-error-handling [client access-token]
  (try
    (authdog/get-user-info client access-token)
    (catch clojure.lang.ExceptionInfo e
      (cond
        (ex/authentication-error? e)
        (do (println "Authentication failed:" (.getMessage e))
            nil)
        
        (ex/api-error? e)
        (do (println "API error:" (.getMessage e))
            nil)))))
```

### Service Class Example

```clojure
(defrecord UserService [client])

(defn make-user-service [base-url & {:keys [api-key timeout]}]
  (->UserService (authdog/make-client base-url 
                                      {:api-key api-key 
                                       :timeout timeout})))

(defn get-user-data [service access-token]
  (try
    (let [user-info (authdog/get-user-info (:client service) access-token)
          user (:user user-info)]
      {:id (:id user)
       :display-name (:display-name user)
       :email (when-let [email (first (:emails user))]
                (:value email))
       :provider (:provider user)
       :active (:active user)})
    (catch clojure.lang.ExceptionInfo e
      (cond
        (ex/authentication-error? e)
        (throw (Exception. (str "Authentication failed: " (.getMessage e))))
        
        (ex/api-error? e)
        (throw (Exception. (str "API error: " (.getMessage e))))))))

;; Usage
(def service (make-user-service "https://api.authdog.com"))
(def user-data (get-user-data service "your-access-token"))
```

### Ring Handler Example

```clojure
(require '[ring.util.response :as response]
         '[compojure.core :refer [defroutes GET]]
         '[authdog.core :as authdog]
         '[authdog.exceptions :as ex])

(def authdog-client (authdog/make-client "https://api.authdog.com"))

(defn user-info-handler [request]
  (let [access-token (get-in request [:params :access_token])]
    (try
      (let [user-info (authdog/get-user-info authdog-client access-token)
            user (:user user-info)]
        (response/response {:id (:id user)
                            :display-name (:display-name user)
                            :email (when-let [email (first (:emails user))]
                                     (:value email))
                            :provider (:provider user)}))
      (catch clojure.lang.ExceptionInfo e
        (cond
          (ex/authentication-error? e)
          (-> (response/response {:error "Authentication failed"})
              (response/status 401))
          
          (ex/api-error? e)
          (-> (response/response {:error (.getMessage e)})
              (response/status 400)))))))

(defroutes app
  (GET "/user/info" request (user-info-handler request)))
```

### Compojure API Example

```clojure
(require '[compojure.api.sweet :refer [defapi GET]]
         '[ring.util.http-response :refer [ok unauthorized bad-request]]
         '[authdog.core :as authdog]
         '[authdog.exceptions :as ex])

(defapi app
  (GET "/user/info" []
    :query-params [access-token :- String]
    (try
      (let [client (authdog/make-client "https://api.authdog.com")
            user-info (authdog/get-user-info client access-token)
            user (:user user-info)]
        (ok {:id (:id user)
             :display-name (:display-name user)
             :email (when-let [email (first (:emails user))]
                      (:value email))
             :provider (:provider user)}))
      (catch clojure.lang.ExceptionInfo e
        (cond
          (ex/authentication-error? e)
          (unauthorized {:error "Authentication failed"})
          
          (ex/api-error? e)
          (bad-request {:error (.getMessage e)}))))))
```

### Pedestal Integration

```clojure
(require '[io.pedestal.http :as http]
         '[io.pedestal.http.route :as route]
         '[authdog.core :as authdog]
         '[authdog.exceptions :as ex])

(defn user-info-interceptor [request]
  (let [access-token (get-in request [:query-params :access_token])]
    (try
      (let [client (authdog/make-client "https://api.authdog.com")
            user-info (authdog/get-user-info client access-token)
            user (:user user-info)]
        {:status 200
         :body {:id (:id user)
                :display-name (:display-name user)
                :email (when-let [email (first (:emails user))]
                         (:value email))
                :provider (:provider user)}})
      (catch clojure.lang.ExceptionInfo e
        (cond
          (ex/authentication-error? e)
          {:status 401
           :body {:error "Authentication failed"}}
          
          (ex/api-error? e)
          {:status 400
           :body {:error (.getMessage e)}})))))

(def routes
  (route/expand-routes
   #{["/user/info" :get user-info-interceptor :route-name :user-info]}))

(def service-map
  {::http/routes routes
   ::http/port 8080})

(defn start-server []
  (http/start (http/create-server service-map)))
```

### Re-frame Integration

```clojure
(require '[re-frame.core :as rf]
         '[authdog.core :as authdog]
         '[authdog.exceptions :as ex])

(def authdog-client (authdog/make-client "https://api.authdog.com"))

(rf/reg-fx
 :authdog/get-user-info
 (fn [[access-token success-event error-event]]
   (-> (future (authdog/get-user-info authdog-client access-token))
       (deref 10000 nil)
       (cond
         (ex/authdog-error? %) (rf/dispatch [error-event (.getMessage %)])
         :else (rf/dispatch [success-event %])))))

(rf/reg-event-fx
 :authdog/load-user-info
 (fn [_ [_ access-token]]
   {:fx [[:authdog/get-user-info [access-token :authdog/user-info-success :authdog/user-info-error]]]}))

(rf/reg-event-db
 :authdog/user-info-success
 (fn [db [_ user-info]]
   (assoc db :user-info user-info)))

(rf/reg-event-db
 :authdog/user-info-error
 (fn [db [_ error-message]]
   (assoc db :authdog-error error-message)))
```

## Building and Testing

### Build the Project

```bash
lein compile
```

### Run Tests

```bash
lein test
```

### Package the Library

```bash
lein jar
```

### Install to Local Repository

```bash
lein install
```

## Development

### Requirements

- Clojure 1.11+
- Leiningen 2.9+
- clj-http 3.12.3+
- Cheshire 5.11.0+
- Midje (for testing)

### Code Style

- Follow Clojure Style Guide
- Use `cljfmt` for formatting
- Use meaningful function and variable names
- Use `defn` for functions
- Use `try-catch` for error handling
- Prefer `let` over `def` for local bindings
- Use `->` and `->>` for threading

### Running Tests

```bash
# Run all tests
lein test

# Run tests with Midje
lein midje

# Run specific test
lein test authdog.core-test
```

## License

MIT License - see [LICENSE](../LICENSE) for details.
