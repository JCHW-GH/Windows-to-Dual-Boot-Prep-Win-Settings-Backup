# 1 Run as Administrator​
# 2 Run this once: Set-ExecutionPolicy Bypass -Scope Process -Force​
# 3 CD to this files location and Run
.\Before_Dualboot_win10_settings.ps1​
# Run as Administrator​
if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Securit
y.Principal.WindowsBuiltInRole] "Administrator"))​
{​
Write-Host "Please run this script as Administrator."
-ForegroundColor Red​
pause​
exit​
}​
​
# ══════════════════════════════════════════════════​
#
CUSTOMISE THIS if you need a different user​
# ══════════════════════════════════════════════════​
$UserName = $env:USERNAME
# Current user - change to e.g. "Bobo" if
needed​
$UserProfile = "C:\Users\$UserName"​
$Base = "$UserProfile\Downloads\Before_Dualboot_win10_settings"​
# ══════════════════════════════════════════════════​
​
New-Item -ItemType Directory -Path $Base -Force | Out-Null​
​
# Progress bar setup​
$totalSteps = 11​
$currentStep = 0​
Write-Progress -Activity "Backing up Windows settings" -Status
"Starting..." -PercentComplete 0​
​
#
---------------------------------------------------------------------
--​
# 1. Wi‑Fi profiles → one file directly in $Base​
#
---------------------------------------------------------------------
--​
$currentStep++​
Write-Progress -Activity "Backing up Windows settings" -Status
"Exporting Wi‑Fi profiles ($currentStep/$totalSteps)"
-PercentComplete ($currentStep/$totalSteps*100)​
​
$wifiOut = "$Base\wifi_profiles.txt"​
🔧$tempXmlDir = "$env:TEMP\wifi_xml_export"​
Remove-Item -Recurse -Force $tempXmlDir -ErrorAction SilentlyContinue​
New-Item -ItemType Directory -Path $tempXmlDir -Force | Out-Null​
netsh wlan export profile folder="$tempXmlDir" key=clear | Out-Null​
​
Get-ChildItem $tempXmlDir -Filter *.xml | ForEach-Object {​
[xml]$xml = Get-Content $_.FullName​
$ssid = $xml.WLANProfile.SSIDConfig.SSID.name​
$sec = $xml.WLANProfile.MSM.security​
$auth = $sec.authEncryption.authentication​
$enc = $sec.authEncryption.encryption​
$key = $sec.sharedKey.keyMaterial​
$conn = $xml.WLANProfile.connectionType​
"==============================================" | Out-File
-Append -FilePath $wifiOut​
"Profile : $ssid"
| Out-File
-Append -FilePath $wifiOut​
"Connection Mode : $conn"
| Out-File
-Append -FilePath $wifiOut​
"Authentication : $auth"
| Out-File
-Append -FilePath $wifiOut​
"Encryption
: $enc"
| Out-File
-Append -FilePath $wifiOut​
if ($key) { "Password
: $key" | Out-File -Append -FilePath
$wifiOut }​
""
| Out-File
-Append -FilePath $wifiOut​
}​
Remove-Item -Recurse -Force $tempXmlDir​
​
#
---------------------------------------------------------------------
--​
# 2. All fonts (diff against Windows defaults - True additions only)​
#
---------------------------------------------------------------------
--​
​
$currentStep++​Write-Progress -Activity "Backing up Windows settings" -Status
"Custom fonts ($currentStep/$totalSteps)" -PercentComplete
($currentStep/$totalSteps*100)​
​
# 1. DYNAMICALLY build a list of protected Windows system fonts from
the Registry​
$SystemFontsRegistry = Get-ItemProperty -Path
"HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts"​
$SystemFontFiles = $SystemFontsRegistry.psobject.Properties | ​
Where-Object { $_.Name -notmatch
"PSPath|PSParentPath|PSChildName|PSDrive|PSProvider" } | ​
Select-Object -ExpandProperty Value | ​
ForEach-Object { $_.Split('(')[0].Trim() } # Cleans up "Font Name
(TrueType)" to just "filename.ttf"​
​
# 2. Keep your hardcoded backup list just in case, but convert
EVERYTHING to lowercase​
$hardcodedDefaults = @(​
"8514fix.fon","8514oem.fon","8514sys.fon","app850.fon","app932.fon","
app936.fon","app949.fon","app950.fon",​
"arial.ttf","arialbd.ttf","arialbi.ttf","ariali.ttf","ariblk.ttf","ba
hnschrift.ttf","calibri.ttf","calibrib.ttf",​
"calibrii.ttf","calibril.ttf","calibrili.ttf","calibriz.ttf","cambria
.ttc","cambriab.ttf","cambriai.ttf",​
"cambriaz.ttf","candara.ttf","candarab.ttf","candarai.ttf","candaraz.
ttf","comic.ttf","comicbd.ttf",​
"comici.ttf","comicz.ttf","consola.ttf","consolab.ttf","consolai.ttf"
,"consolaz.ttf","constan.ttf",​
"constanb.ttf","constani.ttf","constanz.ttf","corbel.ttf","corbelb.tt
f","corbeli.ttf","corbell.ttf",​
"corbelli.ttf","corbelz.ttf","cour.ttf","courbd.ttf","courbi.ttf","co
uri.ttf","dosapp.fon",​"ebrima.ttf","ebrimabd.ttf","framd.ttf","framdit.ttf","gabriola.ttf",
"georgia.ttf","georgiab.ttf",​
"georgiai.ttf","georgiaz.ttf","impact.ttf","inkfree.ttf","javatext.tt
f","l_10646.ttf",​
"lucon.ttf","malgun.ttf","malgunbd.ttf","malgunsl.ttf","micross.ttf",
"modern.fon",​
"msgothic.ttc","msjh.ttc","msjhb.ttc","msjhl.ttc","msjhbd.ttc","msjhb
l.ttc",​
"msmincho.ttc","msyh.ttc","msyhb.ttc","msyhl.ttc","msyhbd.ttc","msyhb
l.ttc",​
"nirmala.ttf","nirmalab.ttf","nirmalas.ttf","palabi.ttf","palab.ttf",
"palai.ttf",​
"pala.ttf","phagspa.ttf","phagspab.ttf","segoeui.ttf","segoeuib.ttf",
"segoeuii.ttf",​
"segoeuil.ttf","segoeuisl.ttf","segoeuiz.ttf","seguibl.ttf","seguibli
.ttf","seguili.ttf",​
"seguisb.ttf","seguisbi.ttf","seguisli.ttf","segoepr.ttf","segoeprb.t
tf","segoesc.ttf",​
"segoescb.ttf","sylfaen.ttf","symbol.ttf","tahoma.ttf","tahomabd.ttf"
,"times.ttf",​
"timesbd.ttf","timesbi.ttf","timesi.ttf","trebuc.ttf","trebucbd.ttf",
"trebucbi.ttf",​
"trebucit.ttf","verdana.ttf","verdanab.ttf","verdanai.ttf","verdanaz.
ttf","webdings.ttf",​
"wingding.ttf","yugoth.ttc","yugothb.ttc","yugothl.ttc","yugothm.ttc"
,"yugothr.ttc",​"holomdl2.ttf","marlett.ttf","segoe_slboot.ttf","segoe_sl.ttf","segmd
l2.ttf",​
"LeelawUI.ttf","LeelaUIb.ttf","Nirmala.ttf","NirmalaB.ttf","NirmalaS.
ttf",​
"Gadugi.ttf","GadugiB.ttf","HoloLensMDL2.ttf"​
)​
​
# Merge both lists and force lowercase string matching​
$allBlacklistedFonts = ($SystemFontFiles + $hardcodedDefaults) |
ForEach-Object { $_.ToLower().Trim() }​
​
# 3. Source paths​
$fontSources = @(​
"$env:windir\Fonts\*",​
"$env:USERPROFILE\AppData\Local\Microsoft\Windows\Fonts\*"​
)​
​
$fontDest = "$Base\Fonts"​
New-Item -ItemType Directory -Path $fontDest -Force | Out-Null​
​
# 4. Copy process​
foreach ($src in $fontSources) {​
if (Test-Path $src) {​
Get-ChildItem -Path $src -Include *.ttf, *.otf, *.ttc, *.fon
-File | Where-Object {​
# CRITICAL: Normalize file name to lowercase before
checking the exclusion list​
$fileNameLower = $_.Name.ToLower().Trim()​
$fileNameLower -notin $allBlacklistedFonts​
} | Copy-Item -Destination $fontDest -Force​
}​
}​
​
​
#
---------------------------------------------------------------------
--​# 3. Installed software list​
#
---------------------------------------------------------------------
--​
$currentStep++​
Write-Progress -Activity "Backing up Windows settings" -Status
"Installed software list ($currentStep/$totalSteps)" -PercentComplete
($currentStep/$totalSteps*100)​
winget list --accept-source-agreements >
"$Base\installed_software.txt"​
​
#
---------------------------------------------------------------------
--​
# 4. Third‑party driver list (text only)​
#
---------------------------------------------------------------------
--​
$currentStep++​
Write-Progress -Activity "Backing up Windows settings" -Status
"Driver list ($currentStep/$totalSteps)" -PercentComplete
($currentStep/$totalSteps*100)​
Get-WindowsDriver -Online | Where-Object { $_.DriverProvider
-notmatch "Microsoft" } |​
Select-Object Driver, ProviderName, Date, Version |​
Out-File "$Base\driver_list.txt"​
​
#
---------------------------------------------------------------------
--​
# 5. Windows product key​
#
---------------------------------------------------------------------
--​
$currentStep++​
Write-Progress -Activity "Backing up Windows settings" -Status
"Product key ($currentStep/$totalSteps)" -PercentComplete
($currentStep/$totalSteps*100)​
try {​$key = (Get-WmiObject -query 'select * from
SoftwareLicensingService').OA3xOriginalProductKey​
"Product Key: $key" | Out-File "$Base\product_key.txt"​
} catch {​
"Could not retrieve product key" | Out-File
"$Base\product_key.txt"​
}​
​
#
---------------------------------------------------------------------
--​
# 6. Hosts file​
#
---------------------------------------------------------------------
--​
$currentStep++​
Write-Progress -Activity "Backing up Windows settings" -Status "Hosts
file ($currentStep/$totalSteps)" -PercentComplete
($currentStep/$totalSteps*100)​
Copy-Item "C:\Windows\System32\drivers\etc\hosts" "$Base\hosts.txt"
-Force​
​
#
---------------------------------------------------------------------
--​
# 7. Saved credentials​
#
---------------------------------------------------------------------
--​
$currentStep++​
Write-Progress -Activity "Backing up Windows settings" -Status
"Credentials list ($currentStep/$totalSteps)" -PercentComplete
($currentStep/$totalSteps*100)​
cmdkey /list > "$Base\credential_list.txt"​
​
#
---------------------------------------------------------------------
--​
# 8. System info​#
---------------------------------------------------------------------
--​
$currentStep++​
Write-Progress -Activity "Backing up Windows settings" -Status
"System info ($currentStep/$totalSteps)" -PercentComplete
($currentStep/$totalSteps*100)​
systeminfo > "$Base\systeminfo.txt"​
​
#
---------------------------------------------------------------------
--​
# 9. WSL distro list (if present)​
#
---------------------------------------------------------------------
--​
$currentStep++​
Write-Progress -Activity "Backing up Windows settings" -Status "WSL
check ($currentStep/$totalSteps)" -PercentComplete
($currentStep/$totalSteps*100)​
$wslList = & wsl --list --verbose 2>$null​
if ($wslList) {​
$wslList | Out-File "$Base\wsl_distros.txt"​
"Run 'wsl --install -d <distro>' to reinstall." | Out-File
-Append "$Base\wsl_distros.txt"​
}​
​
#
---------------------------------------------------------------------
--​
# 10. Paint.NET - all custom files​
#
---------------------------------------------------------------------
--​
$currentStep++​
Write-Progress -Activity "Backing up Windows settings" -Status
"Paint.NET plugins & settings ($currentStep/$totalSteps)"
-PercentComplete ($currentStep/$totalSteps*100)​
​$pdnBase = "$Base\PaintDotNet"​
New-Item -ItemType Directory -Path $pdnBase -Force | Out-Null​
​
# User Files (Effects, Brushes, etc.)​
$pdnUserFiles = "$UserProfile\Documents\Paint.NET User Files"​
if (Test-Path $pdnUserFiles) {​
Copy-Item -Recurse -Force $pdnUserFiles "$pdnBase\UserFiles"​
}​
​
# App Files (Effects, FileTypes, Palettes, Shapes, .exe plugins)​
$pdnAppFiles = "$UserProfile\Documents\Paint.NET App Files"​
if (Test-Path $pdnAppFiles) {​
Copy-Item -Recurse -Force $pdnAppFiles "$pdnBase\AppFiles"​
}​
​
# Program Files plugins (system-wide)​
$pdnProg = "C:\Program Files\paint.net"​
@("Effects", "FileTypes", "Shapes", "Palettes") | ForEach-Object {​
$srcPath = Join-Path $pdnProg $_​
if (Test-Path $srcPath) {​
Copy-Item -Recurse -Force $srcPath
"$pdnBase\ProgramFiles_$_\"​
}​
}​
​
# Registry export (current user only)​
$regPath = "HKCU:\Software\dotPDN LLC\paint.net"​
if (Test-Path $regPath) {​
reg export "HKCU\Software\dotPDN LLC\paint.net"
"$pdnBase\paintdotnet_registry.reg" | Out-Null​
"Registry settings exported for reference. Not directly usable in
portable version." |​
Out-File "$pdnBase\README_registry.txt"​
}​
​
@"​
HOW TO USE THESE FILES WITH PAINT.NET PORTABLE​
==============================================​
You are using a "portable" version of Paint.NET after this backup.​Here's where to put the custom files:​
​
1. Extract the portable Paint.NET zip to a folder, e.g.
D:\PaintDotNetPortable​
​
2. Copy your backed‑up folders into the portable app's folder like
this:​
- Copy AppFiles\Effects
→ D:\PaintDotNetPortable\Effects\​
- Copy AppFiles\FileTypes → D:\PaintDotNetPortable\FileTypes\​
- Copy AppFiles\Shapes
→ D:\PaintDotNetPortable\Shapes\​
- Copy AppFiles\Palettes
→ D:\PaintDotNetPortable\Palettes\​
- Copy AppFiles\*.exe
→ D:\PaintDotNetPortable\ (root, or a
subfolder if the plugin expects it)​
- Copy UserFiles\*
→ D:\PaintDotNetPortable\User Files\
(or equivalent; see portable app's docs)​
​
3. Some plugins may have stored settings in the registry.​
The file paintdotnet_registry.reg is a reference. Do NOT blindly
import it - use it only to look up specific settings if a plugin
doesn't behave.​
​
4. Start Paint.NET portable. If a plugin requires it, repeat the
install process (most are drag‑and‑drop DLLs, but some .exe plugins
need to be run once).​
​
IMPORTANT: The portable version may look for user files in its own
folder under "Paint.NET User Files" or "User Files". Move your
backed‑up "UserFiles" folder contents there.​
"@ | Out-File "$pdnBase\README_PORTABLE.txt"​
​
#
---------------------------------------------------------------------
--​
# 11. Reminder file (sits at the top of the folder)​
#
---------------------------------------------------------------------
--​
$currentStep++​
Write-Progress -Activity "Backing up Windows settings" -Status"Creating reminder file ($currentStep/$totalSteps)" -PercentComplete
($currentStep/$totalSteps*100)​
​
@"​
PHOTOS TO TAKE BEFORE INSTALLING Linux​
=======================================​
[ ] UEFI/BIOS screens: Boot order, SATA mode (should be AHCI), Secure
Boot state​
[ ] Lenovo Vantage battery charge thresholds (if set)​
[ ] Current partition layout in Windows Disk Management​
[ ] Start menu and taskbar arrangement (screenshot)​
[ ] Any BIOS settings you've changed (Fn-lock, boot delay, etc.)​
[ ] If you skipped full system image, note any important Windows‑only
apps you might miss​
[ ] Any BitLocker recovery key (if drive was encrypted)​
​
THINGS TO MANUALLY EXPORT​
==========================​
- Browser bookmarks: In each browser, export bookmarks to HTML and
save to this folder.​
- If you use an email client, back up its data separately.​
- If you have any game saves not in Documents, locate and copy them.​
"@ | Out-File "$Base\__Hey!_you_have_pics_to_take!__.txt"​
​
#
---------------------------------------------------------------------
--​
# Done​
#
---------------------------------------------------------------------
--​
Write-Progress -Activity "Backing up Windows settings" -Completed​
Write-Host "
Backup complete! All files are in: $Base"
-ForegroundColor Green​
Write-Host "Copy this entire folder to your exFAT drive."
-ForegroundColor Yellow
