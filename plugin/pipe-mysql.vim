" Plugin: Pipe-MySQL (MySQL database client)
" Author: Nguyen Nguyen <NLKNguyen@MSN.com>
" License: MIT
" Origin: http://github.com/NLKNguyen/pipe-mysql.vim
" Depend: http://github.com/NLKNguyen/pipe.vim

if exists("g:loaded_pipemysqldotvim") || &cp
  finish
endif
let g:loaded_pipemysqldotvim = 1

" Variables: {{{
" @brief prefix for variables in buffers, help minimize chance of naming conflict
let s:prefix = 'ac59330d' 

" @brief name of temporary file that stores text to be piped into database engine
let s:tempfilename = '._temp_pipemysql_' . s:prefix

" @brief names of variables in buffers; to access variable use for example: {s:var_ssh_address}
let s:var_ssh_address    = 'b:' . s:prefix . 'ssh_address'
let s:var_ssh_port       = 'b:' . s:prefix . 'ssh_port'
let s:var_mysql_username = 'b:' . s:prefix . 'mysql_username'
let s:var_mysql_password = 'b:' . s:prefix . 'mysql_password'
let s:var_mysql_hostname = 'b:' . s:prefix . 'mysql_hostname'
let s:var_mysql_port     = 'b:' . s:prefix . 'mysql_port'
let s:var_mysql_database = 'b:' . s:prefix . 'mysql_database'

let s:var_mysql_custom_statement = 'b:' . s:prefix . 'mysql_custom_statement'
let s:var_mysql_select_limit     = 'b:' . s:prefix . 'mysql_select_limit'

" @brief list of preset login info
if !exists("g:pipemysql_login_info")
  let g:pipemysql_login_info = []
endif
" }}}

" Edit Info: {{{
fun! g:PipeMySQL_SelectPreset()
  let l:list = ["Select login info:"]

  let l:counter = 1
  for l:login in g:pipemysql_login_info
    call add(l:list, l:counter . '. ' . l:login['description'])
    let l:counter += 1
  endfor

  if len(l:list) == 1
    redraw | echo "No preset info found"
    return
  endif

  let l:choice = inputlist(l:list)

  if l:choice < 1 || l:choice >= len(l:list)
    redraw | echo "Invalid choice"
  else
    let l:login = g:pipemysql_login_info[l:choice - 1]
    let {s:var_ssh_address}    = get(l:login, 'ssh_address', '')
    let {s:var_ssh_port}       = get(l:login, 'ssh_port', '')
    let {s:var_mysql_username} = get(l:login, 'mysql_username', '')
    let {s:var_mysql_password} = get(l:login, 'mysql_password', '')
    let {s:var_mysql_hostname} = get(l:login, 'mysql_hostname', '')
    let {s:var_mysql_port}     = get(l:login, 'mysql_port', '')
    let {s:var_mysql_database} = get(l:login, 'mysql_database', '')
  endif
endfun
fun! g:PipeMySQL_SetRemote()
  let {s:var_ssh_address} = g:PipeGetVar(s:var_ssh_address, 'SSH Address (empty to not use SSH) = ', 11)
  if {s:var_ssh_address} !=? ''
    let {s:var_ssh_port}  = g:PipeGetVar(s:var_ssh_port, 'SSH Port = ', 11)
  endif
endfun

fun! g:PipeMySQL_SetAccess()
  " Hostname & Port
  let {s:var_mysql_hostname} = g:PipeGetVar(s:var_mysql_hostname, 'MySQL Hostname = ', 11)
  if {s:var_mysql_hostname} !=? ''
    let {s:var_mysql_port} = g:PipeGetVar(s:var_mysql_port, 'MySQL Port = ', 11)
  endif

  " Username & Password
  let {s:var_mysql_username} = g:PipeGetVar(s:var_mysql_username, 'MySQL Username = ', 11)
  if {s:var_mysql_username} !=? ''
    let {s:var_mysql_password} = g:PipeGetVar(s:var_mysql_password, 'MySQL Password = ', 10)
  endif
endfun

fun! g:PipeMySQL_SetDatabase()
  let {s:var_mysql_database} = g:PipeGetVar(s:var_mysql_database, "MySQL Database = ", 11) "11: always prompt
endfun

fun! g:PipeMySQL_SetEmpty()
  if exists(s:var_ssh_address)
    unlet {s:var_ssh_address}
  endif
  if exists(s:var_ssh_port)
    unlet {s:var_ssh_port}
  endif
  if exists(s:var_mysql_username)
    unlet {s:var_mysql_username}
  endif
  if exists(s:var_mysql_password)
    unlet {s:var_mysql_password}
  endif
  if exists(s:var_mysql_hostname)
    unlet {s:var_mysql_hostname}
  endif
  if exists(s:var_mysql_port)
    unlet {s:var_mysql_port}
  endif
  if exists(s:var_mysql_database)
    unlet {s:var_mysql_database}
  endif
  redraw | echo ' Cleared info'
endfun
" }}}

