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
let s:var_mysql_select_limit = 'b:' . s:prefix . 'mysql_select_limit'
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
    call g:PipeMySQL_EditRemote()
  elseif a:flag == "-i"
    call g:PipeMySQL_EditAccess()
  elseif a:flag == "-d"
    call g:PipeMySQL_EditDatabase()

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

fun! g:PipeMySQL_DescribeTable()
  let l:shell_command = s:Get_SSH_Info()
  let l:shell_command .= ' mysql '
  let l:shell_command .= s:Get_MySQL_Login_Info()
  let l:shell_command .= s:Get_MySQL_Database_To_Use()

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

fun! g:PipeMySQL_SelectTable(with_limit)
  let l:shell_command = s:Get_SSH_Info()
  let l:shell_command .= ' mysql '
  let l:shell_command .= s:Get_MySQL_Login_Info()
  let l:shell_command .= s:Get_MySQL_Database_To_Use()

  let l:table_name = g:PipeGetCurrentWord()
  if l:table_name ==? ''
    echo 'No table name is selected'
    return
  endif

  let l:limit = ''
  if a:with_limit == 1
    let l:limit_input = g:PipeGetVar(s:var_mysql_select_limit, "Limit (maximum number of records to show) = ", 2) "2: always prompt
    if l:limit_input != ''
      let l:limit = ' limit ' . l:limit_input
    endif
  endif

  call writefile(['select * from ' . l:table_name . l:limit . ';'], s:tempfilename, 'w')

  let l:shell_command .= ' -t < ' . s:tempfilename

  call g:Pipe(l:shell_command)
  call delete(s:tempfilename)
endfun

fun! g:PipeMySQL_SelectDatabase()
  let l:shell_command = s:Get_SSH_Info()
  let l:shell_command .= ' mysql '
  let l:shell_command .= s:Get_MySQL_Login_Info()


  " let l:shell_command .= s:Get_MySQL_Database_To_Use()

  " let l:table_name = g:PipeGetCurrentWord()
  " if l:table_name ==? ''
  "   echo 'No table name is selected'
  "   return
  " endif

  " let l:limit = ''
  " if a:with_limit == 1
  "   let l:limit_input = g:PipeGetVar(s:var_mysql_select_limit, "Limit (maximum number of records to show) = ", 2) "2: always prompt
  "   if l:limit_input != ''
  "     let l:limit = ' limit ' . l:limit_input
  "   endif
  " endif

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

  " let l:output = ''
  " call g:Pipe(l:shell_command)
  " call delete(s:tempfilename)
endfun

fun! g:PipeMySQL_ListTables()
  let l:shell_command = s:Get_SSH_Info()
  let l:shell_command .= ' mysql '
  let l:shell_command .= s:Get_MySQL_Login_Info()
  let l:shell_command .= s:Get_MySQL_Database_To_Use()

  call writefile(['show tables;'], s:tempfilename, 'w')

  let l:shell_command .= ' -t < ' . s:tempfilename

  call g:Pipe(l:shell_command)
  call delete(s:tempfilename)
endfun

fun! g:PipeMySQL_ListDatabases()
  let l:shell_command = s:Get_SSH_Info()
  let l:shell_command .= ' mysql '
  let l:shell_command .= s:Get_MySQL_Login_Info()

  call writefile(['show databases;'], s:tempfilename, 'w')

  let l:shell_command .= ' -t < ' . s:tempfilename

  call g:Pipe(l:shell_command)
  call delete(s:tempfilename)
endfun
" }}}


" Edit: {{{
fun! g:PipeMySQL_EditRemote()
  let {s:var_ssh_address} = g:PipeGetVar(s:var_ssh_address, 'SSH Address (empty to not use SSH) = ', 2)
  if {s:var_ssh_address} !=? ''
    let {s:var_ssh_port}  = g:PipeGetVar(s:var_ssh_port, 'SSH Port = ', 2)
  endif
endfun

fun! g:PipeMySQL_EditAccess()
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

fun! g:PipeMySQL_EditDatabase()
  let {s:var_mysql_database} = g:PipeGetVar(s:var_mysql_database, "MySQL Database = ", 2) "2: always prompt
endfun
" }}}

" Mapping: {{{
" TODO: Find the best way to map keys
if !exists("g:pipe_no_mappings") || ! g:pipe_no_mappings
  nmap <leader>rf :call g:PipeMySQL_RunFile()<CR>

  nmap <leader>rl :call g:PipeMySQL_RunLine()<CR>
  vmap <leader>rl :call g:PipeMySQL_RunLine()<CR>

  nmap <leader>rb :call g:PipeMySQL_RunBlock()<CR>
  vmap <leader>rb :call g:PipeMySQL_RunBlock()<CR>

  nmap <leader>rs :call g:PipeMySQL_RunLine()<CR>
  vmap <leader>rs :call g:PipeMySQL_RunBlock()<CR>

  nmap <leader>rc :call g:PipeMySQL_RunCustom()<CR>

  nmap <leader>er :call g:PipeMySQL_EditRemote()<CR>
  nmap <leader>ea :call g:PipeMySQL_EditAccess()<CR>
  nmap <leader>ei :call g:PipeMySQL_SelectLogin()<CR>
  nmap <leader>ed :call g:PipeMySQL_EditDatabase()<CR>

  nmap <leader>dl :call g:PipeMySQL_ListDatabases()<CR>
  nmap <leader>ds :call g:PipeMySQL_SelectDatabase()<CR>

  nmap <leader>td :call g:PipeMySQL_DescribeTable()<CR>
  nmap <leader>tl :call g:PipeMySQL_ListTables()<CR>
  nmap <leader>ts :call g:PipeMySQL_SelectTable(1)<CR>
  nmap <leader>tS :call g:PipeMySQL_SelectTable(0)<CR>

endif
" }}}

" vim: foldmethod=marker
