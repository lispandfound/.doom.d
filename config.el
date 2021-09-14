;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

(setq doom-theme 'doom-one
      doom-font "FiraCode Nerd Font 9"
      langtool-default-language "en-NZ"
      org-directory "~/org"

      display-line-numbers-type 'relative
      user-full-name "Jake Faulkner"
      user-mail-address "jakefaulkn@gmail.com"

      ;; avy-keys is not dvorak friendly by default
      avy-keys '(?a ?o ?e ?u ?i ?d ?h ?t ?n ?s)

      ;; eldoc got this one covered
      lsp-ui-sideline-enable nil

      ;; These don't do what you (future me) think they do, so don't remove them!
      ;; They simply switch window focus when you split the window, saves a keystroke.
      evil-split-window-below t
      evil-vsplit-window-right t

      ;; Use a more powerful LaTeX renderer
      pdf-latex-command "xelatex"
      TeX-command-extra-options "-shell-escape"
      shell-escape-mode "-shell-escape"

      undo-limit 80000000

      +ivy-buffer-preview t

      ;; Allows for nested yasnippet expansions, not sure why this is not the default.
      yas-triggers-in-field t

      browse-url-browser-function 'browse-url-firefox

      ;; Substitution with global means that every instance of a pattern on a line is replaced.
      evil-ex-substitute-global t)


;; NOTE: Symbola package on AUR: ttf-symbola
;; From memory this fixes the return ligature in python mode as well as a couple of the logical operators.
(set-fontset-font t nil (font-spec :size 10 :name "Symbola"))

;; FIXME: This is scheduled to be in develop, check back sometime later when it is and remove this!
(use-package! tree-sitter
  :when (bound-and-true-p module-file-suffix)
  :hook (prog-mode . tree-sitter-mode)
  :hook (tree-sitter-after-on . tree-sitter-hl-mode)
  :config
  (require 'tree-sitter-langs)
  (defadvice! doom-tree-sitter-fail-gracefully-a (orig-fn &rest args)
    "Don't break with errors when current major mode lacks tree-sitter support."
    :around #'tree-sitter-mode
    (condition-case e
        (apply orig-fn args)
      (error
       (unless (string-match-p (concat "^Cannot find shared library\\|"
                                       "^No language registered\\|"
                                       "cannot open shared object file")
                            (error-message-string e))
            (signal (car e) (cadr e)))))))



(after! company-mode
  (setq company-idle-delay 0.2
        company-minimum-prefix-length 2)
  (add-hook 'evil-normal-state-entry-hook #'company-abort))

;; Turn off some splashscreen noise
(remove-hook '+doom-dashboard-functions #'doom-dashboard-widget-shortmenu)
(remove-hook '+doom-dashboard-functions #'doom-dashboard-widget-footer)

(add-hook! '+doom-dashboard-mode-hook (hide-mode-line-mode 1) (hl-line-mode -1))
(setq-hook! '+doom-dashboard-mode-hook evil-normal-state-cursor (list nil))
(defun jake/latex-compile-and-view ()
  (interactive)
  (TeX-command-run-all nil)
  (TeX-view))

(map! :after latex
      :map LaTeX-mode-map
      :localleader
      :desc "Compile" "c" #'jake/latex-compile-and-view)
(map! :localleader
      :map latex-mode-map
      :desc "Compile" "c" #'jake/latex-compile-and-view)

(setq skeletor-user-directory (concat doom-private-dir "project-skeletons"))
(skeletor-define-template "assignment"
  :title "Assignment")
(skeletor-define-template "report"
  :title "Report")
(map! :leader
      :desc "Create new project"
      "p n" #'skeletor-create-project-at)
