(use-modules (gnu packages autotools)
             (gnu packages bison)
             (gnu packages commencement)
             (gnu packages flex)
             (gnu packages man)
             (gnu packages popt)
             (guix build-system gnu)
             (guix download)
             (guix licenses)
             (guix packages)
             (guix profiles)
             (guix utils)
             (srfi srfi-1))

(define gengen
  (package
    (name "gengen")
    (version "1.4.2")
    (source
     (origin
       (method url-fetch)
       (uri (string-append "mirror://gnu/gengen/gengen-"
                           version ".tar.gz"))
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
    (license gpl3+)))

(concatenate-manifests
 (list
  (packages->manifest (list autoconf
                            automake
                            bison
                            flex
                            (specification->package "gcc-toolchain")
                            gengen
                            gengetopt
                            help2man
                            libtool))
  (package->development-manifest gengetopt)))

;;; Local Variables:
;;; geiser-guile-binary: ("guix" "repl")
;;; End:
