Strict

Public

' Imports:
Import hash

Import brl.databuffer
Import brl.datastream

' Functions:
Function Main:Int()
	Print("The following demo should calculate the same hash 4 times:~r~n")
	
	' Local variable(s):
	
	' This is the message we'll be hashing.
	Local Message:String = "Hello world."
	
	Print("Expected:")
	
	'Print("~t~q"+Message+"~q:~t764569E58F53EA8B6404F6FA7FC0247F")
	Print("~tPrecomputed:~t764569E58F53EA8B6404F6FA7FC0247F")
	
	Print("Results (~q"+Message+"~q):")
	
	' Calculate a hash from our 'String'.
	Print("~t'String' :~t" + MD5(Message))
	
	' Allocate a 'DataBuffer' containing our message:
	Local Data:= New DataBuffer(Message.Length)
	
	Data.PokeString(0, Message, "ascii")
	
	' Calculate a hash from our 'DataBuffer':
	Local Result:MD5Hash = MD5(Data)
	
	Print("~t'DataBuffer' :~t" + Result)
	
	' Create a 'DataStream' from 'Data'.
	Local Input:= New DataStream(Data)
	
	' Calculate a hash from our 'Stream'.
	Print("~t'Stream' :~t" + MD5(Input))
	
	Input.Close()
	
	Data.Discard()
	
	' Calculate a hash from an array of integers/characters. (Generated from 'Message')
	Print("~t'Int[]' :~t" + MD5(Message.ToChars()))
	
	' Return the default response.
	Return 0
End