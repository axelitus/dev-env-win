@ECHO OFF
SETLOCAL EnableDelayedExpansion

:: This entries will be filtered from the USER PATH and GLOBAL PATH environment variables.
:: Percents must be escaped with double %% to pass as 'var names' (e.g.: %%SystemRoot%%).
SET known_entries="D:\xampp\5.5\php" "D:\xampp\5.6\php" "D:\xampp\7.0\php"

:SELECT_ROOT
:: Define development root
SET root=
IF "%1" == "" (SET /p "root=Please enter development root (empty for current path): ") ELSE (SET root=%1)
IF "%root%" == "" (SET "root=%~dp0")
FOR /f "delims=" %%A IN ("%root%") DO (
	SET "root=%%~A"
)
IF "%root:~-1%" == "\" (SET "root=%root:~0,-1%")

ECHO The path is not validated. Development root selected: [%root%]
GOTO :CONFIRMATION

:RESUME
ECHO The execution may take a while. Please wait.
ECHO Preparing development environment...

:: Setup development variables
CALL :SETUP_DEV > NUL

:: Setup PATH variable
CALL :ADD_DEV_BIN_TO_PATH > NUL

:: Setup XAMPP variables
CALL :SETUP_XAMPP > NUL

:: Setup PHP variables
CALL :SETUP_PHP > NUL

ECHO Removing known entries from PATH variables...

CALL :REMOVE_KNOWN_PATH_ENTRIES > NUL

ECHO Writing script files...

:: Write script files
CALL :WRITE_PHP5_5 > NUL
CALL :WRITE_PHP5_5DBG > NUL
CALL :WRITE_PHP5_6 > NUL
CALL :WRITE_PHP5_6DBG > NUL
CALL :WRITE_PHP7_0 > NUL
CALL :WRITE_PHP7_0DBG > NUL
CALL :WRITE_PHP > NUL

ECHO Finished configuring the development environment.

GOTO END_SCRIPT
:: ===== End: Main =====


:CONFIRMATION
:: Asks for confirmation to continue.
:: --------------------
ECHO Are you sure you want to continue? If you continue some files will be overwritten.
SET /p "answer=Please select 'Y' (default) to continue, 'N' to select another root or 'C' to cancel: "
IF "%answer%" == "" GOTO RESUME
IF /i "%answer%" EQU "Y" GOTO RESUME
IF /i "%answer%" EQU "N" GOTO SELECT_ROOT
IF /i "%answer%" EQU "C" GOTO CANCEL
GOTO CONFIRMATION
:: ===== End: CONFIRMATION =====


:SETUP_DEV
:: Setup development environment variables.
:: --------------------
SETX DEV %root%
SETX DEV_BIN "%%DEV%%\bin"
EXIT /b
:: ===== End: SETUP_DEV =====


:ADD_DEV_BIN_TO_PATH
:: Add the development bin path to the PATH environment variable.
:: --------------------
FOR /f "usebackq skip=2 tokens=2,*" %%A IN (`REG QUERY "HKCU\Environment" /v "PATH" 2^>nul`) DO (
	SET args=%%B
	SET args=!args:%%=%%%%!
	CALL :FILTER_DEV_BIN_FROM_PATH "!args!"
    SET "user_path=!filtered!;%%DEV_BIN%%"
    SETX PATH "!user_path!"
)
EXIT /b
:: ===== End: ADD_DEV_BIN_TO_PATH =====


:FILTER_DEV_BIN_FROM_PATH <path_string>
:: Parses the given paths list and removes the one that matches with %DEV_BIN% from it.
:: @var <path_string> A string containing the list of paths separated with semi-colon.
:: --------------------
SET filtered=
SET "list=%~1"	:: Clean the argument (removes double quotes)
SET "list="%list:;=" "%""	:: Replaces the path separator with a space and encloses each individual string in double quotes
SET "list=%list:""=%"	:: Removes empty entries

FOR %%A IN (%list%) DO (
	SET entry=%%~A
	IF /i "!entry!" NEQ "%%DEV_BIN%%" (
		IF "!filtered!" == "" (SET filtered=!entry!) ELSE (SET filtered=!filtered!;!entry!)
	)
)
EXIT /b
:: ===== End: FILTER_DEV_BIN_FROM_PATH =====


:SETUP_XAMPP
:: Setup XAMPP environment variables.
:: --------------------
SETX XAMPP "%%DEV%%\xampp"
SETX XAMPP5_5 "%%XAMPP%%\5.5"
SETX XAMPP5_6 "%%XAMPP%%\5.6"
SETX XAMPP7_0 "%%XAMPP%%\7.0"
EXIT /b
:: ===== End: SETUP_XAMPP =====


