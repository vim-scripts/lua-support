"###############################################################################################
"  
"       Filename:  lua-support.vim
"  
"    Description:  Lua-IDE for Vim/gVim. It is written to considerably speed
"                  up writing code in a consistent style.
"                  This is done by inserting complete statements, comments,
"                  idioms, code snippets, templates, and comments.
"                  There a many additional hints and options which can improve
"                  speed and comfort when writing Lua. Please read the
"                  documentation.
"  
"   GVIM Version:  7.0+
"  
"  Configuration:  There are at least some personal details which should be configured 
"                  (see the files README.luasupport and luasupport.txt).
"  
"         Author:  Dr.-Ing. Fritz Mehner, FH Südwestfalen, 58644 Iserlohn, Germany
"          Email:  mehner@fh-swf.de
"  
"        Version:  see variable  g:Lua_Version  below 
"        Created:  06.07.2006
"        License:  Copyright (c) 2006-2007, Fritz Mehner
"                  This program is free software; you can redistribute it and/or
"                  modify it under the terms of the GNU General Public License as
"                  published by the Free Software Foundation, version 2 of the
"                  License.
"                  This program is distributed in the hope that it will be
"                  useful, but WITHOUT ANY WARRANTY; without even the implied
"                  warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
"                  PURPOSE.
"                  See the GNU General Public License version 2 for more details.
"       Revision:  $Id: lua-support.vim,v 1.5 2007/06/30 19:21:32 mehner Exp $
"------------------------------------------------------------------------------
" 
" Prevent duplicate loading: 
" 
if exists("g:Lua_Version") || &cp
 finish
endif
let g:Lua_Version= "1.1"  							" version number of this script; do not change
"        
"###############################################################################################
"
"  Global variables (with default values) which can be overridden.
"          
" Platform specific items:
" - root directory
" - characters that must be escaped for filenames
" 
let	s:MSWIN =		has("win16") || has("win32")     || has("win64") || 
							\ has("win95") || has("win32unix")
" 
if	s:MSWIN
	"
	let	s:Lua_Interpreter	='lua5.1.exe'
	let	s:Lua_Compiler		='luac5.1.exe'
	let s:plugin_dir			= $VIM.'\vimfiles\'
	let s:home_dir	  		= ''
  let s:escfilename 		= ' %#'
  let s:escfilename 		= ''
	"
else
	"
	let	s:Lua_Interpreter	='lua'
	let	s:Lua_Compiler		='luac'
	let s:plugin_dir			= $HOME.'/.vim/'
	let s:home_dir	  		= $HOME.'/'
  let s:escfilename 		= ' \%#[]'
	"
endif
"
"  Key word completion is enabled by the filetype plugin 'c.vim'
"  g:Lua_Dictionary_File  must be global
"          
if !exists("g:Lua_Dictionary_File")
  let g:Lua_Dictionary_File = s:plugin_dir.'lua-support/wordlists/lua.list'
endif
"
"  Modul global variables (with default values) which can be overridden.
"
let s:Lua_AuthorName     = ""
let s:Lua_AuthorRef      = ""
let s:Lua_Email          = ""
let s:Lua_Company        = ""
let s:Lua_Project        = ""
let s:Lua_CopyrightHolder= ""
"
let s:Lua_LoadMenus      = "yes"
" 
let s:Lua_CodeSnippets   = s:plugin_dir.'lua-support/codesnippets/'
let s:Lua_Scripts        = s:plugin_dir.'lua-support/scripts/'
"                     
let s:Lua_MenuHeader     = "yes"
let s:Lua_Printheader    = "%<%f%h%m%<  %=%{strftime('%x %X')}     Page %N"
let s:Lua_OutputGvim     = "vim"
let s:Lua_XtermDefaults  = "-fa courier -fs 12 -geometry 80x24"
let	s:Lua_LineEndCommColDefault	= 49
"  
"   ----- Lua template files ----------------------------------------------
let s:Lua_Template_Directory    = s:plugin_dir."lua-support/templates/"
"
let s:Lua_Template_Lua_File     = "lua-file-header"
let s:Lua_Template_Frame        = "lua-frame"
let s:Lua_Template_Function     = "lua-function-description"
"
"-----------------------------------------------------------------------------
"
"  Look for global variables (if any), to override the defaults.
"  
function! Lua_CheckGlobal ( name )
  if exists('g:'.a:name)
    exe 'let s:'.a:name.'  = g:'.a:name
  endif
endfunction    " ----------  end of function Lua_CheckGlobal ----------
"
call Lua_CheckGlobal("Lua_AuthorName             ")
call Lua_CheckGlobal("Lua_AuthorRef              ")
call Lua_CheckGlobal("Lua_Company                ")
call Lua_CheckGlobal("Lua_Compiler               ")
call Lua_CheckGlobal("Lua_CopyrightHolder        ")
call Lua_CheckGlobal("Lua_Email                  ")
call Lua_CheckGlobal("Lua_Interpreter            ")
call Lua_CheckGlobal("Lua_LoadMenus              ")
call Lua_CheckGlobal("Lua_MenuHeader             ")
call Lua_CheckGlobal("Lua_OutputGvim             ")
call Lua_CheckGlobal("Lua_Printheader            ")
call Lua_CheckGlobal("Lua_Project                ")
call Lua_CheckGlobal("Lua_Template_Directory     ")
call Lua_CheckGlobal("Lua_Template_Frame         ")
call Lua_CheckGlobal("Lua_Template_Function      ")
call Lua_CheckGlobal("Lua_Template_Lua_File      ")
call Lua_CheckGlobal("Lua_XtermDefaults          ")
"
"----- some variables for internal use only -----------------------------------
"
" set default geometry if not specified 
" 
if match( s:Lua_XtermDefaults, "-geometry\\s\\+\\d\\+x\\d\\+" ) < 0
	let s:Lua_XtermDefaults	= s:Lua_XtermDefaults." -geometry 80x24"
