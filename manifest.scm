(define-module (manifest)
  #:use-module ((gnu packages autotools) #:select (autoconf
                                                   automake
                                                   libtool))
  #:use-module ((gnu packages bison) #:select (bison))
  #:use-module ((gnu packages compiler-tools) #:select (flex))
  #:use-module ((gnu packages man) #:select (help2man))
  #:use-module ((gnu packages popt) #:select (gengetopt))
  #:use-module ((guix build-system gnu) #:select (gnu-build-system))
  #:use-module ((guix download) #:select (url-fetch))
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module ((guix packages) #:select (base32
                                          package
                                          origin))
  #:use-module ((guix profiles) #:select (concatenate-manifests
                                          package->development-manifest
                                          packages->manifest)))

(define gengen
  (package
    (name "gengen")
    (version "1.4.2")
    (source
     (origin
       (method url-fetch)
       (uri (string-append "mirror://gnu/gengen/gengen-" version ".tar.gz"))
       (sha256
        (base32
         "1scq0za8xjlls7n1bglrx07x5z3nnhvwnh0zm7vnq589dihxx6zl"))))
    (build-system gnu-build-system)
    (arguments
     `(#:configure-flags '("CXXFLAGS=-std=c++11")
       #:parallel-tests? #f))           ; do not work
    (synopsis "A parameterized-text-generator generator based on a template")
    (description
     "Gengen (GENerator GENerator) is a tool that, starting from a parameterized
text, called template, generates a text generator that can substitute parameters
with values.

At the moment Gengen can generate C++ or C code; however other target languages
are under development (e.g., Java).")
    (home-page "https://www.gnu.org/software/gengen")
    (license license:gpl3+)))

(concatenate-manifests
 (list
  (packages->manifest (list autoconf
                            automake
                            bison
                            flex
                            gengen
                            gengetopt   ;we need ourself for build from git
                            help2man
                            libtool))
  (package->development-manifest gengetopt)))

;;; Local Variables:
;;; geiser-guile-binary: ("guix" "repl")
;;; End:
