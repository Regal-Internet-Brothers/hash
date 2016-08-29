Strict

Public

' Preprocessor related:

' #If LANG = "cpp"
#If TARGET = "stdcpp" Or TARGET = "sexy" Or TARGET = "glfw" Or TARGET = "xna" Or TARGET = "html5" Or TARGET = "android" Or TARGET = "flash" Or TARGET = "bmax"
	#HASH_EXTERNAL_SHIFTING = True
#End

' Imports:
Import config

' Imports (Native):
#If HASH_EXTERNAL_SHIFTING
	#If LANG = "cpp" Or LANG = "java"
		' All of the C++ targets should support this.
		Import "native/hash.${LANG}"
	#Else
		Import "native/hash.${TARGET}.${LANG}"
	#End
#End

' External bindings:
Extern

' Functions:
#If HASH_EXTERNAL_SHIFTING
	#If LANG <> "cpp"
		Function Lsr:Int(Data:Int, ShiftBy:Int) = "external_hash.Lsr"
		Function Lsl:Int(Data:Int, ShiftBy:Int) = "external_hash.Lsl"
	#Else
		Function Lsr:Int(Data:Int, ShiftBy:Int) = "external_hash::Lsr"
		Function Lsl:Int(Data:Int, ShiftBy:Int) = "external_hash::Lsl"
	#End
#End

Public

' Fallbacks:
#If Not HASH_EXTERNAL_SHIFTING
	Function Lsr:Int(Number:Int, ShiftBy:Int)
		Return (Number Shr ShiftBy)
	End
	
	Function Lsl:Int(Number:Int, ShiftBy:Int)
		Return (Number Shl ShiftBy)
	End
#End