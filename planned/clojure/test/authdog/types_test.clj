(ns authdog.types-test
  (:require [clojure.test :refer :all]
            [authdog.types :as types]))

(deftest parse-meta-tests
  (testing "parses meta data"
    (let [data {"code" 200 "message" "Success"}
          result (types/parse-meta data)]
      (is (= (:code result) 200))
      (is (= (:message result) "Success")))))

(deftest parse-session-tests
  (testing "parses session data"
    (let [data {"remainingSeconds" 3600}
          result (types/parse-session data)]
      (is (= (:remaining-seconds result) 3600)))))

(deftest parse-names-tests
  (testing "parses names data"
    (let [data {"id" "name_123"
                "formatted" "John Doe"
                "familyName" "Doe"
                "givenName" "John"
                "middleName" "William"
                "honorificPrefix" "Mr."
                "honorificSuffix" "Jr."}
          result (types/parse-names data)]
      (is (= (:id result) "name_123"))
      (is (= (:formatted result) "John Doe"))
      (is (= (:family-name result) "Doe"))
      (is (= (:given-name result) "John"))
      (is (= (:middle-name result) "William"))
      (is (= (:honorific-prefix result) "Mr."))
      (is (= (:honorific-suffix result) "Jr.")))))

(deftest parse-photo-tests
  (testing "parses photo data"
    (let [data {"id" "photo_123"
                "value" "https://example.com/photo.jpg"
                "type" "profile"}
          result (types/parse-photo data)]
      (is (= (:id result) "photo_123"))
      (is (= (:value result) "https://example.com/photo.jpg"))
      (is (= (:type result) "profile")))))

(deftest parse-email-tests
  (testing "parses email data"
    (let [data {"id" "email_123"
                "value" "john@example.com"
                "type" "work"}
          result (types/parse-email data)]
      (is (= (:id result) "email_123"))
      (is (= (:value result) "john@example.com"))
      (is (= (:type result) "work"))))
  
  (testing "handles nil type"
    (let [data {"id" "email_123"
                "value" "john@example.com"
                "type" nil}
          result (types/parse-email data)]
      (is (= (:id result) "email_123"))
      (is (= (:value result) "john@example.com"))
      (is (nil? (:type result))))))

(deftest parse-verification-tests
  (testing "parses verification data"
    (let [data {"id" "verification_123"
                "email" "john@example.com"
                "verified" true
                "createdAt" "2023-01-01T00:00:00Z"
                "updatedAt" "2023-01-02T00:00:00Z"}
          result (types/parse-verification data)]
      (is (= (:id result) "verification_123"))
      (is (= (:email result) "john@example.com"))
      (is (= (:verified result) true))
      (is (= (:created-at result) "2023-01-01T00:00:00Z"))
      (is (= (:updated-at result) "2023-01-02T00:00:00Z")))))

(deftest parse-user-tests
  (testing "parses user data"
    (let [data {"id" "user_123"
                "externalId" "ext_123"
                "userName" "johndoe"
                "displayName" "John Doe"
                "nickName" "Johnny"
                "profileUrl" "https://example.com/profile"
                "title" "Software Engineer"
                "userType" "employee"
                "preferredLanguage" "en"
                "locale" "en_US"
                "timezone" "UTC"
                "active" true
                "names" {"id" "name_123"
                         "formatted" "John Doe"
                         "familyName" "Doe"
                         "givenName" "John"
                         "middleName" nil
                         "honorificPrefix" nil
                         "honorificSuffix" nil}
                "photos" [{"id" "photo_123"
                           "value" "https://example.com/photo.jpg"
                           "type" "profile"}]
                "phoneNumbers" []
                "addresses" []
                "emails" [{"id" "email_123"
                           "value" "john@example.com"
                           "type" "work"}]
                "verifications" []
                "provider" "authdog"
                "createdAt" "2023-01-01T00:00:00Z"
                "updatedAt" "2023-01-02T00:00:00Z"
                "environmentId" "env_123"}
          result (types/parse-user data)]
      (is (= (:id result) "user_123"))
      (is (= (:external-id result) "ext_123"))
      (is (= (:user-name result) "johndoe"))
      (is (= (:display-name result) "John Doe"))
      (is (= (:provider result) "authdog"))
      (is (= (get-in result [:names :given-name]) "John"))
      (is (= (count (:emails result)) 1))
      (is (= (get-in result [:emails 0 :value]) "john@example.com")))))

(deftest parse-user-info-response-tests
  (testing "parses user info response"
    (let [data {"meta" {"code" 200 "message" "Success"}
                "session" {"remainingSeconds" 3600}
                "user" {"id" "user_123"
                        "externalId" "ext_123"
                        "userName" "johndoe"
                        "displayName" "John Doe"
                        "nickName" nil
                        "profileUrl" nil
                        "title" nil
                        "userType" nil
                        "preferredLanguage" nil
                        "locale" "en_US"
                        "timezone" nil
                        "active" true
                        "names" {"id" "name_123"
                                 "formatted" "John Doe"
                                 "familyName" "Doe"
                                 "givenName" "John"
                                 "middleName" nil
                                 "honorificPrefix" nil
                                 "honorificSuffix" nil}
                        "photos" []
                        "phoneNumbers" []
                        "addresses" []
                        "emails" [{"id" "email_123"
                                   "value" "john@example.com"
                                   "type" "work"}]
                        "verifications" []
                        "provider" "authdog"
                        "createdAt" "2023-01-01T00:00:00Z"
                        "updatedAt" "2023-01-02T00:00:00Z"
                        "environmentId" "env_123"}}
          result (types/parse-user-info-response data)]
      (is (= (get-in result [:meta :code]) 200))
      (is (= (get-in result [:session :remaining-seconds]) 3600))
      (is (= (get-in result [:user :id]) "user_123")))))
