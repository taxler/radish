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

cl /I opus-tools-0.1.9\include /nologo /c /O2 /W3 /DOUTSIDE_SPEEX /DRANDOM_PREFIX=opustools /DFLOATING_POINT /DSPX_RESAMPLE_EXPORT="" opus-tools-0.1.9\src\resample.c
@if errorlevel 1 goto :BAD

lib resample.obj -OUT:opustools_resampler.lib
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
