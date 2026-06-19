(ns authdog.core
  (:require [clj-http.client :as http]
            [cheshire.core :as json]
            [authdog.exceptions :as ex]
            [authdog.types :as types]))

(defn make-client
  "Create a new Authdog client"
  ([base-url]
   (make-client base-url {}))
  ([base-url {:keys [api-key timeout]
              :or {timeout 10000}}]
   {:base-url (clojure.string/replace base-url #"/$" "")
    :api-key api-key
    :timeout timeout}))

(defn get-user-info
  "Get user information using an access token"
  [client access-token]
  (let [url (str (:base-url client) "/v1/userinfo")
        headers {"Content-Type" "application/json"
                 "User-Agent" "authdog-clojure-sdk/0.1.0"
                 "Authorization" (str "Bearer " access-token)}
        
        ;; Add API key if provided
        final-headers (if (:api-key client)
                        (assoc headers "Authorization" (str "Bearer " (:api-key client)))
                        headers)
        
        request {:url url
                 :method :get
                 :headers final-headers
                 :timeout (:timeout client)
                 :as :json}]
    
    (try
      (let [response (http/request request)
            status (:status response)
            body (:body response)]
        (case status
          200 (types/parse-user-info-response body)
          401 (throw (ex/authentication-error "Unauthorized - invalid or expired token"))
          500 (let [error-message (get body "error")]
                (cond
                  (= error-message "GraphQL query failed")
                  (throw (ex/api-error "GraphQL query failed"))
                  
                  (= error-message "Failed to fetch user info")
                  (throw (ex/api-error "Failed to fetch user info"))
                  
                  :else
                  (throw (ex/api-error (str "HTTP error 500: " (json/generate-string body))))))
          (throw (ex/api-error (str "HTTP error " status ": " (json/generate-string body))))))
      (catch clojure.lang.ExceptionInfo e
        (if (= (:type (ex-data e)) :clj-http.client/unexceptional-status)
          (let [status (:status (ex-data e))
                body (:body (ex-data e))]
            (case status
              401 (throw (ex/authentication-error "Unauthorized - invalid or expired token"))
              500 (let [error-message (get body "error")]
                    (cond
                      (= error-message "GraphQL query failed")
                      (throw (ex/api-error "GraphQL query failed"))
                      
                      (= error-message "Failed to fetch user info")
                      (throw (ex/api-error "Failed to fetch user info"))
                      
                      :else
                      (throw (ex/api-error (str "HTTP error 500: " (json/generate-string body))))))
              (throw (ex/api-error (str "HTTP error " status ": " (json/generate-string body))))))
          (throw (ex/api-error (str "Request failed: " (.getMessage e))))))
      (catch Exception e
        (throw (ex/api-error (str "Request failed: " (.getMessage e))))))))
