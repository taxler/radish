@rem Either open a "Visual Studio .NET Command Prompt"
@rem (Note that the Express Edition does not contain an x64 compiler)
@rem -or-
@rem Open a "Windows SDK Command Shell" and set the compiler environment:
@rem     setenv /release /x86
@rem   -or-
@rem     setenv /release /x64
@rem
@rem Then cd to this directory and run this script.

@if not defined INCLUDE goto :FAIL

@setlocal

cl /I ..\include /nologo /c /O2 /W3 /D_USE_MATH_DEFINES /D_CRT_SECURE_NO_DEPRECATE /D_CRT_NONSTDC_NO_DEPRECATE /D_BIND_TO_CURRENT_CRT_VERSION /DWIN32 /DNDEBUG /D_WINDOWS /D_USRDLL /DLIBVORBIS_EXPORTS /wd4244 /wd4100 /wd4267 /wd4189 /wd4305 /wd4127 /wd4706 lib\analysis.c lib\bitrate.c lib\block.c lib\codebook.c lib\envelope.c lib\floor0.c lib\floor1.c lib\info.c lib\lookup.c lib\lpc.c lib\lsp.c lib\mapping0.c lib\mdct.c lib\psy.c lib\registry.c lib\res0.c lib\sharedbook.c lib\smallft.c lib\synthesis.c lib\vorbisenc.c lib\window.c

@if errorlevel 1 goto :BAD

lib *.obj -OUT:libvorbis.lib
@if errorlevel 1 goto :BAD

@del *.obj
@echo.
@echo === Successfully built ===
@echo off

@goto :END
:BAD
@echo.
@echo *******************************************************
@echo *** Build FAILED -- Please check the error messages ***
@echo *******************************************************
@goto :END
:FAIL
@echo You must open a "Visual Studio .NET Command Prompt" to run this script
@pause
:END
