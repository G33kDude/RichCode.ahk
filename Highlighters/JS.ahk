#Include %A_LineFile%\..\Util.ahk

/*
	Colors indices used:
	
	1:  Comments
	2:  Multiline comments
	3:  Functions
	4:  Punctuation
	5:  Numbers
	6:  Strings
	7:  Constants
	8:  Keywords
	9:  Declarations
	10: NOT USED
	11: NOT USED
	12: Builtins
*/

HighlightJS(Settings, ByRef Code)
{
	; Thank you to the Rouge project for compiling these keyword lists
	; https://github.com/jneen/rouge/blob/master/lib/rouge/lexers/javascript.rb
	static Keywords := "for|in|of|while|do|break|return|continue|switch|case|default|if|else|throw|try|catch|finally|new|delete|typeof|instanceof|void|this|yield|import|export|from|as|async|super|this"
	, Declarations := "var|let|const|with|function|class|extends|constructor|get|set"
	, Constants := "true|false|null|NaN|Infinity|undefined"
	, Builtins := "Array|Boolean|Date|Error|Function|Math|netscape|Number|Object|Packages|RegExp|String|sun|decodeURI|decodeURIComponent|encodeURI|encodeURIComponent|Error|eval|isFinite|isNaN|parseFloat|parseInt|document|window|console|navigator|self|global|Promise|Set|Map|WeakSet|WeakMap|Symbol|Proxy|Reflect|Int8Array|Uint8Array|Uint8ClampedArray|Int16Array|Uint16Array|Uint16ClampedArray|Int32Array|Uint32Array|Uint32ClampedArray|Float32Array|Float64Array|DataView|ArrayBuffer"
	, Needle := "
	( LTrim Join Comments
		ODims)
		(\/\/[^\n]+)               ; Comments
		|(\/\*.*?\*\/)             ; Multiline comments
		|([+*!~&\/\\<>^|=?:@;
			,().```%{}\[\]\-]+)    ; Punctuation
		|\b(0x[0-9a-fA-F]+|[0-9]+) ; Numbers
		|(""[^""]*""|'[^']*')      ; Strings
		|\b(" Constants ")\b       ; Constants
		|\b(" Keywords ")\b        ; Keywords
		|\b(" Declarations ")\b    ; Declarations
		|\b(" Builtins ")\b        ; Builtins
		|(([a-zA-Z_$]+)(?=\())     ; Functions
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
			RTF .= "\cf2"
		else if (Match.Value(2) != "")
			RTF .= "\cf3"
		else if (Match.Value(3) != "")
			RTF .= "\cf5"
		else if (Match.Value(4) != "")
			RTF .= "\cf6"
		else if (Match.Value(5) != "")
			RTF .= "\cf7"
		else if (Match.Value(6) != "")
			RTF .= "\cf8"
		else if (Match.Value(7) != "")
			RTF .= "\cf9"
		else if (Match.Value(8) != "")
			RTF .= "\cf10"
		else if (Match.Value(9) != "")
			RTF .= "\cf13"
		else if (Match.Value(10) != "")
			RTF .= "\cf4"
		else
			RTF .= "\cf1"
		
		RTF .= " " EscapeRTF(Match.Value())
		Pos := FoundPos + Match.Len()
	}
	
	return RTFHeader . RTF "\cf1 " EscapeRTF(SubStr(Code, Pos)) "\`n}"
}
