Strict

Public

' Preprocessor related:
#HASH_EXPERIMENTAL = True

' Imports:
Import regal.hash
Import regal.ioutil.stringstream

' Functions:
Function Main:Int()
	Local Message:= "Hello world."
	
	Local SS:= New StringStream(Message, "ascii")
	
	SS.Seek(0)
	
	Local Values:= SHA1(SS, SS.Length)
	
	Print("SHA1: " + Values)
	
	' Return the default response.
	Return 0
End