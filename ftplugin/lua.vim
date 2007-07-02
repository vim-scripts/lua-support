" Vim filetype plugin file
"
"    Language:  lua
"      Plugin:  lua-support.vim (version 1.1)
"  Maintainer:  Fritz Mehner <mehner@fh-swf.de>
"    Revision:  $Id: lua.vim,v 1.4 2007/06/29 13:02:06 mehner Exp $
" ----------------------------------------------------------------------------
"
" Only do this when not done yet for this buffer
" 
if exists("b:did_LUA_ftplugin")
  finish
endif
let b:did_LUA_ftplugin = 1
"
" ---------- tabulator / shiftwidth ------------------------------------------
"  Uncomment the next two lines to force these settings for all files with
"  filetype 'lua' .
"  
"setlocal  tabstop=4
"setlocal  shiftwidth=4
"
" ---------- Lua dictionary -------------------------------------------------
" This will enable keyword completion for Lua
" using Vim's dictionary feature |i_CTRL-X_CTRL-K|.
"
if exists("g:Lua_Dictionary_File")
    silent! exec 'setlocal dictionary+='.g:Lua_Dictionary_File
endif    
"
" ---------- Key mappings : function keys ------------------------------------
"
"   Ctrl-F9   run script
"    Alt-F9   run syntax check
"  Shift-F9   set command line arguments
"
" Vim (non-GUI) : shifted keys are mapped to their unshifted key !!!
" 
if has("gui_running")
  "
   map    <buffer>  <silent>  <A-F9>             :call Lua_SyntaxCheck()<CR>:redraw!<CR>:call Lua_SyntaxCheckMsg()<CR>
  imap    <buffer>  <silent>  <A-F9>        <Esc>:call Lua_SyntaxCheck()<CR>:redraw!<CR>:call Lua_SyntaxCheckMsg()<CR>
  " 
  " <C-C> seems to be essential here:
  "
   map    <buffer>  <silent>  <C-F9>        <C-C>:call Lua_Run()<CR>
  imap    <buffer>  <silent>  <C-F9>   <C-C><C-C>:call Lua_Run()<CR>
  "
   map    <buffer>  <silent>  <S-F9>             :call Lua_Arguments()<CR>
  imap    <buffer>  <silent>  <S-F9>        <Esc>:call Lua_Arguments()<CR>

endif
"
" ---------- Key mappings : menu entries -------------------------------------
"
" ----------  Comments  -----------------------------------------------------
"
nmap    <buffer>  <silent>  <Leader>cl    <Esc><Esc>:call Lua_LineEndComment("-- ")<CR>A
imap    <buffer>  <silent>  <Leader>cl    <Esc><Esc>:call Lua_LineEndComment("-- ")<CR>A
vmap    <buffer>  <silent>  <Leader>cl    <Esc><Esc>:call Lua_MultiLineEndComments("-- ")<CR>A

nmap    <buffer>  <silent>  <Leader>cj    <Esc><Esc>:call Lua_AdjustLineEndComm("a")<CR>
vmap    <buffer>  <silent>  <Leader>cj    <Esc><Esc>:call Lua_AdjustLineEndComm("v")<CR>
imap    <buffer>  <silent>  <Leader>cj    <Esc><Esc>:call Lua_AdjustLineEndComm("v")<CR>

nmap    <buffer>  <silent>  <Leader>cs    <Esc><Esc>:call Lua_GetLineEndCommCol()<CR>
"
nmap    <buffer>  <silent>  <Leader>cc    <Esc><Esc>:s/^/--/<CR><Esc>:nohlsearch<CR>
vmap    <buffer>  <silent>  <Leader>cc    <Esc><Esc>:'<,'>s/^/--/<CR><Esc>:nohlsearch<CR>

nmap    <buffer>  <silent>  <Leader>co    <Esc><Esc>:s/^\(\s*\)--/\1/<CR><Esc>:nohlsearch<CR>
vmap    <buffer>  <silent>  <Leader>co    <Esc><Esc>:'<,'>s/^\(\s*\)--/\1/<CR><Esc>:nohlsearch<CR>

nmap    <buffer>  <silent>  <Leader>cb  	<Esc><Esc>:call Lua_CommentBlock("a")<CR>
vmap    <buffer>  <silent>  <Leader>cb  	<Esc><Esc>:call Lua_CommentBlock("v")<CR>
nmap    <buffer>  <silent>  <Leader>cub   <Esc><Esc>:call Lua_UncommentBlock()<CR>

