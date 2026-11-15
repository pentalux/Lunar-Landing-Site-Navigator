Unicode true
!include "MUI2.nsh"
!include "x64.nsh"
!ifndef PAYLOAD
  !error "Pass /DPAYLOAD=<portable folder>"
!endif
!ifndef OUTPUT
  !error "Pass /DOUTPUT=<setup.exe>"
!endif
Name "Lunar Navigator 0.10"
OutFile "${OUTPUT}"
InstallDir "$LOCALAPPDATA\LunarNavigator"
InstallDirRegKey HKCU "Software\LunarNavigator" "InstallDir"
RequestExecutionLevel user
; Scientific resources inside the executable are already compressed.
SetCompressor zlib
VIProductVersion "0.10.0.0"
VIAddVersionKey /LANG=1033 "ProductName" "Lunar Navigator"
VIAddVersionKey /LANG=1033 "FileDescription" "Lunar Navigator 0.10 Setup"
VIAddVersionKey /LANG=1033 "FileVersion" "0.10.0"
VIAddVersionKey /LANG=1033 "ProductVersion" "0.10"
VIAddVersionKey /LANG=1033 "LegalCopyright" "Copyright (C) 2026 pentalux"
!define MUI_ABORTWARNING
!define MUI_FINISHPAGE_RUN "$INSTDIR\LunarNavigator.exe"
!define MUI_FINISHPAGE_RUN_NOTCHECKED
!insertmacro MUI_PAGE_WELCOME
!insertmacro MUI_PAGE_DIRECTORY
!insertmacro MUI_PAGE_INSTFILES
!insertmacro MUI_PAGE_FINISH
!insertmacro MUI_UNPAGE_CONFIRM
!insertmacro MUI_UNPAGE_INSTFILES
!insertmacro MUI_LANGUAGE "English"
Function .onInit
  ${IfNot} ${RunningX64}
    MessageBox MB_ICONSTOP "Lunar Navigator requires 64-bit Windows."
    Abort
  ${EndIf}
  SetShellVarContext current
FunctionEnd
Section "Application" SEC_MAIN
  SetOutPath "$INSTDIR"
  File /r "${PAYLOAD}\*.*"
  WriteUninstaller "$INSTDIR\Uninstall.exe"
  CreateDirectory "$SMPROGRAMS\Lunar Navigator"
  CreateShortcut "$SMPROGRAMS\Lunar Navigator\Lunar Navigator.lnk" "$INSTDIR\LunarNavigator.exe"
  CreateShortcut "$SMPROGRAMS\Lunar Navigator\Uninstall.lnk" "$INSTDIR\Uninstall.exe"
  WriteRegStr HKCU "Software\LunarNavigator" "InstallDir" "$INSTDIR"
  WriteRegStr HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\LunarNavigator" "DisplayName" "Lunar Navigator 0.10"
  WriteRegStr HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\LunarNavigator" "DisplayVersion" "0.10"
  WriteRegStr HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\LunarNavigator" "Publisher" "pentalux"
  WriteRegStr HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\LunarNavigator" "DisplayIcon" "$INSTDIR\LunarNavigator.exe"
  WriteRegStr HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\LunarNavigator" "InstallLocation" "$INSTDIR"
  WriteRegStr HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\LunarNavigator" "UninstallString" '"$INSTDIR\Uninstall.exe"'
SectionEnd
Section "Uninstall"
  SetShellVarContext current
  ; Only remove shipped files. Never recursively remove a user-selected folder.
  !include "${PAYLOAD}\..\uninstall-files.nsh"
  Delete "$INSTDIR\Uninstall.exe"
  RMDir "$INSTDIR"
  Delete "$SMPROGRAMS\Lunar Navigator\Lunar Navigator.lnk"
  Delete "$SMPROGRAMS\Lunar Navigator\Uninstall.lnk"
  RMDir "$SMPROGRAMS\Lunar Navigator"
  DeleteRegKey HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\LunarNavigator"
  DeleteRegValue HKCU "Software\LunarNavigator" "InstallDir"
SectionEnd
