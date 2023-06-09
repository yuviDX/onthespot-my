@echo off

set "installerUrl=https://www.7-zip.org/a/7z1900-x64.exe"
set "installerPath=%temp%\7zinstaller.exe"
set "downloadUrl=https://www.gyan.dev/ffmpeg/builds/ffmpeg-release-full.7z"
set "outputFile=C:\ffmpeg\ffmpeg-release-full.7z"

REM Verify if 7-Zip is installed

if exist "%ProgramFiles%\7-Zip\7z.exe" (
    echo 7-Zip is installed successfully.
) else (
    echo Installing 7-Zip...
    curl --progress-bar -o "%installerPath%" "%installerUrl%"
    if not errorlevel 0 (
        echo Failed to download the 7-Zip installer.
        exit /b 1
		pause
    )
    echo Installing 7-Zip...
    start /wait "" "%installerPath%" /S
    if not errorlevel 0 (
        echo Failed to install 7-Zip.
        exit /b 1
		pause
    )
)

REM Verify if ffmpeg zip file needs to be downloaded====
echo Step 1 - Create ffmpeg and download required files
REM ====================================================

if not exist "C:\ffmpeg" mkdir "C:\ffmpeg" >nul 2>&1
if not exist "%outputFile%" (
    echo File not found. Downloading...
    curl --progress-bar --location "%downloadUrl%" -o "%outputFile%"
    if not errorlevel 0 (
        echo Failed to download the ffmpeg zip file.
        exit /b 1
		pause
    )
) else (
    echo File already exists. Skipping download.
)

REM Extract the ffmpeg zip file and set the PATH environment variable====
echo Step 2 - Extract the zip file and set the PATH environment variable
REM =====================================================================

"C:\Program Files\7-Zip\7z.exe" x "%outputFile%" -o"C:\ffmpeg" >nul 2>&1
if not errorlevel 0 (
    echo Failed to extract the ffmpeg zip file.
    exit /b 1
	pause
)

for /d %%I in (C:\ffmpeg\ffmpeg-*) do set "extractedFolder=%%~nxI"
move "C:\ffmpeg\%extractedFolder%\bin" "C:\ffmpeg\bin"
echo setx /m PATH "C:\ffmpeg\bin;%%PATH%%" | cmd /q >nul 2>&1

REM Install packages from requirements.txt and winsdk ==========
echo Step 3 - Install packages from requirements.txt and winsdk
REM ============================================================

echo Installing packages from requirements.txt...
pip install -r requirements.txt >nul 2>&1
if not errorlevel 0 (
    echo Failed to install packages from requirements.txt.
    exit /b 1
	pause
) else (
    echo Successfully installed packages from requirements.txt
)

echo Installing winsdk...
pip install winsdk >nul 2>&1
if not errorlevel 0 (
    echo Failed to install winsdk.
    exit /b 1
	pause
) else (
    echo Successfully installed winsdk
)

REM Cleanup===========
echo Step 4 - Cleanup
REM ==================

del C:\ffmpeg\ffmpeg-release-full.7z >nul 2>&1
rmdir /s /q "C:\ffmpeg\%extractedFolder%" >nul 2>&1
echo Successfully removed temp files....

pause
