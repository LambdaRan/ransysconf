### shell 配置

​    这个是自己的shell配置，目前主要使用zsh这个shell版本。

* zsh配置主要参考的是[Oh-my-zsh](https://github.com/ohmyzsh/ohmyzsh)配置，去掉了很多不需要的东西。我不喜欢花里胡哨的终端PROMPT，只留下了自己喜欢的一个主题，以后如果尝试其他的主题再慢慢增加。

* bash配置只是简单的修改了终端PROMPT，参考 [大佬知乎文章](https://zhuanlan.zhihu.com/p/51008087)，其他的功能配置等用到bash环境时再慢慢补充。

##### 更改默认shell

```bash
# 查看系统中有哪些shell
cat /etc/shells
# 查看当前使用的shell
echo $SHELL
# 把zsh设为默认shell
chsh -s $(which zsh)
# 或 chsh -s /bin/zsh
```
