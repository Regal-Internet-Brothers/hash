Strict

Public

' Imports:
Import regal.ioutil.publicdatastream
Import regal.hash.rc4

' Functions:
Function ReadString:String(input:Stream, start_at_beginning:Bool=True)
	Local position:= input.Position
	
	If (start_at_beginning) Then
		input.Seek(0)
	Endif
	
	Local value:= input.ReadString(input.Length)
	
	input.Seek(position)
	
	Return value
End

Function WriteString:Void(output:Stream, value:String, start_at_beginning:Bool=True)
	Local position:= output.Position
	
	If (start_at_beginning) Then
		output.Seek(0)
	Endif
	
	output.WriteString(value)
	
	output.Seek(position)
End

Function Main:Int()
	Local key:= "abcdefghijklmnopqrstuvwxyz"
	Local value:= "Hello world."
	
	Local length:= value.Length
	
	Local input:= New PublicDataStream(length)
	Local output:= New PublicDataStream(length)
	Local result:= New PublicDataStream(length)
	
	WriteString(input, value)
	
	' Encrypt the data using the key specified.
	RC4(input, output, key)
	
	' Seek back to the beginning of 'output'.
	output.Seek(0)
	
	' Decrypt the previously output data using the key specified.
	RC4(output, result, key)
	
	Print("Input: " + ReadString(input))
	Print("Output: " + ReadString(output))
	Print("Result: " + ReadString(result))
	
	input.Close()
	output.Close()
	result.Close()
	
	Return 0
End