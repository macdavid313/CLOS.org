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

;; Customize the HTML output
(setq org-html-doctype "html5"
      org-html-html5-fancy t

      org-html-validation-link t
      org-html-head-include-scripts nil
      org-html-head-include-default-style nil

      org-html-head-extra "<link rel=\"shortcut icon\" href=\"/static/img/favicon.ico\">
<link rel=\"stylesheet\" href=\"https://cdn.simplecss.org/simple.min.css\" />")

;; Define the publishing project
(setq *site-url* "macdavid313.xyz")

(setq org-publish-project-alist
      (list

       (list "pages"
             :recursive nil
             :base-directory "./content"
             :base-extension "org"
             :publishing-function 'org-html-publish-to-html
             :publishing-directory "./public"
             :with-author t
             :with-creator t
             :with-toc nil
             :section-numbers nil
             :time-stamp-file nil)

       (list "posts"
             :recursive t
             :base-directory "./content/posts"
             :base-extension "org"
             :publishing-function 'org-html-publish-to-html
             :publishing-directory "./public/posts"
             :with-author nil
             :with-creator t
             :with-toc t
             :section-numbers nil
             :time-stamp-file nil
             :html-link-home "/"
             :html-link-up "/posts"

             :auto-sitemap t
             :sitemap-title "gty 博客 (Blog)"
             :sitemap-filename "index.org"
             :sitemap-sort-files 'anti-chronologically)

       (list "static"
             :base-directory "./content/static"
             :base-extension "css\\|txt\\|jpg\\|gif\\|png\\|ico"
             :recursive t
             :publishing-directory  "./public/static/"
             :publishing-function 'org-publish-attachment)

       (list *site-url* :components '("pages" "posts" "static"))))

;; Generate the site output
(org-publish *site-url* t)

(message "Published successfully!")

;;; publish.el ends here
