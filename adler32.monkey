Strict

Public

' Imports:
Private

Import monkey.math

Import brl.databuffer

Import hash

Public

' Functions (Public):

' Based loosely on the ZLib / Tiny Inflate source:
Function Adler32:Int(Data:DataBuffer, Length:Int, Offset:Int=0, Prev_Sum:Int=1) ' UInt
	' Constant variable(s):
	Const ADLER32_BASE:= 65521
	Const ADLER32_NMAX:= 5552
	
	' Local variable(s):
	Local S1:= (Prev_Sum & $FFFF) ' UInt
	Local S2:= Lsr(Prev_Sum, 16) ' UInt
	
	While (Length > 0)
		Local K:Int = Min(Length, ADLER32_NMAX)
		
		For Local I:= (K / 16) Until 0 Step -1
			#Rem
				' Unrolled version:
				S1 += __Adler32_PeekByte(Data, Offset);  S2 += S1; S1 += __Adler32_PeekByte(Data, Offset+1);  S2 += S1
				S1 += __Adler32_PeekByte(Data, Offset+2);  S2 += S1; S1 += __Adler32_PeekByte(Data, Offset+3);  S2 += S1
				S1 += __Adler32_PeekByte(Data, Offset+4);  S2 += S1; S1 += __Adler32_PeekByte(Data, Offset+5);  S2 += S1
				S1 += __Adler32_PeekByte(Data, Offset+6);  S2 += S1; S1 += __Adler32_PeekByte(Data, Offset+7);  S2 += S1
				
				S1 += __Adler32_PeekByte(Data, Offset+8);  S2 += S1; S1 += __Adler32_PeekByte(Data, Offset+9);  S2 += S1
				S1 += __Adler32_PeekByte(Data, Offset+10); S2 += S1; S1 += __Adler32_PeekByte(Data, Offset+11); S2 += S1
				S1 += __Adler32_PeekByte(Data, Offset+12); S2 += S1; S1 += __Adler32_PeekByte(Data, Offset+13); S2 += S1
				S1 += __Adler32_PeekByte(Data, Offset+14); S2 += S1; S1 += __Adler32_PeekByte(Data, Offset+15); S2 += S1
			#End
			
			Local EndOffset:= (Offset + 16)
			
			For Offset = Offset Until EndOffset
				S1 += __Adler32_PeekByte(Data, Offset)
				
				S2 += S1
			Next
		Next
		
		For Local I:= (K Mod 16) Until 0 Step -1
			S1 += __Adler32_PeekByte(Data, Offset)
			
			Offset += 1
			
			S2 += S1
		Next
		
		S1 Mod= ADLER32_BASE
		S2 Mod= ADLER32_BASE
		
		Length -= K
	Wend
	
	Return (Lsl(S2, 16) | S1) ' & $FFFFFF
End

' Functions (Private):
Private

Function __Adler32_PeekByte:Int(Buffer:DataBuffer, Address:Int)
	Return (Buffer.PeekByte(Address) & $FF)
End

Public