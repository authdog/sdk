(ns authdog.core-test
  (:require [clojure.test :refer :all]
            [authdog.core :as core]
            [authdog.exceptions :as ex]))

(deftest make-client-tests
  (testing "creates client with base URL"
    (let [client (core/make-client "https://api.authdog.com")]
      (is (= (:base-url client) "https://api.authdog.com"))
      (is (nil? (:api-key client)))
      (is (= (:timeout client) 10000))))
  
  (testing "creates client with API key and timeout"
    (let [client (core/make-client "https://api.authdog.com" 
                                   {:api-key "test-key" 
                                    :timeout 5000})]
      (is (= (:base-url client) "https://api.authdog.com"))
      (is (= (:api-key client) "test-key"))
      (is (= (:timeout client) 5000))))
  
  (testing "trims trailing slash from base URL"
    (let [client (core/make-client "https://api.authdog.com/")]
      (is (= (:base-url client) "https://api.authdog.com")))))
