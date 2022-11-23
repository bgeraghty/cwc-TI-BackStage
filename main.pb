EnableExplicit; PB 6.0.0 LTS x64
Procedure.s ObjectName(h) : Global Desk$ = "ScreenConnectDesktop"
  Protected L=260,R$=Space(L):GetUserObjectInformation_(h,$2,@R$,L,@L):ProcedureReturn R$
EndProcedure
Macro myDesktopName():Trim(ObjectName(GetThreadDesktop_(GetCurrentThreadId_()))):EndMacro
Select UserName()
  Case "SYSTEM" 
    If myDesktopName() <> Desk$ : Global Station$="WinSta0",lpDesk$=(Station$+"\"+Desk$),
      hDesktop=OpenDesktop_(Desk$,1,0,256),szTitle$="NT SERVICE\TrustedInstall",dwF=$430,
      CommandLine_$="cmd.exe /k taskkill /f /im "+GetFilePart(ProgramFilename())+" >nul",
      startup.STARTUPINFO,p.PROCESS_INFORMATION:ZeroMemory_(@startup,SizeOf(STARTUPINFO))
      startup\cb=SizeOf(STARTUPINFO):startup\lpDesktop=@lpDesk$:startup\lpTitle=@szTitle$
      SetProcessWindowStation_( OpenWindowStation_( Station$, 0, $F037F ) )
      SetThreadDesktop_( hDesktop ) : SwitchDesktop_(hDesktop) 
      CreateProcess_(#Null,@CommandLine_$,#Null,#Null,#False,dwF,#Null,#Null,@startup,@p)
    Else:Goto SelfExec:EndIf
  Default
      SelfExec:
      Global hProgram=RunProgram("powershell.exe",
                                 " Register-ScheduledTask -TaskName 'TIBridge' -User 'N"+
                                 "T SERVICE\TrustedInstaller' -Action (New-ScheduledTas"+
                                 "kAction -Execute '"+ProgramFilename()+"');$s=New-Obje"+
                                 "ct -ComObject 'Schedule.Service';$s.Connect();$u='NT "+
                                 "SERVICE\TrustedInstaller';$f=$s.GetFolder('\');$t=$f."+
                                 "GetTask('TIBridge');$t.RunEx($null,0,0,$u);Unregister"+
                                 "-ScheduledTask -TaskName 'TIBridge' -Confirm:$false  ",
                                 GetCurrentDirectory(),$E)
    If hProgram:While ProgramRunning(hProgram):Delay(1):Wend:CloseProgram(hProgram):EndIf
EndSelect
