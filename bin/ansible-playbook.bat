@echo off
REM This batch file allows ansible-playbook to be invoked from Windows (e.g., by Vagrant).
set CYGWIN=C:\cygwin
set SH=%CYGWIN%\bin\bash.exe
"%SH%" -c "/bin/ansible-playbook %*"