endif
"
" escape the printheader
"
let s:Lua_Printheader = escape( s:Lua_Printheader, ' %' )
"
let s:Lua_HlMessage   = ""
"
let s:Lua_Root				= "&Lua."
"
"------------------------------------------------------------------------------
"  Lua_InitMenu
"  Initialization of Lua support menus
"------------------------------------------------------------------------------
"
function! Lua_InitMenu ()
	"
	"===============================================================================================
	"----- Menu : Lua --------------------------------------------------------------------------------
	"===============================================================================================
	"
	if s:Lua_Root != '' && s:Lua_MenuHeader == "yes"
		exe "amenu  ".s:Lua_Root.'Lua	        <Esc>'
		exe "amenu  ".s:Lua_Root.'-Sep00-         :'
	endif
	"
	"===============================================================================================
	"----- Menu : Comments -----------------------------------------------------------------------
	"===============================================================================================
	"
	if s:Lua_MenuHeader == "yes"
		exe "amenu  ".s:Lua_Root.'&Comments.&Comments<Tab>Lua               <Esc>'
		exe "amenu  ".s:Lua_Root.'&Comments.-Sep00-                            :'
	endif
	exe "amenu <silent> ".s:Lua_Root.'&Comments.end-of-&line\ comment        <Esc><Esc><Esc>:call Lua_LineEndComment("-- ")<CR>A' 
	exe "vmenu <silent> ".s:Lua_Root.'&Comments.end-of-&line\ comment        <Esc><Esc><Esc>:call Lua_MultiLineEndComments("-- ")<CR>A'
	exe "amenu <silent> ".s:Lua_Root.'&Comments.ad&just\ end-of-line\ com\.  <Esc><Esc>:call Lua_AdjustLineEndComm("a")<CR>'
	exe "vmenu <silent> ".s:Lua_Root.'&Comments.ad&just\ end-of-line\ com\.  <Esc><Esc>:call Lua_AdjustLineEndComm("v")<CR>'

	exe "amenu <silent> ".s:Lua_Root.'&Comments.&set\ end-of-line\ com\.\ col\.  <Esc><Esc>:call Lua_GetLineEndCommCol()<CR>'

	exe "amenu  ".s:Lua_Root.'&Comments.-SEP1-                              :'
	exe "amenu <silent> ".s:Lua_Root."&Comments.&code->comment       <Esc><Esc>:s/^/--/<CR><Esc>:nohlsearch<CR>"
	exe "vmenu <silent> ".s:Lua_Root."&Comments.&code->comment       <Esc><Esc>:'<,'>s/^/--/<CR><Esc>:nohlsearch<CR>"
	exe "amenu <silent> ".s:Lua_Root."&Comments.c&omment->code       <Esc><Esc>:s/^\\(\\s*\\)--/\\1/<CR><Esc>:nohlsearch<CR>"
	exe "vmenu <silent> ".s:Lua_Root."&Comments.c&omment->code       <Esc><Esc>:'<,'>s/^\\(\\s*\\)--/\\1/<CR><Esc>:nohlsearch<CR>"
	exe "amenu <silent> ".s:Lua_Root.'&Comments.comment\ &block      <Esc><Esc>:call Lua_CommentBlock("a")<CR>'
	exe "vmenu <silent> ".s:Lua_Root.'&Comments.comment\ &block      <Esc><Esc>:call Lua_CommentBlock("v")<CR>'
	exe "amenu <silent> ".s:Lua_Root.'&Comments.u&ncomment\ block    <Esc><Esc>:call Lua_UncommentBlock()<CR>'
	
	exe "amenu          ".s:Lua_Root.'&Comments.-SEP2-                  :'
	exe "amenu <silent> ".s:Lua_Root.'&Comments.&frame\ comment         <Esc><Esc>:call Lua_CommentTemplates("frame")<CR>'
	exe "amenu <silent> ".s:Lua_Root.'&Comments.f&unction\ description  <Esc><Esc>:call Lua_CommentTemplates("function")<CR>'
	exe "amenu <silent> ".s:Lua_Root.'&Comments.file\ &header            <Esc><Esc>:call Lua_CommentTemplates("header")<CR>'
	"
	exe "amenu  ".s:Lua_Root.'&Comments.-SEP3-                        :'
	"
	exe " menu  ".s:Lua_Root.'&Comments.&date                   a<C-R>=strftime("%x")<CR>'
	exe "imenu  ".s:Lua_Root.'&Comments.&date                    <C-R>=strftime("%x")<CR>'
	exe " menu  ".s:Lua_Root.'&Comments.date\ &time             a<C-R>=strftime("%x %X %Z")<CR>'
	exe "imenu  ".s:Lua_Root.'&Comments.date\ &time              <C-R>=strftime("%x %X %Z")<CR>'
	"
	exe "amenu  ".s:Lua_Root.'&Comments.-SEP4-                        :'
	"
	"----- Submenu :  keyword comments  ----------------------------------------------------------
	"
	exe "amenu  ".s:Lua_Root.'&Comments.&KEYWORD+comm\..keyw\.+comm\.<Tab>Lua       <Esc>'
	exe "amenu  ".s:Lua_Root.'&Comments.&KEYWORD+comm\..-Sep0-            :'
	exe "amenu  ".s:Lua_Root.'&Comments.&KEYWORD+comm\..\:&BUG\:          <Esc><Esc>$<Esc>:call Lua_CommentClassified("BUG")        <CR>kgJ$F:la'
	exe "amenu  ".s:Lua_Root.'&Comments.&KEYWORD+comm\..\:&COMPILER\:     <Esc><Esc>$<Esc>:call Lua_CommentClassified("COMPILER")   <CR>kgJ$F:la'
	exe "amenu  ".s:Lua_Root.'&Comments.&KEYWORD+comm\..\:&TODO\:         <Esc><Esc>$<Esc>:call Lua_CommentClassified("TODO")       <CR>kgJ$F:la'
	exe "amenu  ".s:Lua_Root.'&Comments.&KEYWORD+comm\..\:T&RICKY\:       <Esc><Esc>$<Esc>:call Lua_CommentClassified("TRICKY")     <CR>kgJ$F:la'
	exe "amenu  ".s:Lua_Root.'&Comments.&KEYWORD+comm\..\:&WARNING\:      <Esc><Esc>$<Esc>:call Lua_CommentClassified("WARNING")    <CR>kgJ$F:la'
	exe "amenu  ".s:Lua_Root.'&Comments.&KEYWORD+comm\..\:W&ORKAROUND\:   <Esc><Esc>$<Esc>:call Lua_CommentClassified("WORKAROUND") <CR>kgJ$F:la'
	exe "amenu  ".s:Lua_Root.'&Comments.&KEYWORD+comm\..\:&new\ keyword\: <Esc><Esc>$<Esc>:call Lua_CommentClassified("")           <CR>kgJf:a'

	"
	"----- Submenu :  Tags  ----------------------------------------------------------
	"
	exe "amenu  ".s:Lua_Root.'&Comments.ta&gs\ (plugin).tags\ (plugin)<Tab>Lua       <Esc>'
	exe "amenu  ".s:Lua_Root.'&Comments.ta&gs\ (plugin).-Sep0-            :'
	"
	exe "amenu  ".s:Lua_Root.'&Comments.ta&gs\ (plugin).&AUTHOR           a'.s:Lua_AuthorName."<Esc>"
	exe "amenu  ".s:Lua_Root.'&Comments.ta&gs\ (plugin).AUTHOR&REF        a'.s:Lua_AuthorRef."<Esc>"
	exe "amenu  ".s:Lua_Root.'&Comments.ta&gs\ (plugin).&COMPANY          a'.s:Lua_Company."<Esc>"
	exe "amenu  ".s:Lua_Root.'&Comments.ta&gs\ (plugin).C&OPYRIGHTHOLDER  a'.s:Lua_CopyrightHolder."<Esc>"
	exe "amenu  ".s:Lua_Root.'&Comments.ta&gs\ (plugin).&EMAIL            a'.s:Lua_Email."<Esc>"
	exe "amenu  ".s:Lua_Root.'&Comments.ta&gs\ (plugin).&PROJECT          a'.s:Lua_Project."<Esc>"
                                       
	exe "imenu  ".s:Lua_Root.'&Comments.ta&gs\ (plugin).&AUTHOR           <Esc>a'.s:Lua_AuthorName
	exe "imenu  ".s:Lua_Root.'&Comments.ta&gs\ (plugin).AUTHOR&REF        <Esc>a'.s:Lua_AuthorRef
	exe "imenu  ".s:Lua_Root.'&Comments.ta&gs\ (plugin).&COMPANY          <Esc>a'.s:Lua_Company
	exe "imenu  ".s:Lua_Root.'&Comments.ta&gs\ (plugin).C&OPYRIGHTHOLDER  <Esc>a'.s:Lua_CopyrightHolder
	exe "imenu  ".s:Lua_Root.'&Comments.ta&gs\ (plugin).&EMAIL            <Esc>a'.s:Lua_Email
	exe "imenu  ".s:Lua_Root.'&Comments.ta&gs\ (plugin).&PROJECT          <Esc>a'.s:Lua_Project
	"
	"===============================================================================================
	"----- Menu : Lua-Statements ---------------------------------------------------------------------
	"===============================================================================================
	"
	if s:Lua_MenuHeader == "yes"
		exe "amenu  ".s:Lua_Root.'&Statements.&Statements<Tab>Lua       <Esc>'
		exe "amenu  ".s:Lua_Root.'&Statements.-Sep00-                      :'
	endif
	"
	exe "amenu <silent> ".s:Lua_Root.'St&atements.&for\ do\ end                   <Esc><Esc>:call Lua_StatBlock( "a", "for  = , do\nend", "" )<CR>frla'
	exe "amenu <silent> ".s:Lua_Root.'St&atements.f&or\ in\ do\ end               <Esc><Esc>:call Lua_StatBlock( "a", "for  in  do\nend", "" )<CR>frla'
	exe "amenu <silent> ".s:Lua_Root.'St&atements.&if\ then\ end                  <Esc><Esc>:call Lua_StatBlock( "a", "if  then\nend", "" )<CR>ffla'
	exe "amenu <silent> ".s:Lua_Root.'St&atements.if\ then\ &else\ end            <Esc><Esc>:call Lua_StatBlock( "a", "if  then\nelse\nend", "" )<CR>ffla'
	exe "amenu <silent> ".s:Lua_Root.'St&atements.e&lseif\ then                    <Esc><Esc>:call Lua_StatBlock( "a", "elseif  then\nDUMMY", "" )<CR>j"_ddkffla'
	exe "amenu <silent> ".s:Lua_Root.'St&atements.&repeat\ until                  <Esc><Esc>:call Lua_RepeatUntil("a")<CR><Esc>A'
	exe "amenu <silent> ".s:Lua_Root.'St&atements.&while\ do\ end                 <Esc><Esc>:call Lua_StatBlock( "a", "while  do\nend", "" )<CR>fela'
    "
	exe "vmenu <silent> ".s:Lua_Root.'St&atements.&for\ do\ end                   <Esc><Esc>:call Lua_StatBlock( "v", "for  = , do", "end" )<CR>frla'
	exe "vmenu <silent> ".s:Lua_Root.'St&atements.f&or\ in\ do\ end               <Esc><Esc>:call Lua_StatBlock( "v", "for  in  do", "end" )<CR>frla'
	exe "vmenu <silent> ".s:Lua_Root.'St&atements.&if\ then\ end                  <Esc><Esc>:call Lua_StatBlock( "v", "if  then", "end" )<CR>ffla'
	exe "vmenu <silent> ".s:Lua_Root.'St&atements.if\ then\ &else\ end            <Esc><Esc>:call Lua_StatBlock( "v", "if  then", "else\nend" )<CR>ffla'
	exe "vmenu <silent> ".s:Lua_Root.'St&atements.&repeat\ until                  <Esc><Esc>:call Lua_RepeatUntil("v")<CR><Esc>A'
	exe "vmenu <silent> ".s:Lua_Root.'St&atements.&while\ do\ end                 <Esc><Esc>:call Lua_StatBlock( "v", "while  do", "end" )<CR>fela'
	"
	"===============================================================================================
	"----- Menu : Idioms -------------------------------------------------------------------------
	"===============================================================================================
	"
	if s:Lua_MenuHeader == "yes"
		exe "amenu          ".s:Lua_Root.'&Idioms.&Idioms<Tab>Lua         <Esc>'
		exe "amenu          ".s:Lua_Root.'&Idioms.-Sep00-                   :'
	endif

	exe "amenu ".s:Lua_Root.'&Idioms.&function                   <Esc><Esc>:call Lua_Function("a")<CR>f(la'
	exe "vmenu ".s:Lua_Root.'&Idioms.&function                   <Esc><Esc>:call Lua_Function("v")<CR>f(la'

  exe " noremenu ".s:Lua_Root.'&Idioms.&print        <Esc>aprint()<Left>'
  exe "inoremenu ".s:Lua_Root.'&Idioms.&print              print()<Left>'
  exe "vnoremenu ".s:Lua_Root.'&Idioms.&print             sprint()<ESC>P'
	"
	exe "amenu ".s:Lua_Root.'&Idioms.for\ &k,v\ in\ pairs()\ do     <Esc><Esc>:call Lua_ForDoEnd("a")<CR>f(a'
	exe "vmenu ".s:Lua_Root.'&Idioms.for\ &k,v\ in\ pairs()\ do     <Esc><Esc>:call Lua_ForDoEnd("v")<CR>f(a'

  exe " noremenu ".s:Lua_Root.'&Idioms.&assert        <Esc>aassert()<Left>'
  exe "inoremenu ".s:Lua_Root.'&Idioms.&assert              assert()<Left>'
  exe "vnoremenu ".s:Lua_Root.'&Idioms.&assert             sassert()<ESC>P'
	"
	exe "amenu ".s:Lua_Root.'&Idioms.open\ &input\ file            <Esc><Esc>:call Lua_OpenInputFile()<CR>a'
	exe "amenu ".s:Lua_Root.'&Idioms.open\ &output\ file           <Esc><Esc>:call Lua_OpenOutputFile()<CR>a'
	"
	"
	"===============================================================================================
	"----- Menu : Snippets -------------------------------------------------------------------------
	"===============================================================================================
	if s:Lua_CodeSnippets != ""
		if s:Lua_MenuHeader == "yes"
			exe "amenu          ".s:Lua_Root.'S&nippets.S&nippets<Tab>Lua         <Esc>'
			exe "amenu          ".s:Lua_Root.'S&nippets.-Sep00-                   :'
		endif
		exe "amenu  <silent> ".s:Lua_Root.'S&nippets.&read\ code\ snippet   <C-C>:call Lua_CodeSnippet("r")<CR>'
		exe "amenu  <silent> ".s:Lua_Root.'S&nippets.&write\ code\ snippet  <C-C>:call Lua_CodeSnippet("w")<CR>'
		exe "vmenu  <silent> ".s:Lua_Root.'S&nippets.&write\ code\ snippet  <C-C>:call Lua_CodeSnippet("wv")<CR>'
		exe "amenu  <silent> ".s:Lua_Root.'S&nippets.&edit\ code\ snippet   <C-C>:call Lua_CodeSnippet("e")<CR>'
	endif
	"
	"===============================================================================================
	"----- Menu : Regex -------------------------------------------------------------------------
	"===============================================================================================
	"
	if s:Lua_MenuHeader == "yes"
		exe "amenu ".s:Lua_Root.'Rege&x.Rege&x<Tab>Lua      <Esc>'
		exe "amenu ".s:Lua_Root.'Rege&x.-Sep0-         :'
	endif
	"
	exe "anoremenu ".s:Lua_Root.'Rege&x.&Grouping<Tab>(\ )               <Esc><Esc>a()<Left>'
	exe "vnoremenu ".s:Lua_Root.'Rege&x.&Grouping<Tab>(\ )               s()<Esc>P'
	exe "anoremenu ".s:Lua_Root.'Rege&x.Char\.\ &class<Tab>[\ ]          <Esc><Esc>a[]<Left>'
	exe "vnoremenu ".s:Lua_Root.'Rege&x.Char\.\ &class<Tab>[\ ]          s[]<Esc>P'
	"
	exe " menu ".s:Lua_Root.'Rege&x.-SEP1-                             :'
	"
	exe " menu ".s:Lua_Root.'Rege&x.l&etters<Tab>%a                   <Esc>a%a'
	exe " menu ".s:Lua_Root.'Rege&x.&control\ char\.<Tab>%c           <Esc>a%c'
	exe " menu ".s:Lua_Root.'Rege&x.&digits<Tab>%d                    <Esc>a%d'
	exe " menu ".s:Lua_Root.'Rege&x.&lower-case\ letters<Tab>%l       <Esc>a%l'
	exe " menu ".s:Lua_Root.'Rege&x.&punct\.\ char\.<Tab>%p           <Esc>a%p'
	exe " menu ".s:Lua_Root.'Rege&x.&space\ char\.<Tab>%s             <Esc>a%s'
	exe " menu ".s:Lua_Root.'Rege&x.&upper-case\ letters<Tab>%u       <Esc>a%u'
	exe " menu ".s:Lua_Root.'Rege&x.alpha&num\.\ char\.<Tab>%w        <Esc>a%w'
	exe " menu ".s:Lua_Root.'Rege&x.he&xadec\.\ digits<Tab>%x         <Esc>a%x'
	exe " menu ".s:Lua_Root.'Rege&x.&zero-char\.<Tab>%z               <Esc>a%z'
	"
	exe "imenu ".s:Lua_Root.'Rege&x.l&etters<Tab>%a                   %a'
	exe "imenu ".s:Lua_Root.'Rege&x.&control\ char\.<Tab>%c           %c'
	exe "imenu ".s:Lua_Root.'Rege&x.&digits<Tab>%d                    %d'
	exe "imenu ".s:Lua_Root.'Rege&x.&lower-case\ letters<Tab>%l       %l'
	exe "imenu ".s:Lua_Root.'Rege&x.&punct\.\ char\.<Tab>%p           %p'
	exe "imenu ".s:Lua_Root.'Rege&x.&space\ char\.<Tab>%s             %s'
	exe "imenu ".s:Lua_Root.'Rege&x.&upper-case\ letters<Tab>%u       %u'
	exe "imenu ".s:Lua_Root.'Rege&x.alpha&num\.\ char\.<Tab>%w        %w'
	exe "imenu ".s:Lua_Root.'Rege&x.he&xadec\.\ digits<Tab>%x         %x'
	exe "imenu ".s:Lua_Root.'Rege&x.&zero-char\.<Tab>%z               %z'
	"
	"
	"===============================================================================================
	"----- Menu : run  -----------------------------------------------------------------------------
	"===============================================================================================
	"
	if s:Lua_MenuHeader == "yes"
		exe "amenu  ".s:Lua_Root.'&Run.&Run<Tab>Lua         <Esc>'
		exe "amenu  ".s:Lua_Root.'&Run.-Sep00-                 :'
	endif
	exe "amenu <silent> ".s:Lua_Root.'&Run.update,\ &run\ script<Tab><C-F9>         <C-C>:call Lua_Run()<CR>'
	exe "amenu          ".s:Lua_Root.'&Run.update,\ check\ &syntax<Tab><A-F9>       <C-C>:call Lua_SyntaxCheck()<CR>:redraw<CR>:call Lua_SyntaxCheckMsg()<CR>'
	exe "amenu <silent> ".s:Lua_Root.'&Run.cmd\.\ line\ &arg\.<Tab><S-F9>           <C-C>:call Lua_Arguments()<CR>'
	"
	exe "amenu  <silent>  ".s:Lua_Root.'&Run.-SEP0-                              :'
	exe "amenu  <silent>  ".s:Lua_Root.'&Run.&make                               <C-C>:call Lua_Make()<CR>'
	exe "amenu  <silent>  ".s:Lua_Root.'&Run.cmd\.\ line\ ar&g\.\ for\ make      <C-C>:call Lua_MakeArguments()<CR>'
	exe "amenu  <silent>  ".s:Lua_Root.'&Run.-SEP2-                              :'
	if	s:MSWIN
		exe "amenu  <silent>  ".s:Lua_Root.'&Run.&hardcopy\ to\ printer              <C-C>:call Lua_Hardcopy("n")<CR>'
		exe "vmenu  <silent>  ".s:Lua_Root.'&Run.&hardcopy\ to\ printer              <C-C>:call Lua_Hardcopy("v")<CR>'
	else
		exe "amenu  <silent>  ".s:Lua_Root.'&Run.&hardcopy\ to\ FILENAME\.ps         <C-C>:call Lua_Hardcopy("n")<CR>'
		exe "vmenu  <silent>  ".s:Lua_Root.'&Run.&hardcopy\ to\ FILENAME\.ps         <C-C>:call Lua_Hardcopy("v")<CR>'
	endif
	exe "imenu  <silent>  ".s:Lua_Root.'&Run.-SEP3-                              :'

	exe "amenu  <silent>  ".s:Lua_Root.'&Run.s&ettings                             <C-C>:call Lua_Settings()<CR>'
	exe "imenu  <silent>  ".s:Lua_Root.'&Run.-SEP4-                                :'

	if	!s:MSWIN
		exe "amenu  <silent>  ".s:Lua_Root.'&Run.&xterm\ size                             <C-C>:call Lua_XtermSize()<CR>'
	endif
	if s:Lua_OutputGvim == "vim" 
		exe "amenu  <silent>  ".s:Lua_Root.'&Run.&output:\ VIM->buffer->xterm            <C-C>:call Lua_Toggle_Gvim_Xterm()<CR><CR>'
	else
		if s:Lua_OutputGvim == "buffer" 
			exe "amenu  <silent>  ".s:Lua_Root.'&Run.&output:\ BUFFER->xterm->vim        <C-C>:call Lua_Toggle_Gvim_Xterm()<CR><CR>'
		else
			exe "amenu  <silent>  ".s:Lua_Root.'&Run.&output:\ XTERM->vim->buffer          <C-C>:call Lua_Toggle_Gvim_Xterm()<CR><CR>'
		endif
	endif
	"
	"===============================================================================================
	"----- Menu : help  ----------------------------------------------------------------------------
	"===============================================================================================
	"
	if s:Lua_Root != ""
		exe "menu  <silent>  ".s:Lua_Root.'&help\ \(plugin\)     <C-C><C-C>:call Lua_Help()<CR>'
	endif

