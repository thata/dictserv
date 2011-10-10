;;;  Author: Toshiyuki Masui (masui@a.nl.cs.cmu.edu)
;;;  This file contains ejword, a GNU Emacs front end to an
;;;  English-Japanese dictionary lookup tool

;; Everyone is granted permission to copy, modify and redistribute
;; this program.

;; HISTORY
;;
;;	Written by Toshiyuki Masui Nov.-1989
;;		ejdic-word, ejdic-region, and ejdic-point are written.
;;
;;	Revised by Toshiyuki Masui Dec.-1989
;;		ejdic-point is revised to use forward-word,
;;		ejdic-ask and x-ejword are added.
;;
;;	Modified by Toru Matsuda (matsuda@ipe.rdc.ricoh.co.jp) May-1990
;;		ejdic-word is modified to use Yokogawa-san's `consulta'
;;			command instead of Masui-san's `word' command,
;;		ejdic-word and ejdic-ask are merged, and ejdic-ask is removed,
;;		x-ejword comes to be undefined unless the window-system is X.
;;
;;	Commented by Toru Matsuda 1-Jun.-1990
;;		these comments are added.
;;
;;	Revised by Toru Matsuda 3-Aug.-1990
;;		dynamic variables ejdic-shell-command-format and
;;			ejdic-shell-command-args-deciding-method are
;;			introduced to make generality,
;;		(default) lookup command is changed to Matsuda's `ejdic' from
;;			`consulta',
;;		ejdic-word bug (lack of save-excursion) made by Matsuda in
;;			May-1990 is fixed,
;;		epoch-or-not test is added.
;;
;;	Revised by Toru Matsuda 5-Sep.-1990
;;		some modifications for epoch are made.
;;
;;	Revised by Toru Matsuda 7-Sep.-1990
;;		mouse-ejword for Sunview is added.
;;
;;      Revised by Toru Matsuda 12-Dec.-1990
;;		adapted for epoch-3.2.
;;
;;; Suggested USAGE
;;;
;;;	In ~/.emacs
;;;
;;;(autoload 'ejdic-word "local/ejword" nil t nil)
;;;(autoload 'ejdic-region "local/ejword" nil t nil)
;;;(autoload 'ejdic-point "local/ejword" nil t nil)
;;;(setq running-emacs-x
;;;      (and (boundp 'window-system) (eq window-system 'x))
;;;      running-emacstool
;;;      (getenv "IN_EMACSTOOL")
;;;      running-epoch
;;;      (and (boundp 'epoch::version) epoch::version)
;;;      running-epoch-3-2			; the latest version of epoch
;;;      (and running-epoch
;;;           (let ((epoch-version-number
;;;                  (substring epoch::version
;;;                             (string-match "[0-9]" epoch::version))))
;;;             (equal (string-to-char epoch-version-number) ?3)
;;;             (equal
;;;              (string-to-char (substring epoch-version-number 2))
;;;              ?2))))
;;;(cond (running-epoch-3-2		; the latest version of epoch
;;;       (defun x-ejword (arg)
;;;        (let ((oldpoint (point)))
;;;           (mouse::set-point arg)
;;;           (if (= (point) oldpoint)
;;;               (ejdic-point)
;;;             (start-mouse-drag arg))))
;;;       (global-set-mouse mouse-left mouse-down 'x-ejword))
;;;      (running-epoch		; the older epoch
;;;       (defun x-ejword (arg)
;;;         (let ((oldpoint (point)))
;;;           (x-handle-left-down arg)
;;;           (if (= (point) oldpoint)
;;;               (ejdic-point))))
;;;       (require 'x-mouse "smk-x-mouse")
;;;       (define-key mouse-map x-button-left 'x-ejword))
;;;      (running-emacs-x		; usual emacs on X
;;;       (defun x-ejword (arg)
;;;         (let ((oldpoint (point)))
;;;           (x-mouse-set-point arg)
;;;           (if (= (point) oldpoint)
;;;               (ejdic-point))))
;;;       (require 'x-mouse "x-mouse")
;;;       (define-key mouse-map x-button-left 'x-ejword))
;;;      (running-emacstool		; emacstool on Sunview
;;;       (defun mouse-ejword (window x y)
;;;         (let ((oldpoint (point)))
;;;           (mouse-move-point window x y)
;;;           (if (eq oldpoint (point))
;;;               (ejdic-point)
;;;             (mouse-drag-move-point window x y))))
;;;       (require 'sun-mouse)
;;;       (require 'sun-fns)
;;;       (global-set-mouse '(left text) 'mouse-ejword)))
;;;
;;;	then
;;;
;;;	M-x ejdic-word
;;;		to display the meaning of the given English word in Japanese
;;;
;;;	M-x ejdic-region
;;;		to display the meaning of the English word in the region
;;;		in Japanese
;;;
;;;	M-x ejdic-point (or C-c w)
;;;		to display the meaning of the English word at or before the
;;;		point in Japanese
;;;
;;;	double click the left button of the mouse (X or Sunview only)
;;;		displays the meaning of the English word at or before the
;;;		point in Japanese

;;; REMARK
;;;
;;; Users must set their paths appropriately so that they may use ejdic-
;;; program.

;------------------------------------------------
; 英和辞典 (use "ejdic" as default)
;------------------------------------------------

(provide 'ejword)

(setq running-emacs-x
      (and (boundp 'window-system) (eq window-system 'x))
      running-emacstool
      (getenv "IN_EMACSTOOL")
      running-epoch
      (and (boundp 'epoch::version) epoch::version)
      running-epoch-3-2			; the latest version of epoch
      (and running-epoch
	   (let ((epoch-version-number
		  (substring epoch::version
			     (string-match "[0-9]" epoch::version))))
		  (equal (string-to-char epoch-version-number) ?3)
		  (equal
		    (string-to-char (substring epoch-version-number 2))
		    ?2))))

(if running-epoch
    (require 'epoch-dsp))

(defvar ejdic-shell-command-format
  "exec /usr/local/lib/dictionay/ejdict/word.pl %s"
  "*The shell command line format to look up the meaning of the word.")

;(defvar ejdic-shell-command-format "exec findword %s"
;  "*The shell command line format to look up the meaning of the word.")

;(defvar ejdic-shell-command-format "exec ejdic %s"
;  "*The shell command line format to look up the meaning of the word.")

;(setq ejdic-shell-command-format
;  "SEARCH='grep -i';export SEARCH;exec consulta %s")

;(setq ejdic-shell-command-format "exec /bin/grep -i %s %s")

(defvar ejdic-shell-command-args-deciding-method
  (function (lambda (word) (list word))))

;(setq ejdic-shell-command-args-deciding-method
;  (function (lambda (word)
;     (list word (concat "/usr/local/lib/dictionary/ejdic/rmt."
;                        (char-to-string (downcase (string-to-char word)))
;                        ".dic")))))

(defun ejdic-word (englishword)
  "Display the meaning of the given English word in Japanese."
  (interactive "s調べたい英単語: ")
  (let ((wordbuf "英和辞典")
	(ejdic-args
	 (funcall ejdic-shell-command-args-deciding-method englishword)))
    (get-buffer-create wordbuf)
    (save-excursion
      (set-buffer wordbuf)
      (erase-buffer)
      (while (and (= (buffer-size) 0) (> (length englishword) 0))
	(call-process "/bin/tcsh" nil wordbuf t "-c"
		      (apply 'format ejdic-shell-command-format ejdic-args))
	(setq englishword
	      (substring englishword 0 (1- (length englishword)))))
      (if (= (buffer-size) 0)
	  (insert "辞書検索に失敗しました。"))
      (goto-char (point-min))
      (if running-epoch
	  (epoch-display-buffer wordbuf nil
				'((icon-name . "*EJDIC*")
				  (title . "*EJDIC*")
				  (geometry . "80x50")))
	(display-buffer wordbuf)))))

(defun ejdic-region (start end)
  "Display the meaning of the English word in the region in Japanese."
  (interactive "r")
  (ejdic-word (buffer-substring start end)))

(defun ejdic-point ()
  "Display the meaning of the English word at or just before the point in Japanese."
  (interactive)
  (let (start end)
    (save-excursion
      (if (not (looking-at "\\<"))
	  (forward-word -1))
      (setq start (point))
      (forward-word 1)
      (setq end (point))
      (ejdic-region start end))))

