" Include some default settings from the Vim example.
" Note: Intentionally not doing 'behave mswin'
set nocompatible
source $VIMRUNTIME/vimrc_example.vim

" Disable menu and toolbar.
set guioptions-=m
set guioptions-=T
set modelines&
set modeline
set incsearch
" hls is annoying to me, especially for small, common text strings.
set nohls
set mouse=a

" Comma is marginally easier to hit than backslash.
"let maplocalleader = ','

set formatoptions=tcqro
" j is a useful addition (obviates need to delete comment leaders after
" joining lines) but not universally available...
silent! set formatoptions+=j

" Don't leave backup files lying around
set nobackup

if has('persistent_undo')
	set undofile
	set undodir=~/.vimundo,.
endif


colorscheme default
" This should be the Vim default, but isn't...
filetype plugin indent on
syntax enable

"Use Pathogen to manage scripts
"if exists('*pathogen#infect')
	" TODO: Figure out why the if guard doesn't work.
	call pathogen#infect()
"endif
set rtp+=~/.fzf

" Slimv
let g:paredit_disable_lisp = 1
"let g:slimv_impl = 'sbcl'
let g:slimv_lisp = '/usr/bin/sbcl'
let g:slimv_swank_cmd = '! xterm -e sbcl --load /home/bstahlman/.vim/bundle/slimv/slime/start-swank.lisp &'
"let g:slimv_impl = 'clisp'
"let g:slimv_lisp = '/usr/bin/clisp'
"let g:slimv_swank_cmd = '! SWANK_PORT=4005 xterm -iconic -e "/usr/bin/clisp" -i "/home/bstahlman/.vim/bundle/slimv/slime/start-swank.lisp" &

