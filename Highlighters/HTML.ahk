#Include Util.ahk

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

HighlightHTML(Settings, &Code) {
	static Needle := "
	( LTrim Join Comments
		Dims)
		(\<\!--.*?--\>)       ; Multiline comments
		|(<(?:\/\s*)?)(\w+)   ; Tags
		|([<>\/])             ; Punctuation
		|(&[#\w]+?;)          ; Entities
		|((?<=[>;])[^<>&]+)   ; Text
		|("[^"]*"|'[^']*')    ; Strings
		|(\w+\s*)(=)          ; Attributes
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
				Match.1 ? Map.Multiline " " EscapeRTF(Match.1) :
				Match.2 ?  Map.Punctuation " " EscapeRTF(Match.2) "\cf" Map.Tags " " EscapeRTF(Match.3) :
				Match.4 ? Map.Punctuation " " Match.4 :
				Match.5 ? Map.Entities " " EscapeRTF(Match.5) :
				Match.6 ? Map.Plain " " EscapeRTF(Match.6) :
				Match.7 ? Map.Strings " " EscapeRTF(Match.7) :
				Match.8 ?  Map.Attributes " " EscapeRTF(Match.8) "\cf" Map.Punctuation " " Match.9 :
				Map.Plain
			)
		), Pos := FoundPos + Match.Len()
	}
	
	return Settings.Cache.RTFHeader . RTF
	. "\cf" Map.Plain " " EscapeRTF(SubStr(Code, Pos)) "\`n}"
}
