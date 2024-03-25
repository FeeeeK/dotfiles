# set locale to en_US.UTF-8 on linux if not set or not any UTF-8 locale
if [[ $OSTYPE == linux* ]]; then
    if [[ -z $LANG || $LANG != *UTF-8 ]]; then
        locale-gen --purge en_US.UTF-8
        update-locale LANG=en_US.UTF-8
        export LANG=en_US.UTF-8
        exec zsh
    fi
fi

# Zinit Plugin Manager
declare -A ZINIT
ZINIT[HOME_DIR]="${HOME}/.zinit"
ZINIT[BIN_DIR]="${HOME}/.zinit/bin"
if [[ ! -d $ZINIT[BIN_DIR] ]]; then
    print -P "Installing Zinit Plugin Manager..."
    mkdir -p "$ZINIT[BIN_DIR]"
    git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT[BIN_DIR]"
fi
source "${ZINIT[BIN_DIR]}/zinit.zsh"
# end Zinit Plugin Manager


autoload -U colors && colors
autoload -U add-zsh-hook

skip_global_compinit=1
setopt prompt_subst
setopt correct_all
setopt HIST_FIND_NO_DUPS
setopt MENU_COMPLETE    # Automatically highlight first element of completion menu
setopt AUTO_LIST        # Automatically list choices on ambiguous completion.
setopt COMPLETE_IN_WORD # Complete from both ends of a word.

zstyle ':autocomplete:*' min-delay 0.1
zstyle ':autocomplete:*' min-input 2
zstyle ':completion:correct-word:*' max-errors 10
# zstyle ':autocomplete:*complete*:*' insert-unambiguous yes
zstyle ':autocomplete:history-search-backward:*' list-lines 256
zstyle ':autocomplete:history-incremental-search-backward:*' list-lines 8
# zstyle ':completion:*' ignored-patterns '/c/windows/**/*'
zstyle ':completion:*' completer _expand _complete _match _prefix

# zinit ice wait'!' lucid
zinit for OMZL::history.zsh

# zinit ice wait'!' lucid
zinit for OMZL::key-bindings.zsh

__init_autocomplete() {
    # if functions .autocomplete.__init__.precmd >/dev/null; then
    #     .autocomplete.__init__.precmd
    #     print -P "Autocomplete initialized via .autocomplete.__init__.precmd"
    # else
    #     .autocomplete:__main__:precmd
    #     print -P "Autocomplete initialized via .autocomplete:__main__:precmd"
    # fi

    bindkey -M menuselect '\r' .accept-line
    bindkey '\t' menu-select "$terminfo[kcbt]" menu-select
    bindkey -M menuselect '\t' menu-complete "$terminfo[kcbt]" reverse-menu-complete
}
zinit ice lucid nocd \
    atload'__init_autocomplete; unset __init_autocomplete'
zinit light marlonrichert/zsh-autocomplete

zinit ice wait'!' lucid
zinit snippet OMZP::virtualenv

zinit light agkozak/agkozak-zsh-prompt

virtualenv_prompt_info() {}

setopt PROMPT_CR

AGKOZAK_LEFT_PROMPT_ONLY=1
AGKOZAK_SHOW_VIRTUALENV=0
AGKOZAK_PROMPT_DIRTRIM=0
AGKOZAK_CMD_EXEC_TIME=0
AGKOZAK_USER_HOST_DISPLAY=0
AGKOZAK_SHOW_BG=0
AGKOZAK_SHOW_STASH=0
AGKOZAK_MULTILINE=1

AGKOZAK_CUSTOM_SYMBOLS=('⇣⇡' '⇣' '⇡' '+' 'x' '!' '>' '?' 'S')

AGKOZAK_CUSTOM_PROMPT=''
if [[ -v WSL_DISTRO_NAME ]]; then
    AGKOZAK_CUSTOM_PROMPT+='%{$fg_bold[red]%}(WSL)%{$reset_color%} '
fi
AGKOZAK_CUSTOM_PROMPT+='%{$fg_bold[cyan]%}%d%{$reset_color%} '
AGKOZAK_CUSTOM_PROMPT+='%{$(virtualenv_prompt_info)%}'
AGKOZAK_CUSTOM_PROMPT+='%{%(3V.${ZSH_THEME_GIT_PROMPT_PREFIX}%6v%(7V.::%7v.)${ZSH_THEME_GIT_PROMPT_CLEAN}${ZSH_THEME_GIT_PROMPT_SUFFIX}.)%}'
# newline
AGKOZAK_CUSTOM_PROMPT+=$'\n'

AGKOZAK_CUSTOM_PROMPT+='%(?:%{$fg_bold[green]%}➜:%{$fg_bold[red]%}➜) '
AGKOZAK_CUSTOM_PROMPT+=' %{$reset_color%}$ '

ZSH_THEME_GIT_PROMPT_PREFIX="%{$fg_bold[blue]%}(%{$fg[red]%}"
ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_DIRTY="%{$fg[blue]%}) %{$fg[yellow]%}✗ "
ZSH_THEME_GIT_PROMPT_CLEAN="%{$fg[blue]%}) "
ZSH_THEME_VIRTUALENV_PREFIX="%{$fg_bold[blue]%}(%{$fg[green]%}"
ZSH_THEME_VIRTUALENV_SUFFIX="%{$fg[blue]%}) "

