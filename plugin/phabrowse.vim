if !exists('g:fugitive_browse_handlers')
  let g:fugitive_browse_handlers = []
endif

if index(g:fugitive_browse_handlers, function('phabrowse#fugitive_url')) < 0
  call insert(g:fugitive_browse_handlers, function('phabrowse#fugitive_url'))
endif