" Private: {{{
fun! s:Get_Remote()
  let l:ssh_info = ''
  let l:ssh_address = g:PipeGetVar(s:var_ssh_address, 'SSH Address (empty to not use SSH) = ')

  if l:ssh_address !=? ''
    let l:ssh_port = g:PipeGetVar(s:var_ssh_port, 'SSH Port = ')
    if l:ssh_port !=? ''
      let l:ssh_info .= 'ssh -p ' . l:ssh_port . ' ' . l:ssh_address . ' '
    else
      let l:ssh_info .= 'ssh ' . l:ssh_address . ' '
    endif
  endif

  return l:ssh_info
endfun

fun! s:Get_MySQL_Access()
  let l:login_info = ''
  let l:mysql_hostname = g:PipeGetVar(s:var_mysql_hostname, 'MySQL Hostname = ')

  " Hostname & Port
  if l:mysql_hostname !=? ''
    let l:login_info .= ' -h ' . l:mysql_hostname  . ' '

    let l:mysql_port = g:PipeGetVar(s:var_mysql_port, 'MySQL Port = ')
    if l:mysql_port !=? ''
      let l:login_info .= ' -P ' . l:mysql_port . ' '
    endif
  endif


  " Username & Password
  let l:mysql_username = g:PipeGetVar(s:var_mysql_username, 'MySQL Username = ')

  if l:mysql_username !=? ''
    let l:mysql_password = g:PipeGetVar(s:var_mysql_password, 'MySQL Password = ', 0)
    let l:login_info .= ' -u ' . l:mysql_username  . ' -p' . l:mysql_password . ' '
  endif

  return l:login_info
endfun

fun! s:Get_MySQL_Database()
  return ' ' . g:PipeGetVar(s:var_mysql_database, 'MySQL Database = ') . ' '
endfun

" }}}

" Run: {{{
fun! g:PipeMySQL_RunFile()
  let l:shell_command = s:Get_Remote()
  let l:shell_command .= ' mysql '
  let l:shell_command .= s:Get_MySQL_Access()
  let l:shell_command .= ' -t < ' . expand('%:p')

  call g:Pipe(l:shell_command)
endfun

fun! g:PipeMySQL_RunLine()
  let l:shell_command = s:Get_Remote()
  let l:shell_command .= ' mysql '
  let l:shell_command .= s:Get_MySQL_Access()
  let l:shell_command .= s:Get_MySQL_Database()

  call writefile([g:PipeGetCurrentLine()], s:tempfilename, 'w')

  let l:shell_command .= ' -t < ' . s:tempfilename

  call g:Pipe(l:shell_command)
  call delete(s:tempfilename)
endfun

fun! g:PipeMySQL_RunBlock()
  let l:shell_command = s:Get_Remote()
  let l:shell_command .= ' mysql '
  let l:shell_command .= s:Get_MySQL_Access()
  let l:shell_command .= s:Get_MySQL_Database()

  let l:textlist = g:PipeGetSelectedTextAsList()
  if len(l:textlist) == 0
    echo 'Nothing is selected'
    return
  endif
  call writefile(l:textlist, s:tempfilename, 'w')

  let l:shell_command .= ' -t < ' . s:tempfilename

  call g:Pipe(l:shell_command)
  call delete(s:tempfilename)
endfun

fun! g:PipeMySQL_RunCustom()
  let l:shell_command = s:Get_Remote()
  let l:shell_command .= ' mysql '
  let l:shell_command .= s:Get_MySQL_Access()
  let l:shell_command .= s:Get_MySQL_Database()

  let l:custom_statement = g:PipeGetVar(s:var_mysql_custom_statement, "MySQL Statement » ", 11) "11: always prompt
  if l:custom_statement ==? ''
    echo 'No statement is provided to run'
    unlet {s:var_mysql_custom_statement}
    return
  endif
  call writefile([l:custom_statement], s:tempfilename, 'w')

  let l:shell_command .= ' -t < ' . s:tempfilename

  call g:Pipe(l:shell_command)
  call delete(s:tempfilename)
endfun
" }}}

" For Table: {{{
fun! g:PipeMySQL_TableDescription()
  let l:shell_command = s:Get_Remote()
  let l:shell_command .= ' mysql '
  let l:shell_command .= s:Get_MySQL_Access()
  let l:shell_command .= s:Get_MySQL_Database()

  let l:table_name = g:PipeGetCurrentWord()
  if l:table_name ==? ''
    echo 'No table name is selected'
    return
  endif
  call writefile(['describe ' . l:table_name . ';'], s:tempfilename, 'w')

  let l:shell_command .= ' -t < ' . s:tempfilename

  call g:Pipe(l:shell_command)
  call delete(s:tempfilename)
endfun