endfunction    " ----------  end of function  Lua_InitMenu  ----------
"
"===============================================================================================
"----- Menu Functions --------------------------------------------------------------------------
"===============================================================================================
"
"------------------------------------------------------------------------------
"  Input after a highlighted prompt
"------------------------------------------------------------------------------
function! Lua_Input ( promp, text )
	echohl Search												" highlight prompt
	call inputsave()										" preserve typeahead
	let	retval=input( a:promp, a:text )	" read input
	call inputrestore()									" restore typeahead
	echohl None													" reset highlighting
	return retval
endfunction    " ----------  end of function Lua_Input ----------
"
"------------------------------------------------------------------------------
"  Lua_AdjustLineEndComm: adjust line-end comments  
"------------------------------------------------------------------------------
function! Lua_AdjustLineEndComm ( mode ) range
	"
	if !exists("b:Lua_LineEndCommentColumn")
		let	b:Lua_LineEndCommentColumn	= s:Lua_LineEndCommColDefault
	endif

	let save_cursor = getpos(".")

	let	save_expandtab	= &expandtab
	exe	":set expandtab"

	if a:mode == 'v'
		let pos0	= line("'<")
		let pos1	= line("'>")
	else
		let pos0	= line(".")
		let pos1	= pos0
	end

	let	linenumber	= pos0
	exe ":".pos0

	while linenumber <= pos1
		let	line= getline(".")
		" look for a Perl comment
		let idx1	= 1 + match( line, '\s*--.*$' )
		let idx2	= 1 + match( line, '--.*$' )

		let	ln	= line(".")
		call setpos(".", [ 0, ln, idx1, 0 ] )
		let vpos1	= virtcol(".")
		call setpos(".", [ 0, ln, idx2, 0 ] )
		let vpos2	= virtcol(".")

		if   ! (  vpos2 == b:Lua_LineEndCommentColumn 
					\	|| vpos1 > b:Lua_LineEndCommentColumn
					\	|| idx2  == 0 )

			exe ":.,.retab"
			" insert some spaces
			if vpos2 < b:Lua_LineEndCommentColumn
				let	diff	= b:Lua_LineEndCommentColumn-vpos2
				call setpos(".", [ 0, ln, vpos2, 0 ] )
				let	@"	= ' '
				exe "normal	".diff."P"
			end

			" remove some spaces
			if vpos1 < b:Lua_LineEndCommentColumn && vpos2 > b:Lua_LineEndCommentColumn
				let	diff	= vpos2 - b:Lua_LineEndCommentColumn
				call setpos(".", [ 0, ln, b:Lua_LineEndCommentColumn, 0 ] )
				exe "normal	".diff."x"
			end

		end
		let linenumber=linenumber+1
		normal j
	endwhile
	" restore tab expansion settings and cursor position
	let &expandtab	= save_expandtab
	call setpos('.', save_cursor)

