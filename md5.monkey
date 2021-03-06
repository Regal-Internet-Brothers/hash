Strict

Public

#Rem
	NOTES:
		* Please do not use the standard 'MD5Hasher' class for 'DataBuffers' and 'Streams'.
		These must be handled by their respective "hashers". Other than that, you should be good.
		
		* The 'MD5Hasher' class was developed with arrays (Integer arrays) in mind,
		but technically, 'Strings' do work. (Very well, I might add)
		
		* To use this module's MD5 functionality, simply do the following:
		
		Rough example:
		
		MD5HasherClassHere.Run(DataHere)
		
		Real world example:
		
		' To calculate the hash of a string, do this.
		MD5Hasher<String>.Run(Str)
		
		Alternatively, you can call 'MD5HasherClassHere.Instance' in order to configure the global instance.
		Or, you could always create your own instance of the class, and configure it from there.
		
		For the sake of benchmarking, it's recommended that you just use the global instance as you see fit. (Through 'Run', or 'Instance')
		
		* Standard 'Stream' support is implemented, but not completely tested.
		It's a dirty hack, but it does the job well enough; use at your own risk.
		
		* All functionality present should be in working order, and follow standard MD5 behaviour.
		If you get undesired results, please let me know. Please note that on the standard C++ targets (Targets using Monkey's garbage collector),
		this implementation tends to be bottlenecked by your GC settings.
		
		Some things are generated for the sake of memory efficiency. This was built with limited memory environments in mind.
		In fact part of why I made this was to test out Monkey's performance on embedded ARM systems.
		
		Most things which are generated are specific to the input, and because of this, they can not be cached properly.
#End

' Preprocessor related:
#MD5_STREAM_CACHE_MODE_ARRAY		= 0
#MD5_STREAM_CACHE_MODE_STRING		= 1
#MD5_STREAM_CACHE_MODE_BUFFER		= 2

' These mode-comments are ordered from highest to lowest performance (Not memory consumption):
#If TARGET = "android"
	#MD5_STREAM_CACHE_MODE = MD5_STREAM_CACHE_MODE_ARRAY ' MD5_STREAM_CACHE_MODE_STRING ' MD5_STREAM_CACHE_MODE_BUFFER
#Else
	#If TARGET = "xna"
		#MD5_STREAM_CACHE_MODE = MD5_STREAM_CACHE_MODE_STRING ' MD5_STREAM_CACHE_MODE_ARRAY ' MD5_STREAM_CACHE_MODE_BUFFER
	#Elseif TARGET = "html5"
		#MD5_STREAM_CACHE_MODE = MD5_STREAM_CACHE_MODE_STRING ' MD5_STREAM_CACHE_MODE_BUFFER ' MD5_STREAM_CACHE_MODE_ARRAY
	#Else
		#MD5_STREAM_CACHE_MODE = MD5_STREAM_CACHE_MODE_BUFFER ' MD5_STREAM_CACHE_MODE_ARRAY ' MD5_STREAM_CACHE_MODE_STRING
	#End
#End

' If this is enabled, less memory will be used, but performance will be slightly worse.
#MD5_ALTERNATE_SHIFT = False ' True

' By enabling this, you give this module the option to generate shared data on runtime (If needed).
' This acts as a request, not a demand. At the end of the day, it's the module's call.
#MD5_GENERATE_DATA_WHERE_POSSIBLE = True

#Rem
	If this is enabled, this module will use an unrolled implementation of the main block processing-routine.
	Such an act is possible with some targets' compilers, but not all are capable of this.
	For this reason, I've added the option to manually do this. Use this at your own risk, it could be faster on some targets.
	
	ATTENTION: The 'Standard_MD5Data' object will be unavailable if this is enabled. The 'MD5Data' class is still present, however.
#End

#If HASH_EXPERIMENTAL
	#MD5_MANUAL_PROCESSING = True
#Else
	' For now, this is enabled without experimental-confirmation. (This may change in the future)
	#MD5_MANUAL_PROCESSING = True ' False
#End

' If this is disabled, some areas where bulk-loading would normally occur will instead use other methods for data-retrieval.
' If enabled, functionality will be consistent no matter the situation, even if the choices made are slower.
#MD5_STREAM_ALLOW_SLOW_BULK_LOADING = False ' True

#If TARGET <> "xna"
	#MD5_STREAM_ALLOW_DEFAULT_CACHESIZE = True
#End

' Imports (Public):
Import config

' Imports (Private):
Private

Import regal.sizeof
Import regal.util.generic

Import util

Public

' Constant variable(s):
#If UTIL_IMPLEMENTED
	Const MD5_AUTO:= UTIL_AUTO
#Else
	Const MD5_AUTO:Int = -1
#End

' Functions (Public):

' Quick wrappers for the standard classes' 'Run' commands:
Function MD5:MD5Hash(Data:DataBuffer, Length:Int, Offset:Int=MD5BufferHasher.Default_Offset)
	Return MD5BufferHasher.Run(Data, Length, Offset)
End

Function MD5:MD5Hash(Data:DataBuffer)
	Return MD5BufferHasher.Run(Data)
End

Function MD5:MD5Hash(S:Stream, Length:Int, Offset:Int)
	Return MD5StreamHasher.Run(S, Length, Offset)
End

Function MD5:MD5Hash(S:Stream, Length:Int)
	Return MD5StreamHasher.Run(S, Length)
End

Function MD5:MD5Hash(S:Stream)
	Return MD5StreamHasher.Run(S)
End

Function MD5:MD5Hash(IA:Int[], Length:Int, Offset:Int=MD5Hasher<Int[]>.Default_Offset)
	Return MD5Hasher<Int[]>.Run(IA, Length, Offset)
End

Function MD5:MD5Hash(IA:Int[])
	Return MD5Hasher<Int[]>.Run(IA)
End

Function MD5:MD5Hash(Str:String, Length:Int, Offset:Int=MD5Hasher<String>.Default_Offset)
	Return MD5Hasher<String>.Run(Str, Length, Offset)
End

Function MD5:MD5Hash(Str:String)
	Return MD5Hasher<String>.Run(Str)
End

' Classes:
Class MD5Data
	' Constant variable(s):
	Const BLOCK_SIZE:= 16
	
	#If SIZEOF_IMPLEMENTED
		Const BLOCK_SIZE_IN_BYTES:= (BLOCK_SIZE*SizeOf_Byte_InBits)
	#Else
		Const BLOCK_SIZE_IN_BYTES:= (BLOCK_SIZE*8)
	#End
	
	Const BLOCK_SCOPE:= (BLOCK_SIZE Shl 2)
	
	' Shift values (Normally, the "K" values would be here too, but there's just too many):
	#If MD5_ALTERNATE_SHIFT Or Not MD5_GENERATE_DATA_WHERE_POSSIBLE Or MD5_MANUAL_PROCESSING 
		Const S1_1:= 7
		Const S1_2:= 12
		Const S1_3:= 17
		Const S1_4:= 22
		
		Const S2_1:= 5
		Const S2_2:= 9
		Const S2_3:= 14
		Const S2_4:= 20
		
		Const S3_1:= 4
		Const S3_2:= 11
		Const S3_3:= 16
		Const S3_4:= 23
		
		Const S4_1:= 6
		Const S4_2:= 10
		Const S4_3:= 15
		Const S4_4:= 21
	#End
	
	' Defaults:
	
	' Booleans / Flags:
	Const Default_InitKTable:Bool = True
	Const Default_InitShiftTable:Bool = True
	
	' Global variable(s):
	' Nothing so far.
	
	' Functions:
	' Nothing so far.
	
	' Constructor(s):
	Method New(MakeKTable:Bool=Default_InitKTable, MakeShiftTable:Bool=Default_InitShiftTable)
		If (MakeKTable) Then
			InitKTable()
		Endif
		
		If (MakeShiftTable) Then
			InitShiftTable()
		Endif
	End
	
	' Destructor(s):
	Method Free:Bool()
		K = []
		Shift = []
		
		' Return the default response.
		Return True
	End
	
	' Methods:
	Method InitKTable:Int[]()
		'K = [-680876936,-389564586,606105819,-1044525330,-176418897,1200080426,-1473231341,-45705983,1770035416,-1958414417,-42063,-1990404162,1804603682,-40341101,-1502002290,1236535329,-165796510,-1069501632,643717713,-373897302,-701558691,38016083,-660478335,-405537848,568446438,-1019803690,-187363961,1163531501,-1444681467,-51403784,1735328473,-1926607734,-378558,-2022574463,1839030562,-35309556,-1530992060,1272893353,-155497632,-1094730640,681279174,-358537222,-722521979,76029189,-640364487,-421815835,530742520,-995338651,-198630844,1126891415,-1416354905,-57434055,1700485571,-1894986606,-1051523,-2054922799,1873313359,-30611744,-1560198380,1309151649,-145523070,-1120210379,718787259,-343485551]
		K = [$d76aa478, $e8c7b756, $242070db, $c1bdceee, $f57c0faf, $4787c62a, $a8304613, $fd469501, $698098d8, $8b44f7af, $ffff5bb1, $895cd7be,$6b901122, $fd987193, $a679438e, $49b40821,$f61e2562, $c040b340, $265e5a51, $e9b6c7aa,$d62f105d, $02441453, $d8a1e681, $e7d3fbc8,$21e1cde6, $c33707d6, $f4d50d87, $455a14ed,$a9e3e905, $fcefa3f8, $676f02d9, $8d2a4c8a,$fffa3942, $8771f681, $6d9d6122, $fde5380c,$a4beea44, $4bdecfa9, $f6bb4b60, $bebfbc70,$289b7ec6, $eaa127fa, $d4ef3085, $04881d05,$d9d4d039, $e6db99e5, $1fa27cf8, $c4ac5665,$f4292244, $432aff97, $ab9423a7, $fc93a039,$655b59c3, $8f0ccc92, $ffeff47d, $85845dd1,$6fa87e4f, $fe2ce6e0, $a3014314, $4e0811a1,$f7537e82, $bd3af235, $2ad7d2bb, $eb86d391]
		
		Return K
	End
	
	Method InitShiftTable:Int[]()
		#If Not MD5_ALTERNATE_SHIFT
			#If MD5_GENERATE_DATA_WHERE_POSSIBLE
				Shift = New Int[64]
				
				For Local I:= 0 Until 16 Step 4
					Shift[I] = 7 ' S1_1
					Shift[I+1] = Shift[I]+5 ' S1_2
					Shift[I+2] = Shift[I+1]+5 ' S1_3
					Shift[I+3] = Shift[I+2]+5 ' S1_4
				Next
				
				For Local I:= 16 Until 32 Step 4
					Shift[I] = 5 ' S2_1
					Shift[I+1] = ((Shift[I]+Shift[I])-1) ' S2_2
					Shift[I+2] = Shift[I+1] + Shift[I] ' S2_3
					Shift[I+3] = Shift[I+2] + Shift[I] + 1 ' S2_4
				Next
				
				For Local I:= 32 Until 48 Step 4
					Shift[I] = 4 ' S3_1
					Shift[I+1] = Shift[I]+7 ' S3_2
					Shift[I+2] = Shift[I+1]+Shift[I]+1 ' S3_3
					Shift[I+3] = (Shift[I+2]+(Shift[I]*2)-1) ' S3_4
				Next
				
				For Local I:= 48 Until 64 Step 4
					Shift[I] = 6 ' S4_1
					Shift[I+1] = Shift[I]+4 ' S4_2
					Shift[I+2] = Shift[I+1]+(Shift[I]-1) ' S4_3
					Shift[I+3] = Shift[I+2]+Shift[I] ' S4_4
				Next
			#Else
				' This is the long version, see below for the simplified version.
				Shift = [S1_1, S1_2, S1_3, S1_4, S1_1, S1_2, S1_3, S1_4, S1_1, S1_2, S1_3, S1_4, S1_1, S1_2, S1_3, S1_4,
						S2_1, S2_2, S2_3, S2_4, S2_1, S2_2, S2_3, S2_4, S2_1, S2_2, S2_3, S2_4, S2_1, S2_2, S2_3, S2_4,
						S3_1, S3_2, S3_3, S3_4, S3_1, S3_2, S3_3, S3_4, S3_1, S3_2, S3_3, S3_4, S3_1, S3_2, S3_3, S3_4,
						S4_1, S4_2, S4_3, S4_4, S4_1, S4_2, S4_3, S4_4, S4_1, S4_2, S4_3, S4_4, S4_1, S4_2, S4_3, S4_4]
			#End
		#Else
			' This is the simplified version, look above for the long version.
			Shift = [S1_1, S1_2, S1_3, S1_4, S2_1, S2_2, S2_3, S2_4, S3_1, S3_2, S3_3, S3_4, S4_1, S4_2, S4_3, S4_4]
		#End
		
		' Return the generated array.
		Return Shift
	End
	
	' Fields:
	Field Shift:Int[]
	Field K:Int[]
