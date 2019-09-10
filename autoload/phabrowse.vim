" Section: Fugitive :Gbrowse support for Phabricator
"
if exists('g:autoloaded_phabrowse')
  finish
endif
let g:autoloaded_phabrowse = 1

function! phabrowse#homepage_for_url(url) abort
  let domain_pattern = 'secure\.phabricator\.com'

  if !exists('g:phabrowse_domains')
      let g:phabrowse_domains = []
  endif
  call map(copy(g:phabrowse_domains), 'substitute(v:val, "/$", "", "")')
  for domain in g:phabrowse_domains
    let domain_pattern .= '\|' . escape(split(domain, '://')[-1], '.')
  endfor

  let base = matchstr(a:url, '^\%(https\=://\|git://\|git@\|ssh://code@\|ssh://git@\)\=\zs\('.domain_pattern.'\)\/diffusion[/:][^/]\{-\}\ze[/:].\{-\}\%(\.git\)\=$')
  if !empty(base)
    return 'https://' . tr(base, ':', '/')
  else
    return ''
  endif
endfunction

function! s:repo_homepage() abort
  if exists('b:phabrowse_homepage')
    return b:phabrowse_homepage
  endif
  let repo = fugitive#repo()
  let homepage = phabrowse#homepage_for_url(repo.config('remote.origin.url'))
  if !empty(homepage)
    let b:phabrowse_homepage = homepage
    return b:phabrowse_homepage
  endif
  call s:throw('origin is not a Phabricator repository')
endfunction

function! phabrowse#fugitive_url(opts, ...) abort
  if a:0 || type(a:opts) != type({}) || !has_key(a:opts, 'repo')
    return ''
  endif
  let root = phabrowse#homepage_for_url(get(a:opts, 'remote'))
  if empty(root)
    return ''
  endif

  let path = substitute(a:opts.path, '^/', '', '')

  " Hard coded since we don't have any other branches on phab
  let branch = "master"

  if a:opts.commit =~# '^\d\=$'
    let commit = a:opts.repo.rev_parse('HEAD')
  else
    let commit = a:opts.commit
  endif
  if get(a:opts, 'type', '') ==# 'blob' || a:opts.path =~# '[^/]$'
    let url = root . '/browse/' . branch . '/' . path
    " since the hashes are likely different in master, you can't load files of a
    " specific revision. The Phab web interface also doesn't let you jump to the
    " line of the file without also specifying the revision, so we can't do
    " range selections with this Gbrowse plugin.
    " if commit !=# ''
       " let url .= ';' . commit
    " endif
    " if get(a:opts, 'line2') && a:opts.line1 == a:opts.line2
      " let url .= '$L' . a:opts.line1
    " elseif get(a:opts, 'line2')
      " let url .= '$L' . a:opts.line1 . '-L' . a:opts.line2
    " endif
  else
    let url = root . '/commit/' . commit
  endif
  echo url
  return url
endfunction
