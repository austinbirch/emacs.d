;; First a dirty, but cheap way to get .emacs.d subfolders into the load path,
;; and then return us to the user home directory, for find-file etc.
;(progn (cd "~/.emacs.d/") (normal-top-level-add-subdirs-to-load-path) (cd "~"))

(require 'cl)
(require 'package)

(add-to-list 'package-archives
             '("melpa" . "http://melpa.milkbox.net/packages/") t)
(add-to-list 'package-archives
             '("marmalade" . "http://marmalade-repo.org/packages/"))

(package-initialize)

(defvar my-packages
  '(
    auto-complete
    dash
    s
    f
    ag
    multiple-cursors
    js2-refactor
    helm
    dropdown-list
    switch-window
    ;resize-window ;; local
    highlight-indentation
    ;squeeze-view ;; local
    hexrgb
    ;kill-buffer-without-confirm ;; local
    ;scroll-bell-fix ;; local
    dabbrev
    ac-dabbrev
    ;code-wrap ;; local
    evil-matchit
    web-mode
    ;acdabbrev ;; local
    rainbow-delimiters
    simple-httpd
    ;visual-progress ;; local
    solarized-theme
    evil
    evil-leader
    evil-surround
    flycheck
    expand-region
    hideshowvis
    multi-web-mode
    simpleclip
    direx
    popwin
    buffer-move
    projectile
    clojure-mode
    )
  "A list of packages to ensure are installed at launch.")

(defun my-packages-installed-p ()
  "Check if all packages in `my-packages' are installed."
  (every #'package-installed-p my-packages))

(defun my-require-package (package)
  "Install PACKAGE unless already installed."
  (unless (memq package my-packages)
    (add-to-list 'my-packages package))
  (unless (package-installed-p package)
    (package-install package)))

(defun my-require-packages (packages)
  "Ensure PACKAGES are installed.
Missing packages are installed automatically."
  (mapc #'my-require-package packages))

(define-obsolete-function-alias 'my-ensure-module-deps 'my-require-packages)

(defun my-install-packages ()
  "Install all packages listed in `my-packages'."
  (unless (my-packages-installed-p)
    ;; check for new packages (package versions)
    (message "%s" "Emacs my is now refreshing its package database...")
    (package-refresh-contents)
    (message "%s" " done.")
    ;; install the missing packages
    (my-require-packages my-packages)))

;; run package installation
(my-install-packages)

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(custom-safe-themes
   (quote
    ("8aebf25556399b58091e533e455dd50a6a9cba958cc4ebb0aab175863c25b9a4" default))))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )

(add-to-list 'default-frame-alist '(font . "M+ 1mn-11"))

(add-to-list 'load-path "~/.emacs.d/plugins")
(add-to-list 'load-path "~/.emacs.d/modes-init")
(add-to-list 'load-path "~/.emacs.d/custom")


;; menu bar mode only on OS X, just because it's pretty much out of
;; the way, as opposed to sitting right there in the frame.
(if (display-graphic-p)
  (progn
;; turn off toolbar.
    (if (fboundp 'tool-bar-mode) (tool-bar-mode -1))
     (menu-bar-mode 1))
     (menu-bar-mode -1))

(setq frame-title-format '("%b %I %+%@%t%Z %m %n %e"))

;; Explicitly require libs that autoload borks
;; Include common lisp:
(require 'cl-lib)
(require 'dash)
(require 's)
(require 'f)
(require 'ag)
(require 'multiple-cursors)
(require 'js2-refactor)

(when (display-graphic-p)
  (require 'helm))

;;(require 'smartparens)
;;(require 'smartparens-config)

;; -------------------------------------------------------------------------------------------------
;; Additional requires
;; -------------------------------------------------------------------------------------------------
;;; Convenience and completion
;(require 'auto-complete-config)        ;; Very nice autocomplete.
;(ac-config-default)

;(require 'auto-complete)
;(add-to-list 'ac-dictionary-directories "~/.emacs.d/dict")
;(require 'auto-complete-config)
;(ac-config-default)

(require 'dropdown-list)               ;; dropdown list for use with yasnippet
(require 'switch-window)               ;; Select windows by number.
;(require 'resize-window)               ;; interactively size window
(require 'highlight-indentation)       ;; visual guides for indentation
;(require 'squeeze-view)                ;; squeeze view, give yourself a write-room/typewriter like writing page
(require 'hexrgb)
;(require 'kill-buffer-without-confirm) ;; yes, I really meant to close it.
;(require 'scroll-bell-fix)             ;; a small hack to turn off the buffer scroll past top/end bell.
(require 'dabbrev)
(require 'ac-dabbrev)

;; no scrolblars
(when (display-graphic-p)
  (scroll-bar-mode -1))

;; Turn on things that auto-load isn't doing for us...
;(yas-global-mode t)

; Autopair alternative
;(when (display-graphic-p)
  ;(flex-autopair-mode t))

;; Rainbow mode for css automatically
(add-hook 'css-mode-hook 'rainbow-mode)

;; Rainbow delimiters for all prog modes
(add-hook 'prog-mode-hook 'rainbow-delimiters-mode)

;; Git gutter global mode
;(add-hook 'prog-mode-hook 'git-gutter-mode)

;; Smoother scrolling (no multiline jumps.)
(setq redisplay-dont-pause t
      scroll-margin 1
      scroll-step 1
      scroll-conservatively 10000
      scroll-preserve-screen-position 1)

;; show paren mode
(show-paren-mode 1)
(setq show-paren-delay 0)

;; use y / n instead of yes / no
(fset 'yes-or-no-p 'y-or-n-p)

;; allow "restricted" features
(put 'set-goal-column           'disabled nil)
(put 'erase-buffer              'disabled nil)
(put 'downcase-region           'disabled nil)
(put 'upcase-region             'disabled nil)
(put 'narrow-to-region          'disabled nil)
(put 'narrow-to-page            'disabled nil)
(put 'dired-find-alternate-file 'disabled nil)


;; -------------------------------------------------------------------------------------------------
;; Highlight TODO/FIXME/BUG/HACK/REFACTOR/AKKROO_NOTE
(add-hook 'prog-mode-hook
               (lambda ()
                (font-lock-add-keywords nil
                 '(("\\<\\(NOTE\\|FIXME\\|TODO\\|BUG\\|HACK\\|REFACTOR\\|AKKROO_NOTE\\)" 1 font-lock-warning-face t)))))

;; -------------------------------------------------------------------------------------------------
;; use aspell for ispell
(when (file-exists-p "/usr/local/bin/aspell")
  (set-variable 'ispell-program-name "/usr/local/bin/aspell"))

;; -------------------------------------------------------------------------------------------------
;; JavaScript/JSON special files
(dolist (pattern '("\\.jshintrc$" "\\.jslint$"))
  (add-to-list 'auto-mode-alist (cons pattern 'json-mode)))

; javascript
(autoload 'js2-mode "js2-mode" nil t)
(add-to-list 'auto-mode-alist '("\\.js$" . js2-mode))

(require 'simple-httpd)

;; Conditional start of Emacs Server
(setq server-use-tcp t)
(server-start)

;; -------------------------------------------------------------------------------------------------

;; -----------------------------------------------------------------------------------------------
;; Custom stuff from me.
;; -----------------------------------------------------------------------------------------------
;;(require 'powerline)
;;(powerline-default-theme)
;;(require 'visual-progress-mode)
;;(load-theme 'soothe t)
;;(load-theme 'mccarthy t)
;;(load-theme 'cyberpunk)

;; quiet, please! No dinging!
(setq ring-bell-function 'ignore) ;; no bells
;(setq ring-bell-function `(lambda ()
;(set-face-background 'default "DodgerBlue")
;(set-face-background 'default "black")))

(load-theme 'solarized-dark)

;; Kill the welcome buffer
(setq inhibit-startup-message t)

;; Disable splash screen
(setq inhibit-splash-screen t)

;;;; Highlight indent, for python, maybe more
;;(defun setup-indentation-mode ()
  ;;(interactive)
  ;;(require 'highlight-indentation)
  ;;(require 'indent-guide)
  ;;(highlight-indentation-mode)
  ;;(indent-guide-mode)
  ;;)
;;(add-hook 'python-mode-hook 'setup-indentation-mode)

;;; Shortcurt for selecting lispy ranges
;(defun evil-select-lisp-form ()
  ;(interactive)
  ;(evil-visual-char)
  ;(evil-jump-item)
  ;)
;(global-set-key (kbd "C-5") 'evil-select-lisp-form)

;(global-set-key (kbd "C-9") 'zencoding-expand-line)

;; Load evil
(require 'init-evil)

(evil-leader/set-key "n" 'new-buffer)
(evil-leader/set-key "t" 'switch-to-previous-buffer)
;(evil-leader/set-key "re" 'recentf-open-files)
(evil-leader/set-key "rl" 'revert-buffer)
(evil-leader/set-key "l" 'buffer-list-in-window)
(evil-leader/set-key "i" 'imenu)
(evil-leader/set-key "c" 'delete-window)
(evil-leader/set-key "p" 'switch-to-prev-buffer)
(evil-leader/set-key ":" 'helm-complex-command-history)
(evil-leader/set-key "f" 'ace-jump-mode)
(evil-leader/set-key "e" 'projectile-find-file)
(evil-leader/set-key "/" 'evilnc-comment-or-uncomment-lines)

; evil extension for html tag selection like matchit
(require 'evil-matchit)
(global-evil-matchit-mode 1)

;(require 'my-functions) ;; TODO: needed?

;(require 'custom-keys) ;; TODO: needed?

; load evil surround
(require 'evil-surround)
(global-evil-surround-mode 1)

;; Run emacs in server mode, so that we can connect from commandline
(server-start)

(define-key ac-complete-mode-map "\C-n" 'ac-next)
(define-key ac-complete-mode-map "\C-p" 'ac-previous)

;; Support for expand region
(require 'expand-region)
(global-set-key (kbd "C-=") 'er/expand-region)

;; http://stackoverflow.com/questions/6344474/how-can-i-make-emacs-highlight-lines-that-go-over-80-chars
;; free of trailing whitespace and to use 80-column width, standard indentation
(setq whitespace-style '(trailing lines space-before-tab
                                  indentation space-after-tab)
      whitespace-line-column 80)

(setq delete-old-versions t
      kept-new-versions 6
      kept-old-versions 2
      version-control t)

;; flycheck
(require 'flycheck)

;; Switching to relative number
(global-linum-mode 1)
(require 'relative-number)

(when (display-graphic-p)
  (helm-mode 1)
  (global-set-key (kbd "s-.") 'helm-complete-file-name-at-point))

(require 'init-hideshowvis)

 ; set different linum color
; and cua mode for copy / paste
(cua-mode)

(setq evil-default-cursor t)
(set-cursor-color "#ffffff")

;; Terminal
(require 'init-term)

; Multicursor
(require 'init-multicursor)

(require 'multi-web-mode)

;; TODO: why?
; http://stackoverflow.com/questions/683425/globally-override-key-binding-in-emacs
(defvar my-keys-minor-mode-map (make-keymap) "my-keys-minor-mode keymap.")

(define-key my-keys-minor-mode-map (kbd "C-.") 'execute-extended-command)

(define-minor-mode my-keys-minor-mode
  "A minor mode so that my key settings override annoying major modes."
  t " my-keys" 'my-keys-minor-mode-map)

(my-keys-minor-mode 1)

; do not do this in minibuffer
(defun my-minibuffer-setup-hook ()
  (my-keys-minor-mode 0))

(add-hook 'minibuffer-setup-hook 'my-minibuffer-setup-hook)

(require 'ace-jump-mode)
(define-key global-map (kbd "C-c SPC") 'ace-jump-mode)

; Simple clip makes it possible to not overwrite clipboard during yanking
; https://github.com/rolandwalker/simpleclip
(require 'simpleclip)
(simpleclip-mode 1)

; add s-n for opening a new window
(global-set-key (kbd "s-n") 'new-frame)

; file browser (useful especially for scala stuff with the huge directory tree)
(require 'direx)
(require 'popwin)
(push '(direx:direx-mode :position left :width 25 :dedicated t)
      popwin:special-display-config)
(global-set-key (kbd "C-x C-j") 'direx:jump-to-directory-other-window)

; Also, we want to move windows around
(require 'buffer-move)
(global-set-key (kbd "<C-s-up>")     'buf-move-up)
(global-set-key (kbd "<C-s-down>")   'buf-move-down)
(global-set-key (kbd "<C-s-left>")   'buf-move-left)
(global-set-key (kbd "<C-s-right>")  'buf-move-right)

;; my task mode
;;(require 'task-mode)
;; and set up leaders for it
;;(evil-leader/set-key-for-mode 'task-mode "d" 'task-mode-todo-task)
;;(evil-leader/set-key-for-mode 'task-mode "a" 'task-mode-archive-done)
;;(evil-leader/set-key-for-mode 'task-mode "c" 'task-mode-new-todo)

(setq linum-format "%4d")
(ac-linum-workaround)

(require 'projectile)
(projectile-global-mode)
(setq projectile-completion-system 'grizzl)

; Font lock mode variations to maybe speed up scrolling
;(setq font-lock-support-mode 'fast-lock-mode ; lazy-lock-mode  / jit-lock-mode
;(setq jit-lock-defer-time 0.05) ; http://tsengf.blogspot.de/2012/11/slow-scrolling-speed-in-emacs.html
; http://stackoverflow.com/questions/3631220/fix-to-get-smooth-scrolling-in-emacs
(setq redisplay-dont-pause t
  scroll-margin 1
  scroll-step 1
  scroll-conservatively 10000
  scroll-preserve-screen-position 1
  jit-lock-defer-time 0.05
  font-lock-support-mode 'jit-lock-mode)
(setq-default scroll-up-aggressively 0.01 scroll-down-aggressively 0.01) 

;If you never expect to have to display bidirectional scripts, like
;Arabic, you can make that the default:
(setq-default bidi-paragraph-direction 'left-to-right)

(require 'web-mode)

(add-to-list 'auto-mode-alist '("\\.phtml\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.tpl\\.php\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.blade\\.php\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.jsp\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.as[cp]x\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.erb\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.html?\\'" . web-mode))
(add-to-list 'auto-mode-alist
'("/\\(views\\|html\\|theme\\|templates\\)/.*\\.php\\'" . web-mode))

(eval-after-load 'web-mode
  '(progn
     (defun prelude-web-mode-defaults ()
       ;; Disable whitespace-mode when using web-mode
       (whitespace-mode -1)
       ;; Customizations
       (setq web-mode-markup-indent-offset 4)
       (setq web-mode-css-indent-offset 2)
       (setq web-mode-code-indent-offset 4)
       (setq web-mode-disable-autocompletion t)
       (local-set-key (kbd "RET") 'newline-and-indent))
     (setq prelude-web-mode-hook 'prelude-web-mode-defaults)

     (add-hook 'web-mode-hook (lambda ()
                                 (run-hooks 'prelude-web-mode-hook)))))

(setq shell-file-name "bash")

(require 'evil-matchit)
(global-evil-matchit-mode 1)

(defun accents ()
  (interactive)
  (set-language-environment "UTF-8")
  (activate-input-method "latin-1-alt-postfix"))

(defun current-lang ()
  (interactive)
  (eval-expression current-language-environment))

; Dash integration
(global-set-key "\C-cd" 'dash-at-point)

;; toggle comments
(defun comment-or-uncomment-region-or-line ()
    "Comments or uncomments the region or the current line if there's no active region."
    (interactive)
    (let (beg end)
        (if (region-active-p)
            (setq beg (region-beginning) end (region-end))
            (setq beg (line-beginning-position) end (line-end-position)))
        (comment-or-uncomment-region beg end)))
(global-set-key "\C-c\," 'comment-or-uncomment-region-or-line)


;; EDITS AFTER HERE, NEED TO CLEANUP ORDER OF ABOVE

;; general --------------------------------------------------------------------
(setq-default indent-tabs-mode nil) ;; spaces only, no tabs
(setq standard-indent 2) ;; 2 spaces indentation by default
(setq tab-width 2)

(global-linum-mode t) ;; show line numbers
(setq-default column-number-mode t) ;; show column numbers
(global-hl-line-mode 1) ;; highlight the current line
(electric-indent-mode +1) ;; indent on return

(setq-default fill-column 80) ;; 80 chars wide

;; backups & autosaves ---------------------------------------------------------
(setq create-lockfiles nil) ;; no lock files (concurrent user write protection)

(defvar backup-dir (expand-file-name "~/.emacs.d/backups/"))
(defvar autosave-dir (expand-file-name "~/.emacs.d/autosaves/"))
(setq backup-directory-alist (list (cons ".*" backup-dir)))
(setq auto-save-list-file-prefix autosave-dir)
(setq auto-save-file-name-transforms `((".*", autosave-dir t)))

;; delete trailing whitespace on save
(add-hook 'before-save-hook 'delete-trailing-whitespace)

(setq
 make-backup-files t
 delete-old-versions t
 kept-new-versions 6
 kept-old-version 2
 version-control t)


;; move windows with hjkl
(windmove-default-keybindings)
(global-set-key (kbd "C-c h")  'windmove-left)
(global-set-key (kbd "C-c l") 'windmove-right)
(global-set-key (kbd "C-c k")    'windmove-up)
(global-set-key (kbd "C-c j")  'windmove-down)

;; css & scss mode -------------------------------------------------------------
(setq scss-compile-at-save nil)
(setq css-indent-offset 2)

;; autocomplete ----------------------------------------------------------------
(require 'auto-complete)

;; BEFORE
;; (global-auto-complete-mode t)
;; ;; (setq ac-auto-start 1)
;; (global-set-key "\M-/" 'auto-complete)

;; ;; select ac option with C-n & C-p
;; (setq ac-use-menu-map t)

;; Emacs Live

(global-auto-complete-mode t)
(setq ac-auto-show-menu t)
(setq ac-dwim t)
(setq ac-use-menu-map t)
(setq ac-quick-help-delay 1)
(setq ac-quick-help-height 60)
(setq ac-disable-inline t)
(setq ac-show-menu-immediately-on-auto-complete t)
(setq ac-auto-start 2)
(setq ac-candidate-menu-min 0)

(set-default 'ac-sources
             '(ac-source-dictionary
               ac-source-words-in-buffer
               ac-source-words-in-same-mode-buffers))

(dolist (mode '(magit-log-edit-mode log-edit-mode org-mode text-mode haml-mode
                sass-mode yaml-mode csv-mode espresso-mode haskell-mode
                html-mode nxml-mode sh-mode smarty-mode clojure-mode
                lisp-mode textile-mode markdown-mode tuareg-mode))
  (add-to-list 'ac-modes mode))

;; parens ----------------------------------------------------------------------
(require 'rainbow-delimiters)
(add-hook 'prog-mode-hook 'rainbow-delimiters-mode)

;; underline matching parentheses when the cursor is on them
(show-paren-mode 1)
(setq-default show-paren-style 'parentheses)
(set-face-attribute 'show-paren-match-face nil
                    :weight 'bold
                    :underline t
                    :background nil
                    :foreground nil
                    :inverse-video nil)

;; auto complete the pairs
(electric-pair-mode 1)

;; clojure
; docs: https://github.com/clojure-emacs/cider
; C-c C-m : invoke macro-expand at point
; repl M-p M-n back forth history
; repl C-j new line-indent
(add-hook 'cider-mode-hook 'cider-turn-on-eldoc-mode)
(setq nrepl-hide-special-buffers t)
(setq cider-repl-pop-to-buffer-on-connect t)
(setq cider-auto-select-error-buffer t)
(add-hook 'cider-repl-mode-hook 'paredit-mode)
(add-hook 'cider-repl-mode-hook 'rainbow-delimiters-mode)
