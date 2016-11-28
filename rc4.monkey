Strict

Public

' Imports (Public):
Import config

' Imports (Private):
Private

Import brl.stream

Public

' Constant variable(s):
Const RC4_BUFFER_LENGTH:= 256

' Functions (Public):
Function RC4:Void(input:Stream, output:Stream, key:String)
	RC4(input, output, key, input.Length, New Int[RC4_BUFFER_LENGTH])
End

Function RC4:Void(input:Stream, output:Stream, key:String, length:Int, state:Int[])
	Local j:Int
	
	For Local i:= 0 Until state.Length
		state[i] = i
	Next
	
	j = 0
	
	For Local i:= 0 Until RC4_BUFFER_LENGTH
		j = ((j + state[i] + ReadKey(key, i)) & $FF)
		
		SwapArrayValues(state, i, j)
	Next
	
	j = 0
	
	For Local i:= 0 Until input.Length
		i &= $FF
		
		j = (j + state[i]) & $FF
		
		SwapArrayValues(state, i, j)
		
		Local t:= ((state[i] + (state[j] & $FF)) & $FF)
		Local y:= state[t]
		
		output.WriteByte(input.ReadByte() ~ y)
	Next
End

' Functions (Private):
Private

Function ReadKey:Int(key:String, index:Int)
	If (index < 0 Or index > key.Length) Then
		Return 0
	Elseif (index = key.Length) Then
		Return key[0]
	Endif
	
	Return key[index + 1]
End

Function SwapArrayValues:Void(data:Int[], i:Int, j:Int)
	Local temp:= data[i]
	
	data[i] = data[j]
	data[j] = temp
End

Public