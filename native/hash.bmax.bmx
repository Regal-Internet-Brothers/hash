
Type external_hash
	' Functions:
	Function Lsr:Int(data:Int, shiftBy:Int)
		Return (data Shr shiftBy)
	End Function
	
	Function Lsl:Int(data:Int, shiftBy:Int)
		Return (data Shl shiftBy)
	End Function
End Type
