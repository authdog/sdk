(defproject authdog "0.1.0"
  :description "Official Clojure SDK for Authdog authentication and user management platform"
  :url "https://github.com/authdog/sdk"
  :license {:name "MIT License"
            :url "https://opensource.org/licenses/MIT"}
  :dependencies [[org.clojure/clojure "1.11.1"]
                 [clj-http "3.12.3"]
                 [cheshire "5.11.0"]
                 [org.clojure/data.json "2.4.0"]]
  :profiles {:dev {:dependencies [[midje "1.10.9"]]
                   :plugins [[lein-midje "3.2.2"]]}}
  :repositories [["central" {:url "https://repo1.maven.org/maven2/"}]]
  :deploy-repositories [["clojars" {:creds :gpg}]]
  :min-lein-version "2.0.0"
  :source-paths ["src"]
  :test-paths ["test"]
  :resource-paths ["resources"]
  :target-path "target/%s"
  :compile-path "%s/classes"
  :clean-targets ^{:protect false} [:target-path :compile-path]
  :global-vars {*warn-on-reflection* true}
  :jvm-opts ["-Xmx1g"])
