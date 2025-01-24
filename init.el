;; 关闭工具栏，tool-bar-mode 即为一个 Minor Mode
(tool-bar-mode -1)

;;关闭菜单栏
(menu-bar-mode -1)

(scroll-bar-mode -1)

;; 更改光标的样式（不能生效，解决方案见第二集）
(setq cursor-type 'bar)

;; 关闭启动帮助画面
(setq inhibit-splash-screen 1)

(set-face-attribute 'default nil
                    :height 150)

;; Initialize package sources
(require 'package)

(setq package-archives '(("melpa" . "https://melpa.org/packages/")
                         ("org" . "https://orgmode.org/elpa/")
                         ("elpa" . "https://elpa.gnu.org/packages/")))

(package-initialize)
(unless package-archive-contents
   (package-refresh-contents))

;; Initialize use-package on non-Linux platforms
(unless (package-installed-p 'use-package)
   (package-install 'use-package))

(require 'use-package)
(setq use-package-always-ensure t)

(load-theme 'gruvbox-dark-soft t)

;; Automatically tangle our Emacs.org config file when we save it
(defun manjie/org-babel-tangle-config ()
  (when (string-equal (buffer-file-name)
		      (expand-file-name "~/.emacs.d/config.org"))
    ;; Dynamic scoping to the rescue
    (let ((org-confirm-babel-evaluate nil))
      (org-babel-tangle))))

;;(add-hook 'org-mode-hook (lambda () (add-hook 'after-save-hook 'manjie/org-babel-tangle-config)))
(add-hook 'after-save-hook
          (lambda ()
            (when (string-equal (buffer-file-name)
                                (expand-file-name "~/.emacs.d/config.org"))
              (manjie/org-babel-tangle-config))))

(defun manjie/org-mode-setup ()
  (org-indent-mode))

(use-package org
:hook (org-mode . manjie/org-mode-setup)
:config
(setq org-latex-create-formula-image-program 'dvipng) ;; 使用 dvipng 渲染公式
(setq org-format-latex-options (plist-put org-format-latex-options :scale 2.0))
)

  ;; 启用 cdlatex 支持 LaTeX 输入
(use-package cdlatex
  :hook (org-mode . turn-on-org-cdlatex)) ;; 在 org-mode 中启用 cdlatex

(use-package helpful
  :ensure t
  ;; 快捷键绑定
  :bind (("C-h f" . helpful-callable)          
	     ("C-h v" . helpful-variable)
	     ("C-h k" . helpful-key)
	     ("C-h x" . helpful-command)))

(tab-bar-mode 1)

(use-package ace-jump-mode
  :ensure t
  :bind
  (("C-c SPC" . ace-jump-mode)) ;; 可以绑定到您喜欢的快捷键
  :config
  (ace-jump-mode 1))
  ;;;; 如果使用 evil 模式，可以绑定到 normal 模式下的快捷键
  ;;(with-eval-after-load 'evil
  ;;  (define-key evil-normal-state-map (kbd "SPC SPC") 'ace-jump-mode)))

;; ;; Enable Evil
;; (use-package evil
;;   :init
;;   (setq evil-want-integration t)
;;   (setq evil-want-keybinding nil)
;;   (setq evil-want-C-i-jump nil)
;;   (setq evil-want-C-u-scroll t)
;;   :ensure t
;;   :config
;;   (evil-mode 1)    ;; 启用 Evil
;;   ;; Use visual line motions even outside of visual-line-mode buffers
;;   (evil-global-set-key 'motion "j" 'evil-next-visual-line)
;;   (evil-global-set-key 'motion "k" 'evil-previous-visual-line)
;; 
;;   (evil-set-initial-state 'messages-buffer-mode 'normal)
;;   (evil-set-initial-state 'dashboard-mode 'normal))                      
;;
;; (use-package evil-collection
;; :after evil
;; :config
;; (evil-collection-init))
;;
;; ;; evil-nerd-commenter: 快速注释代码
;;(use-package evil-nerd-commenter
;;  :ensure t
;;  :bind
;;  ("M-/" . evilnc-comment-or-uncomment-lines)) ;; 绑定注释快捷键

;; 安装和配置 Helm
(use-package helm
  :ensure t
  :init
  ;; 基础初始化设置
  (setq helm-move-to-line-cycle-in-source t)  ;; 循环浏览候选项
  :config
  ;; 加载核心配置并启用 Helm
  (helm-mode 1)

  ;; 快捷键绑定
  :bind (("M-x" . helm-M-x)                   ;; 替换默认的 M-x
         ("C-s" . helm-occur)                ;; 切换缓冲区
         ("C-x C-f" . helm-find-files)        ;; 查找文件
         ("C-x b" . helm-mini)                ;; 切换缓冲区
         ("M-y" . helm-show-kill-ring)        ;; 剪贴板历史
         ("C-c h o" . helm-occur)))           ;; 搜索当前缓冲区内容

(use-package doom-modeline
  :ensure t
  :init (doom-modeline-mode 1)
  :config
  (setq doom-modeline-icon nil))

;; undo-tree 配置
(use-package undo-tree
  :ensure t
  :init
  (setq undo-tree-auto-save-history t) ;; 自动保存 undo-tree 的历史记录
  (setq undo-tree-history-directory-alist '(("." . "~/.emacs.d/undo"))) ;; 设置历史记录存储位置
  (setq undo-tree-visualizer-timestamps t) ;; 在可视化器中显示时间戳
  (setq undo-tree-visualizer-diff t) ;; 在可视化器中显示 diff
  :config
  ;; 启用全局 undo-tree
  (global-undo-tree-mode 1))
  ;;;; 与 evil 模式集成
  ;;(with-eval-after-load 'evil
  ;;  (define-key evil-normal-state-map (kbd "u") 'undo-tree-undo) ;; 撤销
  ;;  (define-key evil-normal-state-map (kbd "C-r") 'undo-tree-redo))) ;; 重做

(use-package multiple-cursors
:ensure t
:bind (("C-S-c C-S-c" . mc/edit-lines)            ;; 激活多行光标
       ("C->"         . mc/mark-next-like-this)   ;; 标记下一个匹配
       ("C-<"         . mc/mark-previous-like-this) ;; 标记上一个匹配
       ("C-c C-<"     . mc/mark-all-like-this)))  ;; 标记所有匹配

(use-package company
 :ensure t
 :init
 (global-company-mode 1)
 :config
 (setq company-idle-delay 0.2
       company-minimum-prefix-length 1))
;; ;; company mode 默认选择上一条和下一条候选项命令 M-n M-p
;; :bind (("C-n" . company-select-next)
;;        ("C-p" . company-select-previous)))

;;helm-gtags?

;;  (defun my/update-gtags ()
;;  "Update GTAGS in the project root."
;;  (when (and (derived-mode-p 'prog-mode) (executable-find "global"))
;;    (let ((default-directory (locate-dominating-file default-directory "GTAGS")))
;;      (when default-directory
;;        (start-process "update-gtags" nil "global" "-u")))))
;;
;;(add-hook 'after-save-hook #'my/update-gtags)

(use-package lsp-mode
  :init
  ;; set prefix for lsp-command-keymap (few alternatives - "C-l", "C-c l")
  (setq lsp-keymap-prefix "C-c l")
  :hook (;; replace XXX-mode with concrete major-mode(e. g. python-mode)
         (python-mode . lsp)
         ;; if you want which-key integration
         (lsp-mode . lsp-enable-which-key-integration))
  :commands lsp)

;; optionally
(use-package lsp-ui :commands lsp-ui-mode)
;; if you are helm usero
(use-package helm-lsp :commands helm-lsp-workspace-symbol)
;; if you are ivy user
;;(use-package lsp-ivy :commands lsp-ivy-workspace-symbol)
(use-package lsp-treemacs :commands lsp-treemacs-errors-list)

;; optionally if you want to use debugger
(use-package dap-mode)
;; (use-package dap-LANGUAGE) to load the dap adapter for your language

;; optional if you want which-key integration
(use-package which-key
    :config
    (which-key-mode))

(use-package magit
  :ensure t
  :bind (("C-x g" . magit-status)   ;; 快速打开 magit-status
         ("C-x M-g" . magit-dispatch) ;; 打开 magit 调度菜单
         ("C-c M-g" . magit-file-dispatch)) ;; 文件级操作
  :config
  (setq magit-display-buffer-function #'magit-display-buffer-fullframe-status-v1)) ;; 全屏显示 magit-status

(use-package wgrep
:ensure t
:config
;; 配置 wgrep
(setq wgrep-auto-save-buffer t) ;; 自动保存编辑后的结果到文件
(setq wgrep-enable-key "e"))    ;; 按 `e` 启用 wgrep 模式
