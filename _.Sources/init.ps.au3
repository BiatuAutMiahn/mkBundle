#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=Res\Infinity.ico
#AutoIt3Wrapper_Outfile_x64=..\bin\init.ps.exe
#AutoIt3Wrapper_Change2CUI=y
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
#cs ----------------------------------------------------------------------------

 AutoIt Version: 3.3.16.1
 Author:         BiatuAutMiahn[@outlook.com]

#ce ----------------------------------------------------------------------------

#include <AutoItConstants.au3>
#include <Array.au3>

Global $iPid
Global $vStdOut
Global $aStdOut[0]
Global $vStdErr
Global $aStdErr[0]
Global $iErrStdOut
Global $iErrStdErr
Global $iStdOutLast=0
Global $iRun
Global $iState=-3


If $CmdLine[0]<>1 then Exit MsgBox(64,"","Nothing to Do")

Func _RunUpdate()
    $sCommands = 'powershell -ExecutionPolicy ByPass import-module "' & @ScriptDir & '\'&$CmdLine[1]&'"'
    $iPid=RunWait("cmd /c " & $sCommands, "", @SW_SHOW , 0x10)
EndFunc
_RunUpdate()
ConsoleWrite(@CRLF&"Press any key to exit...")
While True
    If ConsoleRead() Then ExitLoop
    Sleep(25)
WEnd

;~ If $CmdLine[0]<>0 Then
;~     If $CmdLine[1]=="0" Then
;~     //RegWrite(); Setup Run Key
;~     ElseIf $CmdLine[1]=="1" Then
;~     ; We run until there is no string returned, ie; no action is taken. If error appears in output 3 times, then we remove run key.
;~         MsgBox(64,@ScriptName,_RunUpdate())
;~     EndIf
;~ Exit 0
