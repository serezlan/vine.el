(require 'emacspeak)

;; Set global key to start vine
(global-set-key (kbd "<escape>") 'vine-normal-mode)

(defvar $vine-active-mode "nil" "Define current buffer vine mode")
(defvar $vine-normal-mode "normal" "Define state of normal mode")
(defvar $vine-insert-mode "insert" "Define vine insert mode state value")
(defvar $vine-white-list-mode
  '(
    "emacs-lisp-mode"
    "lisp-interaction-mode"
    )
  "Holds the list of major mode where vine can run")

(setq $vine-command-list
      '(
	("i" vine-insert-mode)
       ("j" previous-line)
       ))

(defun vine-normal-mode ()
  "Start vine normal mode"
  (interactive)
  (if (member
       (format "%s" major-mode) $vine-white-list-mode)
      (progn
	;; Create local variable first time
	;; Set to insert mode initially
	(if (eq $vine-active-mode "nil")
	  (progn
	    (make-local-variable $vine-active-mode)
	    (setq $vine-active-mode $vine-insert-mode)))

	(unless (eq $vine-active-mode $vine-normal-mode)
	  (progn 
	    (vine-process-command-list t)
	    (setq $vine-active-mode $vine-normal-mode)))

	(message "%s mode" $vine-active-mode))
    (emacspeak-auditory-icon 'off)))
    
(defun vine-insert-mode ()
  "Start vine insert mode"
  (interactive)
  (emacspeak-auditory-icon 'left)
  (setq $vine-active-mode $vine-insert-mode)
  (vine-process-command-list nil))
	
(defun vine-process-command-list (NORMAL-MODE)
  "Register all shortcut in command list.
If NORMAL-MODE is t then start normal mode"
  (interactive)
  (let (
	($command-list $vine-command-list)
	)
    (while $command-list
      (setq $element (car $command-list))
      ;; Get keyboard shortcut and command
      (setq $kbd (car $element))
      (setq $command (car (cdr $element)))
      (if NORMAL-MODE
	  (local-set-key (kbd $kbd) $command)
	(local-unset-key (kbd $kbd)))

      ;; Decrese loop list
      (setq $command-list (cdr $command-list)))))