:SETUP_PHP
:: Setup PHP environment variables.
:: --------------------
SETX PHP "%%DEV_BIN%%\php.bat"

:: PHP 5.5 environment variables
SETX PHP5_5 "%%XAMPP5_5%%\php"
SETX PHP5_5_EXE "%%PHP5_5%%\php.exe"
SETX PHP5_5_XDBG "%%PHP5_5%%\ext\php_xdebug.dll"

:: PHP 5.6 environment variables
SETX PHP5_6 "%%XAMPP5_6%%\php"
SETX PHP5_6_EXE "%%PHP5_6%%\php.exe"
SETX PHP5_6_XDBG "%%PHP5_6%%\ext\php_xdebug.dll"

:: PHP 7.0 environment variables
SETX PHP7_0 "%%XAMPP7_0%%\php"
SETX PHP7_0_EXE "%%PHP7_0%%\php.exe"
SETX PHP7_0_XDBG "%%PHP7_0%%\ext\php_xdebug.dll"
EXIT /b
:: ===== End: SETUP_PHP =====


:REMOVE_KNOWN_PATH_ENTRIES
:: Removes known path entries from USER PATH and GLOBAL PATH.
:: --------------------
:: User PATH
FOR /f "usebackq skip=2 tokens=2,*" %%A IN (`REG QUERY "HKCU\Environment" /v "PATH" 2^>nul`) DO (
	SET args=%%B
	SET args=!args:%%=%%%%!
	CALL :CLEAN_PATH_FROM_KNOWN_ENTRIES "!args!"
    SETX PATH "!filtered!"
)

:: Global PATH
FOR /f "usebackq skip=2 tokens=2,*" %%A IN (`REG QUERY "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment" /v "PATH" 2^>nul`) DO (
	SET args=%%B
	SET args=!args:%%=%%%%!
	CALL :CLEAN_PATH_FROM_KNOWN_ENTRIES "!args!"

    SETX /m PATH "!filtered!"
)
EXIT /b
:: ===== End: REMOVE_KNOWN_PATH_ENTRIES =====


:CLEAN_PATH_FROM_KNOWN_ENTRIES <path_string>
:: Cleans the given PATH list from known entries.
:: @var <path_string> A string containing the list of paths separated with semi-colon.
:: The known_entries variable is set at the beginning of the script. Every known entry
:: is enclosed in double quotes and they are separated by a space.
:: --------------------
SET filtered=
SET "list=%~1"	:: Clean the argument (removes double quotes).
SET "list="%list:;=" "%""	:: Replaces the path separator with a space and encloses each individual string in double quotes.
SET "list=%list:""=%"	:: Removes empty entries.

FOR %%A IN (%list%) DO (
	SET entry=%%~A
	SET remove=0
	FOR %%B IN (%known_entries%) DO (
		SET known=%%~B
		IF /i "!entry!" EQU "!known!" (
			SET remove=1
		)
	)
	IF !remove! EQU 0 (
		IF "!filtered!" == "" (SET filtered=!entry!) ELSE (SET filtered=!filtered!;!entry!)
	)
)
EXIT /b
:: ===== End: :CLEAN_PATH_FROM_KNOWN_ENTRIES =====


:WRITE_PHP5_5
:: Write php5.5 script file.
:: --------------------
SET output_file=%DEV_BIN%\php5.5.bat
IF EXIST %output_file% DEL /F %output_file%

:: Write file contents
>>%output_file% ECHO ^@ECHO OFF
>>%output_file% ECHO CALL %%PHP5_5_EXE%% %%*ECHO ()
EXIT /b
:: ===== End: WRITE_PHP5_5 =====


:WRITE_PHP5_5DBG
:: Write php5.5dbg script file.
:: --------------------
SET output_file=%DEV_BIN%\php5.5dbg.bat
IF EXIST %output_file% DEL /F %output_file%

:: Write file contents
>>%output_file% ECHO ^@ECHO OFF
>>%output_file% ECHO CALL %%PHP5_5_EXE%% -dzend_extension=%%PHP5_5_XDBG%% %%*
EXIT /b
:: ===== End: WRITE_PHP5_5DBG =====


:WRITE_PHP5_6
:: Write php5.6 script file.
:: --------------------
SET output_file=%DEV_BIN%\php5.6.bat
IF EXIST %output_file% DEL /F %output_file%

:: Write file contents
>>%output_file% ECHO ^@ECHO OFF
>>%output_file% ECHO CALL %%PHP5_6_EXE%% %%*
EXIT /b
:: ===== End: WRITE_PHP5_6 =====