nmap    <buffer>  <silent>  <Leader>cfr   <Esc><Esc>:call Lua_CommentTemplates('frame')<CR>
nmap    <buffer>  <silent>  <Leader>cfu   <Esc><Esc>:call Lua_CommentTemplates('function')<CR>
nmap    <buffer>  <silent>  <Leader>ch    <Esc><Esc>:call Lua_CommentTemplates('header')<CR>
imap    <buffer>  <silent>  <Leader>cfr   <Esc><Esc>:call Lua_CommentTemplates('frame')<CR>
imap    <buffer>  <silent>  <Leader>cfu   <Esc><Esc>:call Lua_CommentTemplates('function')<CR>
imap    <buffer>  <silent>  <Leader>ch    <Esc><Esc>:call Lua_CommentTemplates('header')<CR>
"
nnoremap    <buffer>  <silent>  <Leader>cd   a<C-R>=strftime("%x")<CR>
inoremap    <buffer>  <silent>  <Leader>cd    <C-R>=strftime("%x")<CR>
nnoremap    <buffer>  <silent>  <Leader>ct   a<C-R>=strftime("%x %X %Z")<CR>
inoremap    <buffer>  <silent>  <Leader>ct    <C-R>=strftime("%x %X %Z")<CR>

nmap    <buffer>  <silent>  <Leader>ckb   $<Esc>:call Lua_CommentClassified("BUG")     <CR>kJA
nmap    <buffer>  <silent>  <Leader>ckc   $<Esc>:call Lua_CommentClassified("COMPILER")<CR>kJA
nmap    <buffer>  <silent>  <Leader>ckt   $<Esc>:call Lua_CommentClassified("TODO")    <CR>kJA
nmap    <buffer>  <silent>  <Leader>ckr   $<Esc>:call Lua_CommentClassified("TRICKY")  <CR>kJA
nmap    <buffer>  <silent>  <Leader>ckw   $<Esc>:call Lua_CommentClassified("WARNING") <CR>kJA
nmap    <buffer>  <silent>  <Leader>cko   $<Esc>:call Lua_CommentClassified("WORKAROUND") <CR>kJA
nmap    <buffer>  <silent>  <Leader>ckn   $<Esc>:call Lua_CommentClassified("")        <CR>kJf:a
"
" ----------  Statements  ---------------------------------------------------
"
nmap    <buffer>  <silent>  <Leader>sf    <Esc><Esc>:call Lua_StatBlock( "a", "for  = , do\nend", "" )<CR>frla
imap    <buffer>  <silent>  <Leader>sf    <Esc><Esc>:call Lua_StatBlock( "a", "for  = , do\nend", "" )<CR>frla
vmap    <buffer>  <silent>  <Leader>sf    <Esc><Esc>:call Lua_StatBlock( "v", "for  = , do", "end" )<CR>frla

nmap    <buffer>  <silent>  <Leader>sfi   <Esc><Esc>:call Lua_StatBlock( "a", "for  in  do\nend", "" )<CR>frla
imap    <buffer>  <silent>  <Leader>sfi   <Esc><Esc>:call Lua_StatBlock( "a", "for  in  do\nend", "" )<CR>frla
vmap    <buffer>  <silent>  <Leader>sfi   <Esc><Esc>:call Lua_StatBlock( "v", "for  in  do", "end" )<CR>frla

nmap    <buffer>  <silent>  <Leader>si    <Esc><Esc>:call Lua_StatBlock( "a", "if  then\nend", "" )<CR>ffla
imap    <buffer>  <silent>  <Leader>si    <Esc><Esc>:call Lua_StatBlock( "a", "if  then\nend", "" )<CR>ffla
vmap    <buffer>  <silent>  <Leader>si    <Esc><Esc>:call Lua_StatBlock( "v", "if  then", "end" )<CR>ffla

nmap    <buffer>  <silent>  <Leader>sie   <Esc><Esc>:call Lua_StatBlock( "a", "if  then\nelse\nend", "" )<CR>ffla
imap    <buffer>  <silent>  <Leader>sie   <Esc><Esc>:call Lua_StatBlock( "a", "if  then\nelse\nend", "" )<CR>ffla
vmap    <buffer>  <silent>  <Leader>sie   <Esc><Esc>:call Lua_StatBlock( "v", "if  then", "else\nend" )<CR>ffla

nmap    <buffer>  <silent>  <Leader>sei   <Esc><Esc>:call Lua_StatBlock( "a", "elseif  then\nDUMMY", "" )<CR>j"_ddkffla
imap    <buffer>  <silent>  <Leader>sei   <Esc><Esc>:call Lua_StatBlock( "a", "elseif  then\nDUMMY", "" )<CR>j"_ddkffla

