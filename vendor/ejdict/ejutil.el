;;;;
;;;;	Epoch上の英単語帳ツール
;;;;
;;;;				1991 2/19 増井俊之
;;;;
;;;;	$Header: ejutil.el,v 1.9 91/02/22 16:21:17 masui Locked $
;;;;
;;;;	○使用法
;;;;
;;;;	反転表示のボタンをクリックすると記述の動作が行なわれる。
;;;;	アンダライン表示のボタンをクリックするとカーソルがそこへ
;;;;	移動する。単語ボタンにペーストを行なうと自動的に検索も
;;;;	行なわれる。
;;;;
;;;;	表示されているものの他に以下のキーバインディングがある。
;;;;
;;;;		<tab>	ボタン間を移動する
;;;;		RET	検索を行なう(単語の上にあるときのみ)
;;;;		Ctrl-K	エントリを消去する
;;;;

;;;
;;;	個人用の辞書ファイル。
;;;
;;;	英語 <tab> 日本語 [<tab>用法] という行の集合
;;;	(英語でなくてもよい)
;;;

(defvar default-dict-file "/usr/masui/words/newwords")

;;;
;;;	辞書引きプログラム名
;;;

(defvar default-word-program "/usr/masui/bin/findword")

;;;
;;;	ウィンドウのタイトル
;;;

(defvar default-window-title "*EJutil*")

;;;
;;;	ボタンの属性
;;;

(defconst underline-attribute 1)
(defconst reverse-attribute 3)

;;;
;;;	使用ライブラリ
;;;

(require 'epoch-dsp)

;;;
;;;	Epochのマウスハンドラ
;;;	button-dataとして登録されている関数を呼びだす。
;;;	(登録はlocal-set-mouseで行なう)
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
;;;	検索・登録などの各コマンド
;;;

(defun search (&optional button mousedata)
  (interactive)
  (let ((word (get-data word-button)) start end meaning example)
    (if (string-match "^ *$" word)
	(erase-data word-button)
      (progn
	(message "%s の検索..." word)
	(set-buffer dict-buffer)
	(goto-char 0)
	(if (re-search-forward (concat "^" word "\t") (buffer-size) t)
	    (progn ; ローカル辞書の検索
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
	      (progn ; オンライン辞書の検索
		(set-buffer word-buffer)
		(erase-data meaning-button)
		(call-process word-program nil (current-buffer) nil word)
		(goto-button meaning-button)
		(setq start (point))
		(search-forward "\n" nil t)
		(if (> (point) (+ 2 start)) ; 検索成功の場合
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
    (message "単語の問題...")
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
    (message "単語\"%s\"を登録しました。" word)
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
	  (message "単語\"%s\"を消去しました。" word)
	  ))))

(defun finish (&optional button mousedata)
  (interactive)
  (message "辞書ユティリティを終了します")
  (set-buffer dict-buffer)
  (write-file dict-file)
  (kill-buffer dict-buffer)
  (kill-buffer word-buffer)
  (delete-screen)
  )

(defun goto-button (&optional button mousedata)
  (goto-char (1+ (button-start button))))

;;;
;;;	ボタンのところの文字列の取得・表示・消去
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
;;;	文字列本体をbuttonとし、関数を登録する。
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
;;;	文字列の右側を下線付きbuttonとし、関数を登録する。
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
;;;	タブ, Ctrl-K, RET に対応する関数
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
;;;	初期化
;;;

(defun ejutil-initialize (&optional button mousedata)
  (interactive)
  (setq word-buffer "辞書検索")
  (get-buffer-create word-buffer)
  (set-buffer word-buffer)
  (erase-buffer)
  (insert "   ^M      ^L     M-r     M-d      M-i      M-f\n")
  (insert "┌──┐┌──┐┌──┐┌──┐┌───┐┌──┐\n")
  (insert "│検索││問題││登録││消去││初期化││終了│\n")
  (insert "└──┘└──┘└──┘└──┘└───┘└──┘\n")
  (insert "\n")
  (insert "単語:   \n")
  (insert "\n")
  (insert "意味:   \n")
  (insert "\n")
  (insert "用例:   \n")
  (string-button "検索" search-button 'search)
  (string-button "登録" register-button 'register)
  (string-button "消去" clear-button 'clear)
  (string-button "問題" exercise-button 'exercise)
  (string-button "初期化" initialize-button 'ejutil-initialize)
  (string-button "終了" finish-button 'finish)
  (entry-button "単語:" word-button 'goto-button)
  (entry-button "意味:" meaning-button 'goto-button)
  (entry-button "用例:" example-button 'goto-button)
  (select-window
   (epoch-display-buffer word-buffer nil
			 (list (cons 'icon-name window-title)
			       (cons 'title window-title)
			       (cons 'geometry "60x20"))))
  ; (select-window (display-buffer word-buffer)) ; スクリーンを使わないとき
  (goto-button word-button)
  (message "辞書\"%s\"の読み込み中..." dict-file)
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
