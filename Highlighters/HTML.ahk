#Include %A_LineFile%\..\Util.ahk

/*
	Colors indices used:
	
	1: NOT USED
	2: Multiline Comments
	3: Attributes
	4: Punctuation
	5: Numbers
	6: Strings
	7: &Entities;
	8: NOT USED
	9: Tags
*/

HighlightHTML(Settings, ByRef Code, RTFHeader:="")
{
	static Needle := "
	( LTrim Join Comments
		ODims)
		(\<\!--.*?--\>)       ; Multiline comments
		|(<(?:\/\s*)?)(\w+)   ; Tag
		|([<>\/])             ; Punctuation
		|(&\w+?;)             ; Entities
		|((?<=[>;])[^<>&]+)   ; Text
		|(""[^""]*""|'[^']*') ; String
		|(\w+\s*)(=)          ; Attribute
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
			RTF .= "\cf3 " EscapeRTF(Match.Value(1))
		else if (Match.Value(2) != "")
			RTF .= "\cf5 " EscapeRTF(Match.Value(2)) "\cf10 " EscapeRTF(Match.Value(3))
		else if (Match.Value(4) != "")
			RTF .= "\cf5 " Match.Value(4)
		else if (Match.Value(5) != "")
			RTF .= "\cf8 " EscapeRTF(Match.Value(5))
		else if (Match.Value(6) != "")
			RTF .= "\cf1 " EscapeRTF(Match.Value(6))
		else if (Match.Value(7) != "")
			RTF .= "\cf7 " EscapeRTF(Match.Value(7))
		else if (Match.Value(8) != "")
			RTF .= "\cf4 " EscapeRTF(Match.Value(8)) "\cf5 " Match.Value(9)
		
		Pos := FoundPos + Match.Len()
	}
	
	return RTFHeader . RTF "\cf1 " EscapeRTF(SubStr(Code, Pos)) "\`n}"
}
