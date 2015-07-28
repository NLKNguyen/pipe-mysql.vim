" Plugin: Pipe-MySQL (MySQL database client)
" Author: Nguyen Nguyen <NLKNguyen@MSN.com>
" License: MIT
" Origin: http://github.com/NLKNguyen/pipe-mysql.vim
" Depend: http://github.com/NLKNguyen/pipe.vim

" Variables: {{{
if !exists("g:pipemysql_login_info")
  " @brief list of preset login info
  let g:pipemysql_login_info = []
endif

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
" }}}

" Command Line Interface: {{{
fun! g:PipeMySQL(flag)
  if a:flag == "-f"
    call g:PipeMySQL_RunFile()
  elseif a:flag == "-l"
    call g:PipeMySQL_RunLine()
  elseif a:flag == "-b"
    call g:PipeMySQL_RunBlock()
  elseif a:flag == "-c"
    call g:PipeMySQL_RunCustom()

  elseif a:flag == "-s"
    call g:PipeMySQL_SelectLogin()
  elseif a:flag == "-r"
    call g:PipeMySQL_SetRemote()
  elseif a:flag == "-i"
    call g:PipeMySQL_SetLogin()
  elseif a:flag == "-d"
    call g:PipeMySQL_SetDatabase()

  else
    echo 'Unrecognized flag'
  endif
endfun

command! -nargs=1 -range PipeMySQL :call g:PipeMySQL("<args>")
" }}}

fun! g:PipeMySQL_SelectLogin()
  let l:list = ["Select login info:"]

  let l:counter = 1
  for l:login in g:pipemysql_login_info
    call add(l:list, l:counter . '. ' . l:login['description'])
    let l:counter += 1
  endfor

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

fun! g:PipeMySQL_ClearLogin()
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
endfun

" Private: {{{
fun! s:Get_SSH_Info()
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

fun! s:Get_MySQL_Login_Info()
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

fun! s:Get_MySQL_Database_To_Use()
  return ' ' . g:PipeGetVar(s:var_mysql_database, 'MySQL Database = ') . ' '
endfun

" }}}


" Run: {{{
fun! g:PipeMySQL_RunFile()
  let l:shell_command = s:Get_SSH_Info()
  let l:shell_command .= ' mysql '
  let l:shell_command .= s:Get_MySQL_Login_Info()
  let l:shell_command .= ' -t < ' . expand('%:p')

  call g:Pipe(l:shell_command)
endfun

fun! g:PipeMySQL_RunLine()
  let l:shell_command = s:Get_SSH_Info()
  let l:shell_command .= ' mysql '
  let l:shell_command .= s:Get_MySQL_Login_Info()
  let l:shell_command .= s:Get_MySQL_Database_To_Use()

  call writefile([g:PipeGetCurrentLine()], s:tempfilename, 'w')

  let l:shell_command .= ' -t < ' . s:tempfilename

  call g:Pipe(l:shell_command)
  call delete(s:tempfilename)
endfun

fun! g:PipeMySQL_RunBlock()
  let l:shell_command = s:Get_SSH_Info()
  let l:shell_command .= ' mysql '
  let l:shell_command .= s:Get_MySQL_Login_Info()
  let l:shell_command .= s:Get_MySQL_Database_To_Use()

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
  let l:shell_command = s:Get_SSH_Info()
  let l:shell_command .= ' mysql '
  let l:shell_command .= s:Get_MySQL_Login_Info()
  let l:shell_command .= s:Get_MySQL_Database_To_Use()

  let l:custom_statement = g:PipeGetVar(s:var_mysql_custom_statement, "MySQL Statement » ", 2) "2: always prompt
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


" Edit: {{{
fun! g:PipeMySQL_SetRemote()
  let {s:var_ssh_address} = g:PipeGetVar(s:var_ssh_address, 'SSH Address (empty to not use SSH) = ', 2)
  if {s:var_ssh_address} !=? ''
    let {s:var_ssh_port}  = g:PipeGetVar(s:var_ssh_port, 'SSH Port = ', 2)
  endif
endfun

fun! g:PipeMySQL_SetLogin()
  " Hostname & Port
  let {s:var_mysql_hostname} = g:PipeGetVar(s:var_mysql_hostname, 'MySQL Hostname = ', 2)
  if {s:var_mysql_hostname} !=? ''
    let {s:var_mysql_port} = g:PipeGetVar(s:var_mysql_port, 'MySQL Port = ', 2)
  endif

  " Username & Password
  let {s:var_mysql_username} = g:PipeGetVar(s:var_mysql_username, 'MySQL Username = ', 2)
  if {s:var_mysql_username} !=? ''
    let {s:var_mysql_password} = g:PipeGetVar(s:var_mysql_password, 'MySQL Password = ', -2)
  endif
endfun

fun! g:PipeMySQL_SetDatabase()
  " TODO:
endfun
" }}}

" vim: foldmethod=marker
