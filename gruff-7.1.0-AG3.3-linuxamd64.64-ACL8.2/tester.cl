;; -*- mode: common-lisp; package: gruff; readtable: allegrograph -*-

;; -=Begin Copyright Notice=-
;; See the file LICENSE for the full license governing this code.
;; -=End Copyright Notice=-

#|

TO DO

Suddenly it hangs while creating the new store until I move the mouse
or press a key.  What can that mean?  Ah, only when I was tracing.
(trace uf::update-gruff-layout (setf node-is-pinned)
       uf:display-paths uf::gruff-close-triple-store
       uf::test-gruff uf:display-triples
       uf:find-and-display-paths uf::add-or-display-paths-between-two-nodes-command
       uf::display-paths-between-two-nodes-command triple-store:close-triple-store)

|#

(in-package :gruff)

;;; chee   16jul12 new file for automated gruff testers
;;; chee   01sep16 fixed some out-of-date validators that reported bogus errors
(defparameter *gruff-testers*
  '(
    ("the store is open"
     (a-store-is-open)
     result)
    ("show node pane"
     (show-graph-pane np))
    ("set canvas size"
     (set-page-size np 2400 1800)
     (and (= (page-width np) 2400)
          (= (page-height np) 1800)))
    ("center the graph"
     (center-the-graph))
    ("set canvas size to window size"
     (set-page-size np 0 0))
    ("use label predicates"
     (setf (use-label-properties np) t))
    ("add melvin type person"
     (add-sample-triple 'melvin 'type 'person))
    ("display first triple"
     (display-store)
     (and (= (length (node-pictures (network-of-nodes np))) 2)
          (= (length (link-lines (network-of-nodes np))) 1)))
    ("add a few more triples"
     (add-sample-triples '(
                           (melvin silliness high)
                           (arthur type person)
                           (arthur silliness low)
                           (arthur nephew melvin)
                           (melvin pet flarny)
                           (flarny type flarn_bird)
                           (arthur pet rover graph37)
                           (rover type dog graph37)
                           (dog subClassOf animal)
                           (flarn_bird subClassOf animal)
                           )))
    
    ;; -----------------------------------
    ;; Test the exported programmatic API.
    
    ("display-triples arguments"
     (display-triples (get-triples-list-retrying :limit nil) ;; 17oct12
                      :uncache-for-new-triple-store nil
                      :keep-old-nodes t
                      :layout-from-scratch t
                      :node-upi-for-initial-position (sample-upi 'melvin)
                      :max-iterations 8
                      :select-window nil
                      :no-push-go-back-state nil
                      :no-regroup t
                      :node-pane np)
     (and (= (length (node-pictures (network-of-nodes np))) 10)
          (= (length (link-lines (network-of-nodes np))) 11)))
    ("clear the visual graph"
     (remove-all-nodes np :no-push-go-back-state t))
    ("display-upis arguments"
     (display-upis (mapcar 'sample-upi '(melvin arthur person low high))
                   :predicate-upis (mapcar 'sample-upi '(type silliness))
                   :uncache-for-new-triple-store nil
                   :keep-old-nodes t
                   :layout-from-scratch t
                   :node-upi-for-initial-position (sample-upi 'melvin)
                   :max-iterations 8
                   :select-window nil
                   :no-push-go-back-state nil
                   :no-regroup nil
                   :node-pane np)
     (and (= (length (node-pictures (network-of-nodes np))) 5)
          (= (length (link-lines (network-of-nodes np))) 4)))
    ("find only shortest paths"
     (setf (find-only-shortest-paths np) t))
    ("find-and-display-paths arguments"
     (find-and-display-paths
      (sample-upi 'flarny)(sample-upi 'rover)
      (mapcar 'sample-upi '(pet nephew type))
      :finder-function 'triple-store:all-bidirectional-search-paths
      :maximum-depth 6 :warn-on-many-triples nil
      :uncache-for-new-triple-store nil :keep-old-nodes nil
      :end-node-placement :top-and-bottom
      :node-upi-for-initial-position nil
      :max-iterations 8 :select-window nil :no-push-go-back-state nil
      :timeout 20 :node-pane np)
     (and (= (length (node-pictures (network-of-nodes np))) 4)
          (= (length (link-lines (network-of-nodes np))) 3)))
    ("find all paths"
     (setf (find-only-shortest-paths np) nil))
    ;; jj It's still finding only the shortest paths, so
    ;; remove nephew from the predicates here to find a longer path.
    ("find-and-display-paths arguments"
     (find-and-display-paths
      (sample-upi 'flarny)(sample-upi 'rover)
      (mapcar 'sample-upi '(pet type))
      :finder-function 'triple-store:all-depth-first-search-paths
      :maximum-depth 8 :warn-on-many-triples nil
      :uncache-for-new-triple-store nil :keep-old-nodes nil
      :end-node-placement :left-and-right
      :node-upi-for-initial-position nil
      :max-iterations 8 :select-window nil :no-push-go-back-state nil
      :timeout 20 :node-pane np)
     (and (= (length (node-pictures (network-of-nodes np))) 5)
          (= (length (link-lines (network-of-nodes np))) 4)))
    ("display-paths arguments"
     (display-paths (list (mapcar 'sample-upi '(flarny melvin arthur rover))
                          (mapcar 'sample-upi '(flarny melvin person arthur rover)))
                    (mapcar 'sample-upi '(pet nephew type))
                    :warn-on-many-triples t :keep-old-nodes nil
                    :uncache-for-new-triple-store nil
                    :layout-from-scratch t
                    :end-node-placement :left-and-right
                    :end-node-upi-1 (sample-upi 'flarny)
                    :end-node-upi-2 (sample-upi 'rover)
                    :max-iterations 8 :select-window nil :no-push-go-back-state nil
                    :node-pane np)
     (and (= (length (node-pictures (network-of-nodes np))) 5)
          (= (length (link-lines (network-of-nodes np))) 5)))
    ("save-layout arguments"
     (save-layout np (merge-pathnames "gruff-tester.layout" (sys:temporary-directory))))
    ("load-layout arguments"
     (load-layout np (merge-pathnames "gruff-tester.layout" (sys:temporary-directory))))
    ("save layout as pixmap arguments"
     (save-layout-as-pixmap
      np :path (merge-pathnames "gruff-tester.bmp" (sys:temporary-directory))
      :show-saved-pixmap nil))
    ("set current predicates"
     (set-current-predicates
      (mapcar 'sample-upi '(type pet nephew)))
     (= (length (current-predicates)) 3))
    ("select recent current predicates"
     (use-recent-current-predicates-command np :no-dialogs t))
    ("display-linked-nodes arguments"
     (display-linked-nodes
      (sample-upi 'melvin)
      :keep-old-nodes nil :levels-to-add 1
      :deselect-selected-node t
      :exclude-explicitly-excluded-nodes nil
      :node-pane np)
     (and (= (length (node-pictures (network-of-nodes np))) 4)
          (= (length (link-lines (network-of-nodes np))) 4)))
    ("display-store arguments"
     (display-store
      :limit 12 :graph nil :keep-old-nodes nil
      :uncache-for-new-triple-store nil
      :include-nodes-for-label-properties t
      :include-nodes-for-comment-properties t
      :layout-from-scratch t :max-iterations 8 :select-window nil
      :no-push-go-back-state nil :no-regroup nil)
     (and (= (length (node-pictures (network-of-nodes np))) 10)
          (= (length (link-lines (network-of-nodes np))) 8)))
    ("update-the-layout arguments"
     (update-the-layout
      :layout-from-scratch t :max-iterations 24
      :fixed-node-upis (mapcar 'sample-upi '(melvin arthur))
      :deselect-selected-node t
      :compress-layout t :center-the-graph t
      :node-pane np))
    ("remove-node-of-upi arguments"
     (remove-node-of-upi (sample-upi 'arthur)
                         :exclude nil :node-pane np)
     (and (= (length (node-pictures (network-of-nodes np))) 9)
          (= (length (link-lines (network-of-nodes np))) 5)))
    ("remove-orphans arguments"
     (remove-orphans :leaves-too nil :no-update nil :no-warning nil)
     (and (= (length (node-pictures (network-of-nodes np))) 7)
          (= (length (link-lines (network-of-nodes np))) 5)))
    ("remove-leaves arguments"
     (remove-orphans :leaves-too t :no-update nil :no-warning nil)
     (and (= (length (node-pictures (network-of-nodes np))) 2)
          (= (length (link-lines (network-of-nodes np))) 0)))
    ("highlight a node"
     (highlight-node-by-upi (sample-upi 'melvin)))
    ("unhighlight all nodes"
     (remove-all-highlighting :node-pane np))
    ("center-the-graph arguments"
     (center-the-graph :node-pane np :no-message t))
    ("add label triples"
     (add-sample-triples
      '((arthur label "The Arthurmeister")
        (melvin label "Melvin Ferd")
        (melvin comment "Melvin is a very silly person.")
        (melvin comment #.(format nil "Much has been written about Melvin Ferd.  ~
                                       Not much of it is favorable.  But at least ~
                                       some of it, such as this comment, is long ~
                                       enough to occuppy multiple lines in the ~
                                       table view for testing purposes.  Melvin ~
                                       thus fills the role of test subject ~
                                       almost adequately.  Especially if this ~
                                       comment were to reach three lines in the ~
                                       table, for a more astounding effect.")))))
    ("show node by label"
     (show-node-by-label np :keep-old-nodes t :return-only nil
                         :label-string "The Arthurmeister")
     (and *selected-node*
          (triple-store:upi= *selected-node* (sample-upi 'arthur))))
    ("select a link line"
     (rotate-to-next-link-line np nil)
     (and *selected-link*
          (triple-store:upi= *selected-link* (sample-upi 'nephew))))
    ("leap across"
     (leap-across-selected-link-line np)
     (and *selected-node*
          (triple-store:upi= *selected-node* (sample-upi 'melvin))))
    ("store the melving node picture"
     (setf (tester-value :melvin-node-info)
       (represented-object (selected-node-picture (network-of-nodes np)))))
    ("add two blank nodes"
     (progn
       (setf (tester-value :blanker)(triple-store:new-blank-node))
       (add-triple-retrying (sample-upi 'melvin)
                            (sample-upi 'blanker)
                            (tester-value :blanker))
       (setf (tester-value :blanker-with-label)(triple-store:new-blank-node))
       (add-triple-retrying (sample-upi 'melvin)
                            (sample-upi 'blanker)
                            (tester-value :blanker-with-label))
       (add-triple-retrying (tester-value :blanker-with-label)
                            (sample-upi 'label)
                            (sample-upi "Blank Node with Label"))))
    ("add language literals"
     (add-sample-triples '((melvin english-literal "English Literal" nil "en")
                           (melvin russian-literal "Russian Literal" nil "ru"))))
    #+no ;; this just creates long simple literals
    ("add typed literals"
     (dolist (entry *xml-datatype-templates*)
       (add-triple-retrying
        (sample-upi 'melvin)
        (sample-upi (intern (format nil "typed-~a" (first entry))))
        (sample-upi (typed-literal-uri-for-value (first entry)(second entry))))))
    ("add encoded literal"
     (dolist (entry '((:date (- (get-universal-time)(* 60 60 24)))
                      (:time (+ (get-universal-time)(* 60 60 24)))
                      (:date-time (get-universal-time))
                      (:double-float 4/3)
                      (:unsigned-long 12345678)
                      (:int 37)
                      (:telephone-number "5108489862")))
       (add-triple-retrying
        (sample-upi 'melvin)
        (sample-upi (intern (format nil "encoded-~a" (first entry))))
        (value->upi-retrying (eval (second entry))(first entry)))))
    #+later ;; need to find how to specify the subtype
    ("add geospatial"
     (add-triple-retrying
      (sample-upi 'melvin)
      (sample-upi 'geospatial)
      (triple-store:longitude-latitude->upi
       subtype???
       37 43)))
    ("clear display before adding by URI"
     (remove-all-nodes np))
    ("show node by URI"
     (show-node-by-uri np :keep-old-nodes t :return-only nil
                       :uri (sample-uri 'melvin))
     (and *selected-node*
          (triple-store:upi= *selected-node* (sample-upi 'melvin))))
    ("clear display before add nodes by type and class"
     (remove-all-nodes np))
    ("add instance node by type"
     (add-node-by-type np :use-random-choice t))
    ("add type node by type"
     (add-node-by-type np :type-itself t :use-random-choice t))
    #+no ;; there are no instances of animal
    ("add instance node by class"
     (add-or-view-node-by-class np :keep-old-nodes
                                :use-random-choice t))
    ("add class node by class"
     (add-or-view-node-by-class np :keep-old-nodes t :type-itself t
                                :use-random-choice t))
    ("move nodes by type off of each other"
     (update-gruff-layout np :from-scratch nil :max-iterations 8)
     (= (length (node-pictures (network-of-nodes np))) 3))
    ("clear display before displaying a single graph"
     (remove-all-nodes np))
    #+jj ;; until bug22390 is fixed in the lisp client
    ("display all nodes of one graph"
     (display-triples-of-graph-command np :use-random-choice t)
     (and (= (length (node-pictures (network-of-nodes np))) 3)
          (= (length (link-lines (network-of-nodes np))) 2)))
    #-allegrograph3
    ("clear display before freetext"
     (remove-all-nodes np))
    #-allegrograph3
    ("create a freetext index"
     (unless *current-freetext-index*
       (setq *current-freetext-index*
             (triple-store:create-freetext-index
              "all preds" :index-literals t :index-resources t))))
    #-allegrograph3
    ("find subjects by freetext"
     (add-by-freetext np t :freetext-string "Literal" :display-all t)
     (and (= (length (node-pictures (network-of-nodes np))) 1)
          (= (length (link-lines (network-of-nodes np))) 0)))
    #-allegrograph3
    ("find triples by freetext"
     (add-by-freetext np nil :freetext-string "Literal" :display-all t)
     (and (= (length (node-pictures (network-of-nodes np))) 3)
          (= (length (link-lines (network-of-nodes np))) 2)))
    (setf (enforce-max-node-label-length np) nil)
    ("show all of Melvin in graph view"
     (progn
       (display-upis
        (append
         (list (sample-upi 'melvin))
         (mapcar 'object-of-triple (get-triples-list-retrying
                                    :s (sample-upi 'melvin)))
         (mapcar 'subject-of-triple (get-triples-list-retrying
                                     :o (sample-upi 'melvin))))
        :max-iterations 8
        :predicate-upis t ;; all predicates
        :keep-old-nodes t :layout-from-scratch nil)))
    ("show long comment in a node picture"
     (progn
       (setf (enforce-max-node-label-length np) nil)
       (update-gruff-layout np :from-scratch nil :max-iterations 8)
       (setf (enforce-max-node-label-length np) t)
       (update-gruff-layout np :from-scratch nil :max-iterations 8)))
    ("label derivation options"
     (progn
       (setf (use-label-properties np) nil)
       (update-gruff-layout np :from-scratch nil :max-iterations 8)
       (setf (exclude-namespaces-from-labels np) nil)
       (setf (add-spaces-to-labels np) nil)
       (setf (collapse-contiguous-spaces-in-labels np) nil)
       (setf (capitalize-first-word np) nil)
       (setf (convert-percent-hex-in-labels np) nil)
       (setf (display-subclassof-as-superclass np) nil)
       (update-gruff-layout np :from-scratch nil :max-iterations 8)
       (setf (exclude-namespaces-from-labels np) nil)
       (update-gruff-layout np :from-scratch nil :max-iterations 8)
       (setf (exclude-namespaces-from-labels np) t)
       (setf (add-spaces-to-labels np) t)
       (setf (collapse-contiguous-spaces-in-labels np) t)
       (setf (capitalize-first-word np) t)
       (setf (convert-percent-hex-in-labels np) t)
       (setf (display-subclassof-as-superclass np) t)
       (update-gruff-layout np :from-scratch nil :max-iterations 8)
       (setf (exclude-namespaces-from-labels np) t)
       (setf (use-label-properties np) t)
       (setf (show-full-uris-on-nodes np) t)
       (update-gruff-layout np :from-scratch nil :max-iterations 8)
       (setf (show-full-uris-on-nodes np) nil)
       (update-gruff-layout np :from-scratch nil :max-iterations 8)
       ))
    ("string search in the visual graph"
     (progn
       (gruff-string-search-command tp)
       (dolist (char (coerce "arthurmeister" 'list))
         (string-search-character *gruff-string-search-window* char)
         (sleep 0.2))
       (exit-string-search *gruff-string-search-window* nil)
       (sleep 0.5))
     (triple-store:upi= *selected-node* (sample-upi 'arthur)))
    ("select melvin to show in table view"
     (setf (selected-node-picture (network-of-nodes np))
       (dolist (node-picture (node-pictures (network-of-nodes np)))
         (when (eq (represented-object node-picture)
                   (tester-value :melvin-node-info))
           (return node-picture)))))
    (setf (show-full-uris-in-tables np) nil)
    ("show melvin in the table view"
     (show-table-pane np))
    ("sleep" (sleep 0.3)) ;; wait for the redisplay
    ("show full URIs in the table"
     (setf (show-full-uris-in-tables np) t))
    ("sleep" (sleep 0.3)) ;; wait for the redisplay
    ("show short labels in the table"
     (setf (show-full-uris-in-tables np) nil))
    ("one line per property"
     (setf (fit-row-height-to-text np) nil))
    ("sleep" (sleep 0.3)) ;; wait for the redisplay
    ("all lines of each property"
     (setf (fit-row-height-to-text np) t))
    ("sleep" (sleep 0.3)) ;; wait for the redisplay
    ("no label predicates in table"
     (setf (use-label-properties np) nil))
    ("sleep" (sleep 0.3)) ;; wait for the redisplay
    ("label predicates in table"
     (setf (use-label-properties np) t))
    ("sleep" (sleep 0.3)) ;; wait for the redisplay
    ("no labels of all languages"
     (setf (display-literals-of-all-languages-in-tables np) nil))
    ("sleep" (sleep 0.3)) ;; wait for the redisplay
    ("labels of all languages"
     (setf (display-literals-of-all-languages-in-tables np) t))
    ("sleep" (sleep 0.3)) ;; wait for the redisplay
    ("string search in the table"
     (progn
       (gruff-string-search-command tp)
       (dolist (char (coerce "flarn" 'list))
         (string-search-character *gruff-string-search-window* char)
         (sleep 0.2))
       (exit-string-search *gruff-string-search-window* nil)
       (sleep 0.5)))
    ("go forward in the table view"
     (dotimes (j 2)
       (table-grid-value-column-click
        tg 0 (second (subsections (column-section tg :body)))
        (second (subsections (row-section tg :body))) 12)
       (sleep 0.2)))
    ("go back in the table view"
     (dotimes (j 2)
       (gruff-go-back-command tp)
       (sleep 0.2)))
    ("pass flarn from table view to outline view"
     (progn
       (remove-all-nodes op)
       (show-selected-node-in-outline tp))
     (eq (value oo)(node-info (sample-upi 'flarny))))
    ("go back to the graph view"
     (show-graph-pane np))
    ("clear the visual graph"
     (remove-all-nodes np :no-push-go-back-state t))
    ;; jj The call to get-triples-list in load-layout is not finding
    ;; the triples that use :date and :time encoded literals
    ;; (but IS finding the :date-time triple).
    ("load layout"
     (load-layout np (merge-pathnames "gruff-tester.layout" (sys:temporary-directory))))
    ("go back in graph view"
     (dotimes (j 15)(gruff-go-back-command np)(update-window np)))
    ("go forward in graph view"
     (dotimes (j 15)(gruff-go-forward-command np)(update-window np)))
    
    ("display all nodes before exporting N-triples"
     (display-store :max-iterations 12
                    :include-nodes-for-label-properties t
                    :include-nodes-for-comment-properties t))
    ("export N-triples"
     (gruff-export-command np :ntriples
                           :path (merge-pathnames "gruff-tester.nt"
                                                  (sys:temporary-directory))))
    ("count nodes and links before re-importing"
     (progn (setf (tester-value :num-nodes)
              (length (node-pictures (network-of-nodes np))))
       (setf (tester-value :num-links)
         (length (link-lines (network-of-nodes np))))))
    #+later ;; after the load-ntriples bug in bug24170 is fixed
    ("delete all triples before re-importing"
     (delete-triples-retrying)) ;; 29oct12
    #+later ;; after the load-ntriples bug in bug24170 is fixed
    ("re-import N-triples"
     (load-triples np :ntriples
                   :path (merge-pathnames "gruff-tester.nt"
                                          (sys:temporary-directory))
                   :graph "" :file-or-web :file)
     (and (eql (length (node-pictures (network-of-nodes np)))
               (tester-value :num-nodes))
          (eql (length (link-lines (network-of-nodes np)))
               (tester-value :num-links))))
    ("display re-imported triples"
     (display-store :max-iterations 12))
    ("export node URIs"
     (gruff-export-command np :node-uris
                           :path (merge-pathnames "gruff-tester.nodes"
                                                  (sys:temporary-directory))))
    
    ("center the graph at end"
     (center-the-graph))
    (show-graph-pane np) ;; leave the visual graph showing at the end
    
    ;; ------------------
    ;; The HTTP Interface
    
    ("commit"
     #-allegrograph3
     (triple-store:commit-triple-store))
    #+jj ;; try not opening a store in an http server process;
    ("start HTTP server"
     (start-http-server gf :port 8008))
    #+jj ;; try not opening a store in an http server process;
    ;; probably need to add a close-triple-store HTTP command,
    ;; so that these testers can then close the store in the gruff process,
    ;; then use HTTP commands to open, test, and close all in the HTTP server process,
    ;; and then reopen the store in the gruff process
    ("open a store by HTTP"
     #-allegrograph3
     (net.aserve.client:do-http-request
         (format nil "http://localhost:8008/open-store?store-name=gruff-tester~
                      &host=~a&port=~a&access-mode=remote&write-mode=read-write~
                      &user=~a&password=~a"
           (tester-value :host)(tester-value :port)
           (tester-value :username)(tester-value :password)))
     #+allegrograph3
     (net.aserve.client:do-http-request
         (format nil "http://localhost:8008/open-store?store-name=~a"
           (merge-pathnames "gruff-tester" (sys:temporary-directory))))
     (and (>= (length result) 7)
          (string= result "success" :end1 7)))
    #+jj
    ("store name by HTTP"
     (net.aserve.client:do-http-request
         "http://localhost:8008/store-info?attribute=store-name")
     (and (string= result "gruff-tester")))
    
    #+jj ;; currently getting an eof from server, though it was working ...
    ("SPARQL query by HTTP"
     (progn
       (net.aserve.client:do-http-request
           (format nil
               "http://localhost:8008/query?language=sparql&layout=yes&query-string=~a"
             (net.aserve:uriencode-string
              "select ?a ?c where {?a <http://www.w3.org/2000/01/rdf-schema#label> ?c}")))
       (remove-orphans-command np)) ;; the "label" node
     (and (= (length (node-pictures (network-of-nodes np))) 6)
          (= (length (link-lines (network-of-nodes np))) 3)))
    
    ;; ----
    ;; RDFa
    
    stop ;; jj slow
    ("delete all triples before loading RDFa"
     (delete-triples-retrying)) ;; 29oct12
    ("load RDFa"
     (load-triples np :rdfa :path "http://www.franz.com" :graph ""))
    ("display Franz RDFa"
     (display-store :max-iterations 8))
    
    ;; Close the test store at the end, to avoid any AG confusion with
    ;; running Gruff in a different process (such as a Run Project process)
    ;; and closing the test store there.
    ;; Or don't close the store, to allow quickly rerunning the tests.
    (show-graph-pane np) ;; leave the visual graph showing at the end
    stop
    ("uncache for closing"
     (uncache-for-new-triple-store))
    ("close the store"
     (gruff-close-triple-store gf))
    ("clear browser title"
     (update-browser-title np))
    ))

(defparameter *tester-values* nil)

(defun tester-value (key)
  (getf *tester-values* key))

(defun (setf tester-value)(value key)
  (setf (getf *tester-values* key) value))

(defun boole-equal (one two)
  (if one two (not two)))

(defun add-sample-triples (list &key (uncache t))
  (dolist (entry list)
    (add-sample-triple (first entry)(second entry)(third entry)
                       :uncache nil :g (fourth entry) :language (fifth entry)))
  (when uncache
    (uncache-for-modified-triple-store)))

(defun add-sample-triple (s p o &key (uncache t) g language)
  (add-triple-retrying (sample-upi s)(sample-upi p)
                       (sample-upi o :language language)
                       :g (and g (sample-upi g)))
  (when uncache
    (uncache-for-modified-triple-store)))

(defparameter tg nil) ;; table pane grid widget
(defparameter oo nil) ;; outline pane outline widget
(defparameter result nil) ;; test returned value

;;; chee   08oct12 bug21432 in non-os-threads use the single event-handling
;;;        process rather than the window creation process, in case
;;;        gruff was started programmatically outside of the IDE
;;; chee   08nov12 rfe11933 the remote argument to new-triple-store
;;;        is now an access-mode argument, as with open-triple-store
;;; chee   07may12 rfe12282 rename new-triple-store
;;; chee   14nov14 bug22832 a new scheme option when opening a store
(defun test-gruff (&key host port username password debug-on-error)
  
  ;; If a store is open, then ask the user to first close it, to
  ;; avoid closing a store that they are not ready to close.
  ;; If there is a Gruff browser and the testers are being run
  ;; in the same process that created the browser (as when using
  ;; the hidden keyboard shortcut that's in the browser, perhaps
  ;; when invoking it in a standalone Gruff executable), then
  ;; use the usual utility for proceeding if the user agrees
  ;; to close the store.  Though if it's the gruff-test store
  ;; then just delete all of its triples to reuse it quickly.
  (when (a-store-is-open)
    (cond ((and *gruff-browser*
                (windowp *gruff-browser*)
                (eq (gruff-process *gruff-browser*) ;; bug21432
                    mp:*current-process*))
           (unless (or (and (string-equal *current-store-name* "gruff-tester")
                            (progn
                              #-allegrograph3
                              (dolist (index-name (all-freetext-indexes))
                                (triple-store:drop-freetext-index index-name))
                              (setq *current-freetext-index* nil)
                              (delete-triples-retrying) ;; 29oct12
                              #+maybe ;; to recreate the store every time
                              (gruff-close-triple-store *gruff-browser*)
                              t))
                       (check-for-no-open-triple-store
                        (graph-node-pane *gruff-browser*)))
             (gruff-message *gruff-browser*
                 "Gruff testers CANCELED.")
             (return-from test-gruff)))
          
          ;; In other cases, such as calling test-gruff directly in an IDE
          ;; listener when the Gruff project is running in a different process,
          ;; tell the user to close the store rather than doing it ourselves,
          ;; to avoid badly confusing the server as can sometimes(?) haapen when
          ;; we close a store in a different process than the one that created it
          ;; or opened it.  I've needed to restart the AG to straighten things out.
          (t (pop-up-message-dialog
              nil "A Store Is Open"
              "A store was left open.  First close it and then try again."
              error-icon "~OK")
             (return-from test-gruff))))
  
  ;; If there is a Gruff browser open in a different process, then close
  ;; it so that our call to gruff-browser below will create the browser in
  ;; the same process that will run the tests.  This may avoid problems with
  ;; Windows getting confused by creating windows in different processes, as had
  ;; happened when a different process created the menu bar in switch-view .
  (when (and *gruff-browser*
             (windowp *gruff-browser*)
             (not (eq (gruff-process *gruff-browser*) ;; bug21432
                      mp:*current-process*))) 
    (close *gruff-browser*))
  
  (setq uf::*abort-the-command* nil)
  (let* ((frame (gruff-browser :expose t))
         (node-pane (graph-node-pane frame))
         (failure-count 0)
         (error-count 0)
         (report-path (merge-pathnames "gruff-test-results.txt"
                                       (gruff-options-directory)))
         (platform-info (cg.base::cg-os-version-info))
         (options-to-save '(
                            add-spaces-to-labels
                            capitalize-first-word
                            collapse-contiguous-spaces-in-labels
                            convert-percent-hex-in-labels
                            display-subclassof-as-superclass
                            enforce-max-node-label-length
                            exclude-namespaces-from-labels
                            find-only-shortest-paths
                            fit-row-height-to-text
                            show-full-uris-in-tables
                            show-full-uris-on-nodes
                            use-label-properties
                            ))
         (saved-options (mapcar (lambda (option-name)
                                  (list option-name (funcall option-name node-pane)))
                          options-to-save))
         (entries *gruff-testers*)
         (entries-tail (member 'start entries))
         name action-form test-form problem-count finish-message)
    
    ;; If "start" has been inserted into the list of entries,
    ;; then run only the entries after that point.
    (when entries-tail (setq entries (rest entries-tail)))
    
    (setf gf frame)
    (setf np node-pane)
    (setq tp (table-pane frame))
    (setq tg (find-component :grid tp))
    (setq op (outline-view-pane frame))
    (setq oo (find-component :outline op))
    (when host (setf (tester-value :host) host))
    (when port (setf (tester-value :port) port))
    (when username (setf (tester-value :username) username))
    (when password (setf (tester-value :password) password))
    
    ;; Unless the previous gruff tester store was left open for reuse,
    ;; create a new gruff tester store.
    (unless (a-store-is-open)
      #-allegrograph3
      (create-store-from-prompts ;; rfe12282
       np :catalog "Root" :store-name "gruff-tester" :access-mode :remote ;; rfe11933
       :host (tester-value :host) :port (tester-value :port) :scheme :http ;; bug22832
       :user (tester-value :username) :password (tester-value :password)
       :overwrite-if-exists t)
      #+allegrograph3
      (create-store-from-prompts ;; rfe12282
       np :store-name (merge-pathnames "gruff-tester" (sys:temporary-directory))
       :access-mode :local :estimated-triples 1000 ;; rfe11933
       :overwrite-if-exists t)
      #-allegrograph3
      (progn
        (setf (tester-value :host)(most-recent-host np))
        (setf (tester-value :port)(most-recent-port np))
        (setf (tester-value :username)(most-recent-user np))
        (setf (tester-value :password) *gruff-password*)))
    (unless (a-store-is-open)
      (gruff-message gf "Gruff testing CANCELED.")
      (return-from test-gruff))
    
    (with-open-file (out report-path
                         :direction :output
                         :if-exists :supersede)
      (format out ;; from gruff-bug-report-2
          "~&Gruff Tester Results    ~a~%~%~
               Gruff version:          ~a~%~
               AllegroGraph version:   ~a~%~
               CG version:             ~a~%~
               Lisp version:           ~a~%~
               Platform:               ~a"
        (gruff-format-universal-time (get-universal-time))
        *gruff-version*
        triple-store:*agraph-version*
        (common-graphics-implementation-version)
        (lisp-implementation-version)
        (cond (platform-info
               (format nil "~a ~a.~a ~a"
                 (getf platform-info :platform)
                 (getf platform-info :major-version)
                 (getf platform-info :minor-version)
                 (or (getf platform-info :csd-version) "")))
              (t #+gtk "GTK" #-gtk "Unknown")))
      (key-is-down-p vk-escape)
      
      (unwind-protect
          
          ;; Run each of the tests.
          (dolist (entry entries)
            
            ;; If "stop" has been inserted into the list of entries,
            ;; then stop when that point is reached.
            (when (eq entry 'stop)(return))
            
            (setq name (first entry))
            (setq action-form (second entry))
            (setq test-form (third entry))
            (gruff-message frame "Running test ~a" name)
            
            ;; Remember that "result" is a global variable
            ;; that test forms can use.
            (setq result (evaluate-gruff-test-form
                          name action-form out debug-on-error))
            
            (cond ((eq result :gruff-tester-error)
                   (incf error-count)
                   (return))
                  (test-form
                   (unless (evaluate-gruff-test-form
                            name test-form out debug-on-error)
                     (incf failure-count)
                     (format out "~&~%Failure in ~a~%Form        ~s~%~
                                      Result      ~s~%Validator   ~s"
                       name action-form result test-form))))
            
            ;; Let the user interrupt the tests at any time
            ;; by pressing the Escape key.
            (multiple-value-bind (down-now has-been-down)
                (key-is-down-p vk-escape)
              (declare (ignore down-now))
              (when has-been-down (return))))
        
        ;; On unwinding, restore all of the user's preferences
        ;; that the testers may have modified.
        (dolist (pair saved-options)
          (funcall (fdefinition `(setf ,(first pair)))
                   (second pair) node-pane))
      
        (setq problem-count (+ failure-count error-count))
        (setq finish-message
              (format nil "~a  Gruff testing completed with ~
                           ~(~r~) failure~:p and ~(~r~) error~:p."
                (if (zerop problem-count) "Yay!" "Argh.")
                failure-count error-count))
        (format out "~&~%~a~%" finish-message)))
    (unless (zerop problem-count)
      (invoke-program-for-string node-pane (namestring report-path)))
    (gruff-message frame "~a" finish-message)))

(defun evaluate-gruff-test-form (name form stream debug-on-error)
  (handler-bind
      ((error (lambda (condition)
                (format stream "~&~%Error in ~a~%~s~%~a"
                  name form condition)
                (unless debug-on-error
                  (return-from evaluate-gruff-test-form :gruff-tester-error)))))
    (let* ((old-store triple-store:*db*)
           (old-count (and old-store (triple-store:triple-count)))
           (answer (mp:with-message-interrupts-disabled
                       (eval form))))
      (unless (or (not old-store)
                  (not (eq old-store triple-store:*db*))
                  (= old-count (triple-store:triple-count)))
        (uncache-for-modified-triple-store))
      answer)))

#+test
(test-gruff :host "penn" :port 10088 :username "test" :password "xyzzy"
            :debug-on-error nil)


(defun various-upis (node-pane)
  (list
   (intern-resource-retrying "http://franz.com/animal#Harry_the_bird")
   (intern-resource-retrying "http://franz.com/brev#abbreviation")
   (intern-resource-retrying "http://chainyi.com/event-艺术_2173.txt-2780")
   (intern-literal-retrying "simple literal")
   (intern-literal-retrying "中山市Ĺ?力交œ?Ĺ?爱好者学会")
   (intern-literal-retrying "English literal" :language "en")
   (triple-store:intern-literal 
    "1.111E0"
    #-allegrograph3 :datatype
    #-allegrograph3 "http://www.w3.org/2001/XMLSchema#float")
   (uf::find-upi-for-string node-pane "\"1.333E0\"^^<http://www.w3.org/2001/XMLSchema#float>")
   (value->upi-retrying 1.444 :single-float)
   (value->upi-retrying (get-universal-time) :date-time)
   (triple-store:new-blank-node)
   ))

(defun print-strings-of-upis (node-pane)
  (register-namespace-retrying "brev" "http://franz.com/brev#")
  (dolist (upi (various-upis node-pane))
    (let* ((ntriples (part-to-string-safe upi :ntriples)) ;; bug21545
           (long (part-to-string-safe upi :long))
           (concise (part-to-string-safe upi :concise))
           (terse (part-to-string-safe upi :terse)))
      (multiple-value-bind (value type-code extra)
          (ignore-errors (triple-store:part->value upi))
        (format t "~&Type:       ~s~%~
                     Self:       ~a~%~
                     Value:      ~a~%~
                     Extra:      ~a~%~
                     Lisp Type:  ~a~%~
                     N-Triples:  ~a~%~
                     Long:       ~a~%~
                     Concise:    ~a~%~
                     Terse:      ~a~%~%"
          (and type-code (triple-store:type-code->type-name type-code))
          upi value extra (type-of value)
          ntriples long concise terse)))))

    
