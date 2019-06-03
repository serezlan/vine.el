(require 'emacspeak)

;; Set global key to start vine
(global-set-key (kbd "<escape>") 'vine-normal-mode)

(defvar $vine-counter "0" "Holds the value for action repetition")
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
	("1" (lambda () (interactive) (vine-append-counter-value "1")))
	("2" (lambda () (interactive) (vine-append-counter-value "2")))
	("3" (lambda () (interactive) (vine-append-counter-value "3")))
	("4" (lambda () (interactive) (vine-append-counter-value "4")))
	("5" (lambda () (interactive) (vine-append-counter-value "5")))
	("6" (lambda () (interactive) (vine-append-counter-value "6")))
	("7" (lambda () (interactive) (vine-append-counter-value "7")))
	("8" (lambda () (interactive) (vine-append-counter-value "8")))
	("9" (lambda () (interactive) (vine-append-counter-value "9")))
	("0"vine-zero-key-press)
	("b" (lambda() (interactive)  (vine-forward-word nil)))
	("D" duplicate-current-line)
	("i" vine-insert-mode)
	("h" (lambda () (interactive) (vine-right-char nil)))
	("j" (lambda() (interactive) (vine-next-line nil)))
	("k" (lambda() (interactive) (vine-next-line t)))
	("l" (lambda () (interactive) (vine-right-char t)))
	("o" (lambda () (interactive) (vine-insert-blank-line)))
	("O" (lambda () (interactive) (vine-insert-blank-line t)))
	("w" (lambda() (interactive)  (vine-forward-word t)))
	))

(defun vine-normal-mode ()
  "Start vine normal mode"
  (interactive)
  (vine-reset-state)
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
	(message "%s" $vine-active-mode))
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

(defun vine-reset-state ()
  "Reset vine state of current buffer"
  (setq $vine-counter "0"))

(defun vine-append-counter-value (VALUE)
  "Append value of $vine-counter"
  (interactive)
  (setq $vine-counter (concat $vine-counter VALUE)))

(defun vine-get-counter-value()
  "Get counter value in number format"
  (let (
	($counter (string-to-number $vine-counter)))
    (if (> $counter 1)
	$counter
      1)))
(defun vine-next-line(FORWARD)
  "Goto next line if FORWARD is t. Otherwise goto previous line.
The number of lines depends on $vine-counter"
  (interactive)
  (if FORWARD
	(next-line (vine-get-counter-value))
    (previous-line (vine-get-counter-value)))
  (vine-reset-state)
  (emacspeak-speak-line))

(defun vine-right-char (RIGHT)
  "If RIGHT is t then goto right char. Otherwise goto left char.
The number of char depend on $vine-counter"
  (interactive)
  (if RIGHT
      (right-char (vine-get-counter-value))
    (left-char (vine-get-counter-value)))
  (vine-reset-state)
  (setq current-prefix-arg 4)
  (call-interactively 'emacspeak-speak-char))

(defun vine-zero-key-press ()
  "If $vine-counter > 0 then append char 0 to it. Otherwise goto beginning of line"
  (interactive)
  (if (> (string-to-number $vine-counter) 0)
      (vine-append-counter-value "0")
    (progn
      (beginning-of-line)
      (emacspeak-speak-line))))()

(defun vine-forward-word (FORWARD)
  "Forward word if FORWARD is t. Otherwise go backward."
  (interactive)
  (let (
	($counter (vine-get-counter-value))
	)
    (unless FORWARD
      (setq $counter (* $counter -1)))
    (forward-word $counter)
    (vine-reset-state)
    (emacspeak-speak-word)))

(defun vine-insert-blank-line (&optional ABOVE)
  "If ABOVE is t then insert new line above current line. Otherwise insert below current line.
By default it inserts below current line"
  (interactive)
  (let (
	($counter (vine-get-counter-value))
	)
    (if ABOVE
	(progn
	  (beginning-of-line)
	  (open-line $counter)
	  (indent-for-tab-command)
	  (message "Open blank lines above"))
      (progn
	(end-of-line)
	(newline $counter)
	(message "Open blank lines below")))
    (emacspeak-auditory-icon 'modified-object)
    (vine-reset-state)))

	;; For testing purpose
(setq $vine-active-mode "nil")

