;Installation script for Calendrier
; bb - sdtp - april 2021
;--------------------------------

  !include "MUI2.nsh"
  !include "${NSISDIR}\Contrib\Modern UI\BB.nsh"
  !include x64.nsh
  !include FileFunc.nsh
  
;--------------------------------
;Configuration

  ;General
  Name "Calendrier"
  OutFile "Installcalendrier.exe"
  !define lazarus_dir "C:\Users\Bernard\Documents\Lazarus"
  !define source_dir "${lazarus_dir}\calendrier"
  
  RequestExecutionLevel admin
  
  ;Windows vista.. 10 manifest
  ManifestSupportedOS all

  ;!define MUI_LANGDLL_ALWAYSSHOW                     ; To display language selection dialog
  !define MUI_ICON "${source_dir}\calendrier.ico"
  !define MUI_UNICON "${source_dir}\calendrier.ico"

  ; The default installation directory
  InstallDir "$PROGRAMFILES\Calendrier"

;--------------------------------
; Interface Settings

!define MUI_ABORTWARNING

;--------------------------------
;Language Selection Dialog Settings

  ;Remember the installer language
  !define MUI_LANGDLL_REGISTRY_ROOT "HKCU"
  !define MUI_LANGDLL_REGISTRY_KEY "Software\SDTP\calendrier"
  !define MUI_LANGDLL_REGISTRY_VALUENAME "Installer Language"
  !define MUI_FINISHPAGE_SHOWREADME
  !define MUI_FINISHPAGE_SHOWREADME_TEXT "$(Check_box)"
  !define MUI_FINISHPAGE_SHOWREADME_FUNCTION inst_shortcut
; Pages

  !insertmacro MUI_PAGE_WELCOME
  !insertmacro MUI_PAGE_LICENSE $(licence)
  !insertmacro MUI_PAGE_DIRECTORY
  !insertmacro MUI_PAGE_INSTFILES
  !insertmacro MUI_PAGE_FINISH

  !insertmacro MUI_UNPAGE_WELCOME
  !insertmacro MUI_UNPAGE_CONFIRM
  !insertmacro MUI_UNPAGE_INSTFILES
  !insertmacro MUI_UNPAGE_FINISH

;Languages
  !insertmacro MUI_LANGUAGE "English"
  !insertmacro MUI_LANGUAGE "French"
  !insertmacro MUI_RESERVEFILE_LANGDLL

  ;Licence langage file
  LicenseLangString Licence ${LANG_ENGLISH} "${source_dir}\license.txt"
  LicenseLangString Licence ${LANG_FRENCH}  "${source_dir}\licensf.txt"

  ;Language strings for uninstall string
  LangString RemoveStr ${LANG_ENGLISH}  "Calendar"
  LangString RemoveStr ${LANG_FRENCH} "Calendrier"

  ;Language string for links
  LangString ProgramLnkStr ${LANG_ENGLISH} "Calendar.lnk"
  LangString ProgramLnkStr ${LANG_FRENCH} "Calendrier.lnk"
  LangString UninstLnkStr ${LANG_ENGLISH} "Calendar uninstall.lnk"
  LangString UninstLnkStr ${LANG_FRENCH} "Désinstallation de Calendrier.lnk"

  LangString ProgramDescStr ${LANG_ENGLISH} "Calendar"
  LangString ProgramDescStr ${LANG_FRENCH} "Calendrier"

  ;Language strings for language selection dialog
  LangString LangDialog_Title ${LANG_ENGLISH} "Installer Language|$(^CancelBtn)"
  LangString LangDialog_Title ${LANG_FRENCH} "Langue d'installation|$(^CancelBtn)"

  LangString LangDialog_Text ${LANG_ENGLISH} "Please select the installer language."
  LangString LangDialog_Text ${LANG_FRENCH} "Choisissez la langue du programme d'installation."

  ;language strings for checkbox
  LangString Check_box ${LANG_ENGLISH} "Install a shortcut on the desktop"
  LangString Check_box ${LANG_FRENCH} "Installer un raccourci sur le bureau"

  ;Cannot install
  LangString No_Install ${LANG_ENGLISH} "The application cannot be installed on a 32bit system"
  LangString No_Install ${LANG_FRENCH} "Cette application ne peut pas être installée sur un système 32bits"
  
  ; Language string for remove old install
  LangString Remove_Old ${LANG_ENGLISH} "Install will remove a previous installation."
  LangString Remove_Old ${LANG_FRENCH} "Install va supprimer une ancienne installation."

  !define MUI_LANGDLL_WINDOWTITLE "$(LangDialog_Title)"
  !define MUI_LANGDLL_INFO "$(LangDialog_Text)"
