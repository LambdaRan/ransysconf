#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

; https://wyagd001.github.io/zh-cn/docs/Hotkeys.htm
; 基本语法 Start
; ^ -> Ctrl
; ! -> Alt
; + -> Shift
; # -> Win
; ; -> 单行注释 (single-line comment) 
; ` -> 转义字符 (escape character)
; :: -> 按键映射 (key mapping)
; $ -> 抑制原来的按键
; ~ -> 保留系统原有按键功能
; 原键位::映射到的键位


; 按键交换
LAlt::LCtrl
LCtrl::LWin
LWin::LAlt
; RAlt::LWin

; 快速退出
^q::
    send, !{f4}
Return

; 快速切换窗口
Pause::
    Send, ^!{Tab}
Return

;^Tab::
;    Send, {Alt Down}{Tab}
;Return

; TODO: 双屏切换

; 多桌面工作区
; Win -Tab：打开「任务视图」，相当于点击「可视化入口」。
; Win -Ctrl-D：创建新的虚拟桌面。 
; Win -Ctrl-F4：删除当前虚拟桌面。
; Win -Ctrl-左键：切换到相邻左侧的虚拟桌面。
; Win -Ctrl-右键：切换到相邻右侧的虚拟桌面。
; 创建多桌面工作区
^PrintScreen::
Send {LWin Down}{Ctrl Down}{d}{Ctrl Up}{LWin Up}
Return
; 删除桌面
^!PrintScreen::
    Send {LWin Down}{Ctrl Down}{f4}{Ctrl Up}{LWin Up}
Return
; 切换
; ^!Left::
; send {LWin Down}{Ctrl Down}{Left}{Ctrl Up}{LWin Up}
; return
; ^!Right::
; Send {LWin Down}{Ctrl Down}{Right}{Ctrl Up}{LWin Up}
; return


launchOrSwitchApp(name, path)
{
    IfWinExist ahk_class %name%
    {
        WinActivate, ahk_class %name%
    }
    Else
    {
        Run %path%
    }
    Return
}
PrintScreen::launchOrSwitchApp("Emacs", "C:\Program Files\Emacs\x86_64\bin\runemacs.exe")
ScrollLock::launchOrSwitchApp("Chrome_WidgetWin_1", "C:\Program Files\Google\Chrome\Application\chrome.exe")
