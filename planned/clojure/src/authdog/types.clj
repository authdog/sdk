(ns authdog.types
  (:require [cheshire.core :as json]))

(defn parse-meta
  "Parse meta data from JSON"
  [data]
  {:code (get data "code")
   :message (get data "message")})

(defn parse-session
  "Parse session data from JSON"
  [data]
  {:remaining-seconds (get data "remainingSeconds")})

(defn parse-names
  "Parse names data from JSON"
  [data]
  {:id (get data "id")
   :formatted (get data "formatted")
   :family-name (get data "familyName")
   :given-name (get data "givenName")
   :middle-name (get data "middleName")
   :honorific-prefix (get data "honorificPrefix")
   :honorific-suffix (get data "honorificSuffix")})

(defn parse-photo
  "Parse photo data from JSON"
  [data]
  {:id (get data "id")
   :value (get data "value")
   :type (get data "type")})

(defn parse-email
  "Parse email data from JSON"
  [data]
  {:id (get data "id")
   :value (get data "value")
   :type (get data "type")})

(defn parse-verification
  "Parse verification data from JSON"
  [data]
  {:id (get data "id")
   :email (get data "email")
   :verified (get data "verified")
   :created-at (get data "createdAt")
   :updated-at (get data "updatedAt")})

(defn parse-user
  "Parse user data from JSON"
  [data]
  {:id (get data "id")
   :external-id (get data "externalId")
   :user-name (get data "userName")
   :display-name (get data "displayName")
   :nick-name (get data "nickName")
   :profile-url (get data "profileUrl")
   :title (get data "title")
   :user-type (get data "userType")
   :preferred-language (get data "preferredLanguage")
   :locale (get data "locale")
   :timezone (get data "timezone")
   :active (get data "active")
   :names (parse-names (get data "names"))
   :photos (mapv parse-photo (get data "photos" []))
   :phone-numbers (get data "phoneNumbers" [])
   :addresses (get data "addresses" [])
   :emails (mapv parse-email (get data "emails" []))
   :verifications (mapv parse-verification (get data "verifications" []))
   :provider (get data "provider")
   :created-at (get data "createdAt")
   :updated-at (get data "updatedAt")
   :environment-id (get data "environmentId")})

(defn parse-user-info-response
  "Parse user info response from JSON"
  [data]
  {:meta (parse-meta (get data "meta"))
   :session (parse-session (get data "session"))
   :user (parse-user (get data "user"))})
