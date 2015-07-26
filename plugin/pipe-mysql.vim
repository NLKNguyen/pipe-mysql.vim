
if !exists("g:pipemysql_login_info")
  let g:pipemysql_login_info = []
endif

fun! s:Initialize_Login_Info()
endfun
let s:prefix = 'ac59330d' "prefix for variables

let s:var_ssh_address    = 'b:' . s:prefix . 'ssh_address'
let s:var_ssh_port       = 'b:' . s:prefix . 'ssh_port'
let s:var_mysql_username = 'b:' . s:prefix . 'mysql_username'
let s:var_mysql_password = 'b:' . s:prefix . 'mysql_password'
let s:var_mysql_hostname = 'b:' . s:prefix . 'mysql_hostname'
let s:var_mysql_port     = 'b:' . s:prefix . 'mysql_port'
let s:var_mysql_database = 'b:' . s:prefix . 'mysql_database'

fun! g:PipeMySQL(flag)
  if a:flag == "-I"
    call g:PipeMySQL_Login_Info()
  elseif a:flag ==? "-f"
    call g:PipeMySQL_RunFile()
  else
    " redraw | echo "Invalid choice"
    echo 'Unrecognized flag'
  endif
endfun

command! -nargs=1 -range PipeMySQL :call g:PipeMySQL("<args>")

fun! g:PipeMySQL_Login_Info()
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
    let {s:var_mysql_port} = get(l:login, 'mysql_port', '')
    let {s:var_mysql_database} = get(l:login, 'mysql_database', '')

  endif
endfun
" command! -nargs=0  PipeMySQLAddLogin :call add({s:pipemysql_login_info}, <args>)

fun! s:Get_SSH_Info()
  let l:ssh_info = ''
  let l:ssh_address = g:PipeGetVar(s:var_ssh_address, 'SSH Address (empty to unspecify) = ')

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

fun! g:PipeMySQL_Clear_Info()
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

fun! g:PipeMySQL_RunFile()
    let l:shell_command = s:Get_SSH_Info()
    let l:shell_command .= ' mysql '
    let l:shell_command .= s:Get_MySQL_Login_Info() " hostname, port, username & password
    " let l:shell_command .= s:Get_MySQL_Database_To_Use() "database
    let l:shell_command .= ' -t < ' . expand('%')
    call g:Pipe(l:shell_command)

 endfun
