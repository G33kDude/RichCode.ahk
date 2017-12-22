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
		|(#[0-9a-fA-F]{3,8}\b)            ; Color code
		|\b((?:0x[0-9a-fA-F]+|[0-9]+)     ; Numbers
			(?:\s*(?:em|ex|%|px|cm
			|mm|in|pt|pc|ch|rem|vh
			|vw|vmin|vmax|s|deg))?)
		|([+*!~&\/\\<>^|=?:@;
			,().```%{}\[\]\-])            ; Punctuation
		|(""[^""]*""|'[^']*')             ; String
		|([\w-]+\s*(?=:[^:]))             ; Properties
	)"
	
	if (Settings.RTFHeader == "")
		RTFHeader := GenRTFHeader(Settings)
	else
		RTFHeader := Settings.RTFHeader
	
	Pos := 1
	while (FoundPos := RegExMatch(Code, Needle, Match, Pos))
	{
		RTF .= "\cf1 " EscapeRTF(SubStr(Code, Pos, FoundPos-Pos))
		
		; Flat block of if statements for performance
		if (Match.Value(1) != "")
			RTF .= "\cf3"
		else if (Match.Value(2) != "")
			RTF .= "\cf4"
		else if (Match.Value(3) != "")
			RTF .= "\cf6"
		else if (Match.Value(4) != "")
			RTF .= "\cf5"
		else if (Match.Value(5) != "")
			RTF .= "\cf7"
		else if (Match.Value(6) != "")
			RTF .= "\cf10"
		else
			RTF .= "\cf1"
		
		RTF .= " " EscapeRTF(Match.Value())
		Pos := FoundPos + Match.Len()
	}
	
	return RTFHeader . RTF "\cf1 " EscapeRTF(SubStr(Code, Pos)) "\`n}"
}
