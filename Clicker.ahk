/*
������ �������� "����������� � �����" ��� ��������� �������

�������� ������� "Clicker(param1, param2)"
1 �������������� �������� (������) - ���� �����:
	false	- ������ ��������� ������������ ������� �������� (�� ���������)
	true	- ����� ������� ����� ������� - ���� �����
2 �������������� �������� (������) - � ������� ��� ���
	false	- ������ ��������� (�� ���������)
	true	- ������ ��������
	
�������� ��������������� � ���������� ���������� DelayMin � DelayMax,
� ����� � SetBatchLines, SetKeyDelay, SetMouseDelay
*/



; ## ## ## ## ## 
; ## ��������

; ��� ��������� ��������� ����������� ������� ������ � ���� � �����
; ����� ������� ��� ���������������, ����� �������� ����� �����
; #IfWinActive ahk_class MyGame

#Warn										; Enable warnings to assist with detecting common errors.
#NoEnv										; ��� ��������� ��������� ������������� � �������� ���������� ���������. 
#SingleInstance			Force				; �������� ������� ����������, ������������
#MaxHotKeysPerInterval	1000000000			; ����������� �� ���-�� ���������� ��������
#MaxThreadsPerHotkey	1					; ���� ���-�� ������� �� ������
#WinActivateForce							; ���������� ����� ������ ����� ��������� ����
#Persistent									; Keeps a script permanently running

	SetBatchLines,			5ms				; �����-�������� ��� -1 (����� ���� ������������)
	SetKeyDelay,			5, 5			; �������� �������� �������
	SetMouseDelay,			5				; �������� ����	  
	SendMode,				Event			; ������ ��������
	SetWorkingDir,			%A_ScriptDir%	; ������������ ������� �����
	DetectHiddenWindows,	on				; ������������ ������� ����
	SetTitleMatchMode,		2				; Sets the matching behavior of the WinTitle parameter in commands such as WinWait.

	global DelayMin			:= 15			; ����������� �������� ����� ��������� �������
	global DelayMax			:= 20			; ������������ �������� ����� ��������� �������
	global SetPause			:= false		; ���������� ���������� ����� (�� �������)
	global 0
	
	/*
	RunAsAdmin()							; ������������ �� ������
	*/
	
	CreateTray()							; ������ ��������� ����
return


; ## ## ## ## ## 
; ## ������� �������

~*sc10:: ; Q
	Clicker(true, true) ; � ������ � ������� (������ ������ ����� ������ �������� �������)
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
	Clicker(true) ; � ������
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
	Clicker(false) ; ��� �����
return


; ## ## ## ## ## 
; ## ���������

; Home
sc147::
PlayScript:
	SetPause := false
	Menu, Tray, Icon, Shell32.dll, 138
	Tooltip("����� ������.")
return

; End
sc14F::
PauseScript:
	SetPause := true
	Menu, Tray, Icon, Shell32.dll, 132
	Tooltip("����� �����������.")
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
; ## �������

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
	Menu, Tray, Tip, % " Home/End - ���������/������������� ������ `n"
					 . " Ctrl+Home - ������������� ������ `n"
					 . " Ctrl+End - ��������� ������ `n"
	Menu, Tray, Add
	Menu, Tray, Add
	Menu, Tray, Add
	Menu, Tray, Add
	Menu, Tray, Add	
	Menu, Tray, Add, ����������� ������ (Home), PlayScript
	Menu, Tray, Add	
	Menu, Tray, Add, ���������� ������ (End), PauseScript
	Menu, Tray, Add
	Menu, Tray, Add, ������������� (Ctrl + Home), ReloadScript
	Menu, Tray, Add
	Menu, Tray, Add, ����� (Ctrl + End), ExitScript
	Menu, Tray, Add
	Menu, Tray, Add
	Menu, Tray, Add
	Menu, Tray, Add
	Menu, Tray, Add
	Menu, Tray, Icon, Shell32.dll, 138
}

RunAsAdmin() {
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
; �������, � ������� ����� ������� ����� ����������:
ListHotkeys
ListVars
Pause
*/