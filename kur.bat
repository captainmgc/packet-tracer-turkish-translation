@echo off
setlocal EnableDelayedExpansion
title Cisco Packet Tracer - Turkce Dil Paketi Kurulumu

cd /d "%~dp0"

:: 1. Yonetici Yetkisi Kontrolu ve Yukseltme
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo ==================================================================
    echo          Cisco Packet Tracer - Turkce Dil Paketi Kurulumu
    echo ==================================================================
    echo.
    echo [*] Kurulum icin Yonetici izni gerekiyor...
    echo [*] Lutfen acilan guvenlik penceresinde "Evet" secenegine tiklayiniz.
    powershell -NoProfile -ExecutionPolicy Bypass -Command "Start-Process '%~f0' -Verb RunAs"
    exit /b
)

cls
echo ==================================================================
echo          Cisco Packet Tracer - Turkce Dil Paketi Kurulumu
echo ==================================================================
echo.

set "TARGET_DIR="

:: 2. YONTEM A: Windows Kayit Defteri (Registry) Uzerinden Otomatik Bul
:: Packet Tracer farkli bir surucuye (D:, E: vb.) veya ozel klasore kurulsa dahi bulur.
for /f "tokens=2* delims=	 " %%A in ('reg query "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall" /s /f "Packet Tracer" 2^>nul ^| findstr /i "InstallLocation"') do (
    if exist "%%Blanguages" set "TARGET_DIR=%%Blanguages"
    if exist "%%B\languages" set "TARGET_DIR=%%B\languages"
)

if not defined TARGET_DIR (
    for /f "tokens=2* delims=	 " %%A in ('reg query "HKLM\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall" /s /f "Packet Tracer" 2^>nul ^| findstr /i "InstallLocation"') do (
        if exist "%%Blanguages" set "TARGET_DIR=%%Blanguages"
        if exist "%%B\languages" set "TARGET_DIR=%%B\languages"
    )
)

:: 3. YONTEM B: Standart ve Alternatif Surucu Dizinlerini Tara
if not defined TARGET_DIR (
    for %%L in ("%ProgramFiles%\Cisco Packet Tracer 9.0.0\languages"
                "%ProgramFiles%\Cisco Packet Tracer 9.0\languages"
                "%ProgramFiles%\Cisco Packet Tracer 8.2.2\languages"
                "%ProgramFiles%\Cisco Packet Tracer 8.2.1\languages"
                "%ProgramFiles%\Cisco Packet Tracer 8.2.0\languages"
                "%ProgramFiles%\Cisco Packet Tracer 8.1.1\languages"
                "%ProgramFiles%\Cisco Packet Tracer 8.0\languages"
                "%ProgramFiles(x86)%\Cisco Packet Tracer 7.3.1\languages"
                "%ProgramFiles(x86)%\Cisco Packet Tracer 7.3.0\languages"
                "D:\Cisco Packet Tracer 9.0.0\languages"
                "D:\Cisco Packet Tracer 8.2.2\languages"
                "D:\Program Files\Cisco Packet Tracer 9.0.0\languages"
                "E:\Cisco Packet Tracer 9.0.0\languages") do (
        if not defined TARGET_DIR if exist %%L set "TARGET_DIR=%%~fL"
    )
)

if not defined TARGET_DIR (
    for /d %%D in ("%ProgramFiles%\Cisco Packet Tracer*" "D:\Cisco Packet Tracer*" "E:\Cisco Packet Tracer*") do (
        if not defined TARGET_DIR if exist "%%D\languages" set "TARGET_DIR=%%D\languages"
    )
)

:: 4. YONTEM C: Kullanicidan Manuel Giris Iste (Surukle-Birak Destekli)
if not defined TARGET_DIR (
    echo [!] Packet Tracer kurulumu otomatik tespit edilemedi.
    echo Lutfen Packet Tracer'in kurulu oldugu ana klasoru giriniz veya surukleyip birakiniz:
    set /p "USER_INPUT=Klasor Yolu: "
    if defined USER_INPUT (
        set "USER_INPUT=!USER_INPUT:"=!"
        if exist "!USER_INPUT!\languages" (
            set "TARGET_DIR=!USER_INPUT!\languages"
        ) else if exist "!USER_INPUT!" (
            set "TARGET_DIR=!USER_INPUT!"
        )
    )
)

if not defined TARGET_DIR (
    echo.
    echo [HATA] Gecerli bir Packet Tracer klasoru bulunamadi. Kurulum iptal edildi.
    echo.
    pause
    exit /b 1
)

echo [OK] Packet Tracer Kurulumu Bulundu:
echo      "%TARGET_DIR%"
echo.

:: 5. Dosyalari Kopyala
set "COPIED=0"
if exist "%~dp0tur.ptl" (
    copy /y "%~dp0tur.ptl" "%TARGET_DIR%\" >nul 2>&1
    if !errorlevel! equ 0 (
        echo [OK] 'tur.ptl' basariyla yuklendi.
        set "COPIED=1"
    ) else (
        echo [HATA] 'tur.ptl' kopyalanamadi!
    )
) else (
    echo [HATA] 'tur.ptl' dosyasi kurulum klasorunde bulunamadi!
)

if exist "%~dp0tur.ts" (
    copy /y "%~dp0tur.ts" "%TARGET_DIR%\" >nul 2>&1
    if !errorlevel! equ 0 (
        echo [OK] 'tur.ts' basariyla yuklendi.
    )
)

echo.
if "%COPIED%"=="1" (
    echo ==================================================================
    echo                  KURULUM BASARIYLA TAMAMLANDI!
    echo ==================================================================
    echo.
    echo Turkce dili etkinlestirmek icin:
    echo  1. Cisco Packet Tracer'i acin.
    echo  2. Ust menuden Options ^> Preferences ^(veya Change Language^) bolumune gidin.
    echo  3. Dil listesinden 'tur.ptl' ^(veya Turkish^) secenegini secin.
    echo  4. 'Change Language' butonuna tiklayip Packet Tracer'i yeniden baslatin.
    echo.
    echo Iyi calismalar dileriz!
    echo ==================================================================
) else (
    echo [HATA] Dosyalar hedef klasore kopyalanamadi.
)

echo.
pause
