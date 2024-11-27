# dotfiles

## Cloning this repo
```bash
# Bare cloning
git clone --bare <git-repo-url> $HOME/.dotfiles

# In bash
alias config='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'

# In fish
# Do it in bash as of now, and after next step, run "exec fish"

# Checkout the actual content into your $HOME
# Don't forget to either delete the conflicting files, or to back them up
config checkout

# Don't show untracked files
config config --local status.showUntrackedFiles no

# And you're done!
```

## Possible issues
### Cannot fetch remote branches
Check `~/.dotfiles/config`, and make sure that the section `remote "origin"` looks like this:
```toml
[remote "origin"]
	url = ...
	fetch = +refs/heads/*:refs/remotes/origin/*

```
If the "fetch" line was missing, add it, and your problem should be fixed.