End

Class MD5Component
	' Global variable(s):
	Global Standard_MD5Data:MD5Data
	
	' Functions:
	Function Init:Void()
		If (Standard_MD5Data <> Null) Then
			Return
		Endif
		
		Standard_MD5Data = New MD5Data(True, True)
		
		Return
	End
	
	' This isn't recommended:
	Function DeInit:Void()
		If (Standard_MD5Data = Null) Then
			Return
		Endif
		
		Standard_MD5Data.Free()
		
		Standard_MD5Data = Null
		
		Return
	End
End

Class MD5BufferHasher Extends MD5Engine<DataBuffer> Final
	' Constant variable(s):
	
	' Defaults:
	
	' Booleans / Flags:
	Const Default_ByteFix:Bool = True ' False
	Const Default_ClearCacheWhenFinished:Bool = True
	
	' Global variable(s) (Public):
	' Nothing so far.
	
	' Global variable(s) (Private):
	Private
	
	Global _Instance:MD5BufferHasher = Null
	
	Public
	
	' Functions:
	Function Instance:MD5BufferHasher()
		If (_Instance = Null) Then
			_Instance = New MD5BufferHasher()
		Endif
		
		Return _Instance
	End
	
	Function Run:MD5Hash(Data:DataBuffer)
		Return Instance().Execute(Data)
	End
	
	Function Run:MD5Hash(Data:DataBuffer, Length:Int, Offset:Int=Default_Offset)
		Return Instance().Execute(Data, Length, Offset)
	End
	
	' Constructor(s):
	Method New(ByteFix:Bool=Default_ByteFix, ClearCacheWhenFinished:Bool=Default_ClearCacheWhenFinished)
		Super.New(ClearCacheWhenFinished)
		
		Self.ByteFix = ByteFix
	End
	
	#If Not MD5_MANUAL_PROCESSING
		Method New(MetaData:MD5Data, ByteFix:Bool=Default_ByteFix, ClearCacheWhenFinished:Bool=Default_ClearCacheWhenFinished)
			Super.New(MetaData, ClearCacheWhenFinished)
			
			Self.ByteFix = ByteFix
		End
	#End
	
	' Methods:
	Method ExtractData:Int(Message:DataBuffer, Index:Int, Offset:Int, Length:Int=AUTO)
		Return Message.PeekByte(Index+Offset)
	End
	
	Method RetrieveLength:Int(Message:DataBuffer)
		Return Message.Length
	End
	
	Method CorrectByte:Int(B:Int)
		If (ByteFix And B < 0) Then
			Return (256+B)
		Endif
		
		Return B
	End
	
	' Fields:
	
	' Booleans / Flags:
	Field ByteFix:Bool
