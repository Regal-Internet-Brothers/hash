Strict

Public

' Imports:
Import regal.hash.hashcode

#If TARGET = "stdcpp"
	Import regal.time
#Else
	Import mojo.app
#End

' Functions:
Function Main:Int()
	' Local variable(s):
	Local Message:String = "This is a test."
	Local Times:= 400000000
	
	Print("Original message: ~q" + Message + "~q")
	
	Print("As a 'String': " + HashCode(Message))
	Print("As an 'Int[]': " + HashCode(Message.ToChars()))
	
	Print("Calculating this hash an extra " + Times + " times...")
	
	Local Begin:= Millisecs()
	
	For Local I:= 1 To Times
		HashCode(Message)
	Next
	
	Local TimeTaken:= (Millisecs() - Begin)
	
	Print("That took " + TimeTaken + "ms.")
	
	Return 0
End