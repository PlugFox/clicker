/*
 * Скрипт помогает "закликивать в играх" при удержании клавиши
 * 
 * Вызывать функцию "Clicker(param1, param2)"
 * 1 необязательный параметр (булево) - клик мышью:
 *     false   - только совершать закликивание нажатой клавишей (по умолчанию)
 *     true    - после каждого клика кнопкой - клик мышью
 * 2 необязательный параметр (булево) - с тряской или без
 *     false   - тряска отключена (по умолчанию)
 *     true    - тряска включена
 *     
 * Задержки устанавливаются в глобальных переменных DelayMin и DelayMax,
 *  а также в SetBatchLines, SetKeyDelay, SetMouseDelay
 */



; ## ## ## ## ## 
; ## Основное

; Эта деректива позволяет исполняться скрипту только в окне с игрой
; Можно стереть или закоментировать, тогда работать будет везде
; #IfWinActive ahk_class MyGame

#Warn                                  ; Enable warnings to assist with detecting common errors.
#NoEnv                                 ; Эта директива запрещает использование в скриптах переменных окружения. 
#SingleInstance           Force        ; Заменять текущее приложение, запускаемыми
#MaxHotKeysPerInterval    1000000000   ; Ограничение на кол-во посылаемых символов
#MaxThreadsPerHotkey      1            ; Макс кол-во потоков на кнопку
#WinActivateForce                      ; Пропустить более мягкий метод активации окна
#Persistent                            ; Keeps a script permanently running

    SetBatchLines,       5ms           ; Супер-скорость при -1 (могут быть пролагивания)
    SetKeyDelay,         5, 5          ; Скорость эмуляции клавиши
    SetMouseDelay,       5             ; Скорость мыши      
    SendMode,            Event         ; Способ эмуляции
    SetWorkingDir,       %A_ScriptDir% ; Устанавливаю рабочую папку
    DetectHiddenWindows, on            ; Обнаруживать скрытые окна
    SetTitleMatchMode,   2             ; Sets the matching behavior of the WinTitle parameter in commands such as WinWait.

    global DelayMin      := 15         ; Минимальная задержка между проходами кликера
    global DelayMax      := 20         ; Максимальная задержка между проходами кликера
    global SetPause      := false      ; Глобальная переменная паузы (не трогать)
    global 0
    
    /*
    */
    RunAsAdmin()                       ; Перезапускаю от админа
    
    CreateTray()                       ; Создаю параметры трэя
return


; ## ## ## ## ## 
; ## Горячие клавиши

~*sc10:: ; Q
    Clicker(true, true) ; С кликом и тряской (иногда тряска может помочь работать быстрее)
return

~*F1::
~*F2::
~*F3::
~*F4::

~*sc11:: ; W
~*sc12:: ; E
~*sc13:: ; R

~*sc1E:: ; A
~*sc1F:: ; S
~*sc20:: ; D
~*sc21:: ; F
    Clicker(true) ; С кликом
return

~*1:: ; 1
~*2:: ; 2
~*3:: ; 3
~*4:: ; 4
~*5:: ; 5
~*6:: ; 6

~*sc2C:: ; Z
~*sc2D:: ; X
~*sc2E:: ; C
~*sc2F:: ; V
    Clicker(false) ; Без клика
return


; ## ## ## ## ## 
; ## Настройки

; Home
sc147::
PlayScript:
    SetPause := false
    Menu, Tray, Icon, Shell32.dll, 138
    Tooltip("Pause removed.")
return

; End
sc14F::
PauseScript:
    SetPause := true
    Menu, Tray, Icon, Shell32.dll, 132
    Tooltip("Pause set.")
return

; Ctrl + Home
^sc147::
ReloadScript:
    Reload
return

; Ctrl + End
^sc14F::
ExitScript:
    ExitApp
return


; ## ## ## ## ##
; ## Функции

RemoveToolTip:
    SetTimer, RemoveToolTip, Off
    ToolTip
return

Tooltip(text) {
    ToolTip, %text%, A_ScreenWidth-150, A_ScreenHeight-75
    SetTimer, RemoveToolTip, 5000    
}

Clicker(WithClick = false, ShakeMouse = false) {
    if SetPause
        return
    Key := RegExReplace(A_ThisHotkey, "[^a-zA-Z0-9]")
    if WithClick
        Click
    Sleep, 250    
    if not GetKeyState(Key, "P")
        return
    Counter := 0
    Loop
    {
        if not GetKeyState(Key, "P")
            break
        Counter := Counter + 1
        Send, {%Key%}
        if WithClick 
            {
                Click
                if ShakeMouse
                    MouseMove, 0, % ((Mod(Counter,3)-1)*5), 1, R
            }
        Random, Delay, DelayMin, DelayMax
        sleep, %Delay% 
    }
}

CreateTray() {    
    Menu, Tray, NoStandard
    Menu, Tray, Tip, % " Home/End  - start / pause clicker `n"
                     . " Ctrl+Home - restart clicker `n"
                     . " Ctrl+End  - turn off clicker `n"
    Menu, Tray, Add
    Menu, Tray, Add
    Menu, Tray, Add
    Menu, Tray, Add
    Menu, Tray, Add    
    Menu, Tray, Add, Resume script (Home), PlayScript
    Menu, Tray, Add    
    Menu, Tray, Add, Stop script (End), PauseScript
    Menu, Tray, Add
    Menu, Tray, Add, Restart (Ctrl + Home), ReloadScript
    Menu, Tray, Add
    Menu, Tray, Add, Close (Ctrl + End), ExitScript
    Menu, Tray, Add
    Menu, Tray, Add
    Menu, Tray, Add
    Menu, Tray, Add
    Menu, Tray, Add
    Menu, Tray, Icon, Shell32.dll, 138
}

RunAsAdmin() {
    params := " "
    Loop, %0%  ; For each parameter:
    {
        param := %A_Index%  ; Fetch the contents of the variable whose name is contained in A_Index.
        params .= A_Space . param
    }
    ShellExecute := A_IsUnicode ? "shell32\ShellExecute":"shell32\ShellExecuteA"

    if not A_IsAdmin
    {
        If A_IsCompiled
            DllCall(ShellExecute, uint, 0, str, "RunAs", str, A_ScriptFullPath, str, params , str, A_WorkingDir, int, 1)
        Else
            DllCall(ShellExecute, uint, 0, str, "RunAs", str, A_AhkPath, str, """" . A_ScriptFullPath . """" . A_Space . params, str, A_WorkingDir, int, 1)
        ExitApp
    }
}


/*
 * ; Отладка, в скрипте будут созданы точки прерывания:
 * ListHotkeys
 * ListVars
 * Pause
 */