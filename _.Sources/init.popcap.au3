#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=Res\Infinity.ico
#AutoIt3Wrapper_Outfile_x64=..\bin\init.popcap.exe
#AutoIt3Wrapper_UseUpx=n
#AutoIt3Wrapper_Res_Fileversion=1.2310.1023.5541
#AutoIt3Wrapper_Res_Language=1033
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****

#cs ----------------------------------------------------------------------------

 AutoIt Version: 3.3.16.1
 Author:         BiatuAutMiahn[@outlook.com]

#ce ----------------------------------------------------------------------------

Global $sTitle="Init.PopCap"
Global $sIni=@ScriptDir&"\_.mkBundle.ini"
$sRegKey=IniRead($sIni,"Init.PopCap","_.RegRoot",-1)
If $sRegKey=-1 Then
    MsgBox(16,$sTitle,"Cannot read config.")
    Exit 1
EndIf
$aConfig=IniReadSection($sIni,"Init.PopCap")
For $i=1 To $aConfig[0][0]
    $aSplit=StringSplit($aConfig[$i][1],':',2)
    If @error Then ContinueLoop
    RegWrite($sRegKey,$aConfig[$i][0],$aSplit[0],$aSplit[1])
Next
If $CmdLine[0]<>1 Then
    Exit 0
EndIf
If Not FileExists(@ScriptDir&'\'&$CmdLine[1]) Then
    MsgBox(16,$sTitle,"Cannot locate the file specified.")
EndIf
Run($CmdLine[1],@ScriptDir,@SW_SHOW)
