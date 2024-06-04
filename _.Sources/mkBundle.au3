#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=Res\Infinity.ico
#AutoIt3Wrapper_Outfile_x64=..\mkBundle.exe
#AutoIt3Wrapper_UseUpx=y
#AutoIt3Wrapper_Change2CUI=y
#AutoIt3Wrapper_Res_Fileversion=23.926.1339.98
#AutoIt3Wrapper_Res_Fileversion_AutoIncrement=y
#AutoIt3Wrapper_Res_Fileversion_First_Increment=y
#AutoIt3Wrapper_Res_Language=1033
#AutoIt3Wrapper_Run_Au3Stripper=y
#Au3Stripper_Parameters=/so /rsln
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
#cs ----------------------------------------------------------------------------

 AutoIt Version: 3.3.16.1
 Author:         github/BiatuAutMiahn

 Script Function:
	Creates an sfx bundle.



#ce ----------------------------------------------------------------------------
#include <Array.au3>
#include <File.au3>
#include <WinAPIRes.au3>
#include <WinAPIError.au3>
#include <WinAPIConv.au3>
#include <APIResConstants.au3>
#include <MsgBoxConstants.au3>
#include <WinAPIFiles.au3>
#include <WinAPIHObj.au3>
#include <WinAPIRes.au3>
#include <FileConstants.au3>
#include <Date.au3>
;ConsoleWrite("~!Init@"&@ScriptLineNumber&@CRLF)
;#include "Includes\ResourcesEx.au3"


Global $sBaseDir=@ScriptDir
If Not @Compiled Then $sBaseDir=@ScriptDir&"\.."
Global $sCacheDir=$sBaseDir&"\_.Cache"
Global $sProgDir=$sBaseDir&"\_.Progs"
Global $sOutPath=$sBaseDir&"\.."
Global $aProgs[1][0]

If Not _ScanProgs() Then
    ConsoleWrite("No Programs Found. Exiting."&@CRLF)
    Exit
