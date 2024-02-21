#Include Util.ahk

HighlightJS(Settings, &Code) {
	; Thank you to the Rouge project for compiling these keyword lists
	; https://github.com/jneen/rouge/blob/master/lib/rouge/lexers/javascript.rb
	static Keywords := "for|in|of|while|do|break|return|continue|switch|case|default|if|else|throw|try|catch|finally|new|delete|typeof|instanceof|void|this|yield|import|export|from|as|async|super|this"
	, Declarations := "var|let|const|with|function|class|extends|constructor|get|set"
	, Constants := "true|false|null|NaN|Infinity|undefined"
	, Builtins := "Array|Boolean|Date|Error|Function|Math|netscape|Number|Object|Packages|RegExp|String|sun|decodeURI|decodeURIComponent|encodeURI|encodeURIComponent|Error|eval|isFinite|isNaN|parseFloat|parseInt|document|window|console|navigator|self|global|Promise|Set|Map|WeakSet|WeakMap|Symbol|Proxy|Reflect|Int8Array|Uint8Array|Uint8ClampedArray|Int16Array|Uint16Array|Uint16ClampedArray|Int32Array|Uint32Array|Uint32ClampedArray|Float32Array|Float64Array|DataView|ArrayBuffer"
	, Needle := "
	( LTrim Join Comments
		Dims)
		(\/\/[^\n]+)               ; Comments
		|(\/\*.*?\*\/)             ; Multiline comments
		|([+*!~&\/\\<>^|=?:@;
			,().```%{}\[\]\-]+)    ; Punctuation
		|\b(0x[0-9a-fA-F]+|[0-9]+) ; Numbers
		|("[^"]*"|'[^']*')      ; Strings
		|\b(" Constants ")\b       ; Constants
		|\b(" Keywords ")\b        ; Keywords
		|\b(" Declarations ")\b    ; Declarations
		|\b(" Builtins ")\b        ; Builtins
		|(([a-zA-Z_$]+)(?=\())     ; Functions
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
				Match.1 ? Map.Comments :
				Match.2 ? Map.Multiline :
				Match.3 ? Map.Punctuation :
				Match.4 ? Map.Numbers :
				Match.5 ? Map.Strings :
				Match.6 ? Map.Constants :
				Match.7 ? Map.Keywords :
				Match.8 ? Map.Declarations :
				Match.9 ? Map.Builtins :
				Match.10 ? Map.functions :
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
