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

cl /nologo /c /O2 /W3 /D_CRT_SECURE_NO_DEPRECATE radish-*.c lpeg/*.c
@if errorlevel 1 goto :BAD

link /def:exports.def /nologo /out:radish-runner.exe /subsystem:windows radish-*.obj lp*.obj user32.lib gdi32.lib version.lib lua51.lib sqlite3\sqlite3.lib
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
