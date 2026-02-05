
" =====================File: ai.vim {========================= 人工智能相关 ====

" ---------- vim-ai 完整配置 ------------

" debug settings
let g:vim_ai_debug = 0
let g:vim_ai_debug_log_file = g:vimrc_dir . "/vim_ai_debug.log"

" 这样设置了后聊天窗口看起还是很丑陋
" autocmd FileType aichat setlocal filetype=markdown
" autocmd FileType aichat setlocal syntax=markdown

" 这样就完全当成存文本来看
" autocmd FileType aichat setlocal syntax=off

" 通用AI命令配置
let g:vim_ai_complete = {
\  "provider": "openai",
\  "options": {
\    "model": "deepseek-chat",
\    "endpoint_url": "https://api.deepseek.com/v1/chat/completions",
\    "max_tokens": 2000,
\    "max_completion_tokens": 1500,
\    "temperature": 0.7,
\    "request_timeout": 30,
\    "stream": 0,
\  },
\  "ui": {
\    "paste_mode": 0,
\  },
\}

let g:vim_ai_chat = {
\  "provider": "openai",
\  "prompt": "",
\  "options": {
\    "model": "deepseek-chat",
\    "endpoint_url": "https://api.deepseek.com/v1/chat/completions",
\    "max_tokens": 4000,
\    "max_completion_tokens": 2000,
\    "temperature": 0.7,
\    "request_timeout": 30,
\    "stream": 1,
\    "auth_type": "bearer",
\  },
\  "ui": {
\    "open_chat_command": "preset_below",
\    "scratch_buffer_keep_open": 1,
\    "populate_options": 0,
\    "populate_all_options": 0,
\    "force_new_chat": 0,
\    "paste_mode": 0,
\    "code_syntax_enabled": 1,
\    "code_syntax_conceal": 0,
\  },
\}

let g:vim_ai_edit = {
\  "provider": "openai",
\  "prompt": "",
\  "options": {
\    "model": "deepseek-chat",
\    "endpoint_url": "https://api.deepseek.com/v1/chat/completions",
\    "max_tokens": 2000,
\    "max_completion_tokens": 0,
\    "temperature": 0.1,
\    "request_timeout": 20,
\    "stream": 0,
\    "auth_type": "bearer",
\    "selection_boundary": "#####",
\  },
\  "ui": {
\    "paste_mode": 0,
\  },
\}


" 给 AI 发送信息的方法
" :AIChat 这里输入要发送的内容
" 先可视模式选择一段代码，然后 :AIChat 输入想让AI对这段代码做的事情
" 如果要继续提问，只需要在命令行继续输入 :AIChat 即可，上下文都是保留的
"
" AI 原地修改代码的方法
" 选中一段代码，然后
" :AIEdit 把变量全转成小写
" 类似这样
"
" AIImage 是用于图像生成的，暂时用不到

vnoremap <leader>ae :AIEdit |        " ai: ai 编辑选定文本
nnoremap <leader>ac :AIChat |        " ai: ai 发送聊天信息(普通模式)
vnoremap <leader>ac :AIChat |        " ai: ai 发送聊天信息(可视模式)

" =====================File: ai.vim }========================= 人工智能相关 ====