endfunction		" ---------- end of function  Lua_AdjustLineEndComm  ----------
"
"------------------------------------------------------------------------------
"  Comments : get line-end comment position
"------------------------------------------------------------------------------
function! Lua_GetLineEndCommCol ()
	let actcol	= virtcol(".")
	if actcol+1 == virtcol("$")
		let	b:Lua_LineEndCommentColumn	= Lua_Input( 'start line-end comment at virtual column : ', actcol )
	else
		let	b:Lua_LineEndCommentColumn	= virtcol(".") 
	endif
  echomsg "line end comments will start at column  ".b:Lua_LineEndCommentColumn
endfunction		" ---------- end of function  Lua_GetLineEndCommCol  ----------
"
"------------------------------------------------------------------------------
"  Comments : single line-end comment
"------------------------------------------------------------------------------
function! Lua_LineEndComment ( arg1 )
	if !exists("b:Lua_LineEndCommentColumn")
		let	b:Lua_LineEndCommentColumn	= s:Lua_LineEndCommColDefault
	endif
	" ----- trim whitespaces -----
	exe 's/\s*$//'
	let linelength= virtcol("$") - 1
	if linelength < b:Lua_LineEndCommentColumn
		let diff	= b:Lua_LineEndCommentColumn -1 -linelength
		exe "normal	".diff."A "
	endif
	" append at least one blank
	if linelength >= b:Lua_LineEndCommentColumn
		exe "normal A "
	endif
	exe "normal	$A".a:arg1
endfunction		" ---------- end of function  Lua_LineEndComment  ----------
"
"------------------------------------------------------------------------------
"  Comments : multi line-end comments
"------------------------------------------------------------------------------
function! Lua_MultiLineEndComments ( arg1 )
	"
  if !exists("b:Lua_LineEndCommentColumn")
		let	b:Lua_LineEndCommentColumn	= s:Lua_LineEndCommColDefault
  endif
	"
	let pos0	= line("'<")
	let pos1	= line("'>")
	"
	" ----- trim whitespaces -----
  exe pos0.','.pos1.'s/\s*$//'  
	" 
	" ----- find the longest line -----
	let	maxlength		= 0
	let	linenumber	= pos0
	normal '<
	while linenumber <= pos1
		if  getline(".") !~ "^\\s*$"  && maxlength<virtcol("$")
			let maxlength= virtcol("$")
		endif
		let linenumber=linenumber+1
		normal j
	endwhile
	"
	if maxlength < b:Lua_LineEndCommentColumn
	  let maxlength = b:Lua_LineEndCommentColumn
	else
	  let maxlength = maxlength+1		" at least 1 blank
	endif
	"
	" ----- fill lines with blanks -----
	let	linenumber	= pos0
	while linenumber <= pos1
		exe ":".linenumber
		if getline(".") !~ "^\\s*$"
			let diff	= maxlength - virtcol("$")
			exe "normal	".diff."A "
			exe "normal	$A".a:arg1
		endif
		let linenumber=linenumber+1
	endwhile
	" ----- back to the begin of the marked block -----
	exe ":".pos0
