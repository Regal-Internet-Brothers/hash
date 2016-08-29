Strict

Public

' Imports (Public):
Import config
Import types
Import external

' Standard BRL modules:
Import brl.stream
Import brl.databuffer

' Imports (Private):
Private

Import regal.retrostrings

Public

' Functions:
Function IntToHex:HexValue(Data:Int)
	Return HexLE(Data)
End

Function RotateLeft:Int(Value:Int, ShiftBits:Int)
	#If Not SIZEOF_IMPLEMENTED
		Const SizeOf_Integer_InBits:Int = 4*8 ' 32-bit.
	#End
	
	Return Lsl(Value, ShiftBits) | Lsr( Value, (SizeOf_Integer_InBits - ShiftBits))
	'Return (Value Shl ShiftBits) | (Value Shr (SizeOf_Integer_InBits-ShiftBits))
End