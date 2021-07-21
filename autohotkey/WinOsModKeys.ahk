#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

; 基本语法 Start
; ^ -> Ctrl
; ! -> Alt
; + -> Shift
; ; -> 单行注释 (single-line comment) 
; ` -> 转义字符 (escape character)
; :: -> 按键映射 (key mapping)
; $ -> 抑制原来的按键
; ~ -> 保留系统原有按键功能
; 原键位::映射到的键位


; 按键交换
LAlt::LCtrl
LCtrl::LAlt
LWin::RAlt
RAlt::LWin

; 快速退出
^q::
send, !{f4}
return


launchOrSwitchEmacs()
{
    IfWinExist ahk_class Emacs
    {
        WinActivate, ahk_class Emacs
    }
    Else
    {
        Run "C:\Program Files\Emacs\x86_64\bin\runemacs.exe"
    }
    Return
}
PrintScreen::launchOrSwitchEmacs()


launchOrSwitchChrome()
{
    IfWinExist ahk_class Chrome_WidgetWin_1
    {
        WinActivate, ahk_class Chrome_WidgetWin_1
    }
    Else
    {
        Run "C:\Program Files\Google\Chrome\Application\chrome.exe"
    }
    Return
}
ScrollLock::launchOrSwitchChrome()