nmap    <buffer>  <silent>  <Leader>sr    <Esc><Esc>:call Lua_RepeatUntil("a")<CR><Esc>A
imap    <buffer>  <silent>  <Leader>sr    <Esc><Esc>:call Lua_RepeatUntil("a")<CR><Esc>A
vmap    <buffer>  <silent>  <Leader>sr    <Esc><Esc>:call Lua_RepeatUntil("v")<CR><Esc>A

nmap    <buffer>  <silent>  <Leader>sw    <Esc><Esc>:call Lua_StatBlock( "a", "while  do\nend", "" )<CR>fela
imap    <buffer>  <silent>  <Leader>sw    <Esc><Esc>:call Lua_StatBlock( "a", "while  do\nend", "" )<CR>fela
vmap    <buffer>  <silent>  <Leader>sw    <Esc><Esc>:call Lua_StatBlock( "v", "while  do", "end" )<CR>fela
"
" ----------  Idioms  -------------------------------------------------------
"
nmap    <buffer>  <silent>  <Leader>if    <Esc><Esc>:call Lua_Function("a")<CR>f(la
imap    <buffer>  <silent>  <Leader>if    <Esc><Esc>:call Lua_Function("a")<CR>f(la
vmap    <buffer>  <silent>  <Leader>if    <Esc><Esc>:call Lua_Function("v")<CR>f(la
"
 noremap    <buffer>  <silent>  <Leader>ip    <Esc>aprint()<Left>
inoremap    <buffer>  <silent>  <Leader>ip          print()<Left>
vnoremap    <buffer>  <silent>  <Leader>ip         sprint()<ESC>P
"
nnoremap    <buffer>  <silent>  <Leader>ifi    <Esc><Esc>:call Lua_ForDoEnd("a")<CR>f(a
inoremap    <buffer>  <silent>  <Leader>ifi    <Esc><Esc>:call Lua_ForDoEnd("a")<CR>f(a
vnoremap    <buffer>  <silent>  <Leader>ifi    <Esc><Esc>:call Lua_ForDoEnd("v")<CR>f(a
"
 noremap    <buffer>  <silent>  <Leader>ias     <Esc>aassert()<Left>
inoremap    <buffer>  <silent>  <Leader>ias           assert()<Left>
vnoremap    <buffer>  <silent>  <Leader>ias          sassert()<ESC>P
"
nmap    <buffer>  <silent>  <Leader>ii    <Esc><Esc>:call Lua_OpenInputFile()<CR>a
imap    <buffer>  <silent>  <Leader>ii    <Esc><Esc>:call Lua_OpenInputFile()<CR>a

nmap    <buffer>  <silent>  <Leader>io    <Esc><Esc>:call Lua_OpenOutputFile()<CR>a
imap    <buffer>  <silent>  <Leader>io    <Esc><Esc>:call Lua_OpenOutputFile()<CR>a
"
" ----------  Snippets  -----------------------------------------------------
"
nmap    <buffer>  <silent>  <Leader>nr    <Esc><Esc>:call Lua_CodeSnippet("r")<CR>
nmap    <buffer>  <silent>  <Leader>nw    <Esc><Esc>:call Lua_CodeSnippet("w")<CR>
vmap    <buffer>  <silent>  <Leader>nw    <Esc><Esc>:call Lua_CodeSnippet("wv")<CR>
nmap    <buffer>  <silent>  <Leader>ne    <Esc><Esc>:call Lua_CodeSnippet("e")<CR>
"
" ----------  Run  ----------------------------------------------------------
"
map    <buffer>  <silent>  <Leader>rr    <Esc>:call Lua_Run()<CR>
map    <buffer>  <silent>  <Leader>rc    <Esc>:call Lua_SyntaxCheck()<CR>:redraw!<CR>:call Lua_SyntaxCheckMsg()<CR>
map    <buffer>  <silent>  <Leader>ra    <Esc>:call Lua_Arguments()<CR>
"
map    <buffer>  <silent>  <Leader>rm    <C-C>:call Lua_Make()<CR>'
map    <buffer>  <silent>  <Leader>rg    <C-C>:call Lua_MakeArguments()<CR>'

 map    <buffer>  <silent>  <Leader>rh   <Esc>:call Lua_Hardcopy("n")<CR>
vmap    <buffer>  <silent>  <Leader>rh   <Esc>:call Lua_Hardcopy("v")<CR>

 map    <buffer>  <silent>  <Leader>rs   <Esc>:call Lua_Settings()<CR>

if has("gui_running") && has("unix")
   map    <buffer>  <silent>  <Leader>rx    <Esc>:call Lua_XtermSize()<CR>
endif

map    <buffer>  <silent>  <Leader>ro    <Esc>:call Lua_Toggle_Gvim_Xterm()<CR>

map    <buffer>  <silent>  <Leader>h     <Esc>:call Lua_Help()<CR>

