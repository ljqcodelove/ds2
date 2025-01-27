(ns org.apache.storm.shade.carbonite.api
  (:require [clojure.string :as s]
            [org.apache.storm.shade.carbonite.serializer :as serializer])
  (:import [com.esotericsoftware.kryo Kryo Serializer]
           [java.nio ByteBuffer]))

;;;; Creating a Kryo registry

(defn register-serializers
  "Register a map of Class to Kryo Serializer with a Kryo registry."
  [^Kryo registry serializers]
  (doseq [[^Class klass ^Serializer serializer] serializers]
    (.register registry klass serializer))
  registry)

(defn new-registry
  "Create a new Kryo registry that supports unregistered classes and defers to the
   kryo-extend multimethod if an unhandled Class serializer is requested."
  []
  (doto (Kryo.)
    (.setRegistrationRequired false)))

(defn default-registry
  "Create or install a set of default serializers in an existing
   registry.  Modifies and returns the registry instance."
  ([]
     (default-registry (new-registry)))
  ([registry]
     (doto registry
       (register-serializers serializer/clojure-primitives)
       (register-serializers serializer/java-primitives)
       (register-serializers serializer/clojure-collections))))

;;;; APIs to read and write objects using ByteBuffers

(defn new-buffer
  "Create a new on-heap ByteBuffer of size."
  [size]
  (ByteBuffer/allocate size))

(defn write-buffer
  "Write serialized obj into ByteBuffer using registry.  If the buffer
  is not big enough, a SerializationException will be thrown."
  [^Kryo registry byte-buffer obj]
  (.writeClassAndObject registry byte-buffer obj))

(defn read-buffer
  "Read serialized object from byte-buffer using registry."
  [^Kryo registry byte-buffer]
  (.readClassAndObject registry byte-buffer))

;; Copyright 2011 Revelytix, Inc.
;;
;; Licensed under the Apache License, Version 2.0 (the "License");
;; you may not use this file except in compliance with the License.
;; You may obtain a copy of the License at
;; 
;;     http://www.apache.org/licenses/LICENSE-2.0
;; 
;; Unless required by applicable law or agreed to in writing, software
;; distributed under the License is distributed on an "AS IS" BASIS,
;; WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
;; See the License for the specific language governing permissions and
;; limitations under the License.
