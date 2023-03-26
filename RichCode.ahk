/*
	class RichCode({"TabSize": 4     ; Width of a tab in characters
		, "Indent": "`t"             ; What text to insert on indent
		, "FGColor": 0xRRGGBB        ; Foreground (text) color
		, "BGColor": 0xRRGGBB        ; Background color
		, "Font"                     ; Font to use
		: {"Typeface": "Courier New" ; Name of the typeface
			, "Size": 12             ; Font size in points
			, "Bold": False}         ; Bolded (True/False)


		; Whether to use the highlighter, or leave it as plain text
		, "UseHighlighter": True

		; Delay after typing before the highlighter is run
		, "HighlightDelay": 200

		; The highlighter function (FuncObj or name)
		; to generate the highlighted RTF. It will be passed
		; two parameters, the first being this settings array
		; and the second being the code to be highlighted
		, "Highlighter": Func("HighlightAHK")

		; The colors to be used by the highlighter function.
		; This is currently used only by the highlighter, not at all by the
		; RichCode class. As such, the RGB ordering is by convention only.
		; You can add as many colors to this array as you want.
		, "Colors"
		: [0xRRGGBB
			, 0xRRGGBB
			, 0xRRGGBB,
			, 0xRRGGBB]})
*/

class RichCode
{
	#DllLoad "msftedit.dll"
	static IID_ITextDocument := "{8CC497C0-A1DF-11CE-8098-00AA0047BE5D}"
	static MenuItems := ["Cut", "Copy", "Paste", "Delete", "", "Select All", ""
		, "UPPERCASE", "lowercase", "TitleCase"]

	_Frozen := False

	/** @type {Gui.Custom} the underlying control */
	_control := {}

	Settings := {}

	gutter := { Hwnd: 0 }

	; --- Static Methods ---

	static BGRFromRGB(RGB) => RGB >> 16 & 0xFF | RGB & 0xFF00 | RGB << 16 & 0xFF0000

	; --- Properties ---

	Text {
		get => StrReplace(this._control.Text, "`r")
		set => (this.Highlight(Value), Value)
	}

	; TODO: reserve and reuse memory
	selection[i := 0] {
		get => (
			this.SendMsg(0x434, 0, charrange := Buffer(8)), ; EM_EXGETSEL
			out := [NumGet(charrange, 0, "Int"), NumGet(charrange, 4, "Int")],
			i ? out[i] : out
		)

		set => (
			i ? (t := this.selection, t[i] := Value, Value := t) : "",
			NumPut("Int", Value[1], "Int", Value[2], charrange := Buffer(8)),
			this.SendMsg(0x437, 0, charrange), ; EM_EXSETSEL
			Value
		)
	}

	SelectedText {
		get {
			Selection := this.selection
			length := selection[2] - selection[1]
			b := Buffer((length + 1) * 2)
			if this.SendMsg(0x43E, 0, b) > length ; EM_GETSELTEXT
				throw Error("Text larger than selection! Buffer overflow!")
			text := StrGet(b, length, "UTF-16")
			return StrReplace(text, "`r", "`n")
		}

		set {
			this.SendMsg(0xC2, 1, StrPtr(Value)) ; EM_REPLACESEL
			this.Selection[1] -= StrLen(Value)
			return Value
		}
	}

	EventMask {
		get => this._EventMask

		set {
			this._EventMask := Value
			this.SendMsg(0x445, 0, Value) ; EM_SETEVENTMASK
			return Value
		}
	}

	_UndoSuspended := false
	UndoSuspended {
		get {
			return this._UndoSuspended
		}

		set {
			try { ; ITextDocument is not implemented in WINE
				if Value
					this.ITextDocument.Undo(-9999995) ; tomSuspend
				else
					this.ITextDocument.Undo(-9999994) ; tomResume
			}
			return this._UndoSuspended := !!Value
		}
	}