:WRITE_PHP5_6DBG
:: Write php5.6dbg script file.
:: --------------------
SET output_file=%DEV_BIN%\php5.6dbg.bat
IF EXIST %output_file% DEL /F %output_file%

:: Write file contents
>>%output_file% ECHO ^@ECHO OFF
>>%output_file% ECHO CALL %%PHP5_6_EXE%% -dzend_extension=%%PHP5_6_XDBG%% %%*
EXIT /b
:: ===== End: WRITE_PHP5_6DBG =====


:WRITE_PHP7_0
:: Write php7.0 script file.
:: --------------------
SET output_file=%DEV_BIN%\php7.0.bat
IF EXIST %output_file% DEL /F %output_file%

:: Write file contents
>>%output_file% ECHO ^@ECHO OFF
>>%output_file% ECHO CALL %%PHP7_0_EXE%% %%*
EXIT /b
:: ===== End: WRITE_PHP7_0 =====


:WRITE_PHP7_0DBG
:: Write php7.0dbg script file.
:: --------------------
SET output_file=%DEV_BIN%\php7.0dbg.bat
IF EXIST %output_file% DEL /F %output_file%

:: Write file contents
>>%output_file% ECHO ^@ECHO OFF
>>%output_file% ECHO CALL %%PHP7_0_EXE%% -dzend_extension=%%PHP7_0_XDBG%% %%*
EXIT /b
:: ===== End: WRITE_PHP7_0DBG =====


:WRITE_PHP
:: Write php script file.
:: --------------------
SET output_file=%DEV_BIN%\php.bat
IF EXIST %output_file% DEL /F %output_file%

:: Write file contents
>>%output_file% ECHO ^@ECHO OFF
>>%output_file% ECHO CALL :RESET_ERROR_LEVEL
>>%output_file% ECHO.
>>%output_file% ECHO SET phpver=%%1
>>%output_file% ECHO :: Gets rid of the first argument which should be the PHP version.
>>%output_file% ECHO FOR /f "tokens=1,* delims= " %%%%A in ("%%*") DO SET args=%%%%B
>>%output_file% ECHO.
>>%output_file% ECHO CALL :VERSION_%%phpver%% 2^>nul
>>%output_file% ECHO IF errorlevel 1 GOTO DEFAULT
>>%output_file% ECHO EXIT /b
>>%output_file% ECHO :: ===== End: Main =====
>>%output_file% ECHO.
>>%output_file% ECHO.
>>%output_file% ECHO :RESET_ERROR_LEVEL
>>%output_file% ECHO :: Resets errorlevel to 0.
>>%output_file% ECHO :: --------------------
>>%output_file% ECHO EXIT /b 0
>>%output_file% ECHO :: ===== End: RESET_ERROR_LEVEL =====
>>%output_file% ECHO.
>>%output_file% ECHO.
>>%output_file% ECHO :: Filters and sets the wanted php version.
>>%output_file% ECHO :VERSION_5.5
>>%output_file% ECHO :VERSION_5.5dbg
>>%output_file% ECHO :VERSION_5.6
>>%output_file% ECHO :VERSION_5.6dbg
>>%output_file% ECHO :VERSION_7.0
>>%output_file% ECHO :VERSION_7.0dbg
>>%output_file% ECHO SET phpexec=php%%phpver%%
>>%output_file% ECHO GOTO EXEC
>>%output_file% ECHO :: ===== End: VERSION_* =====
>>%output_file% ECHO.
>>%output_file% ECHO.
>>%output_file% ECHO :DEFAULT
>>%output_file% ECHO :: Sets the default PHP version if none is given or not a valid one.
>>%output_file% ECHO :: --------------------
>>%output_file% ECHO :: As no valid PHP version was given, the first argument should be valid.
>>%output_file% ECHO SET args=%%*
>>%output_file% ECHO SET phpexec=php7.0
>>%output_file% ECHO GOTO EXEC
>>%output_file% ECHO :: ===== End: DEFAULT =====
>>%output_file% ECHO.
>>%output_file% ECHO.
>>%output_file% ECHO :EXEC
>>%output_file% ECHO :: Executes the given php version with arguments.
>>%output_file% ECHO :: --------------------
>>%output_file% ECHO CALL %%phpexec%% %%args%%
>>%output_file% ECHO EXIT /b
>>%output_file% ECHO :: ===== End: EXEC =====
EXIT /b
:: ===== End: WRITE_PHP =====


:CANCEL
:: Executes upon script execution cancel.
:: --------------------
ECHO The execution was canceled, no changes were made.
GOTO END_SCRIPT
:: ===== End: CANCEL =====


:END_SCRIPT
:: Ends the script execution.
:: --------------------
ENDLOCAL
PAUSE
EXIT /b
:: ===== End: END_SCRIPT =====