set guioptions-=mT
" Include some default settings from the Vim example.
" Note: Intentionally not doing 'behave mswin'
set nocompatible
source $VIMRUNTIME/vimrc_example.vim

" BEGIN BPS' personal settings
set undofile
set undodir=~/.vimundo,.
" Don't leave backup files lying around
set nobackup

" Get rid of menu/toolbar
set guioptions-=m
set guioptions-=T

" hls is annoying to me, especially for small, common text strings.
set nohls

" PATH adjustment for Cygwin...
if has('win32') || has('win64')
	" If Cygwin bin dir comes after c:/Windows/system32 (or a similar
	" path), move it before...
	" Explanation: Managed pc policies may prepend System PATH to User
	" PATH, and I may have no control over what's in System PATH. If the
	" resulting PATH has Windows system dir before Cygwin, stuff like
	" `find' won't work.
	let re = '\c'
		\.'\%(^\|;\)\@<='
		\.'\(c:[/\\]windows\%([^/\\]\&\f\)*[/\\]system\%([^/\\]\&\f\)*\)'
		\.'\(;.*\);\@<='
		\.'\(c:[/\\]cygwin[/\\]bin\%(;\|$\)\)'
	if $PATH =~ re
		" Rotate so that Cygwin/bin comes first.
		let $PATH = substitute($PATH, re, '\3\1\2', '')
	endif
endif

" Note: The following cscope stuff was copied from Jason Duell's vimrc,
" referenced from the Vim/Cscope tutorial:
" http://cscope.sourceforge.net/cscope_vim_tutorial.html

" This tests to see if vim was configured with the '--enable-cscope' option
" when it was compiled.  If it wasn't, time to recompile vim... 
if has("cscope")

    """"""""""""" Standard cscope/vim boilerplate

    " use both cscope and ctag for 'ctrl-]', ':ta', and 'vim -t'
    set cscopetag

    " check cscope for definition of a symbol before checking ctags: set to 1
    " if you want the reverse search order.
    set csto=0

    " show msg when any other cscope db added
    set cscopeverbose  

    """"""""""""" My cscope/vim key mappings
    "
    " The following maps all invoke one of the following cscope search types:
    "
    "   's'   symbol: find all references to the token under cursor
    "   'g'   global: find global definition(s) of the token under cursor
    "   'c'   calls:  find all calls to the function name under cursor
    "   't'   text:   find all instances of the text under cursor
    "   'e'   egrep:  egrep search for the word under cursor
    "   'f'   file:   open the filename under cursor
    "   'i'   includes: find files that include the filename under cursor
    "   'd'   called: find functions that function under cursor calls
    "
    " Below are three sets of the maps: one set that just jumps to your
    " search result, one that splits the existing vim window horizontally and
    " diplays your search result in the new window, and one that does the same
    " thing, but does a vertical split instead (vim 6 only).
    "
    " I've used CTRL-\ and CTRL-@ as the starting keys for these maps, as it's
    " unlikely that you need their default mappings (CTRL-\'s default use is
    " as part of CTRL-\ CTRL-N typemap, which basically just does the same
    " thing as hitting 'escape': CTRL-@ doesn't seem to have any default use).
    " If you don't like using 'CTRL-@' or CTRL-\, , you can change some or all
    " of these maps to use other keys.  One likely candidate is 'CTRL-_'
    " (which also maps to CTRL-/, which is easier to type).  By default it is
    " used to switch between Hebrew and English keyboard mode.
    "
    " All of the maps involving the <cfile> macro use '^<cfile>$': this is so
    " that searches over '#include <time.h>" return only references to
    " 'time.h', and not 'sys/time.h', etc. (by default cscope will return all
    " files that contain 'time.h' as part of their name).


    " To do the first type of search, hit 'CTRL-\', followed by one of the
    " cscope search types above (s,g,c,t,e,f,i,d).  The result of your cscope
    " search will be displayed in the current window.  You can use CTRL-T to
    " go back to where you were before the search.  
    "

    nmap <C-\>s :cs find s <C-R>=expand("<cword>")<CR><CR>	
    nmap <C-\>g :cs find g <C-R>=expand("<cword>")<CR><CR>	
    nmap <C-\>c :cs find c <C-R>=expand("<cword>")<CR><CR>	
    nmap <C-\>t :cs find t <C-R>=expand("<cword>")<CR><CR>	
    nmap <C-\>e :cs find e <C-R>=expand("<cword>")<CR><CR>	
    nmap <C-\>f :cs find f <C-R>=expand("<cfile>")<CR><CR>	
    nmap <C-\>i :cs find i ^<C-R>=expand("<cfile>")<CR>$<CR>
    nmap <C-\>d :cs find d <C-R>=expand("<cword>")<CR><CR>	


    " Using 'CTRL-spacebar' (intepreted as CTRL-@ by vim) then a search type
    " makes the vim window split horizontally, with search result displayed in
    " the new window.
    "
    " (Note: earlier versions of vim may not have the :scs command, but it
    " can be simulated roughly via:
    "    nmap <C-@>s <C-W><C-S> :cs find s <C-R>=expand("<cword>")<CR><CR>	

    nmap <C-@>s :scs find s <C-R>=expand("<cword>")<CR><CR>	
    nmap <C-@>g :scs find g <C-R>=expand("<cword>")<CR><CR>	
    nmap <C-@>c :scs find c <C-R>=expand("<cword>")<CR><CR>	
    nmap <C-@>t :scs find t <C-R>=expand("<cword>")<CR><CR>	
    nmap <C-@>e :scs find e <C-R>=expand("<cword>")<CR><CR>	
    nmap <C-@>f :scs find f <C-R>=expand("<cfile>")<CR><CR>	
    nmap <C-@>i :scs find i ^<C-R>=expand("<cfile>")<CR>$<CR>	
    nmap <C-@>d :scs find d <C-R>=expand("<cword>")<CR><CR>	


    " Hitting CTRL-space *twice* before the search type does a vertical 
    " split instead of a horizontal one (vim 6 and up only)
    "
    " (Note: you may wish to put a 'set splitright' in your .vimrc
    " if you prefer the new window on the right instead of the left

    nmap <C-@><C-@>s :vert scs find s <C-R>=expand("<cword>")<CR><CR>
    nmap <C-@><C-@>g :vert scs find g <C-R>=expand("<cword>")<CR><CR>
    nmap <C-@><C-@>c :vert scs find c <C-R>=expand("<cword>")<CR><CR>
    nmap <C-@><C-@>t :vert scs find t <C-R>=expand("<cword>")<CR><CR>
    nmap <C-@><C-@>e :vert scs find e <C-R>=expand("<cword>")<CR><CR>
    nmap <C-@><C-@>f :vert scs find f <C-R>=expand("<cfile>")<CR><CR>	
    nmap <C-@><C-@>i :vert scs find i ^<C-R>=expand("<cfile>")<CR>$<CR>	
    nmap <C-@><C-@>d :vert scs find d <C-R>=expand("<cword>")<CR><CR>
