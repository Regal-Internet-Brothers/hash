Strict

Public

' Imports:
Import regal.hash.base64
Import regal.ioutil.stringstream

Import brl.stream

' Functions:
Function Main:Int()
	' Local variable(s):
	Local Source:= "Hello world."
	
	Local X:= New StringStream()
	Local Y:= New StringStream()
	
	X.WriteString(Source)
	X.Seek(0)
	
	EncodeBase64(X, Y)
	
	Local Encoded:= Y.Echo()
	
	Print(Encoded)
	
	Y.Seek(0)
	X.Reset()
	
	DecodeBase64(Y, X)
	
	Local Decoded:= X.Echo()
	
	X.Close()
	Y.Close()
	
	Print("Source: " + Source)
	Print("Encoded: " + Encoded)
	Print("Decoded: " + Decoded)
	
	Return 0
End