" Vim-sexp
" Note: For now, keeping all, in case I want to override some more.
" Eventually, keep only the overridden entries.
" TODO: Consider whether to use the <Plug>(...) mapping method instead. The
" advantage is that it would permit me to create multiple mappings to the same
" command.
" Single-key mappings: h, l, H, L
let g:sexp_expert_mode = 1
if !g:sexp_expert_mode
let g:sexp_mappings = {
    \ 'sexp_outer_list':                'af',
    \ 'sexp_inner_list':                'if',
    \ 'sexp_outer_top_list':            'aF',
    \ 'sexp_inner_top_list':            'iF',
    \ 'sexp_outer_string':              'as',
    \ 'sexp_inner_string':              'is',
    \ 'sexp_outer_element':             'ae',
    \ 'sexp_inner_element':             'ie',
    \ 'sexp_move_to_prev_bracket':      '(',
    \ 'sexp_move_to_next_bracket':      ')',
    \ 'sexp_move_to_prev_element_head': 'B',
    \ 'sexp_move_to_next_element_head': 'W',
    \ 'sexp_move_to_prev_element_tail': 'gE',
    \ 'sexp_move_to_next_element_tail': 'E',
    \ 'sexp_flow_to_prev_close':        '<M-J>',
    \ 'sexp_flow_to_next_open':         '<M-j>',
    \ 'sexp_flow_to_prev_open':         '<M-k>',
    \ 'sexp_flow_to_next_close':        '<M-K>',
    \ 'sexp_flow_to_prev_leaf_head':    '<M-b>',
    \ 'sexp_flow_to_next_leaf_head':    '<M-w>',
    \ 'sexp_flow_to_prev_leaf_tail':    '<M-g>',
    \ 'sexp_flow_to_next_leaf_tail':    '<M-e>',
    \ 'sexp_jump_to_list':              '<Space>L',
    \ 'sexp_jump_to_list_in_top':       '<Space>l',
    \ 'sexp_jump_to_leaf':              '<Space>E',
    \ 'sexp_jump_to_leaf_in_top':       '<Space>e',
    \ 'sexp_jump_to_atom':              '<Space>A',
    \ 'sexp_jump_to_atom_in_top':       '<Space>a',
    \ 'sexp_jump_to_string':            '<Space>S',
    \ 'sexp_jump_to_string_in_top':     "<Space>s",
    \ 'sexp_jump_to_comment':           '<Space>C',
    \ 'sexp_jump_to_comment_in_top':    '<Space>c',
    \ 'sexp_jump_to_char':              '<Space>F',
    \ 'sexp_jump_to_char_in_top':       '<Space>f',
    \ 'sexp_move_to_prev_top_element':  '[[',
    \ 'sexp_move_to_next_top_element':  ']]',
    \ 'sexp_select_prev_element':       '[e',
    \ 'sexp_select_next_element':       ']e',
    \ 'sexp_indent':                    '==',
    \ 'sexp_indent_top':                '=-',
    \ 'sexp_round_head_wrap_list':      '<LocalLeader>(',
    \ 'sexp_round_tail_wrap_list':      '<LocalLeader>)',
    \ 'sexp_square_head_wrap_list':     '<LocalLeader>[',
    \ 'sexp_square_tail_wrap_list':     '<LocalLeader>]',
    \ 'sexp_curly_head_wrap_list':      '<LocalLeader>{',
    \ 'sexp_curly_tail_wrap_list':      '<LocalLeader>}',
    \ 'sexp_round_head_wrap_element':   '<LocalLeader>e(',
    \ 'sexp_round_tail_wrap_element':   '<LocalLeader>e)',
    \ 'sexp_square_head_wrap_element':  '<LocalLeader>e[',
    \ 'sexp_square_tail_wrap_element':  '<LocalLeader>e]',
    \ 'sexp_curly_head_wrap_element':   '<LocalLeader>e{',
    \ 'sexp_curly_tail_wrap_element':   '<LocalLeader>e}',
    \ 'sexp_insert_at_list_head':       '<LocalLeader>I',
    \ 'sexp_insert_at_list_tail':       '<LocalLeader>A',
    \ 'sexp_splice_list':               '<LocalLeader>@',
    \ 'sexp_convolute':                 '<LocalLeader>?',
    \ 'sexp_raise_list':                '<LocalLeader>o',
    \ 'sexp_raise_element':             '<LocalLeader>O',
    \ 'sexp_swap_list_backward':        '<M-h>',
    \ 'sexp_swap_list_forward':         '<M-l>',
    \ 'sexp_swap_element_backward':     '<C-h>',
    \ 'sexp_swap_element_forward':      '<C-l>',
    \ 'sexp_emit_head_element':         '<b',
    \ 'sexp_emit_tail_element':         '>b',
    \ 'sexp_capture_prev_element':      '<s',
    \ 'sexp_capture_next_element':      '>s',
\ }

"e3e008d69dbc8f774c1b180cbbdbb8fddfd2099c
else
    "\ 'sexp_jump_to_list':              '<Space>L',
    "\ 'sexp_jump_to_list_in_top':       '<Space>l',
    "\ 'sexp_jump_to_leaf':              '<Space>E',
    "\ 'sexp_jump_to_leaf_in_top':       '<Space>e',
    "\ 'sexp_jump_to_atom_in_top':       '<Space>A',
    "\ 'sexp_jump_to_atom':              '<Space>a',
    "\ 'sexp_jump_to_subword':           '<Space>W',
    "\ 'sexp_jump_to_subword_in_top':    '<Space>w',
    "\ 'sexp_jump_to_string':            '<Space>S',
    "\ 'sexp_jump_to_string_in_top':     '<Space>s',
    "\ 'sexp_jump_to_comment':           '<Space>C',
    "\ 'sexp_jump_to_comment_in_top':    '<Space>c',
    "\ 'sexp_jump_to_char':              '<Space>F',
    "\ 'sexp_jump_to_char_in_top':       '<Space>f',
