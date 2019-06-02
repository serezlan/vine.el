(global-set-key (kbd "<escape>") 'vine-normal-mode)
	
(setq $vine-command-list
      '(
	("i" vine-insert-mode)
       ("j" previous-line)
       ))

(defun vine-normal-mode ()
  "Start vine normal mode"
  (interactive)
  (message "normal mode")
  (vine-process-command-list t))

(defun vine-insert-mode ()
  "Start vine insert mode"
  (interactive)
  (emacspeak-auditory-icon 'left)
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