End

Class MD5StreamHasher Extends MD5Engine<Stream> Final ' This may end up inheriting from 'MD5Hasher' in the future.
	' Constant variable(s):
	
	' Defaults:
	'#If MD5_STREAM_ALLOW_DEFAULT_CACHESIZE
	Const Default_CacheSize:Int = AUTO ' 2048
	'#End
	
	Const Default_CharacterEncoding:String = "ascii"
	
	' Booleans / Flags:
	Const Default_ByteFix:Bool = True
	Const Default_ClearCacheWhenFinished:Bool = True ' False
	
	' Global variable(s) (Public):
	
	#Rem
		ATTENTION: For obvious reasons, the 'AUTO_CACHE_DIVISOR' variable must never be set to zero.
	#End
	
	#If MD5_STREAM_CACHE_MODE = MD5_STREAM_CACHE_MODE_STRING
		Global MAX_AUTO_CACHE_SIZE:Int = 4*1024*1024*10 ' 4*1024*1024
		Global AUTO_CACHE_DIVISOR:Int = 16 ' 8
		Global MIN_AUTO_CACHE_SIZE:Int = 8*1024*1024 ' 8*1024
	#Elseif MD5_STREAM_CACHE_MODE = MD5_STREAM_CACHE_MODE_BUFFER
		Global MAX_AUTO_CACHE_SIZE:Int = 4*1024*1024*10
		Global AUTO_CACHE_DIVISOR:Int = 8 ' 16 ' 4
		Global MIN_AUTO_CACHE_SIZE:Int = 8*1024*1024 ' 8*1024
	#Else
		Global MAX_AUTO_CACHE_SIZE:Int = 4*1024*1024*10 ' 1*1024*1024
		Global AUTO_CACHE_DIVISOR:Int = 8 ' 16 ' 4
		Global MIN_AUTO_CACHE_SIZE:Int = 8*1024*1024 ' 8*1024
	#End
	
	Global AUTO_CACHE_MAX_SIZE_ENABLED:Bool = True
	Global AUTO_CACHE_MIN_SIZE_ENABLED:Bool = True
	
	' Defaults:
	
	' Booleans / Flags:
	Global Default_BulkLoad:Bool = True
	
	' Global variable(s) (Private):
	Private
	
	Global _Instance:MD5StreamHasher = Null
	
	Public
	
	' Functions:
	Function Instance:MD5StreamHasher()
		If (_Instance = Null) Then
			_Instance = New MD5StreamHasher()
		Endif
		
		Return _Instance
	End
	
	Function Run:MD5Hash(Data:Stream)
		Return Instance().Execute(Data)
	End
	
	Function Run:MD5Hash(Data:Stream, Length:Int)
		Return Instance().Execute(Data, Length)
	End
	
	Function Run:MD5Hash(Data:Stream, Length:Int, Offset:Int)
		Return Instance().Execute(Data, Length, Offset)
	End
	
	' Constructor(s):
	Method New(CacheSize:Int=Default_CacheSize, BulkLoad:Bool=Default_BulkLoad, ClearCacheWhenFinished:Bool=Default_ClearCacheWhenFinished, ByteFix:Bool=Default_ByteFix)
		Super.New(ClearCacheWhenFinished)
		
		Self.CacheSize = CacheSize
		Self.BulkLoad = BulkLoad
		Self.ByteFix = ByteFix
	End
	
	#If Not MD5_MANUAL_PROCESSING
		Method New(MetaData:MD5Data, CacheSize:Int=Default_CacheSize, BulkLoad:Bool=Default_BulkLoad, ClearCacheWhenFinished:Bool=Default_ClearCacheWhenFinished, ByteFix:Bool=Default_ByteFix)
			Super.New(MetaData, ClearCacheWhenFinished)
			
			Self.CacheSize = CacheSize
			Self.BulkLoad = BulkLoad
			Self.ByteFix = ByteFix
		End
	#End
	
	' Methods:
	Method ExtractData:Int(Message:Stream, Position:Int, Offset:Int, Length:Int=AUTO)
		' Check for errors:
		#Rem
			If (Message.Eof()) Then
				Return -1
			Endif
		#End
		
		Local Index:= (Position+Offset)
		
		If (CacheSize = 0) Then
			Return ExtractByte(Message, Index)
		Endif
		
		If (Position = 0 Or Index >= CachePosition+Cache.Length) Then
			If (Length = AUTO) Then
				Length = Message.Length
			Endif
			
			Local BytesLeft:= Max(Length-Message.Position, 0)
			
			CachePosition = Message.Position
			
			Local BytesToRead:= Min(CacheSize, BytesLeft)
			
			#If MD5_STREAM_CACHE_MODE = MD5_STREAM_CACHE_MODE_ARRAY
				#If MD5_STREAM_ALLOW_SLOW_BULK_LOADING And UTIL_IMPLEMENTED
					If (BulkLoad) Then
						GenericUtilities<Int>.CopyStringToArray(Message.ReadString(BytesToRead, Default_CharacterEncoding), Cache)
					Else
				#End
						For Local I:Int = 0 Until BytesToRead
							Cache[I] = ExtractByte(Message, Index+I)
						Next
				#If MD5_STREAM_ALLOW_SLOW_BULK_LOADING And UTIL_IMPLEMENTED
					Endif
				#End
			#Elseif MD5_STREAM_CACHE_MODE = MD5_STREAM_CACHE_MODE_BUFFER
				If (BulkLoad) Then
					Message.ReadAll(Cache, 0, BytesToRead)
				Else
					For Local I:Int = 0 Until BytesToRead
						Cache.PokeByte(I, ExtractByte(Message, Index+I))
					Next
				Endif
			#Elseif MD5_STREAM_CACHE_MODE = MD5_STREAM_CACHE_MODE_STRING
				Cache = Message.ReadString(BytesToRead, Default_CharacterEncoding)
			#End
		Endif
		
		#If MD5_STREAM_CACHE_MODE = MD5_STREAM_CACHE_MODE_BUFFER
			Return Cache.PeekByte(Index-CachePosition)
		#Else
			Return Cache[Index-CachePosition]
		#End
	End
	
	Method ExtractByte:Int(Message:Stream, Index:Int)
		Return Message.ReadByte()
		
		#Rem
			'Local Position:= Message.Position
			Local Data:Int
			
			'Message.Seek(Index)
			
			Data = Message.ReadByte()
			
			'Message.Seek(Position)
			
			Return Data
		#End
	End
	
	Method RetrieveOffset:Int(Message:T)
		Return Message.Position
	End
	
	Method RetrieveLength:Int(Message:Stream)
		Return Message.Length ' AUTO
	End
	
	Method CorrectByte:Int(B:Int)
		If (ByteFix And B < 0) Then
			Return (256+B)
		Endif
		
		Return B
	End
	
	Method MakeCache:Void(Message:Stream)
		Local BytesLeft:= Max(Message.Length-Message.Position, 0)
		
		#If HASH_SAFE
			If (BytesLeft = 0) Then
				Return
			Endif
		#End
		
		If (CacheSize = AUTO) Then
			CacheSize = BytesLeft / AUTO_CACHE_DIVISOR
			
			If (AUTO_CACHE_MAX_SIZE_ENABLED) Then
				CacheSize = Min(CacheSize, MAX_AUTO_CACHE_SIZE)
			Endif
			
			If (AUTO_CACHE_MIN_SIZE_ENABLED) Then
				CacheSize = Max(CacheSize, MIN_AUTO_CACHE_SIZE)
			Endif
		Endif
		
		#If MD5_STREAM_CACHE_MODE = MD5_STREAM_CACHE_MODE_ARRAY
			#If MD5_STREAM_ALLOW_DEFAULT_CACHESIZE
				If (Default_CacheSize > 0 And Default_CacheSize <> AUTO And CacheSize <= 0) Then
					Cache = New Int[Default_CacheSize]
				Else
			#End
					Cache = New Int[CacheSize]
			#If MD5_STREAM_ALLOW_DEFAULT_CACHESIZE
				Endif
			#End
		#Elseif MD5_STREAM_CACHE_MODE = MD5_STREAM_CACHE_MODE_BUFFER
			If (Cache <> Null) Then
				Cache.Discard()
			Endif
			
			If (CacheSize <= 0 And Default_CacheSize > 0) Then
				Cache = New DataBuffer(Default_CacheSize)
			Else
				Cache = New DataBuffer(CacheSize)
			Endif
		#Elseif MD5_STREAM_CACHE_MODE = MD5_STREAM_CACHE_MODE_STRING
			' Nothing so far.
		#Else
			#Error "Unsupported caching mode."
		#End
		
		Return
	End
	
	Method DiscardCache:Void()
		If (ClearCacheWhenFinished) Then
			#If MD5_STREAM_CACHE_MODE = MD5_STREAM_CACHE_MODE_ARRAY
				Cache = []
			#Elseif MD5_STREAM_CACHE_MODE = MD5_STREAM_CACHE_MODE_STRING
				Cache = ""
			#Elseif MD5_STREAM_CACHE_MODE = MD5_STREAM_CACHE_MODE_BUFFER
				If (Cache <> Null) Then
					Cache.Discard(); Cache = Null
				Endif
			#End
		Endif
		
		CacheSize = 0
		CachePosition = 0
		
		Return
	End
	
	' Fields (Public):
	' Nothing so far.
	
	' Fields (Protected):
	Protected
	
	Field CacheSize:Int
	Field CachePosition:Int
	
	#If MD5_STREAM_CACHE_MODE = MD5_STREAM_CACHE_MODE_STRING
		Field Cache:String
	#Elseif MD5_STREAM_CACHE_MODE = MD5_STREAM_CACHE_MODE_BUFFER
		Field Cache:DataBuffer
	#Else 'Elseif MD5_STREAM_CACHE_MODE = MD5_STREAM_CACHE_MODE_ARRAY
		Field Cache:Int[]
	#End
	
	' Booleans / Flags:
	Field ByteFix:Bool
	Field BulkLoad:Bool
	
	Public
