;;; pubish.el --- Description -*- lexical-binding: t; -*-
;;
;; Copyright (C) 2022 Tianyu Gu
;;
;; Author: Tianyu Gu <macdavid313@gmail.com>
;; Maintainer: Tianyu Gu <macdavid313@gmail.com>
;; Created: October 20, 2022
;; Modified: October 20, 2022
                                        ;
;; This file is not part of GNU Emacs.
;;
;;; Code:

(require 'package)
(setq package-user-dir (expand-file-name "./.packages"))
(setq package-archives '(("melpa" . "https://melpa.org/packages/")
                         ("elpa" . "https://elpa.gnu.org/packages/")))

;; Initialize the package system
(package-initialize)
(unless package-archive-contents
  (package-refresh-contents))

;; Install dependencies
(package-install 'htmlize)

;; Load the publishing system
(require 'ox-publish)

;; Disable evaluating code blocks
(setq org-export-use-babel nil)

;; Override org-publish-find-date function
(defun org-publish-find-date (entry project)
  (let ((ts-str (cl-first (org-publish-find-property entry :date project))))
    (org-time-string-to-time ts-str)))

;; Customize the HTML output
(setq org-html-doctype "html5"
      org-html-html5-fancy t

      org-html-validation-link nil
      org-html-head-include-scripts nil
      org-html-head-include-default-style t

      org-html-head-extra "<link rel=\"shortcut icon\" href=\"/static/img/favicon.ico\">
<link rel=\"preconnect\" href=\"https://fonts.googleapis.com\">
<link rel=\"preconnect\" href=\"https://fonts.gstatic.com\" crossorigin>
<link href=\"https://fonts.googleapis.com/css2?family=JetBrains+Mono&family=Source+Serif+Pro&display=swap\" rel=\"stylesheet\">
<link rel=\"stylesheet\" href=\"/static/css/style.css\" type=\"text/css\" />"

      org-html-preamble "<nav>
  <a href=\"/\">&lt; Home</a>
  <a href=\"/posts/index.html\">&lt; Blog</a>
</nav>"

      org-html-postamble "<footer><div class=\"generated\">Created with %c</div></footer>")

;; Sitemap customisations
(setq org-export-global-macros
      '(("timestamp" . "@@html:<span class=\"timestamp\">[$1]</span>@@")))

(defun macdavid313/org-sitemap-date-entry-format (entry style project)
  (let ((filename (org-publish-find-title entry project)))
    (if (= (length filename) 0)
        (format "*%s*" entry)
      (format "{{{timestamp(%s)}}} [[file:%s][%s]]"
              (format-time-string "%Y-%m-%d" (org-publish-find-date entry project))
              entry
              filename))))

;; Define the publishing project
(setq *site-url* "macdavid313.xyz")

(setq org-publish-project-alist
      (list

       (list "pages"
             :recursive nil
             :base-directory (expand-file-name "content")
             :base-extension "org"
             :publishing-function 'org-html-publish-to-html
             :publishing-directory (expand-file-name "public")
             :with-author nil
             :with-creator t
             :with-toc nil
             :section-numbers nil
             :time-stamp-file nil)

       (list "posts"
             :recursive t
             :base-directory (expand-file-name "content/posts")
             :base-extension "org"
             :publishing-function 'org-html-publish-to-html
             :publishing-directory (expand-file-name "public/posts")
             :with-author nil
             :with-creator t
             :with-toc t
             :section-numbers t
             :time-stamp-file nil

             :auto-sitemap t
             :sitemap-title "博客 (Blog)"
             :sitemap-filename "index.org"
             :sitemap-sort-files 'anti-chronologically
             :sitemap-format-entry 'macdavid313/org-sitemap-date-entry-format)

       (list "static"
             :base-directory (expand-file-name "content/static")
             :base-extension "css\\|txt\\|jpe?g\\|gif\\|png\\|ico\\|webp"
             :recursive t
             :publishing-directory (expand-file-name "public/static/")
             :publishing-function 'org-publish-attachment)

       (list *site-url* :components '("pages" "posts" "static"))))

;; Generate the site output
(org-publish *site-url* t)

(message "Published successfully!")

;;; publish.el ends here