endif

" Facilitate adding plugins to pathogen disabled list anywhere below.
if (!exists('g:pathogen_disabled')) | let g:pathogen_disabled = [] | endif

" On non-unix Vim, use Cygwin bash (unless I've disabled).
" Why would I disable? Well, I've already encountered 1 plugin (vimclojure),
" which checks 'win' feature(s) without looking at shell type to see whether
" it needs to do special quoting, and the special quoting breaks with Cygwin
" bash.
" Note: As long as Cygwin bin is in path, I'm thinking I should be able to use
" cmd.exe for a shell.
let prefer_win_cmd = 0

"Note: Only one of the 2 clojure plugins should be in use at a time.
let g:which_clojure_plug = 'slimv'

" Set this if invoking Cygwin tools Vim command line (even if using cmd.exe
" rather than bash for shell)
let g:using_cygwin_utils = 1

" Set shell options properly
if !prefer_win_cmd && !has('unix')
	set shell=bash.exe
 	set shellcmdflag=-c
	" Note: shellslash set with note below
endif
" Caveat: Cygwin tools can often handle windows pathnames (usually with either
" type of slash), but apparently not when the pathname contains wildcards,
" tildes and such; also, certain tools appear to be a bit finicky about what
" they'll accept: e.g., mkdir requires backslashes for a Windows path.
" Conclusion: When using Cygwin tools (even if not using bash shell), it's
" safest to set shellslash, though this is not a panacaea...
" TODO: May need to go back to using bash always...
if g:using_cygwin_utils
	set shellslash
	set shellpipe=2>&1\|tee
endif

" Grep setup
" Note: Even when I'm using windows cmd shell, I should have a unix-style grep
" (e.g., Cygwin).
" TODO: When no matches, Vim displays 'shell returned 1', apparently because the
" temp file isn't created (probably because there's no output from grep). I
" guess this makes sense, but it's sort of disconcerting... Is this the way it
" works on Unix?
"set grepprg=grep\ -n
set grepprg=Ack

com! AsecPrj call asec#init()

" CAVEAT: Having VimClojure and Slimv installed simultaneously can be
" problematic unless you're using Pathogen (or something like it) to permit
" them to be installed in different locations.

