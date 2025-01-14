;; 关闭工具栏，tool-bar-mode 即为一个 Minor Mode
 (tool-bar-mode -1)

 ;;关闭菜单栏
 (menu-bar-mode -1)

 (scroll-bar-mode -1)

;; 更改光标的样式（不能生效，解决方案见第二集）
(setq cursor-type 'bar)

;; 关闭启动帮助画面
(setq inhibit-splash-screen 1)

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

;; Enable Evil
(use-package evil
  :init
  (setq evil-want-integration t)
  (setq evil-want-keybinding nil)
  (setq evil-want-C-i-jump nil)
  (setq evil-want-C-u-scroll t)
  :ensure t
  :config
  (evil-mode 1)    ;; 启用 Evil
  ;; Use visual line motions even outside of visual-line-mode buffers
  (evil-global-set-key 'motion "j" 'evil-next-visual-line)
  (evil-global-set-key 'motion "k" 'evil-previous-visual-line)

  (evil-set-initial-state 'messages-buffer-mode 'normal)
  (evil-set-initial-state 'dashboard-mode 'normal))                      

(use-package evil-collection
:after evil
:config
(evil-collection-init))

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
:hook (org-mode . manjie/org-mode-setup))

(use-package company
:ensure t
:config
(global-company-mode 1)
;; company mode 默认选择上一条和下一条候选项命令 M-n M-p
:bind (("C-n" . company-select-next)
       ("C-p" . company-select-previous)))

(use-package helpful
  :ensure t
  ;; 快捷键绑定
  :bind (("C-h f" . helpful-callable)          
	     ("C-h v" . helpful-variable)
	     ("C-h k" . helpful-key)
	     ("C-h x" . helpful-command)))

(tab-bar-mode -1)

(use-package ace-jump-mode
  :ensure t
  :bind
  (("C-c SPC" . ace-jump-mode)) ;; 可以绑定到您喜欢的快捷键
  :config
  ;; 如果使用 evil 模式，可以绑定到 normal 模式下的快捷键
  (with-eval-after-load 'evil
    (define-key evil-normal-state-map (kbd "SPC") 'ace-jump-mode)))

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
