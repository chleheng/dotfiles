;;; Emacs
;;; -*- lexical-binding: t -*-
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(custom-enabled-themes nil))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
 
 ;; alt t, ctrl alt t
 ; ctrl alt \ indent whole file

(setq default-directory "C:/Users/chieu/Downloads/")


;;; --- UI: dark theme, sane defaults ---
(menu-bar-mode -1)
(tool-bar-mode -1)
(scroll-bar-mode -1)
(load-theme 'wombat t)                 ;; built-in dark theme (try 'tango-dark too)
(setq inhibit-startup-screen t)

;; Line numbers + column number
(global-display-line-numbers-mode 1)
(column-number-mode 1)

;; Highlight matching parens and auto-insert pairs ((), {}, [], "", '')
;;(show-paren-mode 1)
;;(electric-pair-mode 1)
;;(setq electric-pair-pairs '((?\( . ?\)) (?\{ . ?\}) (?\[ . ?\]) (?\" . ?\") (?\'. ?\')))
;;;; (Optional) auto-close angle brackets in web modes
;;(add-hook 'prog-mode-hook (lambda () (setq-local electric-pair-pairs (append electric-pair-pairs '((?< . ?>))))))

;;; --- Editing behavior you’d expect from general IDEs ---
;; Use spaces, never tabs
(setq-default indent-tabs-mode nil)
(setq-default tab-width 4)

(defun replace-tabs-then-indent-region (start end)
  (interactive "r")
  (save-excursion
    (goto-char start)
    (while (search-forward "\t" end t)
      (replace-match (make-string tab-width ? ))))
  (indent-region start end))

