(setq custom-file (make-temp-file "emacs-custom"))

(setq inhibit-startup-message t)


;; ====================
;;  Basic UI tweaks
;; ====================
(scroll-bar-mode 0)
(tool-bar-mode 0)
(tooltip-mode 0)
(menu-bar-mode 0)

(set-face-attribute 'default nil :font "CaskaydiaCove NF" :height 110)

(setq make-backup-files nil)  ;; stop creating backup~ files

(setq display-line-numbers-type 'absolute)
(global-display-line-numbers-mode 1)

;; Make ESC quit prompts
(global-set-key (kbd "<escape>") 'keyboard-escape-quit)

(require 'package)
(setq package-archives '(("melpa" . "https://melpa.org/packages/")
			 ("melpa-stable" . "https://stable.melpa.org/packages/")
			 ("org" . "https://orgmode.org/elpa/")
			 ("elpa" . "https://elpa.gnu.org/packages/")))
(package-initialize)
(unless package-archive-contents
  (package-refresh-contents))

(unless (package-installed-p 'use-package)
  (package-install 'use-package))

(require 'use-package)
(setq use-package-always-ensure t)

;; evil mode for vim bindings may turn this off in future
(use-package evil
  :ensure t
  :init
	(setq evil-want-integration t) ;; This is optional since it's already set to t by default.
  (setq evil-want-keybinding nil)
  :config
  (evil-mode 1)
  ;; Block cursor in all modes, default color
  (setq evil-normal-state-cursor 'box
	evil-insert-state-cursor 'box
	evil-visual-state-cursor 'box
	evil-replace-state-cursor 'box
	evil-operator-state-cursor 'box)

	;; Make C-g behave like ESC in Evil
	(define-key evil-insert-state-map (kbd "C-g") 'evil-normal-state)
	(define-key evil-visual-state-map (kbd "C-g") 'evil-normal-state)
	(define-key evil-replace-state-map (kbd "C-g") 'evil-normal-state)
	(define-key evil-operator-state-map (kbd "C-g") 'evil-normal-state)

	;; Disable Evil in vterm buffers
	(add-hook 'vterm-mode-hook (lambda () (evil-local-mode -1))))

;; evil collection
(use-package evil-collection
  :after evil
  :ensure t
  :config
  (evil-collection-init))

;; vim surround type shi
(use-package evil-surround
  :after evil
  :config
  (global-evil-surround-mode 1))


;; (setq-default indent-tabs-mode nil)
(setq-default tab-width 2)
(setq-default evil-shift-width 2)

;; Global TAB in insert mode inserts 2 spaces
(defun my-global-insert-tab ()
  "Insert spaces equal to `evil-shift-width` in insert mode."
  (interactive)

  (insert (make-string evil-shift-width ?\s)))

;; Remap TAB in insert mode to indent
(define-key evil-insert-state-map (kbd "TAB") 'my-global-insert-tab)
(electric-indent-mode 1)

;; which key
(use-package which-key
  :config
	(setq which-key-idle-delay 0.1)
  (which-key-mode)
  (which-key-setup-side-window-bottom))

;; ivy mode
(use-package ivy
  :diminish
  :bind (("C-s" . swiper)
         :map ivy-minibuffer-map
         ("C-l" . ivy-alt-done)
         ("C-j" . ivy-next-line)
         ("C-k" . ivy-previous-line)
         :map ivy-switch-buffer-map
         ("C-k" . ivy-previous-line)
         ("C-l" . ivy-done)
         ("C-d" . ivy-switch-buffer-kill)
         :map ivy-reverse-i-search-map
         ("C-k" . ivy-previous-line)
         ("C-d" . ivy-reverse-i-search-kill))
  :config
  (ivy-mode 1))
;; counsel
(use-package counsel
  :after ivy
  :config
  (counsel-mode 1))  ;; enables all counsel commands globally
;; ivy-rch
(use-package ivy-rich
  :after counsel
  :init
  (ivy-rich-mode 1))
(use-package all-the-icons
  :ensure t)
(use-package all-the-icons-ivy
  :after ivy-rich
  :init
  (all-the-icons-ivy-setup))

;; remap C-x C-f to use counsel-findfile and 
(global-set-key (kbd "C-x C-f") 'counsel-find-file)             ;; extra shortcut
(global-set-key (kbd "C-c g") 'counsel-git)                     ;; find files in a git repo
(global-set-key (kbd "M-x") 'counsel-M-x)                       ;; use ivy for M-x
(global-set-key (kbd "C-x b") 'counsel-switch-buffer)           ;; use ivy for M-x

;; git wraper
(use-package magit
  :bind ("C-x g" . magit-status))


;; colorscheme
(use-package ir-black-theme
  :ensure t)
(load-theme 'ir-black t)

;; vterm
(use-package vterm
  :ensure t
  :commands vterm
  :config
  (setq vterm-max-scrollback 10000))  ;; optional, keep more scrollback
(global-set-key (kbd "C-c t") 'vterm)
(setq vterm-shell "/bin/zsh")
(setq vterm-term-environment-variable "xterm-256color")

;; Set leader key
(use-package general
  :ensure t
  :config
  (general-create-definer my-leader-def
		:states '(normal visual emacs)      ;; which state states SPC works
    :prefix "SPC")
	(general-define-key
		:states 'normal
		:prefix "]"
		"b" 'next-buffer)
		(general-define-key
		:states 'normal
		:prefix "["
		"b" 'previous-buffer))


;; <leader>ff for find-file
(my-leader-def
  "f"  '(:ignore t :which-key "file")  ;; prefix for file commands
  "ff" '(projectile-find-file :which-key "find file"))

;; to use gcc and gc to comment a line or selected text
(use-package evil-commentary
  :after evil
  :ensure t
  :config
  (evil-commentary-mode))

(use-package doom-modeline
  :ensure t
  :init (doom-modeline-mode 1))
(setq doom-modeline-icon t
      doom-modeline-major-mode-icon t
      doom-modeline-minor-modes nil) ;; hide minor modes if you like

(use-package nerd-icons)
(use-package nerd-icons-dired
	:ensure t
  :hook (dired-mode . nerd-icons-dired-mode))

(use-package evil-mc)
(global-evil-mc-mode 1)
(with-eval-after-load 'evil-mc
  (define-key evil-mc-key-map (kbd "<escape>") 'evil-mc-undo-all-cursors))

(use-package projectile
	:diminish projectile-mode
	:config (projectile-mode)
	:custom ((projectile-completion-system 'ivy))
	:bind-keymap
	("C-c p" . projectile-command-map)
	:init
	(when (file-directory-p "~/projects")
		(setq projectile-project-search-path '("~/projects")))
	(setq projectile-switch-project-action #'projectile-dired))

(use-package counsel-projectile
	:config  (counsel-projectile-mode))
