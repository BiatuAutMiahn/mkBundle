#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=Res\Icon.ico
#AutoIt3Wrapper_Outfile_x64=..\Init.RunWait.exe
#AutoIt3Wrapper_UseUpx=y
#AutoIt3Wrapper_Change2CUI=y
#AutoIt3Wrapper_Run_Au3Stripper=y
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
#cs ----------------------------------------------------------------------------

 AutoIt Version: 3.3.16.1
 Author:         github/BiatuAutMiahn

 Script Function:
	Console App: Run and Wait for Exit.

#ce ----------------------------------------------------------------------------
If $CmdLine[0]=0 Then
    ConsoleWrite("Usage: [--NoPause] "&@ScriptName&" something.exe [paramN,]"&@CRLF&@CRLF)
    Exit 1
EndIf
Global $bPause=1
If $CmdLine[1]="--NoPause" Then $bPause=0
GLobal $iOff=2
if $bPause Then $iOff=1
Global $sCmd=''
For $i=$iOff to $CmdLine[0]
    $sCmd&=$CmdLine[$i]
    if $i<$CmdLine[0] Then $sCmd&=' '
Next
Global $iRet=RunWait($sCmd,@WorkingDir,@SW_SHOW,0x10)
ConsoleWrite(@CRLF&"Return: "&$iRet&@CRLF&@CRLF)
If $bPause then _pause()
Exit $iRet

Func _pause()
    ConsoleWrite("Press any key to exit...")
    While True
        If ConsoleRead() Then ExitLoop
        Sleep(25)
    WEnd
EndFunc
