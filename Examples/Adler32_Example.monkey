Strict

Public

' Preprocessor related:
#ADLER32_DEMO_HEX = True

' Imports:
Import brl.databuffer

Import regal.hash.adler32

#If ADLER32_DEMO_HEX
	Import regal.retrostrings
#End

' Functions:
Function Main:Int()
	Local TestValue:String = "Hello world, this is a test."
	
	Local Buffer:= New DataBuffer(TestValue.Length)
	
	Buffer.PokeString(0, TestValue, "ascii")
	
	Local Hash:= Adler32(Buffer, Buffer.Length, 0, 1) ' 910C09CC
	
	#If ADLER32_DEMO_HEX
		Local DisplayValue:= Hex(Hash)
	#Else
		Local DisplayValue:= Hash
	#End
	
	Print("The Adler32 hash is: " + DisplayValue + " | " + TestValue)
	
	Buffer.Discard()
	
	Return 0
End