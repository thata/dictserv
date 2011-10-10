;;;;
;;;;	Epoch$@>e$N1QC18lD"%D!<%k(J
;;;;
;;;;				1991 2/19 $@A}0f=SG7(J
;;;;
;;;;	$Header: ejutil.el,v 1.9 91/02/22 16:21:17 masui Locked $
;;;;
;;;;	$@!{;HMQK!(J
;;;;
;;;;	$@H?E>I=<($N%\%?%s$r%/%j%C%/$9$k$H5-=R$NF0:n$,9T$J$o$l$k!#(J
;;;;	$@%"%s%@%i%$%sI=<($N%\%?%s$r%/%j%C%/$9$k$H%+!<%=%k$,$=$3$X(J
;;;;	$@0\F0$9$k!#C18l%\%?%s$K%Z!<%9%H$r9T$J$&$H<+F0E*$K8!:w$b(J
;;;;	$@9T$J$o$l$k!#(J
;;;;
;;;;	$@I=<($5$l$F$$$k$b$N$NB>$K0J2<$N%-!<%P%$%s%G%#%s%0$,$"$k!#(J
;;;;
;;;;		<tab>	$@%\%?%s4V$r0\F0$9$k(J
;;;;		RET	$@8!:w$r9T$J$&(J($@C18l$N>e$K$"$k$H$-$N$_(J)
;;;;		Ctrl-K	$@%(%s%H%j$r>C5n$9$k(J
;;;;

;;;
;;;	$@8D?MMQ$N<-=q%U%!%$%k!#(J
;;;
;;;	$@1Q8l(J <tab> $@F|K\8l(J [<tab>$@MQK!(J] $@$H$$$&9T$N=89g(J
;;;	($@1Q8l$G$J$/$F$b$h$$(J)
;;;

(defvar default-dict-file "/usr/masui/words/newwords")

;;;
;;;	$@<-=q0z$-%W%m%0%i%`L>(J
;;;

(defvar default-word-program "/usr/masui/bin/findword")

;;;
;;;	$@%&%#%s%I%&$N%?%$%H%k(J
;;;

(defvar default-window-title "*EJutil*")

;;;
;;;	$@%\%?%s$NB0@-(J
;;;

(defconst underline-attribute 1)
(defconst reverse-attribute 3)

;;;
;;;	$@;HMQ%i%$%V%i%j(J
;;;

(require 'epoch-dsp)

;;;
;;;	Epoch$@$N%^%&%9%O%s%I%i(J
;;;	button-data$@$H$7$FEPO?$5$l$F$$$k4X?t$r8F$S$@$9!#(J
;;;	($@EPO?$O(Jlocal-set-mouse$@$G9T$J$&(J)
;;;

(defun left-click (mousedata)
  (let ((curp (car mousedata)) button buttondata)
    (set-buffer (cadr mousedata))
    (setq button (button-at curp))
    (if (buttonp button)
	(progn
	  (setq buttondata (button-data button))
	  (if buttondata
	      (eval (list buttondata button (quote mousedata)))
	    )))))

(defun middle-click (mousedata)
  (let ((curp (car mousedata)) button)
    (set-buffer (cadr mousedata))
    (setq button (button-at curp))
    (if (eq button word-button)
	(progn
	  (display-data word-button (epoch::get-cut-buffer))
	  (search)
	  )
      (mouse::paste-cut-buffer mousedata)
      )))

;;;
;;;	$@8!:w!&EPO?$J$I$N3F%3%^%s%I(J
;;;

(defun search (&optional button mousedata)
  (interactive)
  (let ((word (get-data word-button)) start end meaning example)
    (if (string-match "^ *$" word)
	(erase-data word-button)
      (progn
	(message "%s $@$N8!:w(J..." word)
	(set-buffer dict-buffer)
	(goto-char 0)
	(if (re-search-forward (concat "^" word "\t") (buffer-size) t)
	    (progn ; $@%m!<%+%k<-=q$N8!:w(J
	      (beginning-of-line)
	      (re-search-forward "[^\t]*\t\\([^\t\n]*\\)\\(\t\\([^\n]*\\)\\)?")
	      (setq meaning (buffer-substring (match-beginning 1)
					      (match-end 1)))
	      (setq example
		    (if (match-beginning 3)
			(buffer-substring (match-beginning 3)
					  (match-end 3))
		      "" ))
	      (set-buffer word-buffer)
	      (display-data meaning-button meaning)
	      (display-data example-button example)
	      )
	  (if word-program
	      (progn ; $@%*%s%i%$%s<-=q$N8!:w(J
		(set-buffer word-buffer)
		(erase-data meaning-button)
		(call-process word-program nil (current-buffer) nil word)
		(goto-button meaning-button)
		(setq start (point))
		(search-forward "\n" nil t)
		(if (> (point) (+ 2 start)) ; $@8!:w@.8y$N>l9g(J
		    (progn
		      (search-forward "\t" nil t)
		      (delete-region start (point))
		      )
		  ))))
	(set-buffer word-buffer)
	(goto-button meaning-button)
	))))

(defun abs (x)
  (if (> x 0) x (- 0 x)))

(defun exercise (&optional button mousedata)
  (interactive)
  (let (word)
    (message "$@C18l$NLdBj(J...")
    (set-buffer dict-buffer)
    (goto-line (1+ (% (abs (random)) dict-entries)))
    (re-search-forward "^\\([^\t]*\\)\t" nil t);
    (setq word (buffer-substring (match-beginning 1) (match-end 1)))
    (set-buffer word-buffer)
    (erase-data meaning-button)
    (erase-data example-button)
    (display-data word-button word)
    (goto-button word-button)
    ))

(defun register (&optional button mousedata)
  (interactive)
  (let (word meaning example)
    (setq word (get-data word-button))
    (setq meaning (get-data meaning-button))
    (setq example (get-data example-button))
    (set-buffer dict-buffer)
    (end-of-buffer)
    (insert word "\t" meaning "\t" example "\n")
    (setq dict-entries (1+ dict-entries))
    (set-buffer word-buffer)
    (message "$@C18l(J\"%s\"$@$rEPO?$7$^$7$?!#(J" word)
    ))

(defun clear (&optional button mousedata)
  (interactive)
  (let (start word)
    (setq word (get-data word-button))
    (set-buffer dict-buffer)
    (goto-char 0)
    (if (re-search-forward (concat "^" word "\t") (buffer-size) t)
	(progn
	  (beginning-of-line)
	  (setq start (point))
	  (forward-line)
	  (delete-region start (point))
	  (setq dict-entries (1- dict-entries))
	  (message "$@C18l(J\"%s\"$@$r>C5n$7$^$7$?!#(J" word)
	  ))))

(defun finish (&optional button mousedata)
  (interactive)
  (message "$@<-=q%f%F%#%j%F%#$r=*N;$7$^$9(J")
  (set-buffer dict-buffer)
  (write-file dict-file)
  (kill-buffer dict-buffer)
  (kill-buffer word-buffer)
  (delete-screen)
  )

(defun goto-button (&optional button mousedata)
  (goto-char (1+ (button-start button))))

;;;
;;;	$@%\%?%s$N$H$3$m$NJ8;zNs$N<hF@!&I=<(!&>C5n(J
;;;

(defun get-data (button)
  (let (start end)
    (set-buffer word-buffer)
    (setq start (button-start button))
    (setq end (button-end button))
    (goto-char start)
    (skip-chars-forward " " end)
    (setq start (point))
    (goto-char end)
    (if (re-search-backward "[^ \t\n]" start t)
	(setq end (1+ (point))))
    (buffer-substring start end)
    ))

(defun erase-data (button)
  (let ((start (button-start button)))
    (set-buffer word-buffer)
    (delete-region (+ 1 start) (button-end button))
    (goto-char start)
    (insert " ")))

(defun display-data (button data)
  (erase-data button)
  (insert data))

;;;
;;;	$@J8;zNsK\BN$r(Jbutton$@$H$7!"4X?t$rEPO?$9$k!#(J
;;;
(defmacro string-button (str buttonname func)
  (` (let (p l)
       (goto-char 0)
       (search-forward (, str))
       (setq p (point))
       (setq l (length (, str)))
       (setq (, buttonname) (add-button (- p l) p reverse-attribute))
       (set-button-data (, buttonname) (, func))
       )))

;;;
;;;	$@J8;zNs$N1&B&$r2<@~IU$-(Jbutton$@$H$7!"4X?t$rEPO?$9$k!#(J
;;;
(defmacro entry-button (str buttonname func)
  (` (let (p)
       (goto-char 0)
       (search-forward (, str))
       (setq p (point))
       (setq (, buttonname) (add-button (+ p 1) (+ p 3) underline-attribute))
       (set-button-data (, buttonname) (, func))
       )))

;;;
;;;	$@%?%V(J, Ctrl-K, RET $@$KBP1~$9$k4X?t(J
;;;

(defun circulate-buttons ()
  (interactive)
  (let (button)
    (setq button (button-at (point)))
    (cond ((eq button word-button) (goto-button meaning-button))
	  ((eq button meaning-button) (goto-button example-button))
	  (t (goto-button word-button)))
    ))

(defun delete-entry ()
  (interactive)
  (let (button)
    (setq button (button-at (point)))
    (if button (erase-data button))
    ))

(defun search-or-newline ()
  (interactive)
  (if (eq (button-at (point)) word-button)
      (search)
    (newline)))

;;;
;;;	$@=i4|2=(J
;;;

(defun ejutil-initialize (&optional button mousedata)
  (interactive)
  (setq word-buffer "$@<-=q8!:w(J")
  (get-buffer-create word-buffer)
  (set-buffer word-buffer)
  (erase-buffer)
  (insert "   ^M      ^L     M-r     M-d      M-i      M-f\n")
  (insert "$@(#(!(!($(#(!(!($(#(!(!($(#(!(!($(#(!(!(!($(#(!(!($(J\n")
  (insert "$@("8!:w("("LdBj("("EPO?("(">C5n("("=i4|2=("("=*N;("(J\n")
  (insert "$@(&(!(!(%(&(!(!(%(&(!(!(%(&(!(!(%(&(!(!(!(%(&(!(!(%(J\n")
  (insert "\n")
  (insert "$@C18l(J:   \n")
  (insert "\n")
  (insert "$@0UL#(J:   \n")
  (insert "\n")
  (insert "$@MQNc(J:   \n")
  (string-button "$@8!:w(J" search-button 'search)
  (string-button "$@EPO?(J" register-button 'register)
  (string-button "$@>C5n(J" clear-button 'clear)
  (string-button "$@LdBj(J" exercise-button 'exercise)
  (string-button "$@=i4|2=(J" initialize-button 'ejutil-initialize)
  (string-button "$@=*N;(J" finish-button 'finish)
  (entry-button "$@C18l(J:" word-button 'goto-button)
  (entry-button "$@0UL#(J:" meaning-button 'goto-button)
  (entry-button "$@MQNc(J:" example-button 'goto-button)
  (select-window
   (epoch-display-buffer word-buffer nil
			 (list (cons 'icon-name window-title)
			       (cons 'title window-title)
			       (cons 'geometry "60x20"))))
  ; (select-window (display-buffer word-buffer)) ; $@%9%/%j!<%s$r;H$o$J$$$H$-(J
  (goto-button word-button)
  (message "$@<-=q(J\"%s\"$@$NFI$_9~$_Cf(J..." dict-file)
  (setq dict-buffer (find-file-noselect dict-file))
  (set-buffer dict-buffer)
  (setq dict-entries (count-lines 1 (buffer-size)))
  (set-buffer word-buffer)
  (local-set-mouse mouse-left mouse-down 'left-click)
  (local-set-mouse mouse-middle mouse-down 'middle-click)
  (local-set-key "\C-m" 'search-or-newline)
  (local-set-key "\C-l" 'exercise)
  (local-set-key "\M-r" 'register)
  (local-set-key "\M-d" 'clear)
  (local-set-key "\M-i" 'initialize)
  (local-set-key "\M-f" 'finish)
  (local-set-key "\t"   'circulate-buttons)
  (local-set-key "\C-k" 'delete-entry)
  (random t)
  )

(defun ejutil ()
  (interactive)
  (setq dict-file default-dict-file)
  (setq word-program default-word-program)
  (setq window-title default-window-title)
  (ejutil-initialize))

(defun espanol ()
  (interactive)
  (setq dict-file "/usr/masui/words/spanish")
  (setq word-program nil)
  (setq window-title "Spanish")
  (ejutil-initialize))
