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
		|(&[#\w]+?;)          ; Entities
		|((?<=[>;])[^<>&]+)   ; Text
		|(""[^""]*""|'[^']*') ; String
		|(\w+\s*)(=)          ; Attribute
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
			RTF .= "\cf" Settings.ColorMap.Multiline " " EscapeRTF(Match.Value(1))
		else if (Match.Value(2) != "")
		{
			RTF .= "\cf" Settings.ColorMap.Punctuation " " EscapeRTF(Match.Value(2))
			RTF .= "\cf" Settings.ColorMap.Tags " " EscapeRTF(Match.Value(3))
		}
		else if (Match.Value(4) != "")
			RTF .= "\cf" Settings.ColorMap.Punctuation " " Match.Value(4)
		else if (Match.Value(5) != "")
			RTF .= "\cf" Settings.ColorMap.Entities " " EscapeRTF(Match.Value(5))
		else if (Match.Value(6) != "")
			RTF .= "\cf" Settings.ColorMap.Plain " " EscapeRTF(Match.Value(6))
		else if (Match.Value(7) != "")
			RTF .= "\cf" Settings.ColorMap.Strings " " EscapeRTF(Match.Value(7))
		else if (Match.Value(8) != "")
		{
			RTF .= "\cf" Settings.ColorMap.Attributes " " EscapeRTF(Match.Value(8))
			RTF .= "\cf" Settings.ColorMap.Punctuation " " Match.Value(9)
		}
		
		Pos := FoundPos + Match.Len()
	}
	
	return Settings.RTFHeader . RTF
	. "\cf" Settings.ColorMap.Plain " " EscapeRTF(SubStr(Code, Pos)) "\`n}"
}
