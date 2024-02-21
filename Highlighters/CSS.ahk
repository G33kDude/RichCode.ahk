#Include Util.ahk

/*
	Colors indices used:
	
	1: NOT USED
	2: Multiline Comments
	3: Hex Color Codes
	4: Punctuation
	5: Numbers
	6: Strings
	7: NOT USED
	8: NOT USED
	9: Properties
*/

HighlightCSS(Settings, &Code) {
	static Needle := "
	( LTrim Join Comments
		Dims)
		(\/\*.*?\*\/)                     ; Multiline comments
		|(\.[a-zA-Z_\-0-9]+)(?=[^}]*\{)   ; Classes
		|(\#[a-zA-Z_\-0-9]+)(?=[^}]*\{)   ; IDs
		|([a-zA-Z]+)(?=[^}]*\{)           ; Normal elements
		|(#[0-9a-fA-F]{3,8}\b)            ; Color codes
		|\b((?:0x[0-9a-fA-F]+|[0-9]+)     ; Numbers
			(?:\s*(?:em|ex|%|px|cm
			|mm|in|pt|pc|ch|rem|vh
			|vw|vmin|vmax|s|deg))?)
		|([+*!~&\/\\<>^|=?:@;
			,().```%{}\[\]\-])            ; Punctuation
		|("[^"]*"|'[^']*')                ; Strings
		|([\w-]+\s*(?=:[^:]))             ; Properties
	)"
	
	GenHighlighterCache(Settings)
	Map := Settings.Cache.ColorMap
	
	rtf := ""
	Pos := 1
	while FoundPos := RegExMatch(Code, Needle, &Match, Pos) {
		RTF .= (
			"\cf" Map.Plain " "
			EscapeRTF(SubStr(Code, Pos, FoundPos - Pos))
			"\cf" (
				Match.1 ? Map.Multiline :
				Match.2 ? Map.Selectors :
				Match.3 ? Map.Selectors :
				Match.4 ? Map.Selectors :
				Match.5 ? Map.ColorCodes :
				Match.6 ? Map.Numbers :
				Match.7 ? Map.Punctuation :
				Match.8 ? Map.Strings :
				Match.9 ? Map.Properties :
				Map.Plain
			) " "
			EscapeRTF(Match.0)
		), Pos := FoundPos + Match.Len()
	}
	
	return (
		Settings.Cache.RTFHeader
		RTF
		"\cf" Map.Plain " "
		EscapeRTF(SubStr(Code, Pos))
		"\`n}"
	)
}
