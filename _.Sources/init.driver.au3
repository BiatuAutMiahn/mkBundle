#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=Res\Infinity.ico
#AutoIt3Wrapper_Outfile_x64=..\bin\init.driver.exe
#AutoIt3Wrapper_UseUpx=y
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
#cs ----------------------------------------------------------------------------

 AutoIt Version: 3.3.16.1
 Author:         BiatuAutMiahn[@outlook.com]

#ce ----------------------------------------------------------------------------

$sSysDrive=EnvGet("SystemDrive")
$sSysPath=$sSysDrive&"\System"
$sDriverPath=$sSysPath&"\Drivers"
DirCreate($sSysPath)
DirCreate($sDriverPath)
$iRet=ShellExecuteWait(@ComSpec,'"'&$sSysPath&'\bin\dpinstx64.exe" /lm /q /se /c /sw /path "'&$sDriverPath&'"',$sSysPath&"\bin",'runas',@SW_SHOW)
ClipPut('"'&$sSysPath&'\bin\dpinstx64.exe" /lm /q /se /c /sw /path "'&$sDriverPath&'"')
MsgBox(64,"","Result: "&$iRet)