EndIf
;_ArrayDisplay($aProgs)
; Gen 7z
;
Local $iBreak=0, $iPid
;Name|Version|SfxOutPath|Icon|IconIndex|Cmd|DefParams|Description|SfxCat|Init
Local $sPath,$sName,$sVersion,$sSfxOutPath,$sIcon,$iIconIdx,$sCmd,$sParam,$sDesc,$sSfxCat,$sInit,$bRunAs,$iLastMod=0
Local $bBuild7z=False, $bBuildSFX=False
;DirRemove($sCacheDir,1)
For $i=1 To $aProgs[0][0]
	; Do Last Mod check on files to determine whether we need to rebuild anything.
    $sPath=$aProgs[$i][0]
    $sName=$aProgs[$i][1]
    $sVersion=$aProgs[$i][2]
    $sSfxOutPath=$aProgs[$i][3]
    $sIcon=$aProgs[$i][4]
    $iIconIdx=$aProgs[$i][5]
    $sCmd=$aProgs[$i][6]
    $sParam=$aProgs[$i][7]
    $sDesc=$aProgs[$i][8]
    $sSfxCat=$aProgs[$i][9]
    $sInit=$aProgs[$i][10]
	$iLastMod=$aProgs[$i][11]

    ConsoleWrite($sPath&@CRLF)
	$iLastModCur=dirGetModtStamp($sProgDir&'\'&$sPath)
	;ConsoleWrite($iLastMod&','&$iLastModCur&@CRLF)
	; Rebuild 7z and SFX if any file changed for prog.
	If $iLastModCur>$iLastMod Or $iLastMod==0 Then
		$bBuild7z=True
		$bBuildSFX=True
	EndIf

	; Rebuild SFX if SFX updated
	$iLastModSfx=IniRead($sCacheDir&"\State.ini","tStamp","SFX",0)
	$iLastModSfxCur=FileGetTime($sBaseDir&"\bin\7zSfxS.exe",0,6)
	If $iLastModSfxCur>$iLastModSfx Or $iLastMod==0 Then
		$bBuildSFX=True
	EndIf

	If Not FileExists($sCacheDir&"\_.7z\"&$sPath&".7z") Then $bBuild7z=True
	If Not FileExists($sOutPath&'\'&$sSfxCat&'\'&$sName&' v'&$sVersion&".exe") And Not FileExists($sOutPath&'\'&$sName&' v'&$sVersion&".exe") Then $bBuildSFX=True

	If $bBuildSFX Then
		ConsoleWrite("Preparing SFX Stub "&$sPath&"..."&@CRLF)
		; Create Cache Paths in case they don't exist
		DirCreate($sCacheDir&"\_.sfx")
		DirCreate($sCacheDir&"\_.res")
		; Delete old data
		FileDelete($sCacheDir&"\_.res\"&$sPath&".ico")
		FileDelete($sCacheDir&"\_.sfx\"&$sPath&".sfx")
		; Extract Icon
		Local $iRet
		if StringRight($sIcon,4)=".ico" Then
			FileCopy($sProgDir&'\'&$sPath&'\'&$sIcon,$sCacheDir&"\_.res\"&$sPath&".ico",9)
		Else
			$iRet=_ExtractIconPE($sProgDir&'\'&$sPath&'\'&$sIcon,$sCacheDir&"\_.res\"&$sPath&".ico",$iIconIdx)
		EndIf
		; Copy SFX Stub
		FileCopy($sBaseDir&"\bin\7zSfxS.sfx",$sCacheDir&"\_.sfx\"&$sPath&".sfx",9)
		; Re5place SFX Stub's Icon
		_UpdateIconPE($sCacheDir&"\_.sfx\"&$sPath&".sfx",$sCacheDir&"\_.res\"&$sPath&".ico")
		If @error Then
			ConsoleWrite("Error Updating SFX Icon (Error: "&@Error&','&@Extended&')'&@CRLF)
			ContinueLoop
		EndIf
		; Set up program's initializer.
		If $sInit<>"" Then ConsoleWrite("Bundling Initializer "&$sPath&"..."&@CRLF)
		If $sInit=="PopCap" Then
			FileCopy($sBaseDir&"\bin\init.popcap.init",$sProgDir&'\'&$sPath&"\init.popcap.exe",9)
			$sParam=$sCmd
			$sCmd="init.popcap.exe"
		EndIf
        If $sInit=="Driver" Then
			FileCopy($sBaseDir&"\bin\init.driver.init",$sProgDir&'\'&$sPath&"\init.driver.exe",9)
			$sParam=$sCmd
			$sCmd="init.driver.exe"
		EndIf
        If StringInStr($sInit,"PowerShell") Then
			FileCopy($sBaseDir&"\bin\init.ps.init",$sProgDir&'\'&$sPath&"\init.ps.exe",9)
			$sParam=$sCmd
			$sCmd="init.ps.exe"
		EndIf
        If $sInit=="NaN" Then
			FileCopy($sBaseDir&"\bin\init.nan.init",$sProgDir&'\'&$sPath&"\init.nan.exe",9)
			$sParam=$sCmd
			$sCmd="init.nan.exe"
        EndIf
        ;If $sInit=="RunAs" Then
			;FileCopy($sBaseDir&"\bin\init.runas.exe",$sProgDir&'\'&$sPath&"\init.runas.exe",1)
			;$sParam=$sCmd
			;$sCmd="init.runas.exe"
			;$bRunAs=True
		;EndIf
        If StringInStr($sInit,"Console") Then
			FileCopy($sBaseDir&"\bin\init.con.init",$sProgDir&'\'&$sPath&"\init.con.exe",9)
			$sParam=$sCmd&' '&$sParam
			$sCmd="init.con.exe"
		EndIf
		; Generate SFX Stub Configuration
		Local $sSfxCfg=";!@Install@!UTF-8!"&@CRLF
		If $sSfxOutPath<>'' Then
			$sSfxCfg&='InstallPath="'&$sSfxOutPath&'"'&@CRLF
		EndIf
		If $sName<>'' Then $sSfxCfg&='Title="'&$sName&'"'&@CRLF
		If $sCmd<>'' Then
			$sSfxCfg&='ExecuteFile="'&$sCmd&'"'&@CRLF
			If $sParam<>'' Then $sSfxCfg&='ExecuteParameters="'&$sParam&'"'&@CRLF
		EndIf
		if StringInStr($sInit,"RunAs") Then $sSfxCfg&='ExecuteRunAs="true"'&@CRLF
		$sSfxCfg&=";!@InstallEnd@!"&@CRLF
		; Append Config to SFX
		$hSfxFile=FileOpen($sCacheDir&"\_.sfx\"&$sPath&".sfx",17)
		FileSetEnd($hSfxFile)
		FileWrite($hSfxFile,$sSfxCfg)
		FileClose($hSfxFile)
	EndIf

	If $bBuild7z Then
		; Ensure cache fir exists
	    DirCreate($sCacheDir&"\_.7z")
		; Delete old data
		FileDelete($sCacheDir&"\_.7z\"&$sPath&".7z")
		ConsoleWrite("Creating Archive "&$sPath&"..."&@CRLF)
		; Create 7z
		$sCmd='"'&$sBaseDir&'\bin\7za.exe" a -mx9 -myx9 -mmemusep80 -mtm -mtc -mtr -ms16g -stl -slp "'&$sCacheDir&'\_.7z\'&$sPath&'.7z" "'&$sProgDir&'\'&$sPath&'\*"'
		ConsoleWrite($sCmd&@CRLF)
		$iRet=RunWait($sCmd,$sBaseDir,@SW_HIDE,0x10)
		If $iRet<>0 Then
			ConsoleWrite("Error Creating SFX Archive (Error: "&$iRet&')'&@CRLF)
			ContinueLoop
		EndIf
	EndIf

	If $bBuild7z Or $bBuildSFX Then
		; Ensure cache fir exists
	    DirCreate($sCacheDir&"\_.Bundle")
		; Delete old data
		FileDelete($sCacheDir&"\_.Bundle\"&$sPath&".sfx")
		; Bundling
		ConsoleWrite("Bundling SFX "&$sPath&"..."&@CRLF)
		FileCopy($sCacheDir&"\_.sfx\"&$sPath&".sfx",$sCacheDir&"\_.Bundle\"&$sPath&".sfx",9)
		$hSfxFile=FileOpen($sCacheDir&"\_.Bundle\"&$sPath&".sfx",17)
		FileSetEnd($hSfxFile)
		$h7zFile=FileOpen($sCacheDir&'\_.7z\'&$sPath&".7z",16)
		$iFileSize=FileGetSize($sCacheDir&'\_.7z\'&$sPath&".7z")
		$iBlockSize=(1024*1024);1 MiB
		$iBlocks=Floor($iFileSize/$iBlockSize)
		$iRemains=$iFileSize-($iBlocks*$iBlockSize)
		$v7zData=''
		;ConsoleWrite($iFileSize&','&$iBlocks&','&$iRemains&@CRLF)
		If $iBlocks Then
			For $j=0 To $iBlocks
				FileSetPos($h7zFile,$j*$iBlockSize,0)
				$v7zData=FileRead($h7zFile,$iBlockSize)
				FileWrite($hSfxFile,$v7zData)
			Next
		EndIf
		If $iRemains Then
			FileSetPos($h7zFile,$iBlocks*$iBlockSize,0)
			$v7zData=FileRead($h7zFile,$iRemains)
			FileWrite($hSfxFile,$v7zData)
		EndIf
		FileClose($h7zFile)
		FileClose($hSfxFile)
		If $sSfxCat<>'' Then
			DirCreate($sOutPath&'\'&$sSfxCat)
			FileDelete($sOutPath&'\'&$sSfxCat&'\'&$sName&' v'&$sVersion&".exe")
			;ConsoleWrite($sOutPath&'\'&$sSfxCat&'\'&$sName&' v'&$sVersion&".exe"&@CRLF)
			FileMove($sCacheDir&"\_.Bundle\"&$sPath&".sfx",$sOutPath&'\'&$sSfxCat&'\'&$sName&' v'&$sVersion&".exe")
		Else
			FileDelete($sOutPath&'\'&$sName&' v'&$sVersion&".exe")
			;ConsoleWrite($sOutPath&'\'&$sName&' v'&$sVersion&".exe"&@CRLF)
			FileMove($sCacheDir&"\_.Bundle\"&$sPath&".sfx",$sOutPath&'\'&$sName&' v'&$sVersion&".exe")
		EndIf
		$iLastModCur=dirGetModtStamp($sProgDir&'\'&$sPath)
		IniWrite($sProgDir&'\'&$sPath&"\_.mkbundle.ini","Infinity.Program","LastMod",$iLastModCur)
	EndIf
;~     $iPid=Run('"'&$sBaseDir&'\bin\7za.exe" a -mx9 -myx9 -mmemusep80 -mtm -mtc -mtr -ms16g -stl -slp "'&$sCacheDir&'\_.7z\'&$sPath&'.7z" "'&$sProgDir&'\'&$sPath&'"',@ScriptDir,@SW_HIDE,0x6)
;~     Do
;~         $vStdOut=StdoutRead($iPid,1)
;~         If @error Then $iBreak=1
;~         If $vStdOut<>'' Then
;~             $vStdOut=StdoutRead($iPid)
;~             ConsoleWrite($vStdOut&@CRLF)
;~         EndIf
;~         $vStdErr=StderrRead($iPid,1)
;~         If @error Then $iBreak=1
;~         If $vStdErr<>'' Then
;~             $vStdErr=StdoutRead($iPid)
;~             ConsoleWrite($vStdErr&@CRLF)
;~         EndIf
;~         If Not ProcessExists($iPid) Then $iBreak=1
;~         Sleep(1)
;~     Until $iBreak
Next

Func _ScanProgs()
    Local $aInfProgList=_FileListToArrayRec($sProgDir,"_.mkBundle.ini",1,1,1)
    Local $aSectKeys=StringSplit("Name|Version|SfxOutPath|Icon|IconIndex|Cmd|DefParams|Description|SfxCat|Init|LastMod",'|')
    If Not IsArray($aInfProgList) Then Return SetError(1,0,0)
    For $i=1 To $aInfProgList[0]
        $iMax=UBound($aProgs,1)
        ReDim $aProgs[$iMax+1][$aSectKeys[0]+1]
        $aProgs[$iMax][0]=StringLeft($aInfProgList[$i],StringInStr($aInfProgList[$i],'\',0,-1)-1)
        For $j=1 To $aSectKeys[0]
            $aProgs[$iMax][1+($j-1)]=IniRead($sProgDir&'\'&$aInfProgList[$i],"Infinity.Program",$aSectKeys[$j],'')
        Next
    Next
    $aProgs[0][0]=$iMax
    Return SetError(0,0,1)
EndFunc


; Aparently most of the implementations only do a dump extraction, this will properly extract an ICON_GROUP resource.
Func _ExtractIconPE($sSrc,$sDst,$vIndex=0)
    Local Const $tagGRPICONDIR = "byte idReserved[2];byte idType[2];byte idCount[2];";6 bytes
    Local Const $tagGRPICONDIRENTRY = "byte bWidth;byte bHeight;byte bColorCount;byte bReserved;word wPlanes;word wBitCount;dword dwBytesInRes;byte nID[2]";14 bytes
    Local $szHdr=6
    Local $szEnt=14
    Local $vFileData
    Local $hModule=_WinAPI_LoadLibraryEx($sSrc,BitOR($DONT_RESOLVE_DLL_REFERENCES,$LOAD_LIBRARY_AS_DATAFILE))
    If $hModule==0 Then Return SetError(1,0,0)
    Local $tIconGrp=_GetRes($hModule,$RT_GROUP_ICON,$vIndex,1)
    If @error Then Return SetError(2,@Error,0)
    Local $tData=BinaryToString(DllStructGetData(DllStructCreate("byte["&6+DllStructGetSize($tIconGrp)&']',DllStructGetPtr($tIconGrp)),1))
    Local $vEntries=StringMid($tData,7)
    $vFileData&=StringMid($tData,1,6)
    $iCount=Int(String(BinaryMid($tData,4,2)))
    Local $iOffset=$szHdr+$iCount*16
    Local $aIDs[$iCount],$iIdx=0
    For $i=1 To BinaryLen($vEntries)-$szHdr Step $szEnt
        $vFileData&=StringMid($vEntries,$i,1);bWidth
        $vFileData&=StringMid($vEntries,$i+1,1);bHeight
        $vFileData&=StringMid($vEntries,$i+2,1);bColorCount
        $vFileData&=StringMid($vEntries,$i+3,1);bReserved
        $vFileData&=StringMid($vEntries,$i+4,2);wPlanes
        $vFileData&=(StringMid($vEntries,$i+6,2));wBitCount
        Local $dwSize=BinaryMid($vEntries,$i+8,4);dwBytesInRes
        $vFileData&=BinaryToString($dwSize)
        $vFileData&=BinaryToString($iOffset)
        $iOffset+=_WinAPI_DWordToInt($dwSize)
        $aIDs[$iIdx]=BinaryMid($vEntries,$i+12,2)
        $iIdx+=1
    Next
    For $i In $aIds
        $vFileData&=BinaryToString(DllStructGetData(_GetRes($hModule,$RT_ICON,$i),1))
    Next
    Local $hFile=FileOpen($sDst,18)
    FileWrite($hFile,BinaryToString($vFileData))
    FileClose($hFile)
    _WinAPI_FreeLibrary($hModule)
EndFunc

Func _GetRes($hModule,$sType,$vName,$isIdx=False);$RT_RCDATA
    If $isIdx Then
        Local $aData = _WinAPI_EnumResourceNames($hModule,$sType)
        $vName=$aData[$vName+1]
    EndIf
    Local $hRes=_WinAPI_FindResource($hModule,$sType,$vName)
    If $hRes==0 Then Return SetError(1,_WinAPI_GetLastError(),0)
    Local $iSize = _WinAPI_SizeOfResource($hModule, $hRes)
    If $iSize==0 Then Return SetError(2,_WinAPI_GetLastError(),0)
    Local $hData = _WinAPI_LoadResource($hModule, $hRes)
    If $hData==0 Then Return SetError(3,_WinAPI_GetLastError(),0)
    Local $pData = _WinAPI_LockResource($hData)
    If $pData==0 Then Return SetError(4,_WinAPI_GetLastError(),0)
    $tStruct=DllStructCreate("byte["&$iSize&']',$pData)
    Return $tStruct
EndFunc

Func _UpdateIconPE($sExePath,$sIcoPath)
	;ConsoleWrite($sExePath&@CRLF)
    Local Const $tagICONRESDIR = 'byte Width;byte Height;byte ColorCount;byte Reserved;ushort Planes;ushort BitCount;dword BytesInRes;ushort IconId;'
    Local Const $tagNEWHEADER = 'ushort Reserved;ushort ResType;ushort ResCount;' ; & $tagICONRESDIR[ResCount]
    Local $iError = 1
    Do
        Local $hUpdate = _WinAPI_BeginUpdateResource($sExePath)
        If @error Then Return SetError(1,_WinAPI_GetLastError(),0)
        Local $tIcon = DllStructCreate('ushort Reserved;ushort Type;ushort Count;byte[' & (FileGetSize($sIcoPath) - 6) & ']')
        Local $hFile = _WinAPI_CreateFile($sIcoPath, 2, 2)
        If Not $hFile Then Return SetError(2,_WinAPI_GetLastError(),0)
        Local $iBytes = 0
        _WinAPI_ReadFile($hFile, $tIcon, DllStructGetSize($tIcon), $iBytes)
        _WinAPI_CloseHandle($hFile)
        If Not $iBytes Then Return SetError(3,_WinAPI_GetLastError(),0)
        Local $iCount = DllStructGetData($tIcon, 'Count')
        Local $tDir = DllStructCreate($tagNEWHEADER & 'byte[' & (14 * $iCount) & ']')
        Local $pDir = DllStructGetPtr($tDir)
        DllStructSetData($tDir, 'Reserved', 0)
        DllStructSetData($tDir, 'ResType', 1)
        DllStructSetData($tDir, 'ResCount', $iCount)
        Local $tInfo, $iSize, $tData, $iID = 1
        Local $pIcon = DllStructGetPtr($tIcon)
        For $i = 1 To $iCount
            $tInfo = DllStructCreate('byte Width;byte Heigth;byte Colors;byte Reserved;ushort Planes;ushort BPP;dword Size;dword Offset', $pIcon + 6 + 16 * ($i - 1))
            $iSize = DllStructGetData($tInfo, 'Size')
            If Not _WinAPI_UpdateResource($hUpdate, $RT_ICON, $iID, 1033, $pIcon + DllStructGetData($tInfo, 'Offset'), $iSize) Then Return SetError(4,_WinAPI_GetLastError(),0)
            $tData = DllStructCreate($tagICONRESDIR, $pDir + 6 + 14 * ($i - 1))
            DllStructSetData($tData, 'Width', DllStructGetData($tInfo, 'Width'))
            DllStructSetData($tData, 'Height', DllStructGetData($tInfo, 'Heigth'))
            DllStructSetData($tData, 'ColorCount', DllStructGetData($tInfo, 'Colors'))
            DllStructSetData($tData, 'Reserved', 0)
            DllStructSetData($tData, 'Planes', DllStructGetData($tInfo, 'Planes'))
            DllStructSetData($tData, 'BitCount', DllStructGetData($tInfo, 'BPP'))
            DllStructSetData($tData, 'BytesInRes', $iSize)
            DllStructSetData($tData, 'IconId', $iID)
            $iID += 1
        Next
        If Not _WinAPI_UpdateResource($hUpdate, $RT_GROUP_ICON, 1, 1033, $pDir, DllStructGetSize($tDir)) Then Return SetError(5,_WinAPI_GetLastError(),0)
        $iError = 0
    Until 1
    If Not _WinAPI_EndUpdateResource($hUpdate, $iError) Then SetError(6,_WinAPI_GetLastError(),0)
    Return SetError(0,0,1)
EndFunc

Func dirGetModtStamp($sDir)
	Local $iStampMax=0
	Local $iStampCur=0
	$aFiles=_FileListToArrayRec($sDir,"*",1,1,0,2)
	For $a=1 to $aFiles[0]
		If StringLower(StringRight($aFiles[$a],14))=="_.mkbundle.ini" Then ContinueLoop
		;ConsoleWrite(StringLower(StringRight($aFiles[0],14))&@CRLF)
		$iStampCur=GetFileLastModWithMs($aFiles[$a])
		If @error Then Exit MsgBox(16,@Error,@extended)
		;ConsoleWrite($aFiles[$a]&';'&$iStampCur&@CRLF)
		if $iStampCur>$iStampMax Then $iStampMax=$iStampCur
	Next
	Return $iStampMax
EndFunc

Func GetFileLastModWithMs($_FullFilePathName)
    local $h = _WinAPI_CreateFile($_FullFilePathName, 2, 2, 2)
    local $aTS = _Date_Time_GetFileTime($h)
    _WinAPI_CloseHandle($h)
    local $aDate = _Date_Time_FileTimeToArray($aTS[2]) ; [2] = LastModified
    If Not IsArray($aDate) Then ConsoleWrite($_FullFilePathName&@CRLF)
    Return _DateDiff('s',"1970/01/01 00:00:00",StringFormat("%04d-%02d-%02d %02d:%02d:%02d", $aDate[2], $aDate[0], $aDate[1], $aDate[3], $aDate[4], $aDate[5]))
EndFunc   ;==>GetFileLastModWithMs
