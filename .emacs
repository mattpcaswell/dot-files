;; ----------------------------------------------------------------------------------------
;; MELPA
(require 'package)
(dolist (source '(("melpa" . "http://melpa.milkbox.net/packages/")
                  ))
  (package-initialize)
  (add-to-list 'package-archives source t))

;; Required packages
;; Will automatically check if those packages are
;; missing, it will install them automatically
(when (not package-archive-contents)
  (package-refresh-contents))
(defvar jmt/packages
  ;; list packages here with spaces inbetween
  '(helm))
(dolist (p jmt/packages)
  (when (not (package-installed-p p))
    (package-install p)))
;; ----------------------------------------------------------------------------------------
;; Appearance
(menu-bar-mode -1)
(tool-bar-mode -1)
(scroll-bar-mode -1)
(add-to-list 'custom-theme-load-path "~/.emacs.d/themes/")
(load-theme 'gruvbox t)
(setq inhibit-startup-screen t)
(add-to-list 'default-frame-alist '(font . "Monospace-11"))
(set-face-attribute 'default t :font "Monospace-11")
(display-time-mode 1)
;; ----------------------------------------------------------------------------------------
;; Evil
(require 'evil)
(require 'key-chord)
(key-chord-mode 1)
(key-chord-define evil-insert-state-map  "jk" 'evil-normal-state)

(evil-define-key 'normal diff-mode-map "q" 'quit-window)

(defvar my-leader-map (make-sparse-keymap)
  "Keymap for \"leader key\" shortcuts.")

;; binding " " to the keymap
(define-key evil-normal-state-map (kbd "SPC") my-leader-map)
;; binding "<SPC>w" to c-w
(define-key my-leader-map "w" 'evil-window-map)
;; binding "<SPC>b" to helm list buffers
(define-key my-leader-map "b" 'helm-buffers-list)
;; binding "<SPC>f" to helm find files
(define-key my-leader-map "f" 'helm-find-files)

(evil-ex-define-cmd "W" 'save-buffer)

(evil-mode 1)
;; ----------------------------------------------------------------------------------------
;; Org
(require 'org)
(define-key global-map "\C-cl" 'org-store-link)
(define-key global-map "\C-ca" 'org-agenda)
(setq org-log-done t)
(setq org-agenda-files (list "~/org/todo.org"))

;; ----------------------------------------------------------------------------------------
;; Helm
(require 'helm)
(require 'helm-config)
;; The default "C-x c" is quite close to "C-x C-c", which quits Emacs.
;; Changed to "C-c h". Note: We must set "C-c h" globally, because we
;; cannot change `helm-command-prefix-key' once `helm-config' is loaded.
(global-set-key (kbd "C-c h") 'helm-command-prefix)
(global-unset-key (kbd "C-x c"))
(define-key helm-map (kbd "<tab>") 'helm-execute-persistent-action) ; rebind tab to run persistent action
(define-key helm-map (kbd "C-i") 'helm-execute-persistent-action) ; make TAB work in terminal
(define-key helm-map (kbd "C-z")  'helm-select-action) ; list actions using C-z
(when (executable-find "curl")
  (setq helm-google-suggest-use-curl-p t))
(setq helm-move-to-line-cycle-in-source     t ; move to end or beginning of source when reaching top or bottom of source.
      helm-split-window-inside-p           t ; open helm buffer inside current window, not occupy whole other window
      helm-ff-search-library-in-sexp        t ; search for library in `require' and `declare-function' sexp.
      helm-scroll-amount                    8 ; scroll 8 lines other window using M-<next>/M-<prior>
      helm-ff-file-name-history-use-recentf t
      helm-echo-input-in-header-line t)
(setq helm-autoresize-max-height 0)
(setq helm-autoresize-min-height 20)
(helm-autoresize-mode 1)
(add-hook 'helm-minibuffer-set-up-hook #'helm-hide-minibuffer-maybe)
(global-set-key (kbd "C-x C-b") 'helm-buffers-list)
(global-set-key (kbd "C-x b") 'helm-buffers-list)
(global-set-key (kbd "C-x C-f") 'helm-find-files)
(global-set-key (kbd "M-y") 'helm-show-kill-ring)
(global-set-key (kbd "M-x") 'helm-M-x)
(helm-mode 1)
;; ----------------------------------------------------------------------------------------
;; Backups
(setq backup-directory-alist `(("." . "~/.saves")))
;; ----------------------------------------------------------------------------------------
;; Misc
(setq confirm-kill-emacs 'yes-or-no-p)
(global-set-key (kbd "<f5>") 'revert-buffer)
(global-set-key (kbd "C-x C-z") 'zone)

(defun fold-classes (arg)
  "Fold classes"
  (interactive "p")
  (set-selective-display 1)
)

(defun fold-funcs (arg)
  "Fold functions"
  (interactive "p")
  (set-selective-display 4)
)

(defun unfold-all (arg)
  "Unfold all"
  (interactive "p")
  (set-selective-display nil)
)

(global-set-key [C-S-f1] 'fold-classes)
(global-set-key [C-S-f2] 'fold-funcs)
(global-set-key [C-S-f3] 'unfold-all)

;; ----------------------------------------------------------------------------------------
;; Custom functions
(defun helm-hide-minibuffer-maybe ()
  "Hide minibuffer contents in a Helm session.
This function should normally go to `helm-minibuffer-set-up-hook'.
It has no effect if `helm-echo-input-in-header-line' is nil."
  (when (with-helm-buffer helm-echo-input-in-header-line)
    (let ((ov (make-overlay (point-min) (point-max) nil nil t)))
      (overlay-put ov 'window (selected-window))
      (helm-aif (and helm-display-header-line
                     (helm-attr 'persistent-help))
          (progn
            (overlay-put ov 'display
                         (truncate-string-to-width
                          (substitute-command-keys
                           (concat "\\<helm-map>\\[helm-execute-persistent-action]: "
                                   (format "%s (keeping session)" it)))
                          (- (window-width) 1)))
            (overlay-put ov 'face 'helm-header))
        (overlay-put ov 'face (let ((bg-color (face-background 'default nil)))
                                  `(:background ,bg-color :foreground ,bg-color))))
      (setq cursor-type nil))))

(defun reload-emacs-config ()
  "load-file on ~/.emacs"
  (interactive)
  (load-file "~/.emacs"))

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(custom-safe-themes
   (quote
    ("bffa9739ce0752a37d9b1eee78fc00ba159748f50dc328af4be661484848e476" "ce0788113995714fd96970417e8e71d5182d02bc40cc7ffef307f5e01e55942f" "6ac7c0f959f0d7853915012e78ff70150bfbe2a69a1b703c3ac4184f9ae3ae02" "1497ded035c9e4471198d549c0a3b01e5e656f9628d108f594c0d21c45ba3fcb" "5a07fa2b7b007bde9c63ac1c188c3dfe8d5ce17ed2e439de6313e3a4656eae9c" default)))
 '(line-number-mode nil)
 '(package-selected-packages (quote (key-chord helm gruvbox-theme evil))))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(mode-line ((t (:background "#626262" :foreground "#bcbcbc" :box (:line-width 2 :color "gray60" :style released-button))))))
(put 'narrow-to-region 'disabled nil)
