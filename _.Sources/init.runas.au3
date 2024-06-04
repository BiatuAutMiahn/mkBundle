#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=Res\Infinity.ico
#AutoIt3Wrapper_Outfile_x64=..\bin\init.runas.exe
#AutoIt3Wrapper_UseUpx=n
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
#cs ----------------------------------------------------------------------------

 AutoIt Version: 3.3.16.1
 Author:        BiatuAutMiahn[@outlook.com]

#ce ----------------------------------------------------------------------------

#include <AutoItConstants.au3>
#include <Array.au3>

If $CmdLine[0]==0 Then
    MsgBox(64,"","Nothing to do!")
    Exit 1
EndIf

Local $sParam=""
For $i=2 To $CmdLine[0]
    $sParam&=$CmdLine[$i]
    If $i<>$CmdLine[0] Then $sParam&=' '
Next
ShellExecuteWait($CmdLine[1],$sParam,@WorkingDir,"runas")

;~ If $CmdLine[0]<>0 Then
;~     If $CmdLine[1]=="0" Then
;~     //RegWrite(); Setup Run Key
;~     ElseIf $CmdLine[1]=="1" Then
;~     ; We run until there is no string returned, ie; no action is taken. If error appears in output 3 times, then we remove run key.
;~         MsgBox(64,@ScriptName,_RunUpdate())
;~     EndIf
;~ Exit 0
