;;; init.el --- EXWM configuration -*- lexical-binding: t; -*-

;; The following lines load an Org file and build the configuration code out of it.

;;; Code:

(let ((gc-cons-percentage .6)
      (gc-cons-threshold most-positive-fixnum)
      (read-process-output-max (* 1024 1024)))

  ;; Disable that pesky echo message
  (setq-default inhibit-startup-echo-area-message (user-login-name))

  ;; Set repositories
  (require 'package)
  (setq-default
   load-prefer-newer t
   package-enable-at-startup nil)
  (add-to-list 'package-archives '("melpa" . "http://melpa.org/packages/") t)
  (add-to-list 'package-archives '("org" . "http://orgmode.org/elpa/") t)
  (package-initialize)

  ;; Install dependencies
  (unless (package-installed-p 'use-package)
    (package-refresh-contents)
    (package-install 'use-package t))
  (setq-default
   use-package-always-defer t
   use-package-always-ensure t)

  ;; Use latest Org
  (use-package org :ensure org-plus-contrib)

  ;; Tangle configuration
  (org-babel-load-file (expand-file-name "config.org" user-emacs-directory))
  (garbage-collect))

;;; init.el ends here
