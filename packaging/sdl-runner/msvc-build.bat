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

cl /I include /nologo /c /O2 /W3 /DWIN32 /D_CRT_SECURE_NO_DEPRECATE radish-*.c
@if errorlevel 1 goto :BAD

link /def:..\win32-runner\exports.def /nologo /out:radish-runner.exe /subsystem:windows radish-*.obj SDL2.lib ..\win32-runner\lua51.lib ..\win32-runner\sqlite3\sqlite3.lib ..\win32-runner\dumb\dumb.lib ..\win32-runner\lpeg\lpeg.lib ..\win32-runner\libogg\libogg.lib ..\win32-runner\libvorbis\libvorbis.lib ..\win32-runner\libvorbis\vorbisfile\vorbisfile.lib ..\win32-runner\opus\opustools_resampler.lib ..\win32-runner\miniz\miniz.lib
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
