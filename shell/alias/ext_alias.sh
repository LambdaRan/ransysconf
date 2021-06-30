
#列出所有的命令别名

# alias rrelay="expect $HOME/lambda/software/quickLogin.exp"
alias relay='$HOME/ransysconf/relay/relay.py'
#alias ls='ls -color=auto'
alias grep="grep --color=auto"
#alias python="python3"

# als请求包ext字段解析
alias alsext="$HOME/lambda/software/alsparse/MainParseData.php"
alias urld="$HOME/lambda/software/url/UrlDecode.php"
alias urle="$HOME/lambda/software/url/UrlEncode.php"
alias unserialize="$HOME/lambda/software/PrintfUnserialize.php"

alias gpush="git_push_for_review"
function git_push_for_review() {
    local origin="$1"
    local branch="$2"
    [[ -z "${origin}" ]] && origin=origin
    [[ -z "${branch}" ]] && branch=$(git symbolic-ref --quiet HEAD) && branch=${branch#refs/heads/}
    if [[ -n "${branch}" ]]; then
        git push "${origin}" HEAD:refs/for/"${branch}"
    else
        echo "no branch related" && kill -INT $$
    fi
}

cls() {cd "$1"; ls}
jsond() {echo "$1" | jq . }

alias ga="git add"
alias gau="git add -u"
alias gc="git commit -m"
alias gca="git commit -am"
alias gb="git branch"
alias gcb="git checkout"
alias gcd='cd $(git rev-parse --show-toplevel)' #goto root dir
alias gs="git status"