;--------------------------------

  !getdllversion  "${source_dir}\calendrierwin64.exe" expv_
   VIProductVersion "${expv_1}.${expv_2}.${expv_3}.${expv_4}"
   VIAddVersionKey "FileVersion" "${expv_1}.${expv_2}.${expv_3}.${expv_4}"
   VIAddVersionKey "ProductName" "Installcalendrier.exe"
   VIAddVersionKey "FileDescription" "Calendar Installer"
   VIAddVersionKey "LegalCopyright" "sdtp - bb"
   VIAddVersionKey "ProductVersion" "${expv_1}.${expv_2}.${expv_3}.${expv_4}"
; The stuff to install
Section "" ;No components page, name is not important
  SetShellVarContext all
  SetOutPath "$INSTDIR"

  ${If} ${RunningX64}
    SetRegView 64    ; change registry entries and install dir for 64 bit
  ${EndIf}
  Var /GLOBAL prg_to_inst
  Var /GLOBAL prg_to_del
  
  ${If} ${RunningX64}  ; change registry entries and install dir for 64 bit
     !getdllversion  "${source_dir}\calendrierwin64.exe" expv_
     StrCpy "$prg_to_inst" "$INSTDIR\calendrierwin64.exe"
     StrCpy "$prg_to_del" "$INSTDIR\calendrierwin32.exe"
     IfFileExists "$WINDIR\sysnative\libeay32.dll" ssl_lib64_found ssl_lib64_not_found
     ssl_lib64_not_found:
       File "${lazarus_dir}\openssl\win64\libeay32.dll"
       File "${lazarus_dir}\openssl\win64\ssleay32.dll"
       File "${lazarus_dir}\openssl\OpenSSL License.txt"
     ssl_lib64_found:
  ${Else}
     !getdllversion  "${source_dir}\calendrierwin32.exe" expv_
     StrCpy "$prg_to_inst" "$INSTDIR\calendrierwin32.exe"
     StrCpy "$prg_to_del" "$INSTDIR\calendrierwin64.exe"
     IfFileExists "$WINDIR\system32\libeay32.dll" ssl_lib32_found ssl_lib32_not_found
     ssl_lib32_not_found:
       File "${lazarus_dir}\openssl\win32\libeay32.dll"
       File "${lazarus_dir}\openssl\win32\ssleay32.dll"
       File "${lazarus_dir}\openssl\OpenSSL License.txt"
     ssl_lib32_found:
   ${EndIf}
  ; Dans le cas ou on n'aurait pas pu fermer l'application
  Delete /REBOOTOK "$INSTDIR\calendrier.exe"
  File "${source_dir}\calendrierwin64.exe"
  File "${source_dir}\calendrierwin32.exe"
  File "${source_dir}\licensf.txt"
  File "${source_dir}\license.txt"
  File "${source_dir}\history.txt"
  File "${source_dir}\calendrier.txt"
  File "${source_dir}\calendrier.lng"
  File "${source_dir}\calendrier.ini"
  ;File /r "${source_dir}\help"
  Rename /REBOOTOK "$prg_to_inst" "$INSTDIR\calendrier.exe"
  Delete /REBOOTOK "$prg_to_del"

  ; write out uninstaller
  WriteUninstaller "$INSTDIR\uninst.exe"
  ; Get install folder size
  ${GetSize} "$INSTDIR" "/S=0K" $0 $1 $2

  ;Write uninstall in register
  WriteRegStr HKEY_LOCAL_MACHINE "Software\Microsoft\Windows\CurrentVersion\Uninstall\calendrier" "UninstallString" "$INSTDIR\uninst.exe"
  WriteRegStr HKEY_LOCAL_MACHINE "Software\Microsoft\Windows\CurrentVersion\Uninstall\calendrier" "DisplayIcon" "$INSTDIR\uninst.exe"
  WriteRegStr HKEY_LOCAL_MACHINE "Software\Microsoft\Windows\CurrentVersion\Uninstall\calendrier" "DisplayName" "$(RemoveStr)"
  WriteRegStr HKEY_LOCAL_MACHINE "Software\Microsoft\Windows\CurrentVersion\Uninstall\calendrier" "DisplayVersion" "${expv_1}.${expv_2}.${expv_3}.${expv_4}"
  WriteRegDWORD HKEY_LOCAL_MACHINE "Software\Microsoft\Windows\CurrentVersion\Uninstall\calendrier" "EstimatedSize" "$0"
  WriteRegStr HKEY_LOCAL_MACHINE "Software\Microsoft\Windows\CurrentVersion\Uninstall\calendrier" "Publisher" "SDTP"
  WriteRegStr HKEY_LOCAL_MACHINE "Software\Microsoft\Windows\CurrentVersion\Uninstall\calendrier" "URLInfoAbout" "www.sdtp.com"
  WriteRegStr HKEY_LOCAL_MACHINE "Software\Microsoft\Windows\CurrentVersion\Uninstall\calendrier" "HelpLink" "www.sdtp.com"
  ;Store install folder
  WriteRegStr HKCU "Software\SDTP\calendrier" "InstallDir" $INSTDIR

