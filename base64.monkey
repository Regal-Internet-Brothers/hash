Strict

Public

' Imports (Public):
Import brl.stream

' Imports (Private):
Private

Import regal.typetool

Public

' Constant variable(s) (Private):
Private

Const BASE64_CHAR_BOUNDS:= 64 ' __BASE64_CHARACTER_TABLE.Length

' DO NOT modify this "constant"; assume this as an internal constant variable.
Global __BASE64_CHARACTER_TABLE:String = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=" ' Const

Public

' Functions:

' This converts 'Value' into its original form.
Function Base64ToReal:Int(Value:Int)
	' Constant variable(s):
	
	' Exact ASCII symbols:
	Const ASCII_PLUS:= 43 ' +
	Const ASCII_SLASH:= 47 ' /
	Const ASCII_EQUALS:= 61 ' =
	
	' Segment lengths:
	Const ALPHABET_LENGTH:= 26
	Const NUMBER_LENGTH:= 10
	
	' "Virtual" array positions:
	Const UPPERCASE_OFFSET:= 0
	Const LOWERCASE_OFFSET:= (ALPHABET_LENGTH)
	Const NUMBER_OFFSET:= (ALPHABET_LENGTH*2)
	Const SPECIAL_OFFSET:= (NUMBER_OFFSET + (NUMBER_LENGTH-1))
	
	' ASCII/UTF8 character attributes:
	Const NUMBER_FIRST_CHAR:= 48 ' 0
	Const NUMBER_LAST_CHAR:= (NUMBER_OFFSET+(NUMBER_LENGTH-1)) ' 9
	
	Const UPPERCASE_FIRST_CHAR:= 65 ' A
	Const UPPERCASE_LAST_CHAR:= (UPPERCASE_FIRST_CHAR + (ALPHABET_LENGTH-1)) ' Z
	
	Const LOWERCASE_FIRST_CHAR:= 97 ' a
	Const LOWERCASE_LAST_CHAR:= (LOWERCASE_FIRST_CHAR + (ALPHABET_LENGTH-1)) ' z
	
	' The minimum character code required to begin parsing.
	Const CHAR_ENTRYPOINT:= NUMBER_FIRST_CHAR
	Const CHAR_ALPH_ENTRYPOINT:= UPPERCASE_FIRST_CHAR
	
	' Check if this is a supported character:
	If (Value >= CHAR_ENTRYPOINT) Then
		' Check if this is an extended or alphabetical character:
		If (Value >= CHAR_ALPH_ENTRYPOINT) Then
			' Check for uppercase characters:
			If (Value <= UPPERCASE_LAST_CHAR) Then
				' Convert 'Value' as an uppercase character.
				Return (Value - UPPERCASE_FIRST_CHAR) + UPPERCASE_OFFSET
			Endif
			
			' Check for lowercase characters:
			If (Value >= LOWERCASE_FIRST_CHAR And Value <= LOWERCASE_LAST_CHAR) Then
				' Convert 'Value' as a lowercase character.
				Return (Value - LOWERCASE_FIRST_CHAR) + LOWERCASE_OFFSET
			Endif
			
			' Check if this is a "special" character, and if so, convert it:
			Select Value
				Case ASCII_PLUS
					Return SPECIAL_OFFSET
				Case ASCII_SLASH
					Return SPECIAL_OFFSET+1
				Case ASCII_EQUALS
					Return SPECIAL_OFFSET+2
			End Select
		Else
			' Check if this is a numeric character:
			If (Value < = NUMBER_LAST_CHAR) Then
				' Convert 'Value' as a number.
				Return (Value - NUMBER_FIRST_CHAR) + NUMBER_OFFSET
			Endif
		Endif
	Endif
	
	' Return the default response. (Unsupported character)
	Return -1
End

' This encodes 'Data' into raw base 64 text; based off of Diddy's implementation.
Function EncodeBase64:Void(Data:Stream, Length:Int, Output:Stream)
	' Local variable(s):
	Local A:Int, B:Int, C:Int, D:Int
	
	For Local I:= 0 Until Length Step 3
		Local S1:Int
		
		' Read the initial byte, then resolve the next two for this cycle:
		S1 = (Data.ReadByte() & $FF)
		
		' Assign our byte representatives:
		A = S1 Shr 2
		B = ((S1 & 3) Shl 4)
		
		' Load our first unresolved byte
		If (I+1 < Length) Then
			Local S2:= (Data.ReadByte() & $FF)
			
			B |= (S2 Shr 4)
			C = ((S2 & 15) Shl 2)
		Else
			C = BASE64_CHAR_BOUNDS
		Endif
		
		' Load the second unresolved byte:
		If (I+2 < Length) Then
			Local S3:= (Data.ReadByte() & $FF)
			
			C |= (S3 Shr 6)
			D = (S3 & 63)
		Else
			D = BASE64_CHAR_BOUNDS
		Endif
		
		Output.WriteByte(__BASE64_CHARACTER_TABLE[A])
		Output.WriteByte(__BASE64_CHARACTER_TABLE[B])
		
		' A bit of an order-hack, but it works:
		If (C <= BASE64_CHAR_BOUNDS) Then
			Output.WriteByte(__BASE64_CHARACTER_TABLE[C])
		Endif
		
		If (D <= BASE64_CHAR_BOUNDS) Then
			Output.WriteByte(__BASE64_CHARACTER_TABLE[D])
		Endif
	Next
	
	Return
End

Function EncodeBase64:Void(Data:Stream, Output:Stream)
	EncodeBase64(Data, Data.Length, Output)
	
	Return
End

' This decodes raw base 64 text from 'Data' into 'Output'; based off of Diddy's implementation.
Function DecodeBase64:Void(Data:Stream, Length:Int, Output:Stream)
	For Local I:= 0 Until Length Step 4
		Local A:Int, B:Int, C:Int, D:Int
		
		A = Base64ToReal(Data.ReadByte())
		
		If (I+1 > Length) Then
			' Throw ...
			
			Exit
		Endif
		
		B = Base64ToReal(Data.ReadByte())
		
		If (I+2 < Length) Then
			C = Base64ToReal(Data.ReadByte())
		Else
			C = BASE64_CHAR_BOUNDS
		Endif
		
		If (I+3 < Length) Then
			D = Base64ToReal(Data.ReadByte())
		Else
			D = BASE64_CHAR_BOUNDS
		Endif
		
		Output.WriteByte((A Shl 2) | (B Shr 4))
		Output.WriteByte(((B & 15) Shl 4) | (C Shr 2))
		Output.WriteByte(((C & 3) Shl 6) | D)
	Next
	
	Return
End

Function DecodeBase64:Void(Data:Stream, Output:Stream)
	DecodeBase64(Data, Data.Length, Output)
	
	Return
End