	Frozen {
		get => this._Frozen

		set {
			if (Value && !this._Frozen)
			{
				try ; ITextDocument is not implemented in WINE
					this.ITextDocument.Freeze()
				catch
					this._control.Opt "-Redraw"
			}
			else if (!Value && this._Frozen)
			{
				try ; ITextDocument is not implemented in WINE
					this.ITextDocument.Unfreeze()
				catch
					this._control.Opt "+Redraw"
			}
			return this._Frozen := !!Value
		}
	}

	Modified {
		get {
			return this.SendMsg(0xB8, 0, 0) ; EM_GETMODIFY
		}

		set {
			this.SendMsg(0xB9, Value, 0) ; EM_SETMODIFY
			return Value
		}
	}

	; --- Construction, Destruction, Meta-Functions ---

	__New(gui, Settings, Options := "")
	{
		this.__Set := this.___Set
		this.Settings := Settings
		FGColor := RichCode.BGRFromRGB(Settings.FGColor)
		BGColor := RichCode.BGRFromRGB(Settings.BGColor)

		this._control := gui.AddCustom("ClassRichEdit50W +0x5031b1c4 +E0x20000 " Options)

		; Enable WordWrap in RichEdit control ("WordWrap" : true)
		if this.Settings.HasOwnProp("WordWrap")
			this.SendMsg(0x448, 0, 0)

		; Register for WM_COMMAND and WM_NOTIFY events
		; NOTE: this prevents garbage collection of
		; the class until the control is destroyed
		this.EventMask := 1 ; ENM_CHANGE
		this._control.OnCommand 0x300, this.CtrlChanged.Bind(this)

		; Set background color
		this.SendMsg(0x443, 0, BGColor) ; EM_SETBKGNDCOLOR

		; Set character format
		f := settings.font
		cf2 := Buffer(116, 0)
		NumPut("UInt", 116, cf2, 0)          ; cbSize      = sizeof(CF2)
		NumPut("UInt", 0xE << 28, cf2, 4)    ; dwMask      = CFM_COLOR|CFM_FACE|CFM_SIZE
		NumPut("UInt", f.Size * 20, cf2, 12) ; yHeight     = twips
		NumPut("UInt", fgColor, cf2, 20) ; crTextColor = 0xBBGGRR
		StrPut(f.Typeface, cf2.Ptr + 26, 32, "UTF-16") ; szFaceName = TCHAR
		SendMessage(0x444, 0, cf2, this.Hwnd) ; EM_SETCHARFORMAT

		; Set tab size to 4 for non-highlighted code
		tabStops := Buffer(4)
		NumPut("UInt", Settings.TabSize * 4, tabStops)
		this.SendMsg(0x0CB, 1, tabStops) ; EM_SETTABSTOPS

		; Change text limit from 32,767 to max
		this.SendMsg(0x435, 0, -1) ; EM_EXLIMITTEXT

		; Bind for keyboard events
		; Use a pointer to prevent reference loop
		this.OnMessageBound := this.OnMessage.Bind(this)
		OnMessage(0x100, this.OnMessageBound) ; WM_KEYDOWN
		OnMessage(0x205, this.OnMessageBound) ; WM_RBUTTONUP

		; Bind the highlighter
		this.HighlightBound := this.Highlight.Bind(this)

		; Create the right click menu
		this.menu := Menu()
		for Index, Entry in RichCode.MenuItems
			(entry == "") ? this.menu.Add() : this.menu.Add(Entry, (*) => this.RightClickMenu.Bind(this))

		; Get the ITextDocument object
		bufpIRichEditOle := Buffer(A_PtrSize, 0)
		this.SendMsg(0x43C, 0, bufpIRichEditOle) ; EM_GETOLEINTERFACE
		this.pIRichEditOle := NumGet(bufpIRichEditOle, "UPtr")
		this.IRichEditOle := ComValue(9, this.pIRichEditOle, 1)
		; ObjAddRef(this.pIRichEditOle)
		this.pITextDocument := ComObjQuery(this.IRichEditOle, RichCode.IID_ITextDocument)
		this.ITextDocument := ComValue(9, this.pITextDocument, 1)
		; ObjAddRef(this.pITextDocument)
	}