SectionEnd ; end the section

; Install shortcuts, language dependant

Section "Start Menu Shortcuts"
  SetShellVarContext all
  CreateDirectory "$SMPROGRAMS\calendrier"
  CreateShortCut  "$SMPROGRAMS\calendrier\$(ProgramLnkStr)" "$INSTDIR\calendrier.exe" "" "$INSTDIR\calendrier.exe" 0 SW_SHOWNORMAL "" "$(ProgramDescStr)"
  CreateShortCut  "$SMPROGRAMS\calendrier\$(UninstLnkStr)" "$INSTDIR\uninst.exe" "" "$INSTDIR\uninst.exe" 0

SectionEnd

;Uninstaller Section

Section Uninstall
SetShellVarContext all
${If} ${RunningX64}
  SetRegView 64    ; change registry entries and install dir for 64 bit
${EndIf}
; add delete commands to delete whatever files/registry keys/etc you installed here.
Delete /REBOOTOK "$INSTDIR\calendrier.exe"
Delete "$INSTDIR\history.txt"
Delete "$INSTDIR\calendrier.txt"
Delete "$INSTDIR\calendrier.lng"
Delete "$INSTDIR\calendrier.ini"
Delete "$INSTDIR\libeay32.dll"
Delete "$INSTDIR\ssleay32.dll"
Delete "$INSTDIR\licensf.txt"
Delete "$INSTDIR\license.txt"
Delete "$INSTDIR\OpenSSL License.txt"
Delete "$INSTDIR\uninst.exe"
;RMDir /r "$INSTDIR\help"
; remove shortcuts, if any.
  Delete  "$SMPROGRAMS\calendrier\$(ProgramLnkStr)"
  Delete  "$SMPROGRAMS\calendrier\$(UninstLnkStr)"
  Delete  "$DESKTOP\$(ProgramLnkStr)"


; remove directories used.
  RMDir "$SMPROGRAMS\calendrier"
  RMDir "$INSTDIR"

; Remove installed keys
DeleteRegKey HKCU "Software\SDTP\calendrier"
DeleteRegKey HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\calendrier"
; remove also autostart settings if any
DeleteRegKey HKCU "Software\Microsoft\Windows\CurentVersion\Run\calendrier"
DeleteRegKey HKCU "Software\Microsoft\Windows\CurrentVersion\RunOnce\calendrier"

SectionEnd ; end of uninstall section

Function inst_shortcut
  CreateShortCut "$DESKTOP\$(ProgramLnkStr)" "$INSTDIR\calendrier.exe"
FunctionEnd

Function .onInit
  ; !insertmacro MUI_LANGDLL_DISPLAY
  ${If} ${RunningX64}
    SetRegView 64    ; change registry entries and install dir for 64 bit
    StrCpy "$INSTDIR" "$PROGRAMFILES64\calendrier"
  ${Else}

  ${EndIf}
  SetShellVarContext all
  ; Close all apps instance
  FindProcDLL::FindProc "$INSTDIR\calendrier.exe"
  ${While} $R0 > 0
    FindProcDLL::KillProc "$INSTDIR\calendrier.exe"
    FindProcDLL::WaitProcEnd "$INSTDIR\calendrier.exe" -1
    FindProcDLL::FindProc "$INSTDIR\calendrier.exe"
  ${EndWhile}
  
FunctionEnd