fun! g:PipeMySQL_TableSelectAll(...)
  let l:shell_command = s:Get_Remote()
  let l:shell_command .= ' mysql '
  let l:shell_command .= s:Get_MySQL_Access()
  let l:shell_command .= s:Get_MySQL_Database()

  let l:table_name = g:PipeGetCurrentWord()
  if l:table_name ==? ''
    echo 'No table name is selected'
    return
  endif

  let l:with_limit = 1
  if a:0 == 1 "the number of optional arguments (...) is 1
    let l:with_limit = a:1
  endif

  let l:limit = ''
  if l:with_limit == 1
    let l:limit_input = g:PipeGetVar(s:var_mysql_select_limit, "Limit (maximum number of records to show) = ", 11) "11: always prompt
    if l:limit_input != ''
      let l:limit = ' limit ' . l:limit_input
    endif
  endif

  call writefile(['select * from ' . l:table_name . l:limit . ';'], s:tempfilename, 'w')

  let l:shell_command .= ' -t < ' . s:tempfilename

  call g:Pipe(l:shell_command)
  call delete(s:tempfilename)
endfun

fun! g:PipeMySQL_TableListing()
  let l:shell_command = s:Get_Remote()
  let l:shell_command .= ' mysql '
  let l:shell_command .= s:Get_MySQL_Access()
  let l:shell_command .= s:Get_MySQL_Database()

  call writefile(['show tables;'], s:tempfilename, 'w')

  let l:shell_command .= ' -t < ' . s:tempfilename

  call g:Pipe(l:shell_command)
  call delete(s:tempfilename)
endfun
" }}}

" For Database: {{{
fun! g:PipeMySQL_DatabaseSwitching()
  let l:shell_command = s:Get_Remote()
  let l:shell_command .= ' mysql '
  let l:shell_command .= s:Get_MySQL_Access()

  call writefile(['show databases;'], s:tempfilename, 'w')

  let l:shell_command .= ' < ' . s:tempfilename

  echohl String | echon ' Getting database names... (press ctrl-c to abort)' | echohl None
  let l:output = split(system(l:shell_command))
  if len(l:output) == 0 || l:output[0] !=? 'Database'
    echo 'No database name detected'
    return
  endif
  redraw!

  let l:list = ["Select database:"]

  let l:counter = 1
  for l:item in l:output[1:]
    call add(l:list, l:counter . '. ' . l:item)
    let l:counter += 1
  endfor
  let l:choice = inputlist(l:list)

  if l:choice < 1 || l:choice >= len(l:list)
    redraw | echo "Invalid choice"
  else
    redraw!
    let {s:var_mysql_database} = l:output[l:choice]
    echo 'MySQL Database = ' . {s:var_mysql_database}
  endif

endfun

fun! g:PipeMySQL_DatabaseListing()
  let l:shell_command = s:Get_Remote()
  let l:shell_command .= ' mysql '
  let l:shell_command .= s:Get_MySQL_Access()

  call writefile(['show databases;'], s:tempfilename, 'w')

  let l:shell_command .= ' -t < ' . s:tempfilename

  call g:Pipe(l:shell_command)
  call delete(s:tempfilename)
endfun
" }}}

" Mapping: {{{
if !exists("g:pipemysql_no_mappings") || ! g:pipemysql_no_mappings
    autocmd Filetype mysql nnoremap <buffer> <leader>rf :call g:PipeMySQL_RunFile()<CR>

    " autocmd Filetype mysql nnoremap <buffer> <leader>rl :call g:PipeMySQL_RunLine()<CR>
    " autocmd Filetype mysql vnoremap <buffer> <leader>rl :call g:PipeMySQL_RunLine()<CR>

    " autocmd Filetype mysql nnoremap <buffer> <leader>rb :call g:PipeMySQL_RunBlock()<CR>
    " autocmd Filetype mysql vnoremap <buffer> <leader>rb :call g:PipeMySQL_RunBlock()<CR>

    autocmd Filetype mysql nnoremap <buffer> <leader>rs :call g:PipeMySQL_RunLine()<CR>
    autocmd Filetype mysql vnoremap <buffer> <leader>rs :call g:PipeMySQL_RunBlock()<CR>

    autocmd Filetype mysql nnoremap <buffer> <leader>rc :call g:PipeMySQL_RunCustom()<CR>

    autocmd Filetype mysql nnoremap <buffer> <leader>sr :call g:PipeMySQL_SetRemote()<CR>
    autocmd Filetype mysql nnoremap <buffer> <leader>sa :call g:PipeMySQL_SetAccess()<CR>
    autocmd Filetype mysql nnoremap <buffer> <leader>sd :call g:PipeMySQL_SetDatabase()<CR>
    autocmd Filetype mysql nnoremap <buffer> <leader>se :call g:PipeMySQL_SetEmpty()<CR>
    autocmd Filetype mysql nnoremap <buffer> <leader>sp :call g:PipeMySQL_SelectPreset()<CR>

    autocmd Filetype mysql nnoremap <buffer> <leader>dl :call g:PipeMySQL_DatabaseListing()<CR>
    autocmd Filetype mysql nnoremap <buffer> <leader>ds :call g:PipeMySQL_DatabaseSwitching()<CR>

    autocmd Filetype mysql nnoremap <buffer> <leader>tl :call g:PipeMySQL_TableListing()<CR>
    autocmd Filetype mysql nnoremap <buffer> <leader>ts :call g:PipeMySQL_TableSelectAll()<CR>
    autocmd Filetype mysql nnoremap <buffer> <leader>td :call g:PipeMySQL_TableDescription()<CR>
endif
" }}}

" vim: foldmethod=marker