(global-set-key (kbd "C-M-\\") 'replace-tabs-then-indent-region)


;; Replace selection when typing (like most editors)
(delete-selection-mode 1)

;; Keep clipboard in sync with OS
(setq select-enable-clipboard t)

;; Trailing whitespace is shown in prog/text modes (helps keep diffs clean)
(add-hook 'prog-mode-hook (lambda () (setq show-trailing-whitespace t)))
(add-hook 'text-mode-hook (lambda () (setq show-trailing-whitespace t)))

;; Remember cursor positions in files
(save-place-mode 1)

;; Recent files menu
(recentf-mode 1)
(setq recentf-max-saved-items 200)

;; Auto-revert files changed on disk (logs, build outputs, etc.)
(global-auto-revert-mode 1)

;; Quieter backups/autosaves: put them in a temp directory instead of littering your project
(let ((backup-dir (expand-file-name "emacs-backups/" temporary-file-directory)))
  (setq backup-directory-alist `(("." . ,backup-dir))
        auto-save-file-name-transforms `((".*" ,backup-dir t))
        create-lockfiles nil))

;;; --- Windows/Notepad++ style keybindings ---
;; CUA mode gives you Ctrl-x/c/v for cut/copy/paste, rectangular selections with Shift, etc.
(cua-mode 1)
(setq cua-auto-mark-last-change nil)   ;; avoid auto-mark surprises

;; Save with Ctrl-s (re-map isearch to Ctrl-f like most editors)
(global-set-key (kbd "C-s") #'save-buffer)
(global-set-key (kbd "C-S-s") #'write-file)       ;; Save As…
(global-set-key (kbd "C-f") #'isearch-forward)
(global-set-key (kbd "C-S-f") #'isearch-forward-regexp)
(global-set-key (kbd "C-o") #'find-file)


;; Select all with Ctrl-a (move-beginning-of-line is now on Home)
(global-set-key (kbd "C-a") #'mark-whole-buffer)
(global-set-key (kbd "<home>") #'move-beginning-of-line)
(global-set-key (kbd "<end>")  #'move-end-of-line)

(global-set-key (kbd "M-c")  #'check-parens)

;; Undo/Redo
(global-set-key (kbd "C-z") #'undo)   ;; CUA already does this, but we ensure it.
;; Emacs 28+ has undo-redo built-in:
(when (fboundp 'undo-redo)
  (global-set-key (kbd "C-S-z") #'undo-redo))
;; If your Emacs is older than 28, consider M-x package-install RET undo-fu RET and:
;; (with-eval-after-load 'undo-fu
;;   (global-set-key (kbd "C-S-z") #'undo-fu-only-redo))

;; Quick “Format / Reindent file” like IDEs
(defun lh/indent-buffer ()
  "Indent the whole buffer."
  (interactive)
  (indent-region (point-min) (point-max)))
(global-set-key (kbd "C-S-i") #'lh/indent-buffer)

;; Comment/uncomment like typical IDEs (Ctrl-/ toggles line or region)
(global-set-key (kbd "C-/") #'comment-line)
(global-set-key (kbd "C-S-/") #'comment-or-uncomment-region)

;; Move between windows with Ctrl-Tab / Ctrl-Shift-Tab
(global-set-key (kbd "<C-tab>")   #'other-window)
(global-set-key (kbd "<C-S-iso-lefttab>") (lambda () (interactive) (other-window -1)))

;; Duplicate line (a handy Notepad++ habit): Ctrl-D
(defun lh/duplicate-line-or-region ()
  "Duplicate current line or active region."
  (interactive)
  (let (beg end (orig (point)))
    (if (use-region-p)
        (setq beg (region-beginning) end (region-end))
      (setq beg (line-beginning-position) end (line-end-position)))
    (let ((text (buffer-substring beg end)))
      (goto-char end)
      (newline)
      (insert text))
    (goto-char orig)))
(global-set-key (kbd "C-d") #'lh/duplicate-line-or-region)

;; Jump to line (Ctrl-G in Notepad++; Emacs uses M-g g; we add Ctrl-G)
(global-set-key (kbd "C-g") #'goto-line)

;;; --- Quality-of-life ---
;; Show available keybinds as you type
(when (fboundp 'which-key-mode)
  (which-key-mode 1))



;; --- Tabs UI (buffer tabs like Notepad++) ---
(global-tab-line-mode 1)
(setq tab-line-new-button-show nil
      tab-line-close-button-show t
      tab-line-separator "  ")
(global-set-key (kbd "C-<next>")  #'tab-line-switch-to-next-tab)   ; Ctrl+PgDn
(global-set-key (kbd "C-<prior>") #'tab-line-switch-to-prev-tab)   ; Ctrl+PgUp

;; Optional: window/tab groups (IDE-like) — comment out if you don’t want this
(tab-bar-mode 1)
(global-set-key (kbd "C-M-t") #'tab-bar-new-tab)
(global-set-key (kbd "C-M-w") #'tab-bar-close-tab)
(global-set-key (kbd "C-M-<next>")  #'tab-bar-switch-to-next-tab)
(global-set-key (kbd "C-M-<prior>") #'tab-bar-switch-to-prev-tab)

;; --- Auto-reopen last session (files, buffers, some window state) ---
(savehist-mode 1)
(setq desktop-dirname user-emacs-directory
      desktop-base-file-name "desktop"
      desktop-save t
      desktop-load-locked-desktop t
      desktop-auto-save-timeout 300
      desktop-restore-eager 8)
(desktop-save-mode 1)

;; --- If you sometimes want real TAB characters ---
(defun lh/tabs-toggle ()
  (interactive)
  (setq indent-tabs-mode (not indent-tabs-mode)))
(defun lh/tabify-region-or-buffer ()
  (interactive)
  (if (use-region-p)
      (tabify (region-beginning) (region-end))
    (tabify (point-min) (point-max))))
(defun lh/untabify-region-or-buffer ()
  (interactive)
  (if (use-region-p)
      (untabify (region-beginning) (region-end))
    (untabify (point-min) (point-max))))
(global-set-key (kbd "C-c t i") #'lh/tabs-toggle)
(global-set-key (kbd "C-c t f") #'lh/tabify-region-or-buffer)
(global-set-key (kbd "C-c t u") #'lh/untabify-region-or-buffer)


(set-scroll-bar-mode 'right)
(scroll-bar-mode 1)

(setq shift-select-mode t)
(cua-selection-mode 1)

(setq-default cursor-type '(bar . 2))
(blink-cursor-mode 1)
(setq blink-cursor-interval 0.7
      blink-cursor-delay 0.5
      blink-cursor-blinks 3)

(defun lh/new-buffer-here ()
  (interactive)
  (let ((buf (generate-new-buffer "untitled")))
    (switch-to-buffer buf)))

(global-set-key (kbd "C-t") #'lh/new-buffer-here)

(cua-selection-mode 0)
(setq cua-enable-cua-keys t
      cua-keep-region-after-copy t
      shift-select-mode t)     ;; keep Shift+arrow selection
(cua-mode 1)
