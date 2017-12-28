#Include %A_LineFile%\..\Util.ahk

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

HighlightCSS(Settings, ByRef Code, RTFHeader:="")
{
	static Needle := "
	( LTrim Join Comments
		ODims)
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
		|(""[^""]*""|'[^']*')             ; Strings
		|([\w-]+\s*(?=:[^:]))             ; Properties
	)"
	
	if !Settings.HasKey("RTFHeader")
		GenRTFHeader(Settings)
	
	Pos := 1
	while (FoundPos := RegExMatch(Code, Needle, Match, Pos))
	{
		RTF .= "\cf" Settings.ColorMap.Plain " "
		RTF .= EscapeRTF(SubStr(Code, Pos, FoundPos-Pos))
		
		; Flat block of if statements for performance
		if (Match.Value(1) != "")
			RTF .= "\cf" Settings.ColorMap.Multiline
		else if (Match.Value(2) != "")
			RTF .= "\cf" Settings.ColorMap.Selectors
		else if (Match.Value(3) != "")
			RTF .= "\cf" Settings.ColorMap.Selectors
		else if (Match.Value(4) != "")
			RTF .= "\cf" Settings.ColorMap.Selectors
		else if (Match.Value(5) != "")
			RTF .= "\cf" Settings.ColorMap.ColorCodes
		else if (Match.Value(6) != "")
			RTF .= "\cf" Settings.ColorMap.Numbers
		else if (Match.Value(7) != "")
			RTF .= "\cf" Settings.ColorMap.Punctuation
		else if (Match.Value(8) != "")
			RTF .= "\cf" Settings.ColorMap.Strings
		else if (Match.Value(9) != "")
			RTF .= "\cf" Settings.ColorMap.Properties
		else
			RTF .= "\cf" Settings.ColorMap.Plain
		
		RTF .= " " EscapeRTF(Match.Value())
		Pos := FoundPos + Match.Len()
	}
	
	return Settings.RTFHeader . RTF
	. "\cf" Settings.ColorMap.Plain " " EscapeRTF(SubStr(Code, Pos)) "\`n}"
}
