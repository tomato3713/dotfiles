if empty(globpath(&rtp, 'plugged/vim-textobj-user'))
    finish
endif
if empty(globpath(&rtp, 'plugged/vim-textobj-jabraces'))
    finish
endif
if empty(globpath(&rtp, 'plugged/vim-textobj-multiblock'))
    finish
endif
if empty(globpath(&rtp, 'plugged/vim-textobj-multitextobj'))
    finish
endif

" Ref: http://kainokikaede.hatenablog.com/entry/2014/07/14/070518

let g:textobj_multitextobj_textobjects_i = [
  \ "\<Plug>(textobj-multiblock-i)",
  \ "\<Plug>(textobj-jabraces-parens-i)",
  \ "\<Plug>(textobj-jabraces-braces-i)",
  \ "\<Plug>(textobj-jabraces-brackets-i)",
  \ "\<Plug>(textobj-jabraces-angles-i)",
  \ "\<Plug>(textobj-jabraces-double-angles-i)",
  \ "\<Plug>(textobj-jabraces-kakko-i)",
  \ "\<Plug>(textobj-jabraces-double-kakko-i)",
  \ "\<Plug>(textobj-jabraces-yama-kakko-i)",
  \ "\<Plug>(textobj-jabraces-double-yama-kakko-i)",
  \ "\<Plug>(textobj-jabraces-kikkou-kakko-i)",
  \ "\<Plug>(textobj-jabraces-sumi-kakko-i)",
  \]
  let g:textobj_multitextobj_textobjects_a = [
  \ "\<Plug>(textobj-multiblock-a)",
  \ "\<Plug>(textobj-jabraces-parens-a)",
  \ "\<Plug>(textobj-jabraces-braces-a)",
  \ "\<Plug>(textobj-jabraces-brackets-a)",
  \ "\<Plug>(textobj-jabraces-angles-a)",
  \ "\<Plug>(textobj-jabraces-double-angles-a)",
  \ "\<Plug>(textobj-jabraces-kakko-a)",
  \ "\<Plug>(textobj-jabraces-double-kakko-a)",
  \ "\<Plug>(textobj-jabraces-yama-kakko-a)",
  \ "\<Plug>(textobj-jabraces-double-yama-kakko-a)",
  \ "\<Plug>(textobj-jabraces-kikkou-kakko-a)",
  \ "\<Plug>(textobj-jabraces-sumi-kakko-a)",
  \]

omap ab <Plug>(textobj-multitextobj-a)
omap ib <Plug>(textobj-multitextobj-i)
vmap ab <Plug>(textobj-multitextobj-a)
vmap ib <Plug>(textobj-multitextobj-i)