if [[ -e $HOME/.pyenv ]]; then
    if [[ $OSTYPE == linux* ]]; then
        PYENV_ROOT="$HOME/.pyenv/"
        zinit ice wait'!' lucid nocd \
            atload'eval "$(pyenv init - --no-rehash zsh)"'
        zinit light zdharma-continuum/null
    elif [[ $OSTYPE == Windows_NT || $OSTYPE == cygwin || $OSTYPE == msys ]]; then
        PYENV_ROOT="$HOME/.pyenv/pyenv-win"
    fi
    PATH="$PYENV_ROOT/bin:$PATH"
fi


if [[ -v WSL_DISTRO_NAME ]]; then
    alias virtualenv='virtualenv ~/.virtualenvs/$(basename $PWD)'
fi

__python_venv() {
    VENVPATH=.venv
    if [[ -v WSL_DISTRO_NAME ]]; then
        if [[ -d ~/.virtualenvs/$(basename $PWD) ]]; then
            source ~/.virtualenvs/$(basename $PWD)/bin/activate >/dev/null 2>&1
            return
        fi

    elif [[ ! -v WSL_DISTRO_NAME && -d $VENVPATH ]]; then
        if [[ -e $VENVPATH/Scripts/activate ]]; then
            source $VENVPATH/Scripts/activate >/dev/null 2>&1
            return
        elif [ -e $VENVPATH/bin/activate ]; then
            source $VENVPATH/bin/activate >/dev/null 2>&1
            return
        fi

    elif [[ -v VIRTUAL_ENV ]]; then
        deactivate
    fi
}

add-zsh-hook chpwd __python_venv
__python_venv


if [[ ! -e $HOME/.rye ]]; then
    if [[ $OSTYPE == linux* ]]; then
        setup_rye() {
            curl -sSf https://rye-up.com/get | bash
        }
    elif [[ $OSTYPE == Windows_NT || $OSTYPE == cygwin || $OSTYPE == msys ]]; then
        setup_rye() {
            curl -sSf https://github.com/astral-sh/rye/releases/latest/download/rye-x86_64-windows.exe -o /tmp/rye.exe
            /tmp/rye.exe self install "$@"
            rm /tmp/rye.exe
        }
    fi
else
    case ":${PATH}:" in
        *:"$HOME/.rye/shims":*)
            ;;
        *)
        export PATH="$HOME/.rye/shims:$PATH"
        ;;
    esac
fi

zinit for \
    wait lucid as"completion" nocompile \
    id-as"rye-completion" \
    has"rye" \
    blockf \
    atclone"rye self completion -s zsh > _rye; zinit creinstall rye-completion" \
    atpull"%atclone" \
    run-atpull \
    zdharma-continuum/null

zinit for \
    wait lucid as"completion" \
    id-as"poetry-completion" \
    has"poetry" \
    atclone"poetry completions zsh > _poetry; zinit creinstall poetry-completion" \
    atpull"%atclone" \
    run-atpull \
    nocompile \
    zdharma-continuum/null

zinit for \
    wait lucid as"completition" nocompile \
    id-as"pip-completion" \
    has"pip" \
    blockf \
    atclone"pip completion --zsh > _pip; zinit creinstall pip-completion" \
    atpull"%atclone" \
    run-atpull \
    zdharma-continuum/null

zinit for \
    wait lucid as"completion" nocompile \
    id-as"packwiz-completion" \
    has"packwiz" \
    blockf \
    atclone"packwiz completion zsh > _packwiz; zinit creinstall packwiz-completion" \
    atpull"%atclone" \
    run-atpull \
    zdharma-continuum/null

if [[ $OSTYPE != Windows_NT && $OSTYPE != cygwin && $OSTYPE != msys ]]; then
    zinit for \
        wait lucid as"completion" nocompile \
        id-as"docker-compose-completion" \
        has"docker" \
        blockf \
        atclone"docker completion zsh > _docker; zinit creinstall docker-compose-completion" \
        atpull"%atclone" \
        run-atpull \
        zdharma-continuum/null

    case ":${PATH}:" in
        *:"$HOME/.local/bin":*)
            ;;
        *)
        export PATH="$HOME/.local/bin:$PATH"
        ;;
    esac

elif [[ ! $IS_WSL ]]; then
    JAVA_HOME=$(cygpath -u $JAVA_HOME)
    for p in /custom_bin/*; do
        if [[ -d $p/bin ]]; then
            # PATH="$p/bin:$PATH"
            p="$p/bin"
        # if $p not directory, then continue
        elif [[ ! -d $p ]]; then
            continue
        fi
        # if $ not in PATH, then add it
        case ":${PATH}:" in
            *:"$p":*)
                ;;
            *)
            PATH="$p:$PATH"
            ;;
        esac

    done
    # PATH=$(echo $PATH | sed -E 's/(.*)(\/mingw64\/bin)(.*)/\1\3:\2/')
fi

# command_not_found_handler() {
#     echo "I don't know what '$1' is." >&2
#     return 1
# }

zinit for \
    atload"zicompinit; zicdreplay" \
    blockf \
    lucid \
    wait \
  zsh-users/zsh-completions