" Vimclojure Setup
let vimclojure#WantNailgun = 1
" The following path works when shell is cmd.exe...
" let vimclojure#NailgunClient = "C:\\Users\\stahlmanb\\vimclojure-nailgun-client\\ng.exe"
" ...and this one works when shell is bash (provided the 'hardcore escaping'
" is removed from autoload/vimclojure.vim.
" let vimclojure#NailgunClient = "C:/Users/stahlmanb/vimclojure-nailgun-client/ng.exe"
" Assumption: Nailgun client (ng.exe) will be in the path. This is safest way.
let vimclojure#NailgunClient = "ng.exe"
let vimclojure#NailgunServer = "127.0.0.1"
let vimclojure#NailgunPort = "2113"
" Enable color coding of parens
let vimclojure#ParenRainbow = 1


" Slimv Setup
"let g:slimv_impl = 'scheme'
"let g:slimv_impl = 'clojure'
let g:slimv_impl = 'clisp'
if g:slimv_impl == 'clojure'
	"let g:scheme_builtin_swank = 1
	let g:slimv_lisp = '"java -cp c:/clojure-1.4.0/clojure-1.4.0.jar clojure.main"'
	"let g:slimv_lisp = 'C:/Racket/mzscheme'
	" NOTE: lein is a shell script; lein.bat is the Windows batch file version of
	" lein. Make sure to use the latter if we're not running some sort of Unix
	" shell.
	" Assumption: lein and lein.bat must be in my path.
	if &shell =~ 'sh'
		let g:slimv_swank_clojure = '! lein swank &'
	else
		" CAVEAT: Wrapping the call to the .bat in the start/cmd/etc... is
		" necessary; otherwise, Vim will simply hang waiting for the batch
		" file to exit.
		let g:slimv_swank_clojure = '! start /B cmd.exe /C call lein.bat swank'
	endif
elseif g:slimv_impl == 'clisp'
	" Using Common Lisp
	let g:scheme_builtin_swank = 1
	let g:slimv_lisp = 'C:/Program Files (x86)/clisp-2.49/clisp.exe'
	let g:slimv_preferred = 'clisp'
endif

" Since vimclojure and slimv have been known to interfere, make sure only one
" is enabled for Clojure development...
if g:slimv_impl == 'clojure'
	if g:which_clojure_plug == 'vimclojure'
		" Use vimclojure - disable slimv
		call add(g:pathogen_disabled, 'slimv')
		" Because I don't like using arrow keys, remap <C-K> and <C-J> to go
		" back/forward through history.
		" TODO: Should I make it work in normal mode as well?
		imap <C-K> <Plug>ClojureReplUpHistory.
		imap <C-J> <Plug>ClojureReplDownHistory.
	else
		" Use slimv - disable vimclojure
		call add(g:pathogen_disabled, 'vimclojure')
		" Don't use buggy paredit mode; it often makes it difficult to edit
		" existing code: e.g., won't let you add double quote at one end of a
		" word, then the other. Always wants to keep balanced...
		let g:paredit_mode = 0
	endif
endif

"Use Pathogen to manage scripts
call pathogen#infect()

" GUI Fonts
set guifont=Lucida_Console:h10:cANSI
set guifont+=Courier_New:h10:cANSI
set guifont+=Courier:h10:cANSI
set guifont+=Terminal:h10:cOEM
set guifont+=Fixedsys:h10:cANSI

" *** TXTFMT-RELATED ***
" Using with .jnl files
" Function: Jnl_configure_txtfmt()
" Description: Set buffer-local txtfmt options just before txtfmt plugins are
" loaded. The intent is for this routine to be called from a BufRead,BufNewFile
" autocommand.
fu! Jnl_configure_txtfmt()
	" Note: The following tokrange setting will be used only if there is no
	" txtfmt modeline. Generally, this will be only when the .jnl file is first
	" created (if ever).
	"let b:txtfmtTokrange = '180s'
	set enc=utf8
	let b:txtfmtTokrange = '0xE000s'
	" Make sure I don't see map ambiguity warnings every time I open a journal
	" file
	"let g:txtfmtMapwarn = "MoOcC"
	" Note: The jnl filetype is normally set as follows:
	" set ft=jnl.txtfmt
	" Currently, one of the jnl maps conflicts with Txtfmt's \ga.
	" TODO: Eventually, need to fix this, but for now, get rid of the warning
	" altogether:
	let g:txtfmtMapwarn = 'cC'
endfu

" DBGPavim (PHP xdebug)
let g:dbgPavimPort = 9009
let g:dbgPavimBreakAtEntry = 1
" Don't catch multiple parallel connections.
let g:dbgPavimOnce = 1

" Conque
let g:ConqueTerm_PyExe = 'C:/Apps/Python27/python.exe'

