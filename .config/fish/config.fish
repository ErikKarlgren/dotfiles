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

    # Do not bind ctrl-v to search variables with fzf
    fzf_configure_bindings --variables=

    if not functions -q fisher
        curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source && fisher install jorgebucaran/fisher
    end
end

set -x EDITOR "nvim"

