#Requires AutoHotkey v2.0

#Include ..\RichCode.ahk
#Include ..\Highlighters\AHK.ahk
#Include ..\Highlighters\CSS.ahk
#Include ..\Highlighters\HTML.ahk
#Include ..\Highlighters\JS.ahk

; Table of supported languages and sample codes for the demo
codes := Map(
	"AHK", {
		Highlighter: HighlightAHK,
		Code: FileRead(A_ScriptFullPath) ;FileOpen(A_ScriptFullPath, "r").Read()
	},
	"HTML", {
		Highlighter: HighlightHTML,
		Code: FileOpen("Language Samples\Sample.html", "r").Read()
	},
	"CSS", {
		Highlighter: HighlightCSS,
		Code: FileOpen("Language Samples\Sample.css", "r").Read()
	},
	"JS", {
		Highlighter: HighlightJS,
		Code: FileOpen("Language Samples\Sample.js", "r").Read()
	},
	"Plain", {
		Highlighter: false,
		Code: FileOpen("Language Samples\Sample.txt", "r").Read()
	}
)

; Settings array for the RichCode control
settings := {
	TabSize: 4,
	Indent: "`t",
	FGColor: 0xEDEDCD,
	BGColor: 0x3F3F3F,
	Font: {Typeface: "Consolas", Size: 11, Bold: false},
	WordWrap: False,
	
	UseHighlighter: True,
	HighlightDelay: 200,
	Colors: {
		Comments:     0x7F9F7F,
		Functions:    0x7CC8CF,
		Keywords:     0xE4EDED,
		Multiline:    0x7F9F7F,
		Numbers:      0xF79B57,
		Punctuation:  0x97C0EB,
		Strings:      0xCC9893,
		
		; AHK
		A_Builtins:   0xF79B57,
		Commands:     0xCDBFA3,
		Directives:   0x7CC8CF,
		Flow:         0xE4EDED,
		KeyNames:     0xCB8DD9,
		
		; CSS
		ColorCodes:   0x7CC8CF,
		Properties:   0xCDBFA3,
		Selectors:    0xE4EDED,
		
		; HTML
		Attributes:   0x7CC8CF,
		Entities:     0xF79B57,
		Tags:         0xCDBFA3,
		
		; JS
		Builtins:     0xE4EDED,
		Constants:    0xF79B57,
		Declarations: 0xCDBFA3
	}
}

; Add some controls
g := Gui()
g.AddDropDownList("vLanguage Choose1", ["AHK", "CSS", "HTML", "JS", "Plain"]).OnEvent("Change", ChangeLang)
g.AddButton("ym", "Block &Comment").OnEvent("Click", BlockComment)
g.AddButton("ym", "Block &Uncomment").OnEvent("Click", BlockUncomment)
g.OnEvent("Close", GuiClose)

; Add the RichCode
rc := RichCode(g, settings, "xm w640 h470")

; Set its starting contents
ChangeLang()

g.Show()


GuiClose(*) {
	global rc

	; Overwrite rc, leaving the only reference from the GUI
	rc := ""

	; Destroy the GUI, freeing the RichCode instance
	g.Destroy()

	; Close the script
	ExitApp
}


BlockComment(*) {
	global language

	; Get the selected language from the GUI
	language := g["Language"].Text

	; Apply an appropriate block comment transformation
	if language == "AHK"
		rc.IndentSelection(false, ";")
	else if language == "HTML"
		rc.SelectedText := "<!-- " rc.SelectedText " -->"
	else if language == "CSS" || language == "JS"
		rc.SelectedText := "/* " rc.SelectedText " */"
}

BlockUncomment(*) {
	global language

	; Get the selected language from the GUI
	language := g["Language"].Text

	; Remove an appropriate block comment transformation
	if language == "AHK"
		rc.IndentSelection(True, ";")
	else if language == "HTML"
		rc.SelectedText := RegExReplace(rc.SelectedText, "s)<!-- ?(.+?) ?-->", "$1")
	else if language == "CSS" || language == "JS"
		rc.SelectedText := RegExReplace(rc.SelectedText, "s)\/\* ?(.+?) ?\*\/", "$1")
}

ChangeLang(*) {
	global language

	; Keep a back up of the contents
	if IsSet(language)
		codes[language].Code := rc.Text

	; Get the selected language from the GUI
	language := g["Language"].Text

	; Set the new highlighter and contents
	rc.Settings.Highlighter := codes[language].Highlighter
	rc.Text := codes[language].Code
}