endfunction		" ---------- end of function  Lua_MultiLineEndComments  ----------
"
"------------------------------------------------------------------------------
"  Comments : classified comments
"------------------------------------------------------------------------------
function! Lua_CommentClassified (class)
  	put = '	-- :'.a:class.':'.strftime(\"%x %X\").':'.s:Lua_AuthorRef.':  '
endfunction    " ----------  end of function Lua_CommentClassified ----------
"
"------------------------------------------------------------------------------
"  comment block
"------------------------------------------------------------------------------
"
let s:Lua_CmtCounter   = 0
let s:Lua_CmtLabel     = "BlockCommentNo_"
"
function! Lua_CommentBlock (mode)
  "
  let s:Lua_CmtCounter = 0
  let save_line         = line(".")
  let actual_line       = 0
  "
  " search for the maximum option number (if any)
  "
  normal gg
  while actual_line < search( s:Lua_CmtLabel."\\d\\+" )
    let actual_line = line(".")
    let actual_opt  = matchstr( getline(actual_line), s:Lua_CmtLabel."\\d\\+" )
    let actual_opt  = strpart( actual_opt, strlen(s:Lua_CmtLabel),strlen(actual_opt)-strlen(s:Lua_CmtLabel))
    if s:Lua_CmtCounter < actual_opt
      let s:Lua_CmtCounter = actual_opt
    endif
  endwhile
  let s:Lua_CmtCounter = s:Lua_CmtCounter+1
  silent exe ":".save_line
  "
  if a:mode=='a'
    let zz=      "--[[  --  ".s:Lua_CmtLabel.s:Lua_CmtCounter
    let zz= zz."\n--]]  --  ".s:Lua_CmtLabel.s:Lua_CmtCounter
    put =zz
  endif

  if a:mode=='v'
    let zz=      "--[[  --  ".s:Lua_CmtLabel.s:Lua_CmtCounter
    :'<put! =zz
    let zz=      "--]]  --  ".s:Lua_CmtLabel.s:Lua_CmtCounter
    :'>put  =zz
  endif

endfunction    " ----------  end of function Lua_CommentBlock ----------
"
"------------------------------------------------------------------------------
"  uncomment block
"------------------------------------------------------------------------------
function! Lua_UncommentBlock ()

  let frstline  = searchpair( '^--\[\[\s*--\s*'.s:Lua_CmtLabel.'\d\+',
      \                       '',
      \                       '^--\]\]\s*--\s*'.s:Lua_CmtLabel.'\d\+',
      \                       'bn' )
  if frstline<=0
    echohl WarningMsg | echo 'no comment block/tag found or cursor not inside a comment block'| echohl None
    return
  endif
  let lastline  = searchpair( '^--\[\[\s*--\s*'.s:Lua_CmtLabel.'\d\+',
      \                       '',
      \                       '^--\]\]\s*--\s*'.s:Lua_CmtLabel.'\d\+',
      \                       'n' )
  if lastline<=0
    echohl WarningMsg | echo 'no comment block/tag found or cursor not inside a comment block'| echohl None
    return
  endif
  let actualnumber1  = matchstr( getline(frstline), s:Lua_CmtLabel."\\d\\+" )
  let actualnumber2  = matchstr( getline(lastline), s:Lua_CmtLabel."\\d\\+" )
  if actualnumber1 != actualnumber2
    echohl WarningMsg | echo 'lines '.frstline.', '.lastline.': comment tags do not match'| echohl None
    return
  endif

  silent exe ':'.lastline.'d'
  silent exe ':'.frstline.'d'
echo frstline." ".lastline

endfunction    " ----------  end of function Lua_UncommentBlock ----------
"
"------------------------------------------------------------------------------
"  Substitute tags
"------------------------------------------------------------------------------
function! Lua_SubstituteTag( pos1, pos2, tag, replacement )
	" 
	" loop over marked block
	" 
	let	linenumber=a:pos1
	while linenumber <= a:pos2
		let line	= getline(linenumber)
		" 
		" loop for multiple tags in one line
		" 
		let	start=0
		while match(line,a:tag,start)>=0				" do we have a tag ?
			let frst = match(line,a:tag,start)
			let last = matchend(line,a:tag,start)
			if frst!=-1
				let part1 = strpart(line,0,frst)
				let part2 = strpart(line,last)
				let line  = part1.a:replacement.part2
				"
				" next search starts after the replacement to suppress recursion
				" 
				let start=strlen(part1)+strlen(a:replacement)
			endif
		endwhile
		call setline( linenumber, line )
		let	linenumber=linenumber+1
	endwhile

endfunction    " ----------  end of function  Lua_SubstituteTag  ----------
"
"------------------------------------------------------------------------------
"  Comments : Insert a template files
"------------------------------------------------------------------------------
function! Lua_CommentTemplates (arg)

	"----------------------------------------------------------------------
	"  templates
	"----------------------------------------------------------------------
	if a:arg=='frame'
		let templatefile=s:Lua_Template_Directory.s:Lua_Template_Frame
	endif
	if a:arg=='function'
		let templatefile=s:Lua_Template_Directory.s:Lua_Template_Function
	endif
	if a:arg=='header'
		let templatefile=s:Lua_Template_Directory.s:Lua_Template_Lua_File
	endif

	if filereadable(templatefile)
		let	length= line("$")
		let	pos1  = line(".")+1
		"
		let l:old_cpoptions	= &cpoptions " Prevent the alternate buffer from being set to this files
		setlocal cpoptions-=a
		if  a:arg=='header' 
			:goto 1
			let	pos1  = 1
			silent exe '0read '.templatefile
		else
			silent exe 'read '.templatefile
		endif
		let &cpoptions	= l:old_cpoptions		" restore previous options
		let	length= line("$")-length
		let	pos2  = pos1+length-1
		"----------------------------------------------------------------------
		"  frame comment will be indented
		"----------------------------------------------------------------------
		if a:arg=='frame'
			let	length	= length-1
			silent exe "normal =".length."+"
			let	length	= length+1
		endif
		"----------------------------------------------------------------------
		"  substitute keywords
		"----------------------------------------------------------------------

		call  Lua_SubstituteTag( pos1, pos2, '|FILENAME|',        expand("%:t")        )
		call  Lua_SubstituteTag( pos1, pos2, '|DATE|',            strftime("%x %X %Z") )
		call  Lua_SubstituteTag( pos1, pos2, '|TIME|',            strftime("%X")       )
		call  Lua_SubstituteTag( pos1, pos2, '|YEAR|',            strftime("%Y")       )
		call  Lua_SubstituteTag( pos1, pos2, '|AUTHOR|',          s:Lua_AuthorName       )
		call  Lua_SubstituteTag( pos1, pos2, '|EMAIL|',           s:Lua_Email            )
		call  Lua_SubstituteTag( pos1, pos2, '|AUTHORREF|',       s:Lua_AuthorRef        )
		call  Lua_SubstituteTag( pos1, pos2, '|PROJECT|',         s:Lua_Project          )
		call  Lua_SubstituteTag( pos1, pos2, '|COMPANY|',         s:Lua_Company          )
		call  Lua_SubstituteTag( pos1, pos2, '|COPYRIGHTHOLDER|', s:Lua_CopyrightHolder  )

		"----------------------------------------------------------------------
		"  Position the cursor
		"----------------------------------------------------------------------
		exe ':'.pos1
		normal 0
		let linenumber=search('|CURSOR|')
		if linenumber >=pos1 && linenumber<=pos2
			let pos1=match( getline(linenumber) ,"|CURSOR|")
			if  matchend( getline(linenumber) ,"|CURSOR|") == match( getline(linenumber) ,"$" )
				silent! s/|CURSOR|//
				" this is an append like A
				:startinsert!
			else
				silent  s/|CURSOR|//
				call cursor(linenumber,pos1+1)
				" this is an insert like i
				:startinsert
			endif
		endif
		:set modified
	else
		echohl WarningMsg | echo 'template file '.templatefile.' does not exist or is not readable'| echohl None
	endif
	
endfunction    " ----------  end of function  Lua_CommentTemplates  ----------
"
"=====================================================================================
"----- Menu : Statements -----------------------------------------------------------
"=====================================================================================
"
"------------------------------------------------------------------------------
"  Statements : repeat-until
"  Also called in the filetype plugin lua.vim
"------------------------------------------------------------------------------
function! Lua_RepeatUntil (arg)

  if a:arg=='a'
      let zz= "repeat\nuntil "
      put =zz
			normal  =1-j
  endif

  if a:arg=='v'
		let zz=    "repeat"
    :'<put! =zz
    let zz=    "until "
    :'>put =zz
    :'<-1
    :exe "normal =".(line("'>")-line(".")+1)."+"
    :'>+1
  endif

endfunction   " ---------- end of function  Lua_RepeatUntil  ----------
"
"------------------------------------------------------------------------------
"  Statements : statement  {}
"------------------------------------------------------------------------------
function! Lua_StatBlock ( mode, stmt1, stmt2)

  let part1 = a:stmt1
  let part2 = a:stmt2
  "
  let cr1=0
  let start=0
  while 1
    let start = matchend( part1, '\n', start ) 
    if start>=0
      let cr1 = cr1+1
    else
      break
    endif
  endwhile
  "
  " whole construct in part1
  if a:mode=='a'
    let zz=    part1
    put =zz
    if v:version<700
      :exe "normal =".cr1."+"
    else
      :exe "normal =".cr1."-"
    endif
  endif

  if a:mode=='v'
    "
    let cr2=0
    let start=0
    while 1
      let start = matchend( part2, '\n', start ) 
      if start>=0
        let cr2 = cr2+1
      else
        break
      endif
    endwhile
    let zz=    part1
    :'<put! =zz
    let zz=  part2
    :'>put =zz
    if cr2>0
      if v:version<700
        :exe "normal ".cr2."j"
      endif
    endif
    let cr1 = cr1+cr2+2+line("'>")-line("'<")
    :exe "normal =".cr1."-"
  endif
endfunction    " ----------  end of function Lua_StatBlock  ----------
"
"------------------------------------------------------------------------------
"  Statements : function
"------------------------------------------------------------------------------
function! Lua_Function (arg1)
  let identifier=Lua_Input("function name : ", "" )
  "
  if identifier==""
    return
  endif
  "
  " ----- normal mode ----------------
  if a:arg1=="a" 
      let zz=    "function ".identifier." (  )\n\treturn\nend"
      let zz= zz."  ----------  end of function ".identifier."  ----------" 
      put =zz
      if v:version<700
        normal 2j
      else
        normal 2k
      endif
  endif
  "
  " ----- visual mode ----------------
  if a:arg1=="v" 
      let zz=    "function ".identifier." (  )"
      :'<put! =zz
      let zz=    "\treturn\nend"
      let zz= zz."  ----------  end of function ".identifier."  ----------" 
      :'>put =zz
			:'<-1
      :exe "normal =".(line("'>")-line(".")+2)."+"
  endif
endfunction   " ---------- end of function  Lua_Function  ----------
"
"------------------------------------------------------------------------------
"  Idioms : for key, val do pairs() ... end
"  Also called in the filetype plugin lua.vim
"------------------------------------------------------------------------------
function! Lua_ForDoEnd (arg)

  if a:arg=='a'
		let zz= "for key, val in pairs() do\nend"
		put =zz
		normal  =1-
  endif

  if a:arg=='v'
		let zz= "for key, val in pairs() do"
    :'<put! =zz
		let zz=    "end"
    :'>put =zz
    :'<-1
    :exe "normal =".(line("'>")-line(".")+1)."+"
  endif

endfunction   " ---------- end of function  Lua_ForDoEnd  ----------
"
"------------------------------------------------------------------------------
"  Idioms : CodeOpenRead
"------------------------------------------------------------------------------
function! Lua_OpenInputFile ()

  let filehandle=Lua_Input( 'input file handle : ', 'INFILE' )
  
  if filehandle==""
    let filehandle  = "INFILE"
  endif
  
  let filename=filehandle."_file_name"

  let zz=    "local\t".filename." = \'\'\n"
  let zz= zz."local\t".filehandle.' = assert( io.open( '.filename.", \"r\" ) )\n\n"
  let zz= zz."assert( io.close(".filehandle.") )\n\n"
  exe " menu ".s:Lua_Root.'&Idioms.'.filehandle.':read()     i'.filehandle.':read)  )<ESC>3hr(la'
  exe "vmenu ".s:Lua_Root.'&Idioms.'.filehandle.':read()     s'.filehandle.':read)  )<ESC>3hr(lp'
  exe "imenu ".s:Lua_Root.'&Idioms.'.filehandle.':read()      '.filehandle.':read)  )<ESC>3hr(la'
  put =zz
	normal =4-
  normal f'
endfunction   " ---------- end of function  Lua_OpenInputFile  ----------
"
"------------------------------------------------------------------------------
"  Idioms : CodeOpenRead
"------------------------------------------------------------------------------
function! Lua_OpenOutputFile ()

  let filehandle=Lua_Input( 'output file handle : ', 'OUTFILE' )
  
  if filehandle==""
    let filehandle  = "OUTFILE"
  endif
  
  let filename=filehandle."_file_name"

  let zz=    "local\t".filename." = \'\'\n"
  let zz= zz."local\t".filehandle.' = assert( io.open( '.filename.", \"w\" ) )\n\n"
  let zz= zz."assert( io.close(".filehandle.") )\n\n"
  exe " menu ".s:Lua_Root.'&Idioms.'.filehandle.':write()     i'.filehandle.':write)  )<ESC>3hr(la'
  exe "vmenu ".s:Lua_Root.'&Idioms.'.filehandle.':write()     s'.filehandle.':write)  )<ESC>3hr(lp'
  exe "imenu ".s:Lua_Root.'&Idioms.'.filehandle.':write()      '.filehandle.':write)  )<ESC>3hr(la'
  put =zz
	normal =4-
  normal f'
endfunction   " ---------- end of function  Lua_OpenOutputFile  ----------

"------------------------------------------------------------------------------
"  Idioms : read / edit code snippet
"------------------------------------------------------------------------------
function! Lua_CodeSnippet(mode)
  if isdirectory(s:Lua_CodeSnippets)
    "
    " read snippet file, put content below current line
    " 
    if a:mode == "r"
			if has("gui_running")
				let l:snippetfile=browse(0,"read a code snippet",s:Lua_CodeSnippets,"")
			else
				let	l:snippetfile=input("read snippet ", s:Lua_CodeSnippets, "file" )
			end
      if filereadable(l:snippetfile)
        let linesread= line("$")
        let l:old_cpoptions = &cpoptions " Prevent the alternate buffer from being set to this files
        setlocal cpoptions-=a
        :execute "read ".l:snippetfile
        let &cpoptions  = l:old_cpoptions   " restore previous options
        "
        let linesread= line("$")-linesread-1
        if linesread>=0 && match( l:snippetfile, '\.\(ni\|noindent\)$' ) < 0 
          silent exe "normal =".linesread."+"
        endif
      endif
    endif
    "
    " update current buffer / split window / edit snippet file
    " 
    if a:mode == "e"
			if has("gui_running")
				let l:snippetfile=browse(0,"edit a code snippet",s:Lua_CodeSnippets,"")
			else
				let	l:snippetfile=input("edit snippet ", s:Lua_CodeSnippets, "file" )
			end
      if l:snippetfile != ""
        :execute "update! | split | edit ".l:snippetfile
      endif
    endif
    "
    " write whole buffer or marked area into snippet file 
    " 
    if a:mode == "w" || a:mode == "wv"
			if has("gui_running")
				let l:snippetfile=browse(0,"write a code snippet",s:Lua_CodeSnippets,"")
			else
				let	l:snippetfile=input("write snippet ", s:Lua_CodeSnippets, "file" )
			end
      if l:snippetfile != ""
        if filereadable(l:snippetfile)
          if confirm("File ".l:snippetfile." exists ! Overwrite ? ", "&Cancel\n&No\n&Yes") != 3
            return
          endif
        endif
				if a:mode == "w"
					:execute ":write! ".l:snippetfile
				else
					:execute ":*write! ".l:snippetfile
				end
      endif
    endif

  else
    redraw
    echohl ErrorMsg
    echo "code snippet directory ".s:Lua_CodeSnippets." does not exist"
    echohl None
  endif
endfunction   " ---------- end of function  Lua_CodeSnippet  ----------
"
"
"------------------------------------------------------------------------------
"  run : Lua_EscapeBlanks
"------------------------------------------------------------------------------
function! Lua_EscapeBlanks (arg)
	return  substitute( a:arg, " ", "\\ ", "g" )
endfunction    " ---------  end of function Lua_EscapeBlanks  ----------
"
"
"------------------------------------------------------------------------------
"  run : syntax check
"  Also called in the filetype plugin lua.vim
"------------------------------------------------------------------------------
"
function! Lua_SyntaxCheck ()
  let s:Lua_SyntaxCheckMsg = ""
  exe ":cclose"
  let l:currentdir      = getcwd()
  let l:currentbuffer   = bufname("%")
  let l:fullname        = l:currentdir."/".l:currentbuffer
  silent exe  ":update"
  "
  " avoid filtering the Lua output if the file name does not contain blanks:
  " 
	let l:fullname        = escape( l:fullname, s:escfilename )
	"
	" 
	let	makeprg_saved	= &makeprg
	exe ':setlocal makeprg='.s:Lua_Compiler
	exe ":setlocal errorformat=".s:Lua_Compiler.':\ %f:%l:%m,'.s:Lua_Compiler.':%m'

  silent exe  ":make -p ".l:fullname
  exe ":setlocal makeprg=".makeprg_saved
  :botright cwindow
  :setlocal errorformat=
  "
  " message in case of success
  "
	if !v:shell_error
    let s:Lua_SyntaxCheckMsg = l:currentbuffer." : Syntax is OK"
    return
  else
    setlocal wrap
    setlocal linebreak
  endif
endfunction   " ---------- end of function  Lua_SyntaxCheck  ----------
"
"  Also called in the filetype plugin lua.vim
function! Lua_SyntaxCheckMsg ()
    echohl Search 
    echo s:Lua_SyntaxCheckMsg
    echohl None
endfunction   " ---------- end of function  Lua_SyntaxCheckMsg  ----------
"
"------------------------------------------------------------------------------
"  run : 	Lua_Run
"  Also called from the filetype plugin lua.vim
"------------------------------------------------------------------------------
"
let s:Lua_OutputBufferName   = "Lua-Output"
let s:Lua_OutputBufferNumber = -1
"
function! Lua_Run ()
  "
  if &filetype != "lua"
    echohl WarningMsg | echo expand("%").' seems not to be a Lua file' | echohl None
    return
  endif
  let buffername  = expand("%")
  "
  let l:currentbuffernr = bufnr("%")
  let l:currentdir      = getcwd()
  let l:arguments       = exists("b:Lua_CmdLineArgs") ? " ".b:Lua_CmdLineArgs : ""
  let l:switches        = exists("b:Lua_Switches") ? b:Lua_Switches.' ' : ""
  let l:currentbuffer   = bufname("%")
  let l:fullname        = l:currentdir."/".l:currentbuffer
  " escape whitespaces
  let l:fullname        = escape( l:fullname, s:escfilename )
  "
  silent exe ":update"
  silent exe ":cclose"
  "
	let dquote	= ''
  if  s:MSWIN
    let l:arguments = substitute( l:arguments, '^\s\+', ' ', '' )
    let l:arguments = substitute( l:arguments, '\s\+', "\" \"", 'g')
    let l:switches  = substitute( l:switches, '^\s\+', ' ', '' )
    let l:switches  = substitute( l:switches, '\s\+', "\" \"", 'g')
		let dquote	= '"'
  endif
  "
  "------------------------------------------------------------------------------
  "  run : run from the vim command line
  "------------------------------------------------------------------------------
	if s:Lua_OutputGvim == "vim"
		if  s:MSWIN
			exe '!'.s:Lua_Interpreter." ".dquote.l:switches.l:fullname.l:arguments.dquote
		else
			let	makeprg_saved	= &makeprg
			exe ':setlocal makeprg='.s:Lua_Interpreter	
			exe ":setlocal errorformat=".s:Lua_Interpreter.':\ %f:%l:%m,'.s:Lua_Interpreter.':%m'
			exe "make ".dquote.l:switches.l:fullname.l:arguments.dquote
			exe ":setlocal makeprg=".makeprg_saved
			:botright cwindow
		endif
	endif
  "
  "------------------------------------------------------------------------------
  "  run : redirect output to an output buffer
  "------------------------------------------------------------------------------
  if s:Lua_OutputGvim == "buffer"
    let l:currentbuffernr = bufnr("%")
    if l:currentbuffer ==  bufname("%")
      "
      "
      if bufloaded(s:Lua_OutputBufferName) != 0 && bufwinnr(s:Lua_OutputBufferNumber) != -1 
        exe bufwinnr(s:Lua_OutputBufferNumber) . "wincmd w"
        " buffer number may have changed, e.g. after a 'save as' 
        if bufnr("%") != s:Lua_OutputBufferNumber
          let s:Lua_OutputBufferNumber=bufnr(s:Lua_OutputBufferName)
          exe ":bn ".s:Lua_OutputBufferNumber
        endif
      else
        silent exe ":new ".s:Lua_OutputBufferName
        let s:Lua_OutputBufferNumber=bufnr("%")
        setlocal buftype=nofile
        setlocal noswapfile
        setlocal syntax=none
        setlocal bufhidden=delete
      endif
      "
      " run script 
      "
      setlocal  modifiable
      silent exe ":update"
			exe '%!'.s:Lua_Interpreter." ".dquote.l:switches.l:fullname.l:arguments.dquote
      setlocal  nomodifiable
      "
      " stdout is empty / not empty
      "
      if line("$")==1 && col("$")==1
        silent  exe ":bdelete"
      else
        if winheight(winnr()) >= line("$")
          exe bufwinnr(l:currentbuffernr) . "wincmd w"
        endif
      endif
    endif
  endif
  "
  "------------------------------------------------------------------------------
  "  run : run in a detached xterm  (not available for MS Windows)
  "------------------------------------------------------------------------------
  if s:Lua_OutputGvim == "xterm"
    "
    if  s:MSWIN
      " same as "vim"
			exe '!'.s:Lua_Interpreter." ".dquote.l:switches.l:fullname.l:arguments.dquote
    else
      silent exe '!xterm -title '.l:fullname.' '.s:Lua_XtermDefaults.' -e '.s:Lua_Scripts.'wrapper.sh '.s:Lua_Interpreter.' '.l:switches.l:fullname.l:arguments
    endif
    "
  endif
  "
endfunction    " ----------  end of function Lua_Run  ----------
"
"------------------------------------------------------------------------------
"  run : Arguments for the executable
"------------------------------------------------------------------------------
function! Lua_Arguments ()
  let filename = escape(expand("%"),s:escfilename)
  if filename == ""
    redraw
    echohl WarningMsg | echo " no file name " | echohl None
    return
  endif
  let prompt   = 'command line arguments for "'.filename.'" : '
  if exists("b:Lua_CmdLineArgs")
    let b:Lua_CmdLineArgs= Lua_Input( prompt, b:Lua_CmdLineArgs )
  else
    let b:Lua_CmdLineArgs= Lua_Input( prompt , "" )
  endif
endfunction   " ---------- end of function  Lua_Arguments  ----------
"
"----------------------------------------------------------------------
"  Toggle output
"----------------------------------------------------------------------
function! Lua_Toggle_Gvim_Xterm ()

  if has("gui_running")
    if s:Lua_OutputGvim == "vim"
      if has("gui_running")
        exe "aunmenu  <silent>  ".s:Lua_Root.'&Run.&output:\ VIM->buffer->xterm'
        exe "amenu    <silent>  ".s:Lua_Root.'&Run.&output:\ BUFFER->xterm->vim              <C-C>:call Lua_Toggle_Gvim_Xterm()<CR><CR>'
      endif
      let s:Lua_OutputGvim = "buffer"
    else
      if s:Lua_OutputGvim == "buffer"
        if has("gui_running")
          exe "aunmenu  <silent>  ".s:Lua_Root.'&Run.&output:\ BUFFER->xterm->vim'
          exe "amenu    <silent>  ".s:Lua_Root.'&Run.&output:\ XTERM->vim->buffer             <C-C>:call Lua_Toggle_Gvim_Xterm()<CR><CR>'
          let s:Lua_OutputGvim = "xterm"
        else
          let s:Lua_OutputGvim = "vim"
        endif
      else
        " ---------- output : xterm -> gvim
        if has("gui_running")
          exe "aunmenu  <silent>  ".s:Lua_Root.'&Run.&output:\ XTERM->vim->buffer'
          exe "amenu    <silent>  ".s:Lua_Root.'&Run.&output:\ VIM->buffer->xterm            <C-C>:call Lua_Toggle_Gvim_Xterm()<CR><CR>'
        endif
        let s:Lua_OutputGvim = "vim"
      endif
    endif
  else
    if s:Lua_OutputGvim == "vim"
      let s:Lua_OutputGvim = "buffer"
    else
      let s:Lua_OutputGvim = "vim"
    endif
  endif

endfunction    " ----------  end of function Lua_Toggle_Gvim_Xterm  ----------
"
"------------------------------------------------------------------------------
"  run : xterm geometry
"------------------------------------------------------------------------------
function! Lua_XtermSize ()
	let regex	= '-geometry\s\+\d\+x\d\+'
	let geom	= matchstr( s:Lua_XtermDefaults, regex )
	let geom	= matchstr( geom, '\d\+x\d\+' )
	let geom	= substitute( geom, 'x', ' ', "" )
	let	answer= Lua_Input("   xterm size (COLUMNS LINES) : ", geom )
	while match(answer, '^\s*\d\+\s\+\d\+\s*$' ) < 0
		let	answer= Lua_Input(" + xterm size (COLUMNS LINES) : ", geom )
	endwhile
	let answer  = substitute( answer, '^\s\+', "", "" )		 				" remove leading whitespaces
	let answer  = substitute( answer, '\s\+$', "", "" )						" remove trailing whitespaces
	let answer  = substitute( answer, '\s\+', "x", "" )						" replace inner whitespaces
	let s:Lua_XtermDefaults	= substitute( s:Lua_XtermDefaults, regex, "-geometry ".answer , "" )
endfunction    " ----------  end of function Lua_XtermSize ----------
"
"------------------------------------------------------------------------------
"  run : run make
"------------------------------------------------------------------------------

let s:Lua_MakeCmdLineArgs   = ""     " command line arguments for Run-make; initially empty

function! Lua_MakeArguments ()
	let	s:Lua_MakeCmdLineArgs= Lua_Input("make command line arguments : ",s:Lua_MakeCmdLineArgs)
endfunction    " ----------  end of function Lua_MakeArguments ----------
"
function! Lua_Make()
	" update : write source file if necessary
	exe	":update"
	" run make
	exe		":make ".s:Lua_MakeCmdLineArgs
endfunction    " ----------  end of function Lua_Make ----------
"
"------------------------------------------------------------------------------
"  run : indent message
"------------------------------------------------------------------------------
function! Lua_HlMessage ()
	echohl Search 
	echo s:Lua_HlMessage
	echohl None
endfunction    " ----------  end of function Lua_HlMessage ----------
"
"------------------------------------------------------------------------------
"  run : settings
"------------------------------------------------------------------------------
function! Lua_Settings ()
	let	txt =     "     Lua-Support settings\n\n"
	let txt = txt.'                   author :  "'.s:Lua_AuthorName."\"\n"
	let txt = txt.'                 initials :  "'.s:Lua_AuthorRef."\"\n"
	let txt = txt.'                    email :  "'.s:Lua_Email."\"\n"
	let txt = txt.'                  company :  "'.s:Lua_Company."\"\n"
	let txt = txt.'                  project :  "'.s:Lua_Project."\"\n"
	let txt = txt.'         copyright holder :  "'.s:Lua_CopyrightHolder."\"\n"
	let txt = txt.'   code snippet directory :  '.s:Lua_CodeSnippets."\n"
	let txt = txt.'       template directory :  '.s:Lua_Template_Directory."\n"
	if	!s:MSWIN
		let txt = txt.'           xterm defaults :  '.s:Lua_XtermDefaults."\n"
	endif
	if g:Lua_Dictionary_File != ""
		let ausgabe= substitute( g:Lua_Dictionary_File, ",", ",\n                           + ", "g" )
		let txt = txt."       dictionary file(s) :  ".ausgabe."\n"
	endif
	let txt = txt.'     current output dest. :  '.s:Lua_OutputGvim."\n"
	let txt = txt."\n"
	let	txt = txt."__________________________________________________________________________\n"
	let	txt = txt." Lua ".g:Lua_Version." / Dr.-Ing. Fritz Mehner / mehner@fh-swf.de\n\n"
	echo txt
endfunction    " ----------  end of function Lua_Settings ----------
"
"------------------------------------------------------------------------------
"  run : hardcopy
"    MSWIN : a printer dialog is displayed
"    other : print PostScript to file
"------------------------------------------------------------------------------
function! Lua_Hardcopy (arg1)
	let Sou	= expand("%")	
  if Sou == ""
		redraw
		echohl WarningMsg | echo " no file name " | echohl None
		return
  endif
	let	Sou		= escape(Sou,s:escfilename)		" name of the file in the current buffer
	let	old_printheader=&printheader
	exe  ':set printheader='.s:Lua_Printheader
	" ----- normal mode ----------------
	if a:arg1=="n"
		silent exe	"hardcopy > ".Sou.".ps"		
		if	!s:MSWIN
			echo "file \"".Sou."\" printed to \"".Sou.".ps\""
		endif
	endif
	" ----- visual mode ----------------
	if a:arg1=="v"
		silent exe	"*hardcopy > ".Sou.".ps"		
		if	!s:MSWIN
			echo "file \"".Sou."\" (lines ".line("'<")."-".line("'>").") printed to \"".Sou.".ps\""
		endif
	endif
	exe  ':set printheader='.escape( old_printheader, ' %' )
endfunction    " ----------  end of function Lua_Hardcopy ----------
"
"------------------------------------------------------------------------------
"  run : help csupport
"------------------------------------------------------------------------------
function! Lua_Help()
	try
		:help luasupport
	catch
		exe ':helptags '.s:plugin_dir.'doc'
		:help luasupport
	endtry
endfunction    " ----------  end of function Lua_Help ----------

"------------------------------------------------------------------------------
"  Lua_CreateGuiMenus
"------------------------------------------------------------------------------
let s:Lua_MenuVisible = 0								" state : 0 = not visible / 1 = visible
"
function! Lua_CreateGuiMenus ()
	if s:Lua_MenuVisible != 1
		aunmenu <silent> &Tools.Load\ Lua\ Support
		amenu   <silent> 40.1000 &Tools.-SEP100- : 
		amenu   <silent> 40.1122 &Tools.Unload\ Lua\ Support <C-C>:call Lua_RemoveGuiMenus()<CR>
		call Lua_InitMenu()
		let s:Lua_MenuVisible = 1
	endif
endfunction    " ----------  end of function Lua_CreateGuiMenus  ----------

"------------------------------------------------------------------------------
"  Lua_ToolMenu
"------------------------------------------------------------------------------
function! Lua_ToolMenu ()
		amenu   <silent> 40.1000 &Tools.-SEP100- : 
		amenu   <silent> 40.1122 &Tools.Load\ Lua\ Support <C-C>:call Lua_CreateGuiMenus()<CR>
endfunction    " ----------  end of function Lua_ToolMenu  ----------

"------------------------------------------------------------------------------
"  Lua_RemoveGuiMenus
"------------------------------------------------------------------------------
function! Lua_RemoveGuiMenus ()
	if s:Lua_MenuVisible == 1
		if s:Lua_Root == ""
			aunmenu <silent> Comments
			aunmenu <silent> Statements
			aunmenu <silent> Idioms
			aunmenu <silent> Snippets
			aunmenu <silent> Regex
			aunmenu <silent> Run
		else
			exe "aunmenu <silent> ".s:Lua_Root
		endif
		"
		aunmenu <silent> &Tools.Unload\ Lua\ Support
		call Lua_ToolMenu ()
		"
		let s:Lua_MenuVisible = 0
	endif
endfunction    " ----------  end of function Lua_RemoveGuiMenus  ----------
"
"------------------------------------------------------------------------------
"  show / hide the lua-support menus
"  define key mappings (gVim only) 
"------------------------------------------------------------------------------
"
if has("gui_running")
	"
	" the Tools menu entry
	"
	call Lua_ToolMenu ()
	" 
	" initialize the Lua menus
	"
	if s:Lua_LoadMenus == 'yes'
		call Lua_CreateGuiMenus()
	endif
	"
	" define unique mappings
	"
	nmap <unique> <silent>  <Leader>lls  :call Lua_CreateGuiMenus()<CR>
	nmap <unique> <silent>  <Leader>uls  :call Lua_RemoveGuiMenus()<CR>
	"
endif
"
"------------------------------------------------------------------------------
"  Automated header insertion
"------------------------------------------------------------------------------
"
if has("autocmd")
	if	s:MSWIN
		" Windows does not distinguish between lower and upper case
		autocmd BufNewFile  *.lua
					\		call Lua_CommentTemplates('header')
	else
		autocmd BufNewFile  *.lua
					\		call Lua_CommentTemplates('header')
	endif
	"
	" Wrap error descriptions in the quickfix window.
	autocmd BufReadPost quickfix  setlocal wrap | setlocal linebreak 
	"
endif " has("autocmd")
"
"=====================================================================================
" vim: set tabstop=2 shiftwidth=2: 
