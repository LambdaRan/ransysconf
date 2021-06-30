# iterm2 软件配置

## 安装rz/sz
1. 安装lrzsz
```
brew install lrzsz
```

2. 将 `iterm2-xx.sh`拷贝到`/usr/local/bin/`目录
```bash
cp iterm2-* /usr/local/bin/
chmod 777 /usr/local/bin/iterm2-*
```

3. 修改iterm2的Preference -> Profiles -> Advanced -> Triggers -> Edit，添加『+』如下内容:
```
Regular expression: rz waiting to receive.\*\*B0100
Action: Run Silent Coprocess
Parameters: /usr/local/bin/iterm2-send-zmodem.sh
Instant: checked

Regular expression: \*\*B00000000000000
Action: Run Silent Coprocess
Parameters: /usr/local/bin/iterm2-recv-zmodem.sh
Instant: checked
```

4. 修复使用expect登录机器后无法使用rzsz命令
```
# 在shell配置中添加一下内容
export LC_CTYPE=en_US
```
