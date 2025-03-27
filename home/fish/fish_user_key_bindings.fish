function fish_user_key_bindings
    fish_vi_key_bindings
    fzf_configure_bindings
    bind y fish_clipboard_copy
    bind p fish_clipboard_paste
end
