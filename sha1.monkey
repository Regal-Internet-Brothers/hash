Strict

Public

' Imports (Public):
Import config

' Imports (Private):
Private

Import util

Import brl.stream

Import regal.util.generic

Public

' Functions:

' To be refactored into a proper generic system:
Function RAW_SHA1:Void(S:Stream, ByteCount:Int, Output:Int[], OutputOffset:Int=0)
	Const BLOCK_SIZE:= 16
	
	Local H0:Int, H1:Int, H2:Int, H3:Int, H4:Int
	
	H0 = $67452301
	H1 = $EFCDAB89
	H2 = $98BADCFE
	H3 = $10325476
	H4 = $C3D2E1F0
	
	Local IntCount:= (((ByteCount + 8) Shr 6) + 1) Shl 4
	
	Local Data:= New Int[IntCount]
	
	For Local I:= 0 Until ByteCount
		' Load a byte into 'C', and fix its encoding:
		#Rem
		Local C:= S.ReadByte()
		
		If (C < 0) Then
			C += 256
		Endif
		#End
		
		Local C:= (S.ReadByte() & $FF)
		
		Data[I Shr 2] = ((Data[I Shr 2] Shl 8) | C)
	Next
	
	Data[ByteCount Shr 2] = ((Data[ByteCount Shr 2] Shl 8) | $80) Shl ((3 - (ByteCount & 3)) Shl 3)
	
	Local ByteCountX8:= (ByteCount * 8)
	
	Data[IntCount - 2] = 0 ' ByteCountX8
	Data[IntCount - 1] = ByteCountX8 ' (ByteCountX8 & $FFFFFFFF)
	
	For Local ChunkStart:= 0 Until IntCount Step BLOCK_SIZE
		Local A:= H0
		Local B:= H1
		Local C:= H2
		Local D:= H3
		Local E:= H4
		
		Local W:= New Int[80]
		
		GenericUtilities<Int>.CopyArray(Data, W, ChunkStart, 0, ChunkStart+16)
		
		For Local I:= 16 Until 80
			W[I] = RotateLeft(W[I - 3] ~ W[I - 8] ~ W[I - 14] ~ W[I - 16], 1)
		Next
		
		For Local I:= 0 Until 20
			Local T:= RotateLeft(A, 5) + (D ~ (B & (C ~ D))) + E + $5A827999 + W[I]
			
			E = D; D = C
			C = RotateLeft(B, 30)
			B = A; A = T
		Next
		
		For Local I:= 20 Until 40
			Local T:= RotateLeft(A, 5) + (B ~ C ~ D) + E + $6ED9EBA1 + W[I]
			
			E = D; D = C
			C = RotateLeft(B, 30)
			B = A; A = T
		Next
		
		For Local I:= 40 Until 60
			Local T:= RotateLeft(A, 5) + ((B & C) | (D & (B | C))) + E + $8F1BBCDC + W[I]
			
			E = D; D = C
			C = RotateLeft(B, 30)
			B = A; A = T
		Next
		
		For Local I:= 60 Until 80
			Local T:= RotateLeft(A, 5) + (B ~ C ~ D) + E + $CA62C1D6 + W[I]
			
			E = D; D = C
			C = RotateLeft(B, 30)
			B = A; A = T
		Next
		
		H0 += A
		H1 += B
		H2 += C
		H3 += D
		H4 += E
	Next
	
	Output[OutputOffset] = H0
	Output[OutputOffset+1] = H1
	Output[OutputOffset+2] = H2
	Output[OutputOffset+3] = H3
	Output[OutputOffset+4] = H4
	
	Return
End

Function RAW_SHA1:Int[](S:Stream, ByteCount:Int)
	Local Out:= New Int[5]
	
	RAW_SHA1(S, ByteCount, Out)
	
	Return Out
End

Function SHA1:String(S:Stream, ByteCount:Int)
	Local Out:= RAW_SHA1(S, ByteCount)
	
	'Return IntToHex(H0) + ", " + IntToHex(H1) + ", " + IntToHex(H2) + ", " + IntToHex(H3) + ", " + IntToHex(H4)
	'Return HexLE(H0) + HexLE(H1) + HexLE(H2) + HexLE(H3) + HexLE(H4)
	'Return HexBE(H0) + HexBE(H1) + HexBE(H2) + HexBE(H3) + HexBE(H4)
	Return IntToHex(Out[0]) + IntToHex(Out[1]) + IntToHex(Out[2]) + IntToHex(Out[3]) + IntToHex(Out[4])
	'Return HexBE(Out[0]) + ", " + HexBE(Out[1]) + ", " + HexBE(Out[2]) + ", " + HexBE(Out[3]) + ", " + HexBE(Out[4])
End

Function SHA1:Hash(S:Stream)
	Return SHA1(S, S.Length)
End