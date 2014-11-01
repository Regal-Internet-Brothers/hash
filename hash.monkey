#Rem
	NOTES:
		* Please do not use the standard 'MD5Hasher' class for 'DataBuffers' and 'Streams'.
		These must be handled by their respective "hashers". Other than that, you should be good.
		
		* The 'MD5Hasher' class was developed with arrays (Integer arrays) in mind, but by extension, 'Strings' do work. (Very well, I might add)
		
		* To use this module simply do the following:
		
		Rough example:
		
		MD5HasherClassHere.Run(DataHere)
		
		Real world example:
		
		' To calculate the hash of a string, do this.
		MD5Hasher<String>.Run(Str)
		
		Alternatively, you can call 'MD5HasherClassHere.Instance' in order to configure the global instance.
		Or, you could always create your own instance of the class, and configure it from there.
		
		For the sake of benchmarking, it's recommended that you just use the global instance as you see fit. (Through 'Run', or 'Instance')
		
		* Standard 'Stream' support is implemented, but not completely tested.
		It's a dirty hack, but it does the job well enough. Use at your own risk.
		
		* All functionality present should be in working order, and follow standard MD5 behaviour.
		If you get undesired results, please let me know. Please note that on the standard C++ targets (Targets using Monkey's garbage collector),
		this implementation tends to be bottlenecked by your GC settings.
		
		Some things are generated for the sake of memory efficiency. This was built with limited memory environments in mind.
		In fact part of why I made this was to test out Monkey performance-wise on embedded ARM systems.
		
		Most things which are generated are specific to the input, and because of this, they can not be cached properly.
		(Without some reworking which I may or may not do)
#End

Strict

Public

' Preprocessor related:
#MD5_STREAM_CACHE_MODE_ARRAY		= 0
#MD5_STREAM_CACHE_MODE_STRING		= 1
#MD5_STREAM_CACHE_MODE_BUFFER		= 2

#If TARGET = "android"
	#MD5_STREAM_CACHE_MODE = MD5_STREAM_CACHE_MODE_ARRAY ' MD5_STREAM_CACHE_MODE_STRING
#Else
	#MD5_STREAM_CACHE_MODE = MD5_STREAM_CACHE_MODE_BUFFER ' MD5_STREAM_CACHE_MODE_ARRAY
#End

' Imports (External):
#If UTIL_IMPLEMENTED
	Import util
#Else
	Import retrostrings
#End

Import sizeof

' Standard BRL modules:
Import brl.stream
Import brl.databuffer

' Imports (Internal):

' External language bindings.
Import external

' Aliases:
Alias HexValue = String
Alias Hash = HexValue
Alias MD5Hash = Hash

' Constant variable(s):
#If UTIL_IMPLEMENTED
	Const MD5_AUTO:= UTIL_AUTO
#Else
	Const MD5_AUTO:Int = -1
#End

' Global variable(s):
' Nothing so far.

' Functions (Public):

' Quick wrappers for the standard classes' 'Run' commands:
Function MD5:MD5Hash(Data:DataBuffer, Length:Int=MD5_AUTO, Offset:Int=0)
	Return MD5BufferHasher.Run(Data, Length, Offset)
End

Function MD5:MD5Hash(S:Stream, Length:Int=MD5_AUTO, Offset:Int=0)
	Return MD5StreamHasher.Run(S, Length, Offset)
End

Function MD5:MD5Hash(IA:Int[], Length:Int=MD5_AUTO, Offset:Int=0)
	Return MD5Hasher<Int[]>.Run(IA, Length, Offset)
End

Function MD5:MD5Hash(Str:String, Length:Int=MD5_AUTO, Offset:Int=0)
	Return MD5Hasher<String>.Run(Str, Length, Offset)
End

' This is effectively just a really quick rewrite of Java's 'hashCode' method:
Function HashCode:Int(S:String)
	' Local variable(s):
	Local Hash:Int = 0
	
	' Compute the "hash code":
	For Local I:= 0 Until S.Length()
		Hash = 31*Hash + S[I]
	Next
	
	' Return the resulting hash.
	Return Hash
End

Function HashCodeInHex:HexValue(S:String)
	' Return the hash-code in hexadecimal.
	Return IntToHex(HashCode(S))
End

Function RotateLeft:Int(Value:Int, ShiftBits:Int)
	#If Not SIZEOF_IMPLEMENTED
		Const SizeOf_Integer_InBits:Int = 4*8 ' 32-bit.
	#End
	
	Return Lsl(Value, ShiftBits) | Lsr( Value, (SizeOf_Integer_InBits - ShiftBits))
	'Return (Value Shl ShiftBits) | (Value Shr (32-ShiftBits))
End

' Functions (Private):
Private

Function IntToHex:HexValue(Data:Int)
	Return HexLE(Data)
End

Public

' Classes:
Class MD5Data
	' Constant variable(s):
	
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
		Shift = New Int[64]
		
		For Local I:= 0 Until 16 Step 4
			Shift[I] = 7
			Shift[I+1] = Shift[I]+5
			Shift[I+2] = Shift[I+1]+5
			Shift[I+3] = Shift[I+2]+5
		Next
		
		For Local I:= 16 Until 32 Step 4
			Shift[I] = 5
			Shift[I+1] = ((Shift[I]+Shift[I])-1)
			Shift[I+2] = Shift[I+1] + Shift[I]
			Shift[I+3] = Shift[I+2] + Shift[I] + 1
		Next
		
		For Local I:= 32 Until 48 Step 4
			Shift[I] = 4
			Shift[I+1] = Shift[I]+7
			Shift[I+2] = Shift[I+1]+Shift[I]+1
			Shift[I+3] = (Shift[I+2]+(Shift[I]*2)-1)
		Next
		
		For Local I:= 48 Until 64 Step 4
			Shift[I] = 6
			Shift[I+1] = Shift[I]+4
			Shift[I+2] = Shift[I+1]+(Shift[I]-1)
			Shift[I+3] = Shift[I+2]+Shift[I]
		Next
		
		Return Shift
	End
	
	' Fields:
	Field Shift:Int[], K:Int[]
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
	
	Function Run:MD5Hash(Data:DataBuffer, Length:Int=AUTO, Offset:Int=Default_Offset)
		Return Instance().Execute(Data, Length, Offset)
	End
	
	' Constructor(s):
	Method New(ByteFix:Bool=Default_ByteFix, ClearCacheWhenFinished:Bool=Default_ClearCacheWhenFinished)
		Super.New(ClearCacheWhenFinished)
		
		Self.ByteFix = ByteFix
	End
	
	Method New(MetaData:MD5Data, ByteFix:Bool=Default_ByteFix, ClearCacheWhenFinished:Bool=Default_ClearCacheWhenFinished)
		Super.New(MetaData, ClearCacheWhenFinished)
		
		Self.ByteFix = ByteFix
	End
	
	' Methods:
	Method ExtractData:Int(Message:DataBuffer, Index:Int, Length:Int=AUTO)
		Return Message.PeekByte(Index)
	End
	
	Method RetrieveLength:Int(Message:DataBuffer)
		Return Message.Length()
	End
	
	Method CorrectByte:Int(B:Int)
		If (ByteFix) Then
			If (B < 0) Then
				Return (256+B)
			Endif
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
	Const Default_CacheSize:Int = AUTO ' 2048
	Const Default_CharacterEncoding:String = "ascii"
	
	' Booleans / Flags:
	Const Default_ByteFix:Bool = True
	Const Default_ClearCacheWhenFinished:Bool = True ' False
	
	' Global variable(s) (Public):
	
	#Rem
		ATTENTION: For obvious reasons, the 'AUTO_CACHE_DIVISOR' variable must never be set to zero.
	#End
	
	#If MD5_STREAM_CACHE_MODE = MD5_STREAM_CACHE_MODE_STRING
		Global MAX_AUTO_CACHE_SIZE:Int = 40*1024*1024 ' 4*1024*1024
		Global AUTO_CACHE_DIVISOR:Int = 16
	#Elseif MD5_STREAM_CACHE_MODE = MD5_STREAM_CACHE_MODE_BUFFER
		Global MAX_AUTO_CACHE_SIZE:Int = 40*1024*1024
		Global AUTO_CACHE_DIVISOR:Int = 8 ' 16
	#Else
		Global MAX_AUTO_CACHE_SIZE:Int = 40*1024*1024 ' 1*1024*1024
		Global AUTO_CACHE_DIVISOR:Int = 16
	#End
	
	Global MIN_AUTO_CACHE_SIZE:Int = 8*1024*1024 ' 8*1024
	
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
	
	Function Run:MD5Hash(Data:Stream, Length:Int=AUTO, Offset:Int=Default_Offset)
		Return Instance().Execute(Data, Length, Offset)
	End
	
	' Constructor(s):
	Method New(CacheSize:Int=Default_CacheSize, BulkLoad:Bool=Default_BulkLoad, ClearCacheWhenFinished:Bool=Default_ClearCacheWhenFinished, ByteFix:Bool=Default_ByteFix)
		Super.New(ClearCacheWhenFinished)
		
		Self.CacheSize = CacheSize
		Self.BulkLoad = BulkLoad
		Self.ByteFix = ByteFix
	End
	
	Method New(MetaData:MD5Data, CacheSize:Int=Default_CacheSize, BulkLoad:Bool=Default_BulkLoad, ClearCacheWhenFinished:Bool=Default_ClearCacheWhenFinished, ByteFix:Bool=Default_ByteFix)
		Super.New(MetaData, ClearCacheWhenFinished)
		
		Self.CacheSize = CacheSize
		Self.BulkLoad = BulkLoad
		Self.ByteFix = ByteFix
	End
	
	' Methods:
	Method ExtractData:Int(Message:Stream, Index:Int, Length:Int=AUTO)
		' Check for errors:
		#Rem
			If (Message.Eof()) Then
				Return -1
			Endif
		#End
		
		If (CacheSize = 0) Then
			Return ExtractByte(Message, Index)
		Endif
		
		Local CacheCheck:Bool = False
		
		#If MD5_STREAM_CACHE_MODE = MD5_STREAM_CACHE_MODE_BUFFER
			CacheCheck = (Cache = Null)
		#End
		
		If (Not CacheCheck) Then
			CacheCheck = (Index >= CachePosition+Cache.Length())
		Endif
		
		If (CacheCheck) Then
			If (Length = AUTO) Then
				Length = Message.Length()
			Endif
			
			Local BytesLeft:= Max(Length-Message.Position(), 0)
			
			Local CacheLengthComparison:Bool = False
			
			#If MD5_STREAM_CACHE_MODE = MD5_STREAM_CACHE_MODE_BUFFER
				CacheLengthComparison = (Cache = Null)
			#End
			
			If (Not CacheLengthComparison) Then
				CacheLengthComparison = (CacheSize <> Cache.Length())
			Endif
			
			If (CacheLengthComparison) Then
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
					If (CacheSize <= 0 And Default_CacheSize > 0) Then
						Cache = New Int[Default_CacheSize]
					Else
						Cache = New Int[CacheSize]
					Endif
				#Elseif MD5_STREAM_CACHE_MODE = MD5_STREAM_CACHE_MODE_BUFFER
					If (Cache <> Null) Then
						Cache.Discard()
					Endif
					
					If (CacheSize <= 0 And Default_CacheSize > 0) Then
						Cache = New DataBuffer(Default_CacheSize)
					Else
						Cache = New DataBuffer(CacheSize)
					Endif
				#Else
					' Nothing so far.
				#End
			Else
				'GenericUtilities<Int>.Zero(Cache)
			Endif
			
			CachePosition = Message.Position()
			
			Local BytesToRead:= Min(CacheSize, BytesLeft)
			
			#If MD5_STREAM_CACHE_MODE = MD5_STREAM_CACHE_MODE_ARRAY
				If (BulkLoad) Then
					GenericUtilities<Int>.CopyStringToArray(Message.ReadString(BytesToRead, Default_CharacterEncoding), Cache)
				Else
					For Local I:Int = 0 Until BytesToRead
						Cache[I] = ExtractByte(Message, Index+I)
					Next
				Endif
			#Elseif MD5_STREAM_CACHE_MODE = MD5_STREAM_CACHE_MODE_BUFFER
				If (BulkLoad) Then
					Message.Read(Cache, 0, BytesToRead)
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
			'Local Position:= Message.Position()
			Local Data:Int
			
			'Message.Seek(Index)
			
			Data = Message.ReadByte()
			
			'Message.Seek(Position)
			
			Return Data
		#End
	End
	
	Method RetrieveLength:Int(Message:Stream)
		Return Message.Length() ' AUTO
	End
	
	Method CorrectByte:Int(B:Int)
		If (ByteFix) Then
			If (B < 0) Then
				Return (256+B)
			Endif
		Endif
		
		Return B
	End
	
	Method DiscardCache:Void()
		#If MD5_STREAM_CACHE_MODE = MD5_STREAM_CACHE_MODE_ARRAY
			Cache = []
		#Elseif MD5_STREAM_CACHE_MODE = MD5_STREAM_CACHE_MODE_STRING
			Cache = ""
		#Elseif MD5_STREAM_CACHE_MODE = MD5_STREAM_CACHE_MODE_BUFFER
			Cache.Discard(); Cache = Null
		#End
		
		Return
	End
	
	' Fields:
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
	
	Function Run:MD5Hash(Data:T, Length:Int=AUTO, Offset:Int=Default_Offset)
		Return Instance().Execute(Data, Length, Offset)
	End
	
	' Constructor(s):
	Method New(ClearCacheWhenFinished:Bool=Default_ClearCacheWhenFinished)
		Super.New(ClearCacheWhenFinished)
	End
	
	Method New(MetaData:MD5Data, ClearCacheWhenFinished:Bool=Default_ClearCacheWhenFinished)
		Super.New(MetaData, ClearCacheWhenFinished)
	End
	
	' Methods:
	Method ExtractData:Int(Message:T, Index:Int, Length:Int=AUTO)
		Return Message[Index]
	End
	
	Method RetrieveLength:Int(Message:T)
		Return Message.Length()
	End
End

Class MD5Engine<T> Extends MD5Component Abstract
	' Constant variable(s):
	Const BLOCK_SIZE:Int = 16
	
	Const ZERO:Int = 0
	Const AUTO:= MD5_AUTO
	
	' Defaults:
	Const Default_Offset:Int = 0
	
	' Booleans / Flags:
	Const Default_ClearCacheWhenFinished:Bool = False ' True
	
	' Constructor(s):
	Method New(ClearCacheWhenFinished:Bool=Default_ClearCacheWhenFinished)
		Init()
		
		Self.MetaData = Standard_MD5Data
		Self.ClearCacheWhenFinished = ClearCacheWhenFinished
	End
	
	Method New(MetaData:MD5Data, ClearCacheWhenFinished:Bool=Default_ClearCacheWhenFinished)
		Self.MetaData = MetaData
		Self.ClearCacheWhenFinished = ClearCacheWhenFinished
	End
	
	' Methods (Public):
	Method Execute:MD5Hash(Message:T, Length:Int=AUTO, Offset:Int=Default_Offset)
		If (Length = AUTO) Then
			Length = RetrieveLength(Message)
		Endif
		
		' Local variable(s):
		Local BlockCount:Int = ((Length + 8) Shr 6) + 1
		
		Local A0:Int = $67452301 ' 1732584193
		Local B0:Int = $efcdab89 ' -271733879
		Local C0:Int = $98badcfe ' -1732584194
		Local D0:Int = $10325476 ' 271733878
		
		Local VirtualBlockArraySize:= (BlockCount * BLOCK_SIZE)
		Local BlockCalculationScope:= (BLOCK_SIZE Shl 2)
		
		For Local BlockIndex:= 0 Until VirtualBlockArraySize Step BLOCK_SIZE
			Local BlockID:Int = 0
			
			If (BlockIndex > 0) Then
				BlockID = (BlockIndex/BLOCK_SIZE)
			Endif
			
			Block = ZeroBlock(Block)
			
			For Local I:= BlockCalculationScope*BlockID Until Min(BlockCalculationScope*(BlockID+1), Length)
				'(I+Offset) Mod Length
				Block[((I Shr 2) Mod BLOCK_SIZE)] |= (CorrectByte(ExtractData(Message, (I+Offset), Length)) Shl ((I Mod 4) * 8))
			Next
			
			If (BlockIndex = VirtualBlockArraySize - (BLOCK_SIZE)) Then
				Block[(Length Shr 2) Mod BLOCK_SIZE] |= (128 Shl ((Length Mod 4) * 8))
				Block[(VirtualBlockArraySize - 2) Mod BLOCK_SIZE] = Length * 8
			Endif
			
			' Local variable(s):
			Local A:= A0
			Local B:= B0
			Local C:= C0
			Local D:= D0
			
			Local F:Int
			Local G:Int
			
			For Local I:= 0 Until 64
				If (I < 16) Then
					'F = (B & C) | ((~B) & D)
					'G = I
					
					F = D ~ (B & (C ~ D))
					G = I
				Elseif (I < 32) Then
					'F = (D & B) | ((~D) & C)
					'G = (5*I + 1) Mod 16
					
					F = C ~ (D & (B ~ C))
					G = (5 * I + 1) Mod 16
				Elseif (I < 48) Then
					'F = B ~ C ~ D
					'G = (3*I + 5) Mod 16
					
					F = B ~ C ~ D
					G = (3 * I + 5) Mod 16
				Elseif (I < 64) Then
					'F = C ~ (B | (~D))
					'G = (7*I) Mod 16
					
					F = C ~ (B | (~D))
					G = (7 * I) Mod 16
				Endif
				
				Local TempD:= D
				
				D = C
				C = B
				B += RotateLeft(A + F + MetaData.K[I] + Block[G Mod BLOCK_SIZE], MetaData.Shift[I])
				A = TempD
			Next
			
			A0 += A
			B0 += B
			C0 += C
			D0 += D
		Next
		
		If (ClearCacheWhenFinished) Then
			DiscardCache()
		Endif
		
		Return IntToHex((A0)) + IntToHex((B0)) + IntToHex((C0)) + IntToHex((D0))
	End
	
	Method CorrectByte:Int(B:Int)
		Return B
	End
	
	Method ZeroBlock:Int[](Block:Int[])
		#If UTIL_IMPLEMENTED
			GenericUtilities<Int>.Zero(Block)
		#Else
			For Local Index:= 0 Until Block.Length()
				Block[Index] = ZERO
			Next
		#End
		
		Return Block
	End
	
	' Purely virtual methods:
	Method DiscardCache:Void()
		' Implement this if needed.
		
		Return
	End
	
	' Abstract methods:
	Method ExtractData:Int(Message:T, Index:Int, Length:Int=AUTO) Abstract
	Method RetrieveLength:Int(Message:T) Abstract
	
	' Methods (Private):
	Private
	
	' Nothing so far.
	
	Public
	
	' Fields:
	
	' Most MD5 related meta-data needed for execution.
	Field MetaData:MD5Data
	
	' An array cached per-hasher, which is used for block calculations upon execution.
	Field Block:Int[BLOCK_SIZE]
	
	' Booleans / Flags:
	Field ClearCacheWhenFinished:Bool
End