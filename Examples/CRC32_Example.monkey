Strict

Public

' Preprocessor related:
#CRC32_DEMO_HEX = True

' Imports:
Import brl.databuffer

Import regal.hash.crc32

#If CRC32_DEMO_HEX
	Import regal.retrostrings
#End

' Functions:
Function Main:Int()
	Local TestValue:String = "This is a value."
	
	Local Buffer:= New DataBuffer(TestValue.Length)
	
	Buffer.PokeString(0, TestValue, "ascii")
	
	Local Hash:= CRC32(Buffer, Buffer.Length) ' B9B5B039
	
	#If CRC32_DEMO_HEX
		Local DisplayValue:= Hex(Hash)
	#Else
		Local DisplayValue:= Hash
	#End
	
	Print("The CRC32 hash is: " + DisplayValue + " | " + TestValue)
	
	Buffer.Discard()
	
	Return 0
End