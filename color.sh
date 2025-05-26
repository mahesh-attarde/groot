#! /bin/bash
#When you want to have a colored, context-sensitive PS1 prompt, add this to your .bashrc or modify the existing parts of it (in Ubuntu and maybe all Debian-based distris):

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
        # We have color support; assume it's compliant with Ecma-48
        # (ISO/IEC-6429). (Lack of such support is extremely rare, and such
        # a case would tend to support setf rather than setaf.)
        color_prompt=yes
    else
        color_prompt=
    fi
fi

if [ "$color_prompt" = yes ]; then
    # when system is accessed via SSH, hostname with light grey background
    if [[ $(pstree -s $$) = *sshd* ]]; then sshbg="\[\033[48;5;7m\]"; fi
    # when used as root, change username to orange and '#' to red for prompt
    if [ $(id -u) -eq 0 ]; then usercol="\[\033[38;5;3m\]"; hashcol="\[\033[38;5;1m\]"; else usercol="\[\033[38;5;2m\]"; fi
    # bash PS1 prompt. $(realpath .) instead of \w avoids symlink paths
    PS1="${usercol}\u\[$(tput sgr0)\]@\[$(tput sgr0)\]\[\033[38;5;4m\]${sshbg}\h\[$(tput sgr0)\]:[$ICS_WSNAME]\[$(tput sgr0)\]\[\033[38;5;6m\]\w\[$(tput sgr0)\]${hashcol}\\$ \[$(tput sgr0)\] \n"
    unset sshbg rootcol hashcol
fi
unset color_prompt force_color_prompt

prompt_less(){
    export PS1="\[$(tput sgr0)\]\[\033[38;5;4m\]${sshbg}\h\[$(tput sgr0)\]\[$(tput sgr0)\]\[\033[38;5;6m\]\[$(tput sgr0)\]${hashcol}\\$ \[$(tput sgr0)\] \n"

}