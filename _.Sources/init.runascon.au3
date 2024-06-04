#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=Res\Infinity.ico
#AutoIt3Wrapper_Outfile_x64=..\bin\init.runas.exe
#AutoIt3Wrapper_Change2CUI=y
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
If Not IsAdmin() Then
    For $i=1 To $CmdLine[0]
        $sParam&=$CmdLine[$i]
        If $i<>$CmdLine[0] Then $sParam&=' '
    Next
    Exit ShellExecuteWait(@AutoItExe,$sParam,@WorkingDir,"runas")
EndIf
For $i=1 To $CmdLine[0]
    $sParam&=$CmdLine[$i]
    If $i<>$CmdLine[0] Then $sParam&=' '
Next
RunWait($sParam,@WorkingDir,@SW_SHOW,0x10)
ConsoleWrite(@CRLF&"Press any key to exit...")
While True
    If ConsoleRead() Then ExitLoop
    Sleep(25)
WEnd