let g:sexp_state_toggle = '<C-k>'
"let g:sexp_state_toggle = 'jk'
let g:sexp_escape_key = ','
let g:sexp_mappings = {
    \ 'sexp_outer_list':                '<>af',
    \ 'sexp_inner_list':                '<>if',
    \ 'sexp_outer_top_list':            '<>aF',
    \ 'sexp_inner_top_list':            '<>iF',
    \ 'sexp_outer_string':              '<>as',
    \ 'sexp_inner_string':              '<>is',
    \ 'sexp_outer_element':             '<>ae',
    \ 'sexp_inner_element':             '<>ie',
    \ 'sexp_move_to_prev_bracket':      '(',
    \ 'sexp_move_to_next_bracket':      ')',
    \ 'sexp_move_to_prev_element_head': 'b',
    \ 'sexp_move_to_next_element_head': 'w',
    \ 'sexp_move_to_prev_element_tail': 'ge',
    \ 'sexp_move_to_next_element_tail': 'e',
    \ 'sexp_flow_to_prev_close':        'J',
    \ 'sexp_flow_to_next_open':         'j',
    \ 'sexp_flow_to_prev_open':         'k',
    \ 'sexp_flow_to_next_close':        'K',
    \ 'sexp_flow_to_prev_leaf_head':    'B',
    \ 'sexp_flow_to_next_leaf_head':    'W',
    \ 'sexp_flow_to_prev_leaf_tail':    'gE',
    \ 'sexp_flow_to_next_leaf_tail':    'E',
    \ 'sexp_jump_to_list':              '',
    \ 'sexp_jump_to_list_in_top':       '',
    \ 'sexp_jump_to_leaf':              '',
    \ 'sexp_jump_to_leaf_in_top':       '',
    \ 'sexp_jump_to_atom_in_top':       '',
    \ 'sexp_jump_to_atom':              '',
    \ 'sexp_jump_to_subword':           '',
    \ 'sexp_jump_to_subword_in_top':    '',
    \ 'sexp_jump_to_string':            '',
    \ 'sexp_jump_to_string_in_top':     '',
    \ 'sexp_jump_to_comment':           '',
    \ 'sexp_jump_to_comment_in_top':    '',
    \ 'sexp_jump_to_char':              '',
    \ 'sexp_jump_to_char_in_top':       '',
    \ 'sexp_move_to_prev_top_element':  'p',
    \ 'sexp_move_to_next_top_element':  'n',
    \ 'sexp_select_prev_element':       '<',
    \ 'sexp_select_next_element':       '>',
    \ 'sexp_indent':                    'm',
    \ 'sexp_indent_top':                'M',
    \ 'sexp_round_head_wrap_list':      'gr',
    \ 'sexp_round_tail_wrap_list':      'gR',
    \ 'sexp_square_head_wrap_list':     'g[',
    \ 'sexp_square_tail_wrap_list':     'g]',
    \ 'sexp_curly_head_wrap_list':      'g{',
    \ 'sexp_curly_tail_wrap_list':      'g}',
    \ 'sexp_round_head_wrap_element':   'r',
    \ 'sexp_round_tail_wrap_element':   'R',
    \ 'sexp_square_head_wrap_element':  '[',
    \ 'sexp_square_tail_wrap_element':  ']',
    \ 'sexp_curly_head_wrap_element':   '{',
    \ 'sexp_curly_tail_wrap_element':   '}',
    \ 'sexp_insert_at_list_head':       'I',
    \ 'sexp_insert_at_list_tail':       'A',
    \ 'sexp_splice_list':               '@',
    \ 'sexp_convolute':                 'g?',
    \ 'sexp_raise_list':                'gO',
    \ 'sexp_raise_element':             'go',
    \ 'sexp_swap_list_backward':        'H',
    \ 'sexp_swap_list_forward':         'L',
    \ 'sexp_swap_element_backward':     '<C-h>',
    \ 'sexp_swap_element_forward':      '<C-l>',
    \ 'sexp_emit_head_element':         'gB',
    \ 'sexp_emit_tail_element':         'gb',
    \ 'sexp_capture_prev_element':      'gS',
    \ 'sexp_capture_next_element':      'gs',
    \ }

endif

" Easymotion
map <Space> <Plug>(easymotion-prefix)
" -- FZF Customization --
" Use ripgrep instead of default ag for searches.
command! -bang -nargs=* Rg
  \ call fzf#vim#grep(
  \   'rg --column --line-number --no-heading --color=always '.shellescape(<q-args>), 1,
  \   <bang>0 ? fzf#vim#with_preview('up:60%')
  \           : fzf#vim#with_preview('right:50%:hidden', '?'),
  \   <bang>0)

" IMPORTANT TODO: Grep, Ctags, Cscope, etc... were written for Pikewerks
" stuff. They're mostly generic, but a better approach would be to have some
" sort of hook whereby .vimrc.local can tailor behavior, possibly even on
" project-by-project basis...

" -- Grep --
let pats = ['*.c', '*.h', '*.S', '*.s', '*.asm', '*.mk', 'Makefile']
let incs = map(copy(pats), "'--include=''' . v:val . ''''")
let &grepprg = 'grep -Rn ' . join(incs) . ' $* .'

" -- Ctags --
" Look upwards to the nearest tags-global file.
" Priority: Prefer local files and files in dir of current file.
" TODO: Perhaps add HOME stop dir...
set tags=./tags,tags,./tags-global;,tags-global;

" Rebuild local tags only.
" Note: Extra CR gets rid of the 'Hit Enter...' prompt.
nmap ,t :!(cd %:p:h; ctags *.[ch])&<CR><CR>

" -- Virtual clipboard --
" Explanation: Can't easily copy between gvim and console vim running in tmux.
" These commands provide simple way to do it using netrw with scp protocol.
" Usage:
" In source:
"   :Cbc
"   Note: Range is optional, defaults to current line.
" In destination
"   :Cbp root@stahlman-vm2
com! -range Cbc <line1>,<line2>w! /tmp/cb.txt
" TODO: Get more sophisticated with args (e.g., default user to root, perhaps
" provide way to cache hostname).
com! -nargs=1 Cbp r scp://<args>//tmp/cb.txt

" -- Cscope --
if has("cscope")
	" -- BPS Stuff --
	fu! s:find_and_attach_cscope(bang)
		" Look upwards for the nearest global cscope db.
		" Caveat! May want to check both cwd and directory of current file (in
		" case we get jumped out of the project structure).
		" Caveat: For now, just give .; or ; with no stop dir.
		" TODO: Understand why Vim's upward search with stopdir seems buggy.
		let paths = ['.', '']
		for path in paths
			let db = findfile('cscope-global.out', path . ';')
			if !empty(db)
				break
			endif
		endfor
		if empty(db)
			echoerr "Can't find global cscope db to attach to! Run bldcs from the root of the project."
			return
		endif
		if a:bang == '!'
			exe 'cs kill -1'
		endif
		exe 'cs add ' . db
	endfu

	" Add bang to kill existing connections, omit bang to append.
	com! -nargs=0 -bang CSadd :call s:find_and_attach_cscope("<bang>")

	" Use quickfix (without appending) for everything.
	set cscopequickfix=s-,c-,d-,i-,t-,e-
	" Search cscope db before tags.
	set csto=0
	" Use :cstag for normal tag commands.
	set cst


	" -- Jason Duell's cscope mappings --
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


	""""""""""""" key map timeouts
	"
	" By default Vim will only wait 1 second for each keystroke in a mapping.
	" You may find that too short with the above typemaps.  If so, you should
	" either turn off mapping timeouts via 'notimeout'.
	"
	"set notimeout 
	"
	" Or, you can keep timeouts, by uncommenting the timeoutlen line below,
	" with your own personal favorite value (in milliseconds):
	"
	"set timeoutlen=4000
	"
	" Either way, since mapping timeout settings by default also set the
	" timeouts for multicharacter 'keys codes' (like <F1>), you should also
	" set ttimeout and ttimeoutlen: otherwise, you will experience strange
	" delays as vim waits for a keystroke after you hit ESC (it will be
	" waiting to see if the ESC is actually part of a key code like <F1>).
	"
	"set ttimeout 
	"
	" personally, I find a tenth of a second to work well for key code
	" timeouts. If you experience problems and have a slow terminal or network
	" connection, set it higher.  If you don't set ttimeoutlen, the value for
	" timeoutlent (default: 1000 = 1 second, which is sluggish) is used.
	"
	"set ttimeoutlen=100
endif

" --- Txtfmt / Journal ---
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

" TODO: Consider having both pre and post local vimrcs.
if filereadable('~/.vimrc.local')
	so ~/.vimrc.local
endif

" vim:ts=4:sw=4:tw=78