End

#Rem
	This class is mainly targeted towards arrays (Integer arrays mainly, but 'Object' based arrays would work if 'ToInt' is implemented).
	In addition, 'Strings' and objects which implement 'ToString' should also work.
#End

Class MD5Hasher<T> Extends MD5Engine<T> Final
	' Constant variable(s):
	
	' Defaults:
	
	' Booleans / Flags:
	Const Default_ClearCacheWhenFinished:Bool = False
	
	' Global variable(s) (Public):
	' Nothing so far.
	
	' Global variable(s) (Private):
	Private
	
	Global _Instance:MD5Hasher<T> = Null
	
	Public
	
	' Functions:
	Function Instance:MD5Hasher<T>()
		If (_Instance = Null) Then
			_Instance = New MD5Hasher<T>()
		Endif
		
		Return _Instance
	End
	
	Function Run:MD5Hash(Data:T)
		Return Instance().Execute(Data)
	End
	
	Function Run:MD5Hash(Data:T, Length:Int, Offset:Int=Default_Offset)
		Return Instance().Execute(Data, Length, Offset)
	End
	
	' Constructor(s):
	Method New(ClearCacheWhenFinished:Bool=Default_ClearCacheWhenFinished)
		Super.New(ClearCacheWhenFinished)
	End
	
	#If Not MD5_MANUAL_PROCESSING
		Method New(MetaData:MD5Data, ClearCacheWhenFinished:Bool=Default_ClearCacheWhenFinished)
			Super.New(MetaData, ClearCacheWhenFinished)
		End
	#End
	
	' Methods:
	Method ExtractData:Int(Message:T, Index:Int, Offset:Int, Length:Int=AUTO)
		Return Message[Index+Offset]
	End
	
	Method RetrieveLength:Int(Message:T)
		Return Message.Length
	End
End

Class MD5Engine<T> Extends MD5Component Abstract
	' Constant variable(s):
	Const BLOCK_SIZE:= MD5Data.BLOCK_SIZE
	Const BLOCK_SIZE_IN_BYTES:= MD5Data.BLOCK_SIZE_IN_BYTES
	Const BLOCK_SCOPE:= MD5Data.BLOCK_SCOPE
	
	Const AUTO:= MD5_AUTO
	
	Const ZERO:Int = 0
	
	' Defaults:
	Const Default_Offset:= 0
	
	' Booleans / Flags:
	Const Default_ClearCacheWhenFinished:Bool = False ' True
	
	' Functions (Public):
	
	' These functions are only used within the main implementation when 'MD5_MANUAL_PROCESSING' is enabled.
	Function MD5_FF:Int(A:Int, B:Int, C:Int, D:Int, BlockData:Int, ShiftValue:Int, KValue:Int)
		Return RotateLeft(A + MD5_F(B, C, D) + BlockData + KValue, ShiftValue) + B
	End
	
	Function MD5_GG:Int(A:Int, B:Int, C:Int, D:Int, BlockData:Int, ShiftValue:Int, KValue:Int)
		Return RotateLeft(A + MD5_G(B, C, D) + BlockData + KValue, ShiftValue) + B
	End
	
	Function MD5_HH:Int(A:Int, B:Int, C:Int, D:Int, BlockData:Int, ShiftValue:Int, KValue:Int)
		Return RotateLeft(A + MD5_H(B, C, D) + BlockData + KValue, ShiftValue) + B
	End
	
	Function MD5_II:Int(A:Int, B:Int, C:Int, D:Int, BlockData:Int, ShiftValue:Int, KValue:Int)
		Return RotateLeft(A + MD5_I(B, C, D) + BlockData + KValue, ShiftValue) + B
	End
	
	' Functions (Private):
	Private
	
	Function MD5_F:Int(X:Int, Y:Int, Z:Int)
		Return ((X & Y) | ((~X) & Z))
	End
	
	Function MD5_G:Int(X:Int, Y:Int, Z:Int)
		Return ((X & Z) | (Y & (~Z)))
	End
	
	Function MD5_H:Int(X:Int, Y:Int, Z:Int)
		Return (X ~ Y ~ Z)
	End
	
	Function MD5_I:Int(X:Int, Y:Int, Z:Int)
		Return (Y ~ (X | (~Z)))
	End
	
	Public
	
	' Constructor(s):
	Method New(ClearCacheWhenFinished:Bool=Default_ClearCacheWhenFinished)
		#If Not MD5_MANUAL_PROCESSING
			Init()
			
			Self.MetaData = Standard_MD5Data
		#End
		
		Self.ClearCacheWhenFinished = ClearCacheWhenFinished
	End
	
	#If Not MD5_MANUAL_PROCESSING
		Method New(MetaData:MD5Data, ClearCacheWhenFinished:Bool=Default_ClearCacheWhenFinished)
			Self.MetaData = MetaData
			Self.ClearCacheWhenFinished = ClearCacheWhenFinished
		End
	#End
	
	' Methods (Public):
	Method Execute:MD5Hash(Message:T)
		Return Execute(Message, RetrieveLength(Message), RetrieveOffset(Message))
	End
	
	Method Execute:MD5Hash(Message:T, Length:Int)
		Return Execute(Message, Length, RetrieveOffset(Message))
	End
	
	Method Execute:MD5Hash(Message:T, Length:Int, Offset:Int)
		' Local variable(s):
		Local BlockCount:Int = ((Length + 8) Shr 6) + 1
		Local BlockID:Int = 0
		
		Local A0:Int = $67452301 ' 1732584193
		Local B0:Int = $efcdab89 ' -271733879
		Local C0:Int = $98badcfe ' -1732584194
		Local D0:Int = $10325476 ' 271733878
		
		' The "virtual" size of the block cache/array. (Used for data transformation)
		Local VirtualBlockArraySize:= (BlockCount * BLOCK_SIZE)
		Local FinalBlockPosition:= (VirtualBlockArraySize - BLOCK_SIZE)
		
		MakeCache(Message)
		
		For Local BlockIndex:= 0 Until VirtualBlockArraySize Step BLOCK_SIZE
			' Calculate the current block-ID:
			If (BlockIndex > 0) Then
				BlockID = (BlockIndex/BLOCK_SIZE)
			Endif
			
			' Clear the current block.
			'Block = ZeroBlock(Block)
			ZeroBlock(Block)
			
			' Copy the data from the message into the block's cache (In shifted/encoded form):
			For Local I:= BLOCK_SCOPE*BlockID Until Min(BLOCK_SCOPE*(BlockID+1), Length)
				'(I+Offset) Mod Length
				Block[((I Shr 2) Mod BLOCK_SIZE)] |= (CorrectByte(ExtractData(Message, I, Offset, Length)) Shl ((I Mod 4) * 8))
			Next
			
			If (BlockIndex = FinalBlockPosition) Then
				Block[(Length Shr 2) Mod BLOCK_SIZE] |= (BLOCK_SIZE_IN_BYTES Shl ((Length Mod 4) * 8)) ' ((BLOCK_SCOPE*2) Shl ...)
				Block[(VirtualBlockArraySize - 2) Mod BLOCK_SIZE] = Length * 8
			Endif
			
			' Local variable(s):
			Local A:= A0
			Local B:= B0
			Local C:= C0
			Local D:= D0
			
			#If MD5_MANUAL_PROCESSING
				' First round:
				A = MD5_FF(A, B, C, D, Block[0], MD5Data.S1_1, $d76aa478)
				D = MD5_FF(D, A, B, C, Block[1], MD5Data.S1_2, $e8c7b756)
				C = MD5_FF(C, D, A, B, Block[2], MD5Data.S1_3, $242070db)
				B = MD5_FF(B, C, D, A, Block[3], MD5Data.S1_4, $c1bdceee)
				
				A = MD5_FF(A, B, C, D, Block[4], MD5Data.S1_1, $f57c0faf)
				D = MD5_FF(D, A, B, C, Block[5], MD5Data.S1_2, $4787c62a)
				C = MD5_FF(C, D, A, B, Block[6], MD5Data.S1_3, $a8304613)
				B = MD5_FF(B, C, D, A, Block[7], MD5Data.S1_4, $fd469501)
				
				A = MD5_FF(A, B, C, D, Block[8], MD5Data.S1_1, $698098d8)
				D = MD5_FF(D, A, B, C, Block[9], MD5Data.S1_2, $8b44f7af)
				C = MD5_FF(C, D, A, B, Block[10], MD5Data.S1_3, $ffff5bb1)
				B = MD5_FF(B, C, D, A, Block[11], MD5Data.S1_4, $895cd7be)
				
				A = MD5_FF(A, B, C, D, Block[12], MD5Data.S1_1, $6b901122)
				D = MD5_FF(D, A, B, C, Block[13], MD5Data.S1_2, $fd987193)
				C = MD5_FF(C, D, A, B, Block[14], MD5Data.S1_3, $a679438e)
				B = MD5_FF(B, C, D, A, Block[15], MD5Data.S1_4, $49b40821)
				
				' Second round:
				A = MD5_GG(A, B, C, D, Block[1], MD5Data.S2_1, $f61e2562)
				D = MD5_GG(D, A, B, C, Block[6], MD5Data.S2_2, $c040b340)
				C = MD5_GG(C, D, A, B, Block[11], MD5Data.S2_3, $265e5a51)
				B = MD5_GG(B, C, D, A, Block[0], MD5Data.S2_4, $e9b6c7aa)
				
				A = MD5_GG(A, B, C, D, Block[5], MD5Data.S2_1, $d62f105d)
				D = MD5_GG(D, A, B, C, Block[10], MD5Data.S2_2, $02441453)
				C = MD5_GG(C, D, A, B, Block[15], MD5Data.S2_3, $d8a1e681)
				B = MD5_GG(B, C, D, A, Block[4], MD5Data.S2_4, $e7d3fbc8)
				
				A = MD5_GG(A, B, C, D, Block[9], MD5Data.S2_1, $21e1cde6)
				D = MD5_GG(D, A, B, C, Block[14], MD5Data.S2_2, $c33707d6)
				C = MD5_GG(C, D, A, B, Block[3], MD5Data.S2_3, $f4d50d87)
				B = MD5_GG(B, C, D, A, Block[8], MD5Data.S2_4, $455a14ed)
				
				A = MD5_GG(A, B, C, D, Block[13], MD5Data.S2_1, $a9e3e905)
				D = MD5_GG(D, A, B, C, Block[2], MD5Data.S2_2, $fcefa3f8)
				C = MD5_GG(C, D, A, B, Block[7], MD5Data.S2_3, $676f02d9)
				B = MD5_GG(B, C, D, A, Block[12], MD5Data.S2_4, $8d2a4c8a)
				
				' Third round:
				A = MD5_HH(A, B, C, D, Block[5], MD5Data.S3_1, $fffa3942)
				D = MD5_HH(D, A, B, C, Block[8], MD5Data.S3_2, $8771f681)
				C = MD5_HH(C, D, A, B, Block[11], MD5Data.S3_3, $6d9d6122)
				B = MD5_HH(B, C, D, A, Block[14], MD5Data.S3_4, $fde5380c)
				
				A = MD5_HH(A, B, C, D, Block[1], MD5Data.S3_1, $a4beea44)
				D = MD5_HH(D, A, B, C, Block[4], MD5Data.S3_2, $4bdecfa9)
				C = MD5_HH(C, D, A, B, Block[7], MD5Data.S3_3, $f6bb4b60)
				B = MD5_HH(B, C, D, A, Block[10], MD5Data.S3_4, $bebfbc70)
				
				A = MD5_HH(A, B, C, D, Block[13], MD5Data.S3_1, $289b7ec6)
				D = MD5_HH(D, A, B, C, Block[0], MD5Data.S3_2, $eaa127fa)
				C = MD5_HH(C, D, A, B, Block[3], MD5Data.S3_3, $d4ef3085)
				B = MD5_HH(B, C, D, A, Block[6], MD5Data.S3_4, $04881d05)
				
				A = MD5_HH(A, B, C, D, Block[9], MD5Data.S3_1, $d9d4d039)
				D = MD5_HH(D, A, B, C, Block[12], MD5Data.S3_2, $e6db99e5)
				C = MD5_HH(C, D, A, B, Block[15], MD5Data.S3_3, $1fa27cf8)
				B = MD5_HH(B, C, D, A, Block[2], MD5Data.S3_4, $c4ac5665)
				
				' Fourth / Final round:
				A = MD5_II(A, B, C, D, Block[0], MD5Data.S4_1, $f4292244)
				D = MD5_II(D, A, B, C, Block[7], MD5Data.S4_2, $432aff97)
				C = MD5_II(C, D, A, B, Block[14], MD5Data.S4_3, $ab9423a7)
				B = MD5_II(B, C, D, A, Block[5], MD5Data.S4_4, $fc93a039)
				
				A = MD5_II(A, B, C, D, Block[12], MD5Data.S4_1, $655b59c3)
				D = MD5_II(D, A, B, C, Block[3], MD5Data.S4_2, $8f0ccc92)
				C = MD5_II(C, D, A, B, Block[10], MD5Data.S4_3, $ffeff47d)
				B = MD5_II(B, C, D, A, Block[1], MD5Data.S4_4, $85845dd1)
				
				A = MD5_II(A, B, C, D, Block[8], MD5Data.S4_1, $6fa87e4f)
				D = MD5_II(D, A, B, C, Block[15], MD5Data.S4_2, $fe2ce6e0)
				C = MD5_II(C, D, A, B, Block[6], MD5Data.S4_3, $a3014314)
				B = MD5_II(B, C, D, A, Block[13], MD5Data.S4_4, $4e0811a1)
				
				A = MD5_II(A, B, C, D, Block[4], MD5Data.S4_1, $f7537e82)
				D = MD5_II(D, A, B, C, Block[11], MD5Data.S4_2, $bd3af235)
				C = MD5_II(C, D, A, B, Block[2], MD5Data.S4_3, $2ad7d2bb)
				B = MD5_II(B, C, D, A, Block[9], MD5Data.S4_4, $eb86d391)
			#Else
				#If Not MD5_ALTERNATE_SHIFT
					Local F:Int
					Local G:Int
				#End
				
				For Local I:= 0 Until 64
					#If Not MD5_ALTERNATE_SHIFT
						If (I < 16) Then
							'F = (B & C) | ((~B) & D)
							'G = I Mod BLOCK_SIZE
							
							F = D ~ (B & (C ~ D))
							G = I Mod BLOCK_SIZE
						Elseif (I < 32) Then
							'F = (D & B) | ((~D) & C)
							'G = (5*I + 1) Mod BLOCK_SIZE
							
							F = C ~ (D & (B ~ C))
							G = (5 * I + 1) Mod BLOCK_SIZE
						Elseif (I < 48) Then
							'F = B ~ C ~ D
							'G = (3*I + 5) Mod BLOCK_SIZE
							
							F = B ~ C ~ D
							G = (3 * I + 5) Mod BLOCK_SIZE
						Elseif (I < 64) Then
							'F = C ~ (B | (~D))
							'G = (7*I) Mod BLOCK_SIZE
							
							F = C ~ (B | (~D))
							G = (7 * I) Mod BLOCK_SIZE
						Endif
					#End
					
					Local E:= D
					
					D = C
					C = B
					
					#If MD5_ALTERNATE_SHIFT
						If (I < 16) Then
							' (D ~ (E & (C ~ D)))
							B += RotateLeft(A + (E ~ (C & (D ~ E))) + MetaData.K[I] + Block[I Mod BLOCK_SIZE], MetaData.Shift[I Mod 4])
						Elseif (I < 32) Then
							B += RotateLeft(A + (D ~ (E & (C ~ D))) + MetaData.K[I] + Block[(5 * I + 1) Mod BLOCK_SIZE], MetaData.Shift[(I Mod 4) + 4])
						Elseif (I < 48) Then
							B += RotateLeft(A + (C ~ D ~ E) + MetaData.K[I] + Block[(3 * I + 5) Mod BLOCK_SIZE], MetaData.Shift[(I Mod 4) + 8])
						Else ' If (I < 64) Then
							B += RotateLeft(A + (D ~ (C | (~E))) + MetaData.K[I] + Block[(7 * I) Mod BLOCK_SIZE], MetaData.Shift[(I Mod 4) + 12])
						Endif
					#Else
						B += RotateLeft(A + F + MetaData.K[I] + Block[G], MetaData.Shift[I])
					#End
					
					A = E
				Next
			#End
			
			A0 += A
			B0 += B
			C0 += C
			D0 += D
		Next
		
		DiscardCache()
		
		Return IntToHex((A0)) + IntToHex((B0)) + IntToHex((C0)) + IntToHex((D0))
	End
	
	Method CorrectByte:Int(B:Int)
		Return B
	End
	
	Method ZeroBlock:Int[](Block:Int[])
		#If UTIL_IMPLEMENTED
			GenericUtilities<Int>.Zero(Block)
		#Else
			For Local Index:= 0 Until Block.Length
				Block[Index] = ZERO
			Next
		#End
		
		Return Block
	End
	
	Method RetrieveOffset:Int(Message:T)
		Return Default_Offset
	End
	
	' Purely virtual methods:
	
	' This routine should not copy/read from, or otherwise mutate 'Message'.
	' That argument is passed for analysis purposes only.
	Method MakeCache:Void(Message:T)
		' Implement this if needed.
		
		Return
	End
	
	Method DiscardCache:Void()
		' Implement this if needed.
		
		Return
	End
	
	' Abstract methods:
	Method ExtractData:Int(Message:T, Index:Int, Offset:Int, Length:Int=AUTO) Abstract
	Method RetrieveLength:Int(Message:T) Abstract
	
	' Methods (Private):
	Private
	
	' Nothing so far.
	
	Public
	
	' Fields:
	
	' Most MD5 related meta-data needed for execution.
	#If Not MD5_MANUAL_PROCESSING
		Field MetaData:MD5Data
	#End
	
	' An array cached per-hasher, which is used for block calculations upon execution.
	Field Block:Int[BLOCK_SIZE]
	
	' Booleans / Flags:
	Field ClearCacheWhenFinished:Bool
End