	RightClickMenu(ItemName, ItemPos, MenuName)
	{
		if (ItemName == "Cut")
			Clipboard := this.SelectedText, this.SelectedText := ""
		else if (ItemName == "Copy")
			Clipboard := this.SelectedText
		else if (ItemName == "Paste")
			this.SelectedText := A_Clipboard
		else if (ItemName == "Delete")
			this.SelectedText := ""
		else if (ItemName == "Select All")
			this.Selection := [0, -1]
		else if (ItemName == "UPPERCASE")
			this.SelectedText := Format("{:U}", this.SelectedText)
		else if (ItemName == "lowercase")
			this.SelectedText := Format("{:L}", this.SelectedText)
		else if (ItemName == "TitleCase")
			this.SelectedText := Format("{:T}", this.SelectedText)
	}

	__Delete()
	{
		; Release the ITextDocument object
		this.ITextDocument := unset, ObjRelease(this.pITextDocument)
		this.IRichEditOle := unset, ObjRelease(this.pIRichEditOle)

		; Release the OnMessage handlers
		OnMessage(0x100, this.OnMessageBound, 0) ; WM_KEYDOWN
		OnMessage(0x205, this.OnMessageBound, 0) ; WM_RBUTTONUP

		; Destroy the right click menu
		this.menu := unset
	}

	__Call(Name, Params) => this._control.%Name%(Params*)
	__Get(Name, Params) => this._control.%Name%[Params*]
	___Set(Name, Params, Value) {
		try {
			this._control.%Name%[Params*] := Value
		} catch Any as e {
			e2 := Error(, -1)
			e.What := e2.What
			e.Line := e2.Line
			e.File := e2.File
			throw e
		}
	}

	; --- Event Handlers ---

	OnMessage(wParam, lParam, Msg, hWnd)
	{
		if (hWnd != this._control.hWnd)
			return

		if (Msg == 0x100) ; WM_KEYDOWN
		{
			if (wParam == GetKeyVK("Tab"))
			{
				; Indentation
				Selection := this.Selection
				if GetKeyState("Shift")
					this.IndentSelection(True) ; Reverse
				else if (Selection[2] - Selection[1]) ; Something is selected
					this.IndentSelection()
				else
				{
					; TODO: Trim to size needed to reach next TabSize
					this.SelectedText := this.Settings.Indent
					this.Selection[1] := this.Selection[2] ; Place cursor after
				}
				return False
			}
			else if (wParam == GetKeyVK("Escape")) ; Normally closes the window
				return False
			else if (wParam == GetKeyVK("v") && GetKeyState("Ctrl"))
			{
				this.SelectedText := A_Clipboard ; Strips formatting
				this.Selection[1] := this.Selection[2] ; Place cursor after
				return False
			}
		}
		else if (Msg == 0x205) ; WM_RBUTTONUP
		{
			this.menu.Show()
			return False
		}
	}

	CtrlChanged(control)
	{
		; Delay until the user is finished changing the document
		SetTimer this.HighlightBound, -Abs(this.Settings.HighlightDelay)
	}

	; --- Methods ---

