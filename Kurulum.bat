@echo off
title Cisco Packet Tracer - Turkce Dil Paketi Kurulumu
cd /d "%~dp0"

if not exist "%~dp0Kurulum.ps1" (
    echo [HATA] Kurulum.ps1 bulunamadi. Depoyu eksiksiz indirdiginizden emin olun.
    pause
    exit /b 1
)

:: Yonetici degilse kendini yukselterek yeniden baslat
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo [*] Kurulum icin Yonetici izni gerekiyor...
    echo [*] Acilan guvenlik penceresinde "Evet" secenegine tiklayiniz.
    powershell -NoProfile -ExecutionPolicy Bypass -Command "Start-Process -FilePath '%~f0' -Verb RunAs"
    exit /b
)

:: Arayuzu ac (konsol penceresi gizli)
powershell -NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File "%~dp0Kurulum.ps1"
exit /b
