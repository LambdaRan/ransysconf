#!/bin/env sh

# set -e

source $RSCF/apps/utils.sh

brew_commands=(
    "rg::rg"
    "fd::fd"
    "wget::wget"
    "lua::lua"
    "ctags::--HEAD universal-ctags/universal-ctags/universal-ctags"
    "go::go"
)

setup_brew() {
    local cur_path=$(pwd)

    ohai "${tty_yellow}setup brew....${tty_reset}"
    command_exists brew || {
        # 安装brew
        echo "${tty_yellow}brew not installed, next install${tty_reset}"
        execute "sh -c" "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    }
    # 配置brew
    echo "${tty_green}Configuring brew...${tty_reset}"
    # 替换brew.git:
    execute "cd" "$(brew --repo)"
    execute "git" "remote" "set-url" "origin" "https://mirrors.ustc.edu.cn/brew.git"
    # 替换homebrew-core.git:
    execute "cd" "$(brew --repo)/Library/Taps/homebrew/homebrew-core"
    execute "git" "remote" "set-url" "origin" "https://mirrors.ustc.edu.cn/homebrew-core.git"

    execute "cd" "$HOME"
    # 替换homebrew-bottles:
    if ! grep -q "HOMEBREW_BOTTLE_DOMAIN" ${shell_conf} 2> /dev/null ; then
        echo 'export HOMEBREW_BOTTLE_DOMAIN=https://mirrors.ustc.edu.cn/homebrew-bottles' >> ${shell_conf}
        echo 'export HOMEBREW_NO_AUTO_UPDATE=true' >> ${shell_conf}
        execute "source" "${shell_conf}"
    fi
    # 应用生效:
    echo "${tty_green}brew update...${tty_reset}"
    execute "brew" "update"

    # 安装应用
    local KEY=""
    local VALUE=""
    for cmd in "${brew_commands[@]}"; do
        KEY="${cmd%%::*}"
        VALUE="${cmd##*::}"
        if ! command_exists ${KEY};then
            echo "${tty_yellow}brew install ${KEY}...${tty_reset}"
            brew install ${VALUE} || true
        else
            echo "${tty_green}${KEY}${tty_reset} is exists"
        fi
    done
}
# test_color
# setup_color
# setup_brew