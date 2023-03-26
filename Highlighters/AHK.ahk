#Include %A_LineFile%\..\Util.ahk

class HighlightAHK {
	static flow := "if|else|loop|loop files|loop parse|loop read|loop reg|while|for|continue|break|until|try|throw|"
		. "catch|finally|class|global|local|static|return|goto"
	static library := (
		"Abs|ACos|ASin|ATan|BlockInput|Break|Buffer|CallbackCreate|CallbackFree|CaretGetPos|Catch|Ceil|Chr|Click|"
		"ClipboardAll|ClipWait|ComCall|ComObjActive|ComObjArray|ComObjConnect|ComObject|ComObjFlags|ComObjFromPtr|"
		"ComObjGet|ComObjQuery|ComObjType|ComObjValue|ComValue|Continue|ControlAddItem|ControlChooseIndex|"
		"ControlChooseString|ControlClick|ControlDeleteItem|ControlFindItem|ControlFocus|ControlGetChecked|"
		"ControlGetChoice|ControlGetClassNN|ControlGetEnabled|ControlGetFocus|ControlGetHwnd|ControlGetIndex|"
		"ControlGetItems|ControlGetPos|ControlGetStyle|ControlGetText|ControlGetVisible|ControlHide|"
		"ControlHideDropDown|ControlMove|ControlSend|ControlSetChecked|ControlSetEnabled|ControlSetStyle|"
		"ControlSetText|ControlShow|ControlShowDropDown|CoordMode|Cos|Critical|DateAdd|DateDiff|DetectHiddenText|"
		"DetectHiddenWindows|DirCopy|DirCreate|DirDelete|DirExist|DirMove|DirSelect|DllCall|Download|DriveEject|"
		"DriveGetCapacity|DriveGetFileSystem|DriveGetLabel|DriveGetList|DriveGetSerial|DriveGetSpaceFree|"
		"DriveGetStatus|DriveGetStatusCD|DriveGetType|DriveLock|DriveRetract|DriveSetLabel|DriveUnlock|Edit|"
		"EditGetCurrentCol|EditGetCurrentLine|EditGetLine|EditGetLineCount|EditGetSelectedText|EditPaste|Else|EnvGet|"
		"EnvSet|Exit|ExitApp|Exp|FileAppend|FileCopy|FileCreateShortcut|FileDelete|FileEncoding|FileExist|"
		"FileGetAttrib|FileGetShortcut|FileGetSize|FileGetTime|FileGetVersion|FileInstall|FileMove|FileOpen|FileRead|"
		"FileRecycle|FileRecycleEmpty|FileSelect|FileSetAttrib|FileSetTime|Finally|Float|Floor|For|Format|FormatTime|"
		"GetKeyName|GetKeySC|GetKeyState|GetKeyVK|GetMethod|Goto|GroupActivate|GroupAdd|GroupClose|GroupDeactivate|Gui|"
		"GuiCtrlFromHwnd|GuiFromHwnd|HasBase|HasMethod|HasProp|HotIf|Hotkey|Hotstring|If|IL_Add|IL_Create|IL_Destroy|"
		"ImageSearch|IniDelete|IniRead|IniWrite|InputBox|InputHook|InstallKeybdHook|InstallMouseHook|InStr|Integer|"
		"IsLabel|IsObject|IsSet|KeyHistory|KeyWait|ListHotkeys|ListLines|ListVars|ListViewGetContent|Ln|LoadPicture|"
		"Log|Loop|Map|Max|Menu|MenuBar|MenuFromHandle|MenuSelect|Min|Mod|MonitorGet|MonitorGetCount|MonitorGetName|"
		"MonitorGetPrimary|MonitorGetWorkArea|MouseClick|MouseClickDrag|MouseGetPos|MouseMove|MsgBox|Number|NumGet|"
		"NumPut|ObjAddRef|ObjBindMethod|ObjGetBase|ObjGetCapacity|ObjHasOwnProp|ObjOwnPropCount|ObjOwnProps|ObjSetBase|"
		"ObjSetCapacity|OnClipboardChange|OnError|OnExit|OnMessage|Ord|OutputDebug|Pause|Persistent|PixelGetColor|"
		"PixelSearch|PostMessage|ProcessClose|ProcessExist|ProcessGetName|ProcessGetParent|ProcessGetPath|"
		"ProcessSetPriority|ProcessWait|ProcessWaitClose|Random|RegCreateKey|RegDelete|RegDeleteKey|RegExMatch|"
		"RegExReplace|RegRead|RegWrite|Reload|Return|Round|Run|RunAs|RunWait|Send|SendEvent|SendInput|SendLevel|"
		"SendMessage|SendMode|SendPlay|SendText|SetCapsLockState|SetControlDelay|SetDefaultMouseSpeed|SetKeyDelay|"
		"SetMouseDelay|SetNumLockState|SetRegView|SetScrollLockState|SetStoreCapsLockMode|SetTimer|SetTitleMatchMode|"
		"SetWinDelay|SetWorkingDir|Shutdown|Sin|Sleep|Sort|SoundBeep|SoundGetInterface|SoundGetMute|SoundGetName|"
		"SoundGetVolume|SoundPlay|SoundSetMute|SoundSetVolume|SplitPath|Sqrt|StatusBarGetText|StatusBarWait|StrCompare|"
		"StrGet|String|StrLen|StrLower|StrPtr|StrPut|StrReplace|StrSplit|StrUpper|SubStr|Suspend|Switch|SysGet|"
		"SysGetIPAddresses|Tan|Thread|Throw|ToolTip|TraySetIcon|TrayTip|Trim|Try|Type|Until|VarSetStrCapacity|"
		"VerCompare|While|WinActivate|WinActivateBottom|WinActive|WinClose|WinExist|WinGetClass|WinGetClientPos|"
		"WinGetControls|WinGetControlsHwnd|WinGetCount|WinGetID|WinGetIDLast|WinGetList|WinGetMinMax|WinGetPID|"
		"WinGetPos|WinGetProcessName|WinGetProcessPath|WinGetStyle|WinGetText|WinGetTitle|WinGetTransColor|"
		"WinGetTransparent|WinHide|WinKill|WinMaximize|WinMinimize|WinMinimizeAll|WinMove|WinMoveBottom|WinMoveTop|"
		"WinRedraw|WinRestore|WinSetAlwaysOnTop|WinSetEnabled|WinSetRegion|WinSetStyle|WinSetTitle|WinSetTransColor|"
		"WinSetTransparent|WinShow|WinWait|WinWaitActive|WinWaitClose"
	)
	static keynames := (
		"alt|altdown|altup|appskey|backspace|blind|browser_back|browser_favorites|browser_forward|browser_home|"
		"browser_refresh|browser_search|browser_stop|bs|capslock|click|control|ctrl|ctrlbreak|ctrldown|ctrlup|del|"
		"delete|down|end|enter|esc|escape|f1|f10|f11|f12|f13|f14|f15|f16|f17|f18|f19|f2|f20|f21|f22|f23|f24|f3|f4|f5|"
		"f6|f7|f8|f9|home|ins|insert|joy1|joy10|joy11|joy12|joy13|joy14|joy15|joy16|joy17|joy18|joy19|joy2|joy20|joy21|"
		"joy22|joy23|joy24|joy25|joy26|joy27|joy28|joy29|joy3|joy30|joy31|joy32|joy4|joy5|joy6|joy7|joy8|joy9|joyaxes|"
		"joybuttons|joyinfo|joyname|joypov|joyr|joyu|joyv|joyx|joyy|joyz|lalt|launch_app1|launch_app2|launch_mail|"
		"launch_media|lbutton|lcontrol|lctrl|left|lshift|lwin|lwindown|lwinup|mbutton|media_next|media_play_pause|"
		"media_prev|media_stop|numlock|numpad0|numpad1|numpad2|numpad3|numpad4|numpad5|numpad6|numpad7|numpad8|numpad9|"
		"numpadadd|numpadclear|numpaddel|numpaddiv|numpaddot|numpaddown|numpadend|numpadenter|numpadhome|numpadins|"
		"numpadleft|numpadmult|numpadpgdn|numpadpgup|numpadright|numpadsub|numpadup|pause|pgdn|pgup|printscreen|ralt|"
		"raw|rbutton|rcontrol|rctrl|right|rshift|rwin|rwindown|rwinup|scrolllock|shift|shiftdown|shiftup|space|tab|up|"
		"volume_down|volume_mute|volume_up|wheeldown|wheelleft|wheelright|wheelup|xbutton1|xbutton2"
	)
	static builtins := "A_\w+|true|false|this|super"
	static needle := (
		"ims)"
		"((?:^|\s);[^\n]+)"          ; Comments
		"|(^\s*/\*.*?(?:^\s*\*\/|\*/\s*$|\z))"    ; Multiline comments
		"|(^\s*#\w+\b(?!:)(?:(?<!HotIf)[^\n]*)?)" ; Directives
		"|([$#+*!~&/\\<>^|=?:,().``%}{\[\]\-]+)"   ; Punctuation
		"|\b(0x[0-9a-fA-F]+|[0-9]+)" ; Numbers
		"|('[^'\n]*'|" . '"[^"\n]*")' ; Strings
		"|\b(" this.builtins ")\b"  ; A_Builtins
		"|\b(" this.flow ")\b"            ; Flow
		"|\b(" this.library ")(?!\()\b"       ; Commands
		"|\b(" this.keynames ")\b"        ; Keynames
		; "|\b(" this.keywords ")\b"        ; Other keywords
		"|(\w+(?=\())"     ; Functions
	)

