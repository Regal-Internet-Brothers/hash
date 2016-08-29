Strict

Public

' Preprocessor related:

' By enabling this, you allow this module to use optimization strategies inside and outside of Monkey.
' Please take caution when using this functionality. Very few targets are supported to begin with.
'#HASH_EXPERIMENTAL = False

#If CONFIG = "release" ' "debug"
	#HASH_SAFE = True
#End

#If HASH_EXPERIMENTAL
	' With this enabled some targets (Mainly STDCPP / C++ Tool) could see performance improvements for some of these algorithms.
	' This is only enabled when the 'HASH_EXPERIMENTAL' preprocessor-variable is set to 'True'.
	' See the "Compiler configuration" section for details.
	#HASH_USE_SIMD_WHEN_AVAILABLE = True
#End

' Compiler configuration:

#Rem
	ATTENTION:
		THE FOLLOWING NOTES WERE WRITTEN IN NOVEMBER OF 2014,
		AND MAY NOT DIRECTLY REFLECT THE CURRENT STATUS OF THESE EXTENSIONS IN THE COMING YEARS:
		
		-- EXPLICIT SIMD AND/OR SSE FUNCTIONALITY (FOR THIS MODULE) IS CURRENTLY ONLY AVAILABLE FOR GCC-BASED COMPILERS (THIS INCLUDES MINGW) --
		
		THE FOLLOWING OPTIMIZATION OPTIONS ARE MAINLY FOR X86/X64 PROCESSORS,
		AND SHOULD BE USED WITH CAUTION AND UNDERSTANDING OF YOUR TARGETED HARDWARE.
		
		THESE OPTIONS ARE BETTER MANAGED BY GCC/MINGW WHEN TARGETING 64-bit PROCESSORS.
		THESE OPTIONS ARE MAINLY FOR TESTING, BENCHMARKING, AND EXPERIMENTAL FUNCTIONALITY.
		
		DO NOT CONFIGURE THESE SETTINGS WITHOUT FULL UNDERSTANDING OF THE HARDWARE YOU WISH TO TARGET.
		
		All SIMD and/or SSE options within this module should
		only be used by those who feel they need them.
		
		These compiler-flags will be added to the entire project if they are enabled here.
		By enabling these, you effectively leave everything up to your compiler (GCC/MINGW in this case)
		not all versions of GCC support all of these flags, nor should they all be used as of yet.
		
		Unless you are completely aware of the available hardware, do not use these options.
		In the case of modern x86/x64 processors, you could probably get away with SSE and SSE2, but take caution.
		
		From what I hear, 64-bit/x64 versions of GCC and MINGW handle these features much better, and may not need explicit intervention.
		
		Please read up about which processors support which versions of SSE.
		Some notes were made below to help your choices if you wish to enable SSE or AVX.
#End

#If HASH_USE_SIMD_WHEN_AVAILABLE
	#If LANG = "cpp"
		'#HASH_CPP_NEWEST_SIMD_INSTRUCTIONS = False
		
		' In the event SIMD instructions are enabled, this will use a preset option.
		#HASH_CPP_AVERAGE_SIMD_INSTRUCTIONS = True
		'#HASH_CPP_HIGHEND_SIMD_INSTRUCTIONS = True
		
		#If HASH_CPP_AVERAGE_SIMD_INSTRUCTIONS Or HASH_CPP_HIGHEND_SIMD_INSTRUCTIONS
			' The current default for this feature is SSE2:
			#HASH_CPP_SSE = True
			#HASH_CPP_SSE_2 = True
		#End
		
		#If HASH_CPP_HIGHEND_SIMD_INSTRUCTIONS
			#HASH_CPP_SSE_3 = True
			#HASH_CPP_SSE_4 = True
			'#HASH_CPP_SSE_4_1 = True
			'#HASH_CPP_SSE_4_2 = True
		#End
		
		#If HASH_CPP_NEWEST_SIMD_INSTRUCTIONS
			#HASH_CPP_AVX = True
			'#HASH_CPP_AVX_2 = True
		#End
	#End
	
	' THE FOLLOWING PREPROCESSOR-CODE ONLY APPLIES TO GCC/MINGW BASED TARGETS:
	
	' Chances are, this won't have any effect with GLFW, but the check's here anyway.
	#If TARGET = "stdcpp" Or (TARGET = "glfw" And GLFW_USE_MINGW)
		' You can generally get away with using these instructions:
		
		#Rem
			Today, SSE and SSE2 are effectively industry standards.
			Just about any modern x86 and/or x64 based processor will support SSE and SSE2.
			
			SSE was introduced in the late '90s (1999), and SSE2 was introduced in the early 2000s (2001).
			SSE2 would not be supported by vendors like AMD until a couple years later.
			
			You shouldn't have much of an issue using SSE2 instructions. SSE3 and onward is a different story...
		#End
		
		#If HASH_CPP_SSE
			#CC_OPTS += "-msse"
		#End
		
		#If HASH_CPP_SSE_2
			#CC_OPTS += "-msse2"
		#End
		
		#Rem
			SSE3 was introduced in 2004 and 2005, and has somewhat variable support from vendors.
			SSE3 is commonly found in AMD processors after their later revisions of the Athlon 64 platform,
			and is supported by most consumer AMD processors available today. Intel has supported SSE3 for some time,
			but it didn't become common place until the advent of the 'Core' architecture,
			and is also supported in some Xeons, and most Pentium D processors.
		#End
		
		#If HASH_CPP_SSE_3
			#CC_OPTS += "-msse3"
		#End
		
		' These extensions are a bit rarer, currently:
		
		#Rem
			SSE4 can be found on a majority of newer processors, but using it will likely make your binaries unable to run on older processors.
			SSE4 has several subsets, and is overall best left unused without detailed understanding of your targeted hardware.
			It's best not to use SSE4 until it becomes more common (Which will likely be within the next few years).
			
			SSE4 is available from most of AMD's modern processors, and is available from Intel's newer 'Core' processors.
			
			Please read more about SSE4 before trying to use it.
		#End
		
		#If HASH_CPP_SSE_4
			#CC_OPTS += "-msse4"
		#End
		
		#If HASH_CPP_SSE_4_1
			#CC_OPTS += "-msse4.1"
		#End
		
		#If HASH_CPP_SSE_4_2
			#CC_OPTS += "-msse4.2"
		#End
		
		' Very few processors support these extensions (DO NOT USE THEM YET):
		
		#Rem
			AVX is only supported by the new processors introduced by Intel and AMD in 2011 and onward.
			AVX is overall not recommended as of yet, as very few processors support it, currently.
			
			AVX2 is effectively unsupported by the vast majority, as it's currently a brand new extension.
			
			I DO NOT recommend using AVX2 at all, let alone AVX.
			
			AVX should not be used until it becomes standard for the majority of processors,
			or you are targeting specific hardware which supports AVX and/or AVX2.
		#End
		
		#If HASH_CPP_AVX
			#CC_OPTS += "-mavx"
		#End
		
		#If HASH_CPP_AVX_2
			#CC_OPTS += "-mavx2"
		#End
	#End
#End