#Region ;**** 参数创建于 ACNWrapper_GUI ****
#PRE_Icon=APK-Info.ico
#PRE_Outfile=APK-Info.exe
#PRE_Compression=3
#PRE_UseX64=n
#PRE_Res_Comment=haikejishu
#PRE_Res_Description=APK-Info
#PRE_Res_Fileversion=0.4.0.3
#PRE_Res_Fileversion_AutoIncrement=p
#PRE_Res_LegalCopyright=haikejishu
#PRE_Res_requestedExecutionLevel=None
#PRE_Run_Tidy=y
#EndRegion ;**** 参数创建于 ACNWrapper_GUI ****
#include <EditConstants.au3>
#include <GUIConstantsEx.au3>
#include <StaticConstants.au3>
#include <WindowsConstants.au3>
#include <GDIPlus.au3>
#include <WinAPI.au3>
#include <Array.au3>
#include <String.au3>
#include <Constants.au3>
#include <Crypt.au3>

Opt("TrayMenuMode", 1)
Opt("TrayIconHide", 1)

Global $apkApplication, $apkVersionName, $apkVersionCode, $apkPkgName
Global $apkMinSDK, $apkMinSDKVer, $apkMinSDKName, $apkTargetSDK, $apkTargetSDKVer, $apkTargetSDKName
Global $apkScreens, $apkDensities, $apkPermissions, $apkFeatures
Global $md5Txt, $sCurrentName, $sNewName
Global $fullPathAPK, $dirAPK, $tmpFilename
Global $sMinAndroidString, $sTgtAndroidString, $apkIconName, $apkIconPath

If $CmdLine[0] > 0 Then
	$tmpFilename = $CmdLine[1]
Else
	$tmpFilename = ""
EndIf

$tempPath = @TempDir & "\APK-Info"
_parseApk()

;================== GUI ===========================

$hGUI = GUICreate("APK-Info v1.1.1", 400, 494)
$hLblApplication = GUICtrlCreateLabel("Application", 8, 12, 78, 17)
$hLblVersion = GUICtrlCreateLabel("Version Name", 8, 36, 78, 17)
$hLblVersionCode = GUICtrlCreateLabel("Version Code", 8, 60, 78, 17)
$hLblPackage = GUICtrlCreateLabel("Package Name", 8, 84, 78, 17)
$hLblMinSDK = GUICtrlCreateLabel("Min. SDK", 8, 108, 78, 17)
$hLblTargetSDK = GUICtrlCreateLabel("Target SDK", 8, 132, 78, 17)
$hLblScreenSizes = GUICtrlCreateLabel("Screen Sizes", 8, 156, 78, 17)
$hLblResolutions = GUICtrlCreateLabel("Resolutions", 8, 180, 78, 17)
$hInputApplication = GUICtrlCreateInput($apkApplication, 88, 9, 220, 20, BitOR($GUI_SS_DEFAULT_INPUT, $ES_READONLY))
$hInputVersionName = GUICtrlCreateInput($apkVersionName, 88, 33, 220, 20, BitOR($GUI_SS_DEFAULT_INPUT, $ES_READONLY))
$hInputVersionCode = GUICtrlCreateInput($apkVersionCode, 88, 57, 220, 20, BitOR($GUI_SS_DEFAULT_INPUT, $ES_READONLY))
$hInputPkgName = GUICtrlCreateInput($apkPkgName, 88, 81, 220, 20, BitOR($GUI_SS_DEFAULT_INPUT, $ES_READONLY))
$hInputMinSDK = GUICtrlCreateInput($apkMinSDK, 88, 105, 20, 20, BitOR($GUI_SS_DEFAULT_INPUT, $ES_READONLY))
$hInputMinAndroidString = GUICtrlCreateInput($sMinAndroidString, 110, 105, 198, 20, BitOR($GUI_SS_DEFAULT_INPUT, $ES_READONLY))
$hInputTargetSDK = GUICtrlCreateInput($apkTargetSDK, 88, 129, 20, 20, BitOR($GUI_SS_DEFAULT_INPUT, $ES_READONLY))
$hInputTgtAndroidString = GUICtrlCreateInput($sTgtAndroidString, 110, 129, 198, 20, BitOR($GUI_SS_DEFAULT_INPUT, $ES_READONLY))
$hInputScreens = GUICtrlCreateInput($apkScreens, 88, 153, 220, 20, BitOR($GUI_SS_DEFAULT_INPUT, $ES_READONLY))
$hInputDensities = GUICtrlCreateInput($apkDensities, 88, 177, 220, 20, BitOR($GUI_SS_DEFAULT_INPUT, $ES_READONLY))
$hLblPermissions = GUICtrlCreateLabel("Permissions", 8, 208, 78, 17)
$hEditPermissions = GUICtrlCreateEdit($apkPermissions, 88, 205, 220, 80, BitOR($ES_READONLY, $ES_AUTOVSCROLL, $ES_AUTOHSCROLL, $WS_VSCROLL, $ES_WANTRETURN))
$hLblFeatures = GUICtrlCreateLabel("Features", 8, 301, 78, 17)
$hEditFeatures = GUICtrlCreateEdit($apkFeatures, 88, 298, 220, 60, BitOR($ES_READONLY, $ES_AUTOVSCROLL, $ES_AUTOHSCROLL, $WS_VSCROLL, $ES_WANTRETURN))
$hLblMd5 = GUICtrlCreateLabel("Apk Md5", 8, 370, 78, 17)
$hInputMd5 = GUICtrlCreateInput($md5Txt, 88, 367, 220, 20, BitOR($GUI_SS_DEFAULT_INPUT, $ES_READONLY))
$hLblCurrentName = GUICtrlCreateLabel("Current Name", 8, 400, 78, 17)
$hInputCurrentName = GUICtrlCreateInput($sCurrentName, 88, 397, 220, 20, BitOR($GUI_SS_DEFAULT_INPUT, $ES_READONLY))
$hLblNewName = GUICtrlCreateLabel("New Name", 8, 428, 78, 17)
$hInputNewName = GUICtrlCreateInput($sNewName, 88, 425, 220, 20, BitOR($GUI_SS_DEFAULT_INPUT, $ES_READONLY))
$hBtnSource = GUICtrlCreateButton("Github", 8, 460, 80)
$hBtnRename = GUICtrlCreateButton("Rename File", 313, 422, 80)
$hBtnExit = GUICtrlCreateButton("Exit", 313, 460, 80)
$hBtnOpen = GUICtrlCreateButton("Open", 313, 90, 80)

