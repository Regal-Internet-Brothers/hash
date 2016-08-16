Strict

Public

' Preprocessor related:
#HASH_CRC32_USE_ARRAYS = True

' Imports:
Private

Import monkey.math

Import brl.databuffer

Import hash

Public

' Functions (Public):

' Loosely based on the ZLib and UZLib source:
Function CRC32:Int(Data:DataBuffer, Length:Int, Offset:Int=0, CRC:Int=$FFFFFFFF, FixValue:Bool=True) ' UInt
	If (Length = 0) Then
		Return 0
	Endif
	
	For Local I:= 0 Until Length
		CRC ~= (Data.PeekByte(I) & $FF)
		
		CRC = _CRC32_Table_Get(CRC & $0F) ~ Lsr(CRC, 4)
		CRC = _CRC32_Table_Get(CRC & $0F) ~ Lsr(CRC, 4)
	Next
	
	If (Not FixValue) Then
		Return CRC
	Endif
	
	Return (CRC ~ $FFFFFFFF)
End

' Functions (Private):
Private

' Constant variable(s):
#If HASH_CRC32_USE_ARRAYS
	Global __CRC32_Table:Int[] = [	$00000000, $1DB71064, $3B6E20C8, $26D930AC, $76DC4190,
									$6B6B51F4, $4DB26158, $5005713C, $EDB88320, $F00F9344,
									$D6D6A3E8, $CB61B38C, $9B64C2B0, $86D3D2D4, $A00AE278,
									$BDBDF21C] ' Const
#End

Function _CRC32_Table_Get:Int(Index:Int)
	#If HASH_CRC32_USE_ARRAYS
		Return __CRC32_Table[Index]
	#Else
		Select (Index)
			Case 0; Return $00000000
			Case 1; Return $1DB71064
			Case 2; Return $3B6E20C8
			Case 3; Return $26D930AC
			Case 4; Return $76DC4190
			Case 5; Return $6B6B51F4
			Case 6; Return $4DB26158
			Case 7; Return $5005713C
			Case 8; Return $EDB88320
			Case 9; Return $F00F9344
			Case 10; Return $D6D6A3E8
			Case 11; Return $CB61B38C
			Case 12; Return $9B64C2B0
			Case 13; Return $86D3D2D4
			Case 14; Return $A00AE278
			Case 15; Return $BDBDF21C
		End Select
		
		Return 0
	#End
End

Public