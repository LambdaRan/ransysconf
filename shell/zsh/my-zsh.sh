#!/usr/bin/env zsh

# custom
ZSH="${RSCF}/shell/zsh"

ZSH_THEME="robbyrussell"
# ZSH_THEME="ran"



# https://www.csse.uwa.edu.au/programming/linux/zsh-doc/zsh_23.html

# add a function path
fpath=($ZSH/functions $ZSH/completions $fpath)

# Load all stock functions (from $fpath files) called below.
autoload -U compaudit compinit

# Save the location of the current completion dump file.
if [ -z "$ZSH_COMPDUMP" ]; then
  ZSH_COMPDUMP="${ZDOTDIR:-${HOME}}/.zcompdump-${SHORT_HOST}-${ZSH_VERSION}"
fi

# Construct zcompdump OMZ metadata
zcompdump_metadata="\
#omz revision: $(builtin cd -q "$ZSH"; git rev-parse HEAD 2>/dev/null)
#omz fpath: $fpath\
"

# Delete the zcompdump file if OMZ zcompdump metadata changed
if ! cmp -s <(command grep '^#omz' "$ZSH_COMPDUMP" 2>/dev/null) <(echo "$zcompdump_metadata"); then
  command rm -f "$ZSH_COMPDUMP"
  zcompdump_refresh=1
fi

if [[ $ZSH_DISABLE_COMPFIX != true ]]; then
  source $ZSH/lib/compfix.zsh
  # If completion insecurities exist, warn the user
  handle_completion_insecurities
  # Load only from secure directories
  compinit -i -C -d "${ZSH_COMPDUMP}"
else
  # If the user wants it, load from all found directories
  compinit -u -C -d "${ZSH_COMPDUMP}"
fi

# Append zcompdump metadata if missing
if (( $zcompdump_refresh )); then
  echo "\n$zcompdump_metadata" | tee -a "$ZSH_COMPDUMP" &>/dev/null
fi

unset zcompdump_metadata zcompdump_refresh


# 加载库配置文件
# Load all of the config files in ~/oh-my-zsh that end in .zsh
# TIP: Add files you don't want in git to .gitignore
for config_file ($ZSH/lib/*.zsh); do
  source $config_file
done

# 加载插件

# 加载自定义配置

# load the theme
if [ ! "$ZSH_THEME" = ""  ]; then
    if [ -f "$ZSH/theme/$ZSH_THEME.zsh-theme" ]; then
        source "$ZSH/theme/$ZSH_THEME.zsh-theme"
    else
        echo "error not find ${ZSH_THEME} theme"
    fi
fi