	static Call(Settings, &Code) {
		GenHighlighterCache(Settings)
		Map := Settings.Cache.ColorMap

		rtf := ""
		Pos := 1
		while FoundPos := RegExMatch(Code, this.needle, &Match, Pos) {
			RTF .= (
				"\cf" Map.Plain " "
				EscapeRTF(SubStr(Code, Pos, FoundPos - Pos))
				"\cf" (
					Match.1 != "" && Map.Comments ||
					Match.2 != "" && Map.Multiline ||
					Match.3 != "" && Map.Directives ||
					Match.4 != "" && Map.Punctuation ||
					Match.5 != "" && Map.Numbers ||
					Match.6 != "" && Map.Strings ||
					Match.7 != "" && Map.A_Builtins ||
					Match.8 != "" && Map.Flow ||
					Match.9 != "" && Map.Commands ||
					Match.10 != "" && Map.Keynames ||
					; Match.11 != "" && Map.Keywords ||
					Match.11 != "" && Map.Functions ||
					Map.Plain
				) " "
				EscapeRTF(Match.0)
			), Pos := FoundPos + Match.Len
		}

		return Settings.Cache.RTFHeader . RTF
			. "\cf" Map.Plain " " EscapeRTF(SubStr(Code, Pos)) "\`n}"
	}
}