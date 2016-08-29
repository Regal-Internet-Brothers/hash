Strict

Public

#Rem
	Cryptographic routines for the Monkey programming language.
	
	// List of features \\
		' Stable:
		* MD5
		* BASE64
		
		' Experimental:
		* SHA1
		* ADLER32
		* CRC32
#End

' Imports (Public):

' Internal:
Import config

Import types

' External language bindings.
Import external

Import md5
Import base64

' Experimental functionality:
#If HASH_EXPERIMENTAL
	Import sha1
	Import adler32
	Import crc32
#End