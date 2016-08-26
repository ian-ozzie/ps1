# ps1

## Installing

Run the below

```
git clone --recursive https://github.com/ian-ozzie/ps1.git ~/.ps1
echo '[ -e $HOME/.ps1/ps1.bash ] && source $HOME/.ps1/ps1.bash' >> ~/.bashrc
```

Background updates on repos has been offloaded to atd instead of trying to background async tasks. This may cause it to take up to 30 seconds to update, but the shell will no longer lock waiting for command completion.

## Customising

See [variables.bash](variables.bash) for variables you can set to customise the output.