	; First parameter is taken as a replacement value
	; Variadic form is used to detect when a parameter is given,
	; regardless of content
	Highlight(NewVal := unset)
	{
		if !(this.Settings.UseHighlighter && this.Settings.Highlighter) {
			if IsSet(NewVal)
				this._control.Text := NewVal
			return
		}

		; Freeze the control while it is being modified, stop change event
		; generation, suspend the undo buffer, buffer any input events
		PrevFrozen := this.Frozen, this.Frozen := True
		PrevEventMask := this.EventMask, this.EventMask := 0 ; ENM_NONE
		PrevUndoSuspended := this.UndoSuspended, this.UndoSuspended := True
		PrevCritical := Critical(1000)

		; Run the highlighter
		Highlighter := this.Settings.Highlighter
		if !IsSet(NewVal)
			NewVal := this.text
		RTF := Highlighter(this.Settings, &NewVal)

		; "TRichEdit suspend/resume undo function"
		; https://stackoverflow.com/a/21206620


		; Save the rich text to a UTF-8 buffer
		buf := Buffer(StrPut(RTF, "UTF-8"))
		StrPut(RTF, buf, "UTF-8")

		; Set up the necessary structs
		zoom := Buffer(8, 0) ; Zoom Level
		point := Buffer(8, 0) ; Scroll Pos
		charrange := Buffer(8, 0) ; Selection
		settextex := Buffer(8, 0) ; SetText settings
		NumPut("UInt", 1, settextex) ; flags = ST_KEEPUNDO

		; Save the scroll and cursor positions, update the text,
		; then restore the scroll and cursor positions
		MODIFY := this.SendMsg(0xB8, 0, 0)    ; EM_GETMODIFY
		this.SendMsg(0x4E0, ZOOM.ptr, ZOOM.ptr + 4)   ; EM_GETZOOM
		this.SendMsg(0x4DD, 0, POINT)        ; EM_GETSCROLLPOS
		this.SendMsg(0x434, 0, CHARRANGE)    ; EM_EXGETSEL
		this.SendMsg(0x461, SETTEXTEX, Buf) ; EM_SETTEXTEX
		this.SendMsg(0x437, 0, CHARRANGE)    ; EM_EXSETSEL
		this.SendMsg(0x4DE, 0, POINT)        ; EM_SETSCROLLPOS
		this.SendMsg(0x4E1, NumGet(ZOOM, "UInt")
			, NumGet(ZOOM, 4, "UInt"))        ; EM_SETZOOM
		this.SendMsg(0xB9, MODIFY, 0)         ; EM_SETMODIFY

		; Restore previous settings
		Critical PrevCritical
		this.UndoSuspended := PrevUndoSuspended
		this.EventMask := PrevEventMask
		this.Frozen := PrevFrozen
	}

	IndentSelection(Reverse := False, Indent := unset) {
		; Freeze the control while it is being modified, stop change event
		; generation, buffer any input events
		PrevFrozen := this.Frozen
		this.Frozen := True
		PrevEventMask := this.EventMask
		this.EventMask := 0 ; ENM_NONE
		PrevCritical := Critical(1000)

		if !IsSet(Indent)
			Indent := this.Settings.Indent
		IndentLen := StrLen(Indent)

		; Select back to the start of the first line
		sel := this.selection
		top := this.SendMsg(0x436, 0, sel[1]) ; EM_EXLINEFROMCHAR
		bottom := this.SendMsg(0x436, 0, sel[2]) ; EM_EXLINEFROMCHAR
		this.Selection := [
			this.SendMsg(0xBB, top, 0), ; EM_LINEINDEX
			this.SendMsg(0xBB, bottom + 1, 0) - 1 ; EM_LINEINDEX
		]

		; TODO: Insert newlines using SetSel/ReplaceSel to avoid having to call
		; the highlighter again
		Text := this.SelectedText
		out := ""
		if Reverse { ; Remove indentation appropriately
			loop parse text, "`n", "`r" {
				if InStr(A_LoopField, Indent) == 1
					Out .= "`n" SubStr(A_LoopField, 1 + IndentLen)
				else
					Out .= "`n" A_LoopField
			}
		} else { ; Add indentation appropriately
			loop parse Text, "`n", "`r"
				Out .= "`n" Indent . A_LoopField
		}
		this.SelectedText := SubStr(Out, 2)

		this.Highlight()

		; Restore previous settings
		Critical PrevCritical
		this.EventMask := PrevEventMask

		; When content changes cause the horizontal scrollbar to disappear,
		; unfreezing causes the scrollbar to jump. To solve this, jump back
		; after unfreezing. This will cause a flicker when that edge case
		; occurs, but it's better than the alternative.
		point := Buffer(8, 0)
		this.SendMsg(0x4DD, 0, POINT) ; EM_GETSCROLLPOS
		this.Frozen := PrevFrozen
		this.SendMsg(0x4DE, 0, POINT) ; EM_SETSCROLLPOS
	}

	; --- Helper/Convenience Methods ---

	SendMsg(Msg, wParam, lParam) =>
		SendMessage(msg, wParam, lParam, this._control.Hwnd)
}