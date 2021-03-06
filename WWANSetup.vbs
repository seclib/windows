'==========================================================================
'
' VBScript Source File -- Created with SAPIEN Technologies PrimalScript 2011
'
' NAME: 
'
' AUTHOR: Brian Gonzalez, Panasonic
' DATE  : 8/14/2012
'
' COMMENT: Handles GOBI 1000/2000 or Ericson modem installations.
'
' ERROR CODES:
'	10 - No WWAN modem was detected
'
'Modem Listing...........
'VID_04DA&PID_250F 'GOBI 2000 PNP ID
'VID_04DA&PID_250E 'GOBI 2000 PNP ID
'VID_04DA&PID_250C 'GOBI 1000 PNP ID
'VEN_1022&DEV_2000 'VMWare NIC
'VID_0BDB&PID_190D 'Ericson Modem
'==========================================================================
'On Error Resume Next

strGOBI2KFPNP = "VID_04DA&PID_250F" 'GOBI 2000 PNP ID
strGOBI2KEPNP = "VID_04DA&PID_250E" 'GOBI 2000 PNP ID
strGOBI1KPNP = "VID_04DA&PID_250C" 'GOBI 1000 PNP ID
strERICSONPNP = "VID_0BDB&PID_190D" 'Ericson Modem

If PNPMatch(strGOBI2KFPNP) Or PNPMatch(strGOBI2KEPNP) Then
	WScript.Echo "Gobi 2000 Detected"
ElseIf PNPMatch(strGOBI1KPNP) Then
	WScript.Echo "Gobi 1000 Detected"
ElseIf PNPMatch(strERICSONPNP) Then
	WScript.Echo "Eriscon modem Detected"
Else
	WScript.Quit(10)
End If

Function PNPMatch(strPNPDeviceID)
	Set objWMIService = GetObject("winmgmts:\\.\root\CIMV2")
	Set colItems = objWMIService.ExecQuery("SELECT * FROM Win32_PnPEntity WHERE PNPDeviceID LIKE '%" & strPNPDeviceID & "%'")
	PNPMatch = colItems.Count
End Function
