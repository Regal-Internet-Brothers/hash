Strict

Public

' Imports:
Import config
Import types

' Functions:

' This is effectively just a rewrite of Java's 'hashCode' method:
Function HashCode:Int(S:String)
	' Local variable(s):
	Local Hash:Int = 0
	
	' Compute the "hash code":
	For Local I:= 0 Until S.Length
		Hash = ((31*Hash) + S[I])
	Next
	
	' Return the resulting hash.
	Return Hash
End

Function HashCode:Int(Data:Int[], Offset:Int, Length:Int)
	' Local variable(s):
	Local Hash:Int = 0
	
	' Compute the "hash code":
	For Local I:= Offset Until Length
		Hash = ((31*Hash) + Data[I])
	Next
	
	' Return the resulting hash.
	Return Hash
End

Function HashCode:Int(Data:Int[], Offset:Int=0)
	Return HashCode(Data, Offset, Data.Length)
End

' This command simply wraps 'HashCode',
' and outputs the result in hexadecimal.
Function HashCodeInHex:HexValue(S:String)
	' Return the hash-code in hexadecimal.
	Return IntToHex(HashCode(S))
End