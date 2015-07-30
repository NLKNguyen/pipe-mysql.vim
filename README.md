# pipe-mysql.vim
Easy-to-use MySQL client for Vim

Based on [pipe.vim](https://github.com/NLKNguyen/pipe.vim)

**Features**

* Work with MySQL database at local (with respect to Vim) or at remote machine (via SSH)
* No need to have MySQL installed at local if you plan to execute MySQL statements at remote machine
* Edit MySQL script locally, execute at remote machine, and get result back in Vim's Preview window at local
* Execute a whole MySQL script file, a single line, or a block of MySQL statements
* Set SSH remote and MySQL access on the fly; or use preset for frequently used login info
* Each buffer has independent login info to database
* Easily switch database on the fly
* Include common queries to operate on the target where the cursor is at


# Install
Using [Vundle](https://github.com/VundleVim/Vundle.vim) plugin manager:
```VimL
Plugin 'NLKNguyen/pipe.vim' "required
Plugin 'NLKNguyen/pipe-mysql.vim'
```

# Default Keymaps

The plugin comes with default keymaps for MySQL filetype. To turn off, add `let g:pipemysql_no_mappings = 0` to your .vimrc file

## Set Actions

| Mode   | Key          | Action                | Function call              |
| ---    | ---          | ---                   | ---                        |
| Normal | `<leader>sr` | Set remote info (SSH) | g:PipeMySQL_SetRemote()    |
| Normal | `<leader>sa` | Set MySQL access info | g:PipeMySQL_SetAccess()    |
| Normal | `<leader>sd` | Set database to use   | g:PipeMySQL_SetDatabase()  |
| Normal | `<leader>se` | Set all fields empty  | g:PipeMySQL_SetEmpty()     |
| Normal | `<leader>sp` | Select preset info\*  | g:PipeMySQL_SelectPreset() |

\* See **Use Preset Login Info** for how to store preset login info in .vimrc file

## Run Actions

| Mode   | Key          | Action                            | Function call           |
| ---    | ---          | ---                               | ---                     |
| Normal | `<leader>rf` | Run MySQL script file             | g:PipeMySQL_RunFile()   |
| Normal | `<leader>rs` | Run statement on the current line | g:PipeMySQL_RunLine()   |
| Visual | `<leader>rs` | Run selected block of statements  | g:PipeMySQL_RunBlock()  |
| Normal | `<leader>rc` | Run custom statement (prompt)     | g:PipeMySQL_RunCustom() |

## Common Actions

| Mode   | Key          | Action                         | Function call                   |
| ---    | ---          | ---                            | ---                             |
| Normal | `<leader>dl` | List databases                 | g:PipeMySQL_DatabaseListing()   |
| Normal | `<leader>ds` | Switch database                | g:PipeMySQL_DatabaseSwitching() |
| Normal | `<leader>tl` | List tables                    | g:PipeMySQL_TableListing()      |
| Normal | `<leader>ts` | Select \* from table at cursor | g:PipeMySQL_TableSelectAll()    |
| Normal | `<leader>td` | Describe table at cursor       | g:PipeMySQL_TableDescription()  |

## Use Preset Login Info
In `.vimrc` you can store frequently used login info like the below snippet. The `description` value is what you see in the list of preset info in order to select. 
All other fields are optional. They can be set on the fly using the Set Actions; therefore, you don't have to store sensitive information like password in .vimrc if you don't want to.

```VimL
let g:pipemysql_login_info = [
                             \ {
                             \    'description' : 'my server 1',
                             \    'ssh_address' : 'root@server1',
                             \    'ssh_port' : '',
                             \    'mysql_hostname' : 'somehostname',
                             \    'mysql_username' : 'my_username',
                             \    'mysql_password' : 'my_password',
                             \    'mysql_database' : 'cs332h20'
                             \ },
                             \ {
                             \    'description' : 'my server 2',
                             \    'ssh' : 'root@server2',
                             \    'mysql_hostname' : 'somehostname',
                             \    'mysql_username' : 'my_username',
                             \ },
                             \ {
                             \    'description' : 'my local',
                             \    'mysql_hostname' : 'localhost',
                             \ }
                           \ ]
```

-------
Suggestions/Wishes/Questions/Comments are welcome via [Github issues](https://github.com/NLKNguyen/pipe-mysql.vim/issues)

# License MIT
Copyright (c) Nguyen Nguyen
