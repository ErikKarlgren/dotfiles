if status is-interactive
    # Commands to run in interactive sessions can go here
    set fish_greeting

    # Aliases
    alias diff 'git diff --no-index'
    alias e nvim
    alias ip 'ip --color=auto'

    if command -q lsd
        alias ls 'lsd -A'
        alias ll 'lsd -Al'
    else
        alias ls 'ls -A --color=auto'
        alias ll 'ls -Ahl --color=auto'
    end

    if command -q random
        # Use MY random cli (made in rust btw)
        # Maybe rename to `sample`?
        alias random (which random)
    end

end

set -x EDITOR "nvim"

# Working at GMV
if [ "$hostname" = "ltexeekd" ]
    # Add npm (and node?) to path. If you need to run nvm, do so from bash instead.
    fish_add_path /root/.nvm/versions/node/v22.4.1/bin/
end
