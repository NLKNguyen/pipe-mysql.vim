<h1 align="center">pipe-mysql.vim</h1>
<p align="center">
  <a href="https://github.com/NLKNguyen/S-Expression.JS/blob/master/LICENSE" target="_blank">
    <img alt="License: ISC" src="https://img.shields.io/github/license/NLKNguyen/pipe-mysql.vim.svg?color=blueviolet" />
  </a>

  <a href="https://www.patreon.com/Nikyle" title="Donate to this project using Patreon">
    <img src="https://img.shields.io/badge/support%20me-patreon-red.svg" alt="Patreon donate button" />
  </a>

  <a href="https://paypal.me/NLKNguyen" title="Donate one time via PayPal">
    <img src="https://img.shields.io/badge/paypal-me-blue.svg" alt="PayPal donate button" />
  </a>

  <a href="https://www.amazon.com/gp/registry/wishlist/3E0E6ZS7RQ5GS/" title="Send a gift through my Amazon wishlist">
    <img src="https://img.shields.io/badge/send%20a%20gift-amazon-darkorange.svg" alt="Amazon donate button" />
  </a>
</p>

<p align="center">
  <a href="https://www.buymeacoffee.com/Nikyle" target="_blank">
    <img src="https://cdn.buymeacoffee.com/buttons/v2/default-yellow.png" alt="Buy Me A Coffee" height=45 />
  </a>
</p>

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

| Mode   | Key          | Action                                         | Function call                  |
| ---    | ---          | ---                                            | ---                            |
| Normal | `<leader>rf` | Run MySQL script file                          | g:PipeMySQL_RunFile()          |
| Normal | `<leader>rs` | Run statement on the current line (table view) | g:PipeMySQL_RunLine('table')   |
| Visual | `<leader>rs` | Run selected block of statements  (table view) | g:PipeMySQL_RunBlock('table')  |
| Normal | `<leader>rS` | Run statement on the current line (batch view) | g:PipeMySQL_RunLine('batch')   |
| Visual | `<leader>rS` | Run selected block of statements  (batch view) | g:PipeMySQL_RunBlock('batch')  |
| Normal | `<leader>rc` | Run custom statement (prompt)                  | g:PipeMySQL_RunCustom()        |

<!-- TODO: `rc` to use table view and addition `rC` to use batch view -->

## Common Actions

| Mode   | Key          | Action                                          | Function call                   |
| ---    | ---          | ---                                             | ---                             |
| Normal | `<leader>dl` | List databases                                  | g:PipeMySQL_DatabaseListing()   |
| Normal | `<leader>ds` | Switch database                                 | g:PipeMySQL_DatabaseSwitching() |
| Normal | `<leader>tl` | List tables                                     | g:PipeMySQL_TableListing()      |
| Normal | `<leader>ts` | Select \* from table at cursor                  | g:PipeMySQL_TableSelectAll()    |
| Normal | `<leader>td` | Describe table at cursor                        | g:PipeMySQL_TableDescription()  |
| Normal | `<leader>tD` | Show `create` SQL definition of table at cursor | g:PipeMySQL_TableDefinition()   |

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

# 👋 Author

👤 **Nikyle Nguyen**

  <a href="https://twitter.com/NLKNguyen" target="_blank">
    <img alt="Twitter: NLKNguyen" src="https://img.shields.io/twitter/follow/NLKNguyen.svg?style=social" />
  </a>

-   Website: <https://dephony.com/Nikyle>
-   Twitter: [@NLKNguyen](https://twitter.com/NLKNguyen)
-   Github: [@NLKNguyen](https://github.com/NLKNguyen)
-   LinkedIn: [@NLKNguyen](https://linkedin.com/in/NLKNguyen)

# 🤝 Contributing

Give a ⭐️ if this project helped you working with MySQL in Vim seamlessly!

Contributions, issues and feature requests are welcome! Feel free to check [issues page](https://github.com/NLKNguyen/pipe-mysql.vim/issues).

## 🙇 Your support is very much appreciated

I create open-source projects on GitHub and continue to develop/maintain as they are helping others. You can integrate and use these projects in your applications for free! You are free to modify and redistribute anyway you like, even in commercial products.

I try to respond to users' feedback and feature requests as much as possible. Obviously, this takes a lot of time and efforts (speaking of mental context-switching between different projects and daily work). Therefore, if these projects help you in your work, and you want to encourage me to continue create, here are a few ways you can support me:

-   💬 Following my blog and social profiles listed above to help me connect with your network
-   ⭐️ Starring this project and sharing with others as more users come, more great ideas arrive!
-   ☘️ Donating any amount is a great way to help me work on the projects more regularly!

<p>

  <a href="https://paypal.me/NLKNguyen" target="_blank">
      <img src="https://user-images.githubusercontent.com/4667129/101101433-71b7ff00-357d-11eb-8cf2-3c529960d422.png" height=44 />
  </a>

  <a href="https://www.patreon.com/Nikyle" target="_blank">
    <img src="https://c5.patreon.com/external/logo/become_a_patron_button@2x.png" height=44 style="border-radius: 5px;" />
  </a>

  <a href="https://www.buymeacoffee.com/Nikyle" target="_blank">
      <img src="https://cdn.buymeacoffee.com/buttons/v2/default-yellow.png" alt="Buy Me A Coffee" height=44 />
  </a>

</p>

# 📝 License

Copyright © 2015 - 2020 [Nikyle Nguyen](https://github.com/NLKNguyen)

The project is [MIT License](https://github.com/NLKNguyen/S-Expression.JS/blob/master/LICENSE)
