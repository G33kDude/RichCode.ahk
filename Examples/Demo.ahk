#NoEnv
SetBatchLines, -1
SetWorkingDir, %A_ScriptDir%

#Include %A_ScriptDir%\..
#Include RichCode.ahk
#Include Highlighters\AHK.ahk
#Include Highlighters\CSS.ahk
#Include Highlighters\HTML.ahk
#Include Highlighters\JS.ahk

; Table of supported languages and sample codes for the demo
Codes :=
( LTrim Join
{
	"AHK": {
		"Highlighter": "HighlightAHK",
		"Code": FileOpen(A_ScriptFullPath, "r").Read()
	},
	"HTML": {
		"Highlighter": "HighlightHTML",
		"Code": FileOpen("Language Samples\Sample.html", "r").Read()
	},
	"CSS": {
		"Highlighter": "HighlightCSS",
		"Code": FileOpen("Language Samples\Sample.css", "r").Read()
	},
	"JS": {
		"Highlighter": "HighlightJS",
		"Code": FileOpen("Language Samples\Sample.js", "r").Read()
	},
	"Plain": {
		"Highlighter": "",
		"Code": FileOpen("Language Samples\Sample.txt", "r").Read()
	}
}
)

; Settings array for the RichCode control
Settings :=
( LTrim Join Comments
{
	"TabSize": 4,
	"Indent": "`t",
	"FGColor": 0xEDEDCD,
	"BGColor": 0x3F3F3F,
	"Font": {"Typeface": "Consolas", "Size": 11},
	
	"UseHighlighter": True,
	"HighlightDelay": 200,
	"Colors": [
		; RRGGBB  ;    ; AHK                ; HTML
		0x7F9F7F, ;  1 ; Comments           ; NOT USED
		0x7F9F7F, ;  2 ; Multiline comments ; Multiline Comments
		0x7CC8CF, ;  3 ; Directives         ; Attributes
		0x97C0EB, ;  4 ; Punctuation        ; Punctuation
		0xF79B57, ;  5 ; Numbers            ; Numbers
		0xCC9893, ;  6 ; Strings            ; Strings
		0xF79B57, ;  7 ; A_Builtins         ; &Entities;
		0xE4EDED, ;  8 ; Flow               ; NOT USED
		0xCDBFA3, ;  9 ; Commands           ; Tags
		0x7CC8CF, ; 10 ; Functions          ; NOT USED
		0xCB8DD9, ; 11 ; Key names          ; NOT USED
		0xE4EDED  ; 12 ; Other keywords     ; NOT USED
	]
}
)

; Precompute and cache the RTF header for the highlighters
; (optional performance enhancement)
Settings.RTFHeader := GenRTFHeader(Settings)

; Add some controls
Gui, Add, DropDownList, gChangeLang vLanguage, AHK||CSS|HTML|JS|Plain
Gui, Add, Button, ym gBlockComment, Block &Comment
Gui, Add, Button, ym gBlockUncomment, Block &Uncomment

; Add the RichCode
RC := new RichCode(Settings.Clone(), "xm w640 h470")
GuiControl, Focus, % RC.hWnd

; Set its starting contents
GoSub, ChangeLang

Gui, Show
return


GuiClose:
; Overwrite RC, leaving the only reference from the GUI
RC := ""

; Destroy the GUI, freeing the RichCode instance
Gui, Destroy

; Close the script
ExitApp
return


BlockComment:
; Get the selected language from the GUI
GuiControlGet, Language

; Apply an appropriate block comment transformation
if (Language == "AHK")
	RC.IndentSelection(False, ";")
else if (Language == "HTML")
	RC.SelectedText := "<!-- " RC.SelectedText " -->"
else if (Language == "CSS" || Language == "JS")
	RC.SelectedText := "/* " RC.SelectedText " */"
return

BlockUncomment:
; Get the selected language from the GUI
GuiControlGet, Language

; Remove an appropriate block comment transformation
if (Language == "AHK")
	RC.IndentSelection(True, ";")
else if (Language == "HTML")
	RC.SelectedText := RegExReplace(RC.SelectedText, "s)<!-- ?(.+?) ?-->", "$1")
else if (Language == "CSS" || Language == "JS")
	RC.SelectedText := RegExReplace(RC.SelectedText, "s)\/\* ?(.+?) ?\*\/", "$1")
return

ChangeLang:
; Keep a back up of the contents
if Language
	Codes[Language].Code := RC.Value

; Get the selected language from the GUI
GuiControlGet, Language

; Set the new highlighter and contents
RC.Settings.Highlighter := Codes[Language].Highlighter
RC.Value := Codes[Language].Code
return