GUICtrlSetDefBkColor(0xF0F0F0, $hGUI)
_GDIPlus_Startup()
$hImage = _GDIPlus_ImageLoadFromFile($tempPath & "\" & $apkIconName)
$hGraphic = _GDIPlus_GraphicsCreateFromHWND($hGUI)
$hBitmap = _GDIPlus_BitmapCreateFromGraphics(48, 48, $hGraphic)
$hGfxCtxt = _GDIPlus_ImageGetGraphicsContext($hBitmap)
_GDIPlus_GraphicsClear($hGfxCtxt, 0xFFF0F0F0)
GUIRegisterMsg($WM_PAINT, "MY_WM_PAINT")
GUISetState(@SW_SHOW)

;==================== End GUI =====================================

While 1
	$nMsg = GUIGetMsg()
	Switch $nMsg
		Case $hBtnSource
			_openSource()

		Case $hBtnRename
			$sNewNameInput = InputBox("Rename APK File", "New APK Filename:", $sNewName, "", 300, 130)
			If $sNewNameInput <> "" Then _renameAPK($sNewName)

		Case $hBtnExit
			_cleanUp()
			ExitLoop

		Case $GUI_EVENT_CLOSE
			_cleanUp()
			ExitLoop

		Case $hBtnOpen
			_cleanUp()
			_setEmpty()
			_parseApk()
			_setData()
	EndSwitch
WEnd

; Clean up resources
_GDIPlus_ImageDispose($hImage)
_GDIPlus_BitmapDispose($hBitmap)
_GDIPlus_GraphicsDispose($hGraphic)
_GDIPlus_GraphicsDispose($hGfxCtxt)
_GDIPlus_Shutdown()
Exit

Func _setEmpty()
	GUICtrlSetData($hInputApplication, "")
	GUICtrlSetData($hInputVersionName, "")
	GUICtrlSetData($hInputVersionCode, "")
	GUICtrlSetData($hInputPkgName, "")
	GUICtrlSetData($hInputMinSDK, "")
	GUICtrlSetData($hInputMinAndroidString, "")
	GUICtrlSetData($hInputTargetSDK, "")
	GUICtrlSetData($hInputTgtAndroidString, "")
	GUICtrlSetData($hInputScreens, "")
	GUICtrlSetData($hInputDensities, "")
	GUICtrlSetData($hInputCurrentName, "")
	GUICtrlSetData($hInputNewName, "")
	GUICtrlSetData($hInputMd5, "")
	GUICtrlSetData($hEditPermissions, "")
	GUICtrlSetData($hEditFeatures, "")
EndFunc   ;==>_setEmpty

Func _setData()
	GUICtrlSetData($hInputApplication, $apkApplication)
	GUICtrlSetData($hInputVersionName, $apkVersionName)
	GUICtrlSetData($hInputVersionCode, $apkVersionCode)
	GUICtrlSetData($hInputPkgName, $apkPkgName)
	GUICtrlSetData($hInputMinSDK, $apkMinSDK)
	GUICtrlSetData($hInputMinAndroidString, $sMinAndroidString)
	GUICtrlSetData($hInputTargetSDK, $apkTargetSDK)
	GUICtrlSetData($hInputTgtAndroidString, $sTgtAndroidString)
	GUICtrlSetData($hInputScreens, $apkScreens)
	GUICtrlSetData($hInputDensities, $apkDensities)
	GUICtrlSetData($hInputCurrentName, $sCurrentName)
	GUICtrlSetData($hInputNewName, $sNewName)
	GUICtrlSetData($hInputMd5, $md5Txt)
	GUICtrlSetData($hEditPermissions, $apkPermissions)
	GUICtrlSetData($hEditFeatures, $apkFeatures)
	$hImage = _GDIPlus_ImageLoadFromFile($tempPath & "\" & $apkIconName)
	_GDIPlus_GraphicsDrawImageRect($hGraphic, $hImage, 330, 20, 48, 48)
EndFunc   ;==>_setData

Func _parseApk()
	$fullPathAPK = _checkFileParameter($tmpFilename)
	$dirAPK = _SplitPath($fullPathAPK, True)
	$sCurrentName = _SplitPath($fullPathAPK, False)
	$tmpArrBadge = _getBadge($fullPathAPK)
	_parseLines($tmpArrBadge)
	_extractIcon($fullPathAPK, $apkIconPath)
	If $apkMinSDKVer <> "" Then $sMinAndroidString = 'Android ' & $apkMinSDKVer & ' / ' & $apkMinSDKName
	If $apkTargetSDKVer <> "" Then $sTgtAndroidString = 'Android ' & $apkTargetSDKVer & ' / ' & $apkTargetSDKName
	$sNewName = StringReplace($apkApplication, " ", " ") & "_" & StringReplace($apkVersionName, " ", " ") & ".apk"
EndFunc   ;==>_parseApk

; Draw PNG image
Func MY_WM_PAINT($hWnd, $msg, $wParam, $lParam)
	_WinAPI_RedrawWindow($hGUI, 0, 0, $RDW_UPDATENOW)
	_GDIPlus_GraphicsDrawImageRect($hGraphic, $hImage, 330, 20, 48, 48)
	_WinAPI_RedrawWindow($hGUI, 0, 0, $RDW_VALIDATE)
	Return $GUI_RUNDEFMSG
EndFunc   ;==>MY_WM_PAINT

Func _renameAPK($prmNewFilenameAPK)
	$result = FileMove($fullPathAPK, $dirAPK & "\" & $sNewName)
	If $result <> 1 Then MsgBox(0, "Error!", "APK File could not be renamed.")
EndFunc   ;==>_renameAPK

Func _SplitPath($prmFullPath, $prmReturnDir = False)
	$posSlash = StringInStr($prmFullPath, "\", 0, -1)
	Switch $prmReturnDir
		Case False
			Return StringMid($prmFullPath, $posSlash + 1)
		Case True
			Return StringLeft($prmFullPath, $posSlash - 1)
	EndSwitch
EndFunc   ;==>_SplitPath

Func _checkFileParameter($prmFilename)
	If FileExists($prmFilename) Then
		Return $prmFilename
	Else
		$f_Sel = FileOpenDialog("Select APK file", @WorkingDir, "(*.apk)", 1, "")
		If @error Then Exit
		$md5Txt = StringTrimLeft(_Crypt_HashFile($f_Sel, $CALG_MD5), 2)
		Return $f_Sel
	EndIf
EndFunc   ;==>_checkFileParameter

Func _getBadge($prmAPK)
	Local $foo = Run('aapt.exe d badging ' & '"' & $prmAPK & '"', @ScriptDir, @SW_HIDE, $STDERR_CHILD + $STDOUT_CHILD)
	Local $output
	Local $line
	Local $tmp = ""
	While 1
		$line = StdoutRead($foo, False, True)
		If @error Then ExitLoop
		$tmp &= BinaryToString($line, 4)
	WEnd
	$output = $tmp

	$arrayLines = _StringExplode($output, @CRLF)
	Return $arrayLines
EndFunc   ;==>_getBadge

Func _parseLines($prmArrayLines)
	For $line In $prmArrayLines
		$arraySplit = _StringExplode($line, ":", 1)
		If UBound($arraySplit) > 1 Then
			$key = $arraySplit[0]
			$value = $arraySplit[1]
		Else
			ContinueLoop
		EndIf

		Switch $key
			Case 'application'
				$tmpArr = _StringBetween($value, "label='", "'")
				$apkApplication = $tmpArr[0]
				$tmpArr = _StringBetween($value, "icon='", "'")
				$apkIconPath = $tmpArr[0]
				$tmpArr = _StringExplode($apkIconPath, "/")
				$apkIconName = $tmpArr[UBound($tmpArr) - 1]

			Case 'package'
				$tmpArr = _StringBetween($value, "name='", "'")
				$apkPkgName = $tmpArr[0]
				$tmpArr = _StringBetween($value, "versionCode='", "'")
				$apkVersionCode = $tmpArr[0]
				$tmpArr = _StringBetween($value, "versionName='", "'")
				$apkVersionName = $tmpArr[0]

			Case 'uses-permission'
				$tmpArr = _StringBetween($value, "'", "'")
				$apkPermissions &= StringLower(StringReplace($tmpArr[0], "android.permission.", "") & @CRLF)

			Case 'uses-feature'
				$tmpArr = _StringBetween($value, "'", "'")
				$apkFeatures &= StringLower(StringReplace($tmpArr[0], "android.hardware.", "") & @CRLF)

			Case 'sdkVersion'
				$tmpArr = _StringBetween($value, "'", "'")
				$apkMinSDK = $tmpArr[0]
				$apkMinSDKVer = _translateSDKLevel($apkMinSDK)
				$apkMinSDKName = _translateSDKLevel($apkMinSDK, True)

			Case 'targetSdkVersion'
				$tmpArr = _StringBetween($value, "'", "'")
				$apkTargetSDK = $tmpArr[0]
				$apkTargetSDKVer = _translateSDKLevel($apkTargetSDK)
				$apkTargetSDKName = _translateSDKLevel($apkTargetSDK, True)

			Case 'supports-screens'
				$apkScreens = StringStripWS(StringReplace($value, "'", ""), 3)

			Case 'densities'
				$apkDensities = StringStripWS(StringReplace($value, "'", ""), 3)

		EndSwitch
	Next
EndFunc   ;==>_parseLines

Func _extractIcon($prmAPK, $prmIconPath)
	$runCmd = "unzip.exe -o -j -q " & '"' & $prmAPK & '" ' & $prmIconPath & " -d " & '"' & $tempPath & '"'
	ConsoleWrite($runCmd)
	RunWait($runCmd, @ScriptDir, @SW_HIDE)
EndFunc   ;==>_extractIcon

Func _cleanUp()
	_GDIPlus_GraphicsDrawImageRect($hGraphic, $hBitmap, 330, 20, 48, 48)
	_GDIPlus_ImageDispose($hImage)
	FileDelete($tempPath & "\" & $apkIconName)
	DirRemove($tempPath)
EndFunc   ;==>_cleanUp

Func _openSource()
	$url = 'https://github.com/haikejishu/APK-Info'
	ShellExecute($url)
EndFunc   ;==>_openSource

Func _translateSDKLevel($prmSDKLevel, $prmReturnCodeName = False)

	Switch String($prmSDKLevel)
		;You can see uses-sdk on "https://developer.android.com/guide/topics/manifest/uses-sdk-element.html"
		;or "https://developer.android.com/reference/android/os/Build.VERSION_CODES.html"
		Case "38"
			$sVersion = "18"
			$sCodeName = "Android18"
		Case "37"
			$sVersion = "17"
			$sCodeName = "Android17"
		Case "36"
			$sVersion = "16"
			$sCodeName = "Android16"
		Case "35"
			$sVersion = "15"
			$sCodeName = "Vanilla Ice Cream"
		Case "34"
			$sVersion = "14"
			$sCodeName = "Upside Down Cake"
		Case "33"
			$sVersion = "13"
			$sCodeName = "Tiramisu"
		Case "32"
			$sVersion = "12L"
			$sCodeName = "Snow Cone V2"
		Case "31"
			$sVersion = "12"
			$sCodeName = "Snow Cone"
		Case "30"
			$sVersion = "11"
			$sCodeName = "Red Velvet Cake"
		Case "29"
			$sVersion = "10"
			$sCodeName = "Quince Tart"
		Case "28"
			$sVersion = "9"
			$sCodeName = "Pie"
		Case "27"
			$sVersion = "8.1.0"
			$sCodeName = "Oreo MR1"
		Case "26"
			$sVersion = "8.0.0"
			$sCodeName = "Oreo"
		Case "25"
			$sVersion = "7.1"
			$sCodeName = "Nougat MR1"
		Case "24"
			$sVersion = "7.0"
			$sCodeName = "Nougat"
		Case "23"
			$sVersion = "6.0"
			$sCodeName = "Marshmallow"
		Case "22"
			$sVersion = "5.1"
			$sCodeName = "Lollipop MR1"
		Case "21"
			$sVersion = "5.0"
			$sCodeName = "Lollipop"
		Case "20"
			$sVersion = "4.4W"
			$sCodeName = "Kitkat Watch"
		Case "19"
			$sVersion = "4.4"
			$sCodeName = "KitKat"
		Case "18"
			$sVersion = "4.3"
			$sCodeName = "Jelly Bean MR2"
		Case "17"
			$sVersion = "4.2.x"
			$sCodeName = "Jelly Bean MR1"
		Case "16"
			$sVersion = "4.1.x"
			$sCodeName = "Jelly Bean"
		Case "15"
			$sVersion = "4.0.3-4"
			$sCodeName = "Ice Cream Sandwich MR1"
		Case "14"
			$sVersion = "4.0.0-2"
			$sCodeName = "Ice Cream Sandwich"
		Case "13"
			$sVersion = "3.2"
			$sCodeName = "Honeycomb MR2"
		Case "12"
			$sVersion = "3.1.x"
			$sCodeName = "Honeycomb MR1"
		Case "11"
			$sVersion = "3.0.x"
			$sCodeName = "Honeycomb"
		Case "10"
			$sVersion = "2.3.3-4"
			$sCodeName = "Gingerbread MR1"
		Case "9"
			$sVersion = "2.3.0-2"
			$sCodeName = "Gingerbread"
		Case "8"
			$sVersion = "2.2.x"
			$sCodeName = "Froyo"
		Case "7"
			$sVersion = "2.1.x"
			$sCodeName = "Eclair MR1"
		Case "6"
			$sVersion = "2.0.1"
			$sCodeName = "Eclair 01"
		Case "5"
			$sVersion = "2.0"
			$sCodeName = "Eclair"
		Case "4"
			$sVersion = "1.6"
			$sCodeName = "Donut"
		Case "3"
			$sVersion = "1.5"
			$sCodeName = "Cupcake"
		Case "2"
			$sVersion = "1.1"
			$sCodeName = "Base 11"
		Case "1"
			$sVersion = "1.0"
			$sCodeName = "Base"
		Case "10000"
			$sVersion = "Cur_Dev"
			$sCodeName = "Current Dev. Build"
		Case Else
			$sVersion = "Unknown"
			$sCodeName = "Unknown"
	EndSwitch

	Switch $prmReturnCodeName
		Case True
			Return $sCodeName
		Case Else
			Return $sVersion
	EndSwitch
EndFunc   ;==>_translateSDKLevel
