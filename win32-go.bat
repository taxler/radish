@setlocal
@packaging\luajit packaging\packaging.lua
@if errorlevel 1 goto :BAD
@goto :END
:BAD
@echo.
@echo *********************************************************
@echo *** Package FAILED -- Please check the error messages ***
@echo *********************************************************
@pause
:END
