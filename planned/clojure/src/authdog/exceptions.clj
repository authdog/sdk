(ns authdog.exceptions)

(defn authdog-error
  "Base error for all Authdog SDK errors"
  [message]
  (ex-info message {:type :authdog-error}))

(defn authentication-error
  "Error for authentication failures"
  [message]
  (ex-info message {:type :authentication-error}))

(defn api-error
  "Error for API request failures"
  [message]
  (ex-info message {:type :api-error}))

(defn authdog-error?
  "Check if exception is an Authdog error"
  [e]
  (and (instance? clojure.lang.ExceptionInfo e)
       (contains? #{:authdog-error :authentication-error :api-error}
                  (:type (ex-data e)))))

(defn authentication-error?
  "Check if exception is an authentication error"
  [e]
  (and (instance? clojure.lang.ExceptionInfo e)
       (= (:type (ex-data e)) :authentication-error)))

(defn api-error?
  "Check if exception is an API error"
  [e]
  (and (instance? clojure.lang.ExceptionInfo e)
       (= (:type (ex-data e)) :api-error)))
