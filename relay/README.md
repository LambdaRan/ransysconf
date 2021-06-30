### Relay 

​	**服务器选择自动登录脚本**

​	工作中经常需要登录服务器（测试机、中控机、线上机器）进行开发测试或线上日志查询、问题排查，每次先登录relay机器验证再登录服务器太过麻烦。根据公司内网auto_relay脚本和[SSHGO](https://github.com/emptyhua/sshgo)脚本，进行简单修改以适合公司环境。

* 使用expect实现登录自动交互
* 使用Python的curse、Json库实现服务选择界面与地址配置。

##### 配置步骤：

1、修改host配置文件，配置主机、用户、密码、分组

2、创建alias，修改bashrc/zshrc

```bash
# 脚本需要添加可执行权限
alias relay = "~/ransysconf/relay/relay.py"
```

##### 快捷键：

- 退出: q
- 向上滚动: k
- 向下滚动: j
- 选择主机: space、enter、f
- 搜索: /
- 退出搜索结果: q
- 展开分组: o
- 收起分组: c
- 展开所有分组: O
- 收起所有分组: C

