(require 'emacspeak)

;; Set global key to start vine
(global-set-key (kbd "<escape>") 'vine-normal-mode)

(defvar $vine-counter "0" "Holds the value for action repetition")
(defconst $vine-initial-state "init" "Define initial state of each new buffer")
(defconst $vine-delete-command "delete" "Define the value of delete command")
(defvar $vine-leader-command $vine-initial-state "Holds the value of leader command")
(defvar $vine-active-mode $vine-initial-state "Define current buffer vine mode")
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
	("d" vine-delete)
	("D" duplicate-current-line)
	("f" vine-find-char-in-line)
	("g" vine-goto-line)
	("G" beginning-of-buffer)
	("i" vine-insert-mode)
	("h" (lambda () (interactive) (vine-right-char nil)))
	("j" (lambda() (interactive) (vine-next-line nil)))
	("k" (lambda() (interactive) (vine-next-line t)))
	("l" (lambda () (interactive) (vine-right-char t)))
	("o" (lambda () (interactive) (vine-insert-blank-line)))
	("O" (lambda () (interactive) (vine-insert-blank-line t)))
("r" emacspeak-speak-line)
("u" undo-tre)
("v"vine-visual-mode)
("V"(lambda () (interactive) (vine-visual-mode t)))
	("w" (lambda() (interactive)  (vine-forward-word t)))
	("{" beginning-of-defun)
	("}" end-of-defun)
	("$"  vine-end-of-line)
	("^" (lambda () (interactive) (back-to-indentation) (emacspeak-speak-line)))
	))
;; ##

(defun vine-normal-mode ()
  "Start vine normal mode"
  (interactive)
  (vine-reset-state)
  (if (member
       (format "%s" major-mode) $vine-white-list-mode)
      (progn
	;; Create local variable first time
	;; Set to insert mode initially
	(if (string-equal $vine-active-mode $vine-initial-state)
	  (progn
	    (make-local-variable '$vine-active-mode)
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
  (setq $vine-leader-command $vine-initial-state)
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
    (if (string-equal $vine-leader-command $vine-delete-command)
	(progn
	  ;; Delete word
	  (kill-word $counter)
	  (vine-reset-state)
	  (emacspeak-speak-line)
	  (emacspeak-auditory-icon 'modified-object))
      (progn
	;; Usual forward word 
	(unless FORWARD
	  (setq $counter (* $counter -1)))
	(forward-word $counter)
	(vine-reset-state)
	(emacspeak-speak-word)))))

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
    (vine-reset-state)
    (vine-insert-mode)))

(defun vine-end-of-line()
  "Go to end of line"
  (interactive)
  (end-of-line)
  (emacspeak-speak-line))

(defun vine-goto-line ()
  "Goto line. If user press 'g' twice it will go to the end of buffer"
  (interactive)
  (let (
	($line-number (string-to-number $vine-counter))
	$keystroke 
	)
    (if (= $line-number 0)
	(progn
	  ;; Wait for user to press another 'g' key 
	  (setq $keystroke (read-char ""))
	  (if (= $keystroke 103)
	      (end-of-buffer)
	    (emacspeak-auditory-icon 'off)))
      (progn
	;; Here we jump to line number xx
	(goto-line $line-number)))
    (emacspeak-speak-line)))

(defun vine-delete()
  "Delete line, word or char, delete inside deleimiter or delete until certain char"
  (interactive)
  (let (
	($counter (vine-get-counter-value))
	)
    (if (string-equal $vine-leader-command $vine-initial-state)
	(setq $vine-leader-command $vine-delete-command)
      (progn
	;; Here we delete lines
	(kill-whole-line $counter)
	(vine-reset-state)
	(emacspeak-auditory-icon 'modified-object)
	))))
(defun vine-visual-mode (&optional LINE)
  "Start visual mode. If LINE is t then start visual line mode"
  (interactive)
  (if LINE
      (beginning-of-line))
  (call-interactively 'set-mark-command))
(defun vine-find-char-in-line()
  "Find a char in line. Move point after target char if found"
  (interactive)
  (let (
	($starting-line (line-number-at-pos))
	($start-pos (point))
	$end-pos
	$char
	)
    (setq $char (read-char ""))
    (setq $end-pos (search-forward (format "%c" $char) nil t))
    (print $end-pos)
    (if (and 
	 $end-pos
	 (= $starting-line (line-number-at-pos $end-pos)))
	(progn 
	  ;; We have a match)))
	  (emacspeak-speak-line -1))
      (progn
	(goto-char $start-pos)
	(emacspeak-auditory-icon 'off)))))

    ;; For testing purpose
(setq $vine-active-mode $vine-initial-state)
