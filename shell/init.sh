
# 设置alias
for alias in $RSCF/shell/alias/*.sh;do
    source ${alias}
done

# 配置shell
if [ -n "$ZSH_VERSION" ]; then
    source $RSCF/shell/zsh/my-zsh.sh
    if [[ "$INSIDE_EMACS" = 'vterm' ]] \
           && [[ -n ${EMACS_VTERM_PATH} ]] \
           && [[ -f ${EMACS_VTERM_PATH}/etc/emacs-vterm-zsh.sh ]]; then
	    source ${EMACS_VTERM_PATH}/etc/emacs-vterm-zsh.sh
    fi
elif [ -n "$BASH_VERSION" ]; then
    source $RSCF/shell/bash/my_bash.sh
    if [[ "$INSIDE_EMACS" = 'vterm' ]] \
           && [[ -n ${EMACS_VTERM_PATH} ]] \
           && [[ -f ${EMACS_VTERM_PATH}/etc/emacs-vterm-bash.sh ]]; then
	    source ${EMACS_VTERM_PATH}/etc/emacs-vterm-bash.sh
    fi
else
    echo "not support shell"
fi
