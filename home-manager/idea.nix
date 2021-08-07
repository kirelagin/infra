{
  home.file.".ideavimrc".text = ''
    set incsearch
    set surround

    " Nav: tabs
    noremap <C-n> gt
    noremap <C-p> gT

    " Nav: inheritance hierarchy
    nnoremap gs :action GotoSuperMethod<CR>
    nnoremap gi :action GotoImplementation<CR>

    " Nav: errors
    nnoremap ]e :action GotoNextError<CR>
    nnoremap [e :action GotoPreviousError<CR>

    nnoremap <C-o> :action Back<CR>
    nnoremap <C-i> :action Forward<CR>
  '';
}
