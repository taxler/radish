@setlocal
@packaging\luajit -e "package.path = 'lua/?.lua;lua/?/init.lua'" packaging\packaging.lua run
@if errorlevel 1 goto :BAD
@goto :END
:BAD
@echo.
@echo *********************************************************
@echo *** Package FAILED -- Please check the error messages ***
@echo *********************************************************
@pause
:END
