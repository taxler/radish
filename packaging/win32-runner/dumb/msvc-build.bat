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

@rem /O2 /W3 /D_USE_SSE /D_CRT_SECURE_NO_DEPRECATE /D_LIB /DNDEBUG

cl /I include /nologo /c /DWIN32 /DDUMB_DECLARE_DEPRECATED /DRESAMPLER_DECORATE=dumb /DBARRAY_DECORATE=dumb src\core\*.c src\it\*.c src\helpers\*.c
@if errorlevel 1 goto :BAD

lib *.obj -OUT:dumb.lib
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
