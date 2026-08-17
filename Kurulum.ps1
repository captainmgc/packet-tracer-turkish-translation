# Cisco Packet Tracer - Türkçe Dil Paketi
# Küçük WinForms kurulum arayüzü. Kurulum.bat üzerinden (yönetici olarak) başlatılır.

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
[System.Windows.Forms.Application]::EnableVisualStyles()

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

function Find-PacketTracerLanguagesDir {
    # 1) Kayıt defteri (özel sürücü/klasöre kurulmuş olsa da bulur)
    $uninstallKeys = @(
        'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*',
        'HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*'
    )
    foreach ($key in $uninstallKeys) {
        $entries = Get-ItemProperty $key -ErrorAction SilentlyContinue |
            Where-Object { $_.DisplayName -like '*Packet Tracer*' -and $_.InstallLocation }
        foreach ($entry in $entries) {
            $candidate = Join-Path $entry.InstallLocation.TrimEnd('\') 'languages'
            if (Test-Path -LiteralPath $candidate) { return $candidate }
        }
    }

    # 2) Standart ve alternatif dizinler
    $roots = @($env:ProgramFiles, ${env:ProgramFiles(x86)}, 'C:\', 'D:\', 'E:\', 'D:\Program Files') |
        Where-Object { $_ -and (Test-Path -LiteralPath $_) }
    foreach ($root in $roots) {
        $dirs = Get-ChildItem -LiteralPath $root -Directory -Filter 'Cisco Packet Tracer*' -ErrorAction SilentlyContinue |
            Sort-Object Name -Descending
        foreach ($dir in $dirs) {
            $candidate = Join-Path $dir.FullName 'languages'
            if (Test-Path -LiteralPath $candidate) { return $candidate }
        }
    }
    return $null
}

$form = New-Object System.Windows.Forms.Form
$form.Text = 'Packet Tracer - Türkçe Dil Paketi'
$form.ClientSize = New-Object System.Drawing.Size(500, 290)
$form.FormBorderStyle = 'FixedDialog'
$form.MaximizeBox = $false
$form.MinimizeBox = $false
# Pencere her zaman ekranın tam ortasında açılır
$form.StartPosition = 'CenterScreen'
$form.TopMost = $true
$form.Font = New-Object System.Drawing.Font('Segoe UI', 9)

$iconPath = Join-Path $ScriptDir 'cisco.png'
if (Test-Path -LiteralPath $iconPath) {
    try {
        $bmp = New-Object System.Drawing.Bitmap $iconPath
        $form.Icon = [System.Drawing.Icon]::FromHandle($bmp.GetHicon())
    } catch { }
}

$title = New-Object System.Windows.Forms.Label
$title.Text = 'Cisco Packet Tracer Türkçe Dil Paketi'
$title.Font = New-Object System.Drawing.Font('Segoe UI', 12, [System.Drawing.FontStyle]::Bold)
$title.Location = New-Object System.Drawing.Point(20, 18)
$title.Size = New-Object System.Drawing.Size(460, 26)
$form.Controls.Add($title)

$subtitle = New-Object System.Windows.Forms.Label
$subtitle.Text = 'Dil dosyaları Packet Tracer''ın languages klasörüne kopyalanacak.'
$subtitle.ForeColor = [System.Drawing.Color]::DimGray
$subtitle.Location = New-Object System.Drawing.Point(20, 44)
$subtitle.Size = New-Object System.Drawing.Size(460, 20)
$form.Controls.Add($subtitle)

$pathLabel = New-Object System.Windows.Forms.Label
$pathLabel.Text = 'Kurulum klasörü:'
$pathLabel.Location = New-Object System.Drawing.Point(20, 82)
$pathLabel.Size = New-Object System.Drawing.Size(120, 20)
$form.Controls.Add($pathLabel)

$pathBox = New-Object System.Windows.Forms.TextBox
$pathBox.Location = New-Object System.Drawing.Point(20, 104)
$pathBox.Size = New-Object System.Drawing.Size(370, 24)
$form.Controls.Add($pathBox)

$browseButton = New-Object System.Windows.Forms.Button
$browseButton.Text = 'Gözat...'
$browseButton.Location = New-Object System.Drawing.Point(398, 103)
$browseButton.Size = New-Object System.Drawing.Size(82, 26)
$form.Controls.Add($browseButton)

$ptlCheck = New-Object System.Windows.Forms.CheckBox
$ptlCheck.Text = 'tur.ptl (dil dosyası - gerekli)'
$ptlCheck.Location = New-Object System.Drawing.Point(20, 140)
$ptlCheck.Size = New-Object System.Drawing.Size(240, 22)
$ptlCheck.Checked = $true
$ptlCheck.Enabled = $false
$form.Controls.Add($ptlCheck)

$tsCheck = New-Object System.Windows.Forms.CheckBox
$tsCheck.Text = 'tur.ts (kaynak dosya - isteğe bağlı)'
$tsCheck.Location = New-Object System.Drawing.Point(260, 140)
$tsCheck.Size = New-Object System.Drawing.Size(240, 22)
$tsCheck.Checked = $true
$form.Controls.Add($tsCheck)

$status = New-Object System.Windows.Forms.Label
$status.Location = New-Object System.Drawing.Point(20, 174)
$status.Size = New-Object System.Drawing.Size(460, 60)
$form.Controls.Add($status)

$installButton = New-Object System.Windows.Forms.Button
$installButton.Text = 'Kur'
$installButton.Location = New-Object System.Drawing.Point(288, 244)
$installButton.Size = New-Object System.Drawing.Size(96, 30)
$form.Controls.Add($installButton)

$closeButton = New-Object System.Windows.Forms.Button
$closeButton.Text = 'Kapat'
$closeButton.Location = New-Object System.Drawing.Point(392, 244)
$closeButton.Size = New-Object System.Drawing.Size(88, 30)
$form.Controls.Add($closeButton)
$form.CancelButton = $closeButton

function Set-Status([string]$text, [System.Drawing.Color]$color) {
    $status.Text = $text
    $status.ForeColor = $color
}

$detected = Find-PacketTracerLanguagesDir
if ($detected) {
    $pathBox.Text = $detected
    Set-Status 'Packet Tracer bulundu. Kuruluma hazır.' ([System.Drawing.Color]::ForestGreen)
} else {
    Set-Status "Packet Tracer otomatik bulunamadı. Kurulum klasörünü 'Gözat' ile seçin." ([System.Drawing.Color]::Firebrick)
}

$browseButton.Add_Click({
    $dialog = New-Object System.Windows.Forms.FolderBrowserDialog
    $dialog.Description = 'Packet Tracer kurulum klasörünü seçin'
    if ($pathBox.Text -and (Test-Path -LiteralPath $pathBox.Text)) { $dialog.SelectedPath = $pathBox.Text }
    if ($dialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
        $selected = $dialog.SelectedPath
        # Ana klasör seçildiyse languages alt klasörüne in
        $sub = Join-Path $selected 'languages'
        if (Test-Path -LiteralPath $sub) { $selected = $sub }
        $pathBox.Text = $selected
        Set-Status 'Klasör seçildi. Kuruluma hazır.' ([System.Drawing.Color]::ForestGreen)
    }
})

$installButton.Add_Click({
    $target = $pathBox.Text.Trim('"').Trim()
    if (-not $target -or -not (Test-Path -LiteralPath $target)) {
        Set-Status 'Geçerli bir kurulum klasörü seçilmedi.' ([System.Drawing.Color]::Firebrick)
        return
    }

    $files = @('tur.ptl')
    if ($tsCheck.Checked) { $files += 'tur.ts' }

    $copied = @()
    foreach ($file in $files) {
        $source = Join-Path $ScriptDir $file
        if (-not (Test-Path -LiteralPath $source)) {
            Set-Status "'$file' bu klasörde bulunamadı. Depoyu eksiksiz indirdiğinizden emin olun." ([System.Drawing.Color]::Firebrick)
            return
        }
        try {
            Copy-Item -LiteralPath $source -Destination $target -Force -ErrorAction Stop
            $copied += $file
        } catch {
            Set-Status "'$file' kopyalanamadı: $($_.Exception.Message)" ([System.Drawing.Color]::Firebrick)
            return
        }
    }

    Set-Status ('Kurulum tamamlandı: ' + ($copied -join ', ')) ([System.Drawing.Color]::ForestGreen)
    $form.TopMost = $false
    [System.Windows.Forms.MessageBox]::Show(
        "Kurulum başarıyla tamamlandı.`n`nTürkçeyi etkinleştirmek için:`n1. Packet Tracer'ı açın.`n2. Options > Preferences bölümüne gidin.`n3. Dil listesinden 'tur.ptl' seçeneğini seçin.`n4. 'Change Language' düğmesine tıklayıp uygulamayı yeniden başlatın.",
        'Kurulum tamamlandı',
        [System.Windows.Forms.MessageBoxButtons]::OK,
        [System.Windows.Forms.MessageBoxIcon]::Information) | Out-Null
    $form.TopMost = $true
})

$closeButton.Add_Click({ $form.Close() })

# Pencere açıldığında öne gelsin
$form.Add_Shown({ $form.Activate() })
[System.Windows.Forms.Application]::Run($form)
