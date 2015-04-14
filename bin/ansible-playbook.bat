@echo off
REM This batch file allows ansible-playbook to be invoked from Windows (e.g., by Vagrant).
set CYGWIN=C:\cygwin
set SH=%CYGWIN%\bin\bash.exe
REM Use cygwin-wrapper script to convert paths in opts/args from windows to cygwin form.
"%SH%" -c "cygwin-wrapper.sh ansible-playbook %*"
