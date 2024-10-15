if status is-interactive
    # Commands to run in interactive sessions can go here
    set fish_greeting

    # Aliases
    alias ip 'ip -c'
    alias ls 'lsd -A'
    alias ll 'lsd -Al'
    alias code codium
    alias e nvim

    if which random > /dev/null
        # Use MY random cli (made in rust btw)
        alias random (which random)
    end

    # Bindings
    bind '[3;5~' kill-word  # ctrl + supr: delete word to the right

end

set -x EDITOR "nvim"

