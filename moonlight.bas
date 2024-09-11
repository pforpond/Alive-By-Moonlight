REM alive by moonlight
REM dp 2024

setup:
REM initiates engine and assigns values
ON ERROR GOTO errorhandler
RANDOMIZE TIMER
LET setupboot = 1: REM sets value for engine booting
LET hertz = 30
LET title$ = "Alive By Moonlight"
LET devmode = 1: REM sets value for developer mode
LET screenmode = 2: REM sets value for screen mode
LET resx = 512: REM game x resolution
LET resy = 288: REM game y resolution
LET dloc$ = "moondata/": REM game data folder
LET autoupdate = 666: REM sets auto update value
LET checkupdatelink$ = "https://github.com/pforpond/Alive-By-Moonlight/raw/main/update/checkupdate.ddf"
LET versionno$ = "0.1"
_ALLOWFULLSCREEN _OFF: REM block alt-enter
REM check os
IF INSTR(_OS$, "[WINDOWS]") THEN LET ros$ = "win"
IF INSTR(_OS$, "[LINUX]") THEN LET ros$ = "lnx"
IF INSTR(_OS$, "[MACOSX]") THEN LET ros$ = "mac"
REM sets up console
$CONSOLE
IF devmode = 1 THEN _CONSOLE ON: _CONSOLETITLE "Alive By Moonlight Console"
REM sends platform details to console 
LET eventtitle$ = "ALIVE BY MOONLIGHT:"
LET eventdata$ = "system boot"
LET eventnumber = 0
GOSUB consoleprinter
LET eventtitle$ = "OPERATING SYSTEM DETECTED:"
IF ros$ = "win" THEN LET eventdata$ = "Microsoft Windows"
IF ros$ = "lnx" THEN LET eventdata$ = "Linux"
IF ros$ = "mac" THEN LET eventdata$ = "Apple macOS"
LET eventnumber = 0
GOSUB consoleprinter
REM sets up game screen
GOSUB screenmode
_PRINTMODE _FILLBACKGROUND
PRINT "WAIT..."
REM checks for updates
GOSUB updatechecker
REM loads assets
GOSUB assetload
REM main menu
GOSUB mainmenu
PRINT "WAIT..."
DIM playerlocx(5) AS INTEGER
DIM playerlocy(5) AS INTEGER
DIM playerloctile(5) AS INTEGER
DIM demonhealth(4) AS INTEGER
DIM demonstatus(5) AS INTEGER
DIM demonname(4) AS STRING
DIM demonstruggle(4) AS INTEGER
DIM demonrecover(4) AS INTEGER
DIM demontraptime(4) AS INTEGER
DIM demonescapeattempt(4) AS INTEGER
DIM demonmessage(100) AS INTEGER
DIM demonmessage1(100) AS STRING
DIM demonmessage2(100) AS STRING
DIM demonmessage3(100) AS STRING
DIM demonmessage4(100) AS STRING
DIM exitlevel(2) AS INTEGER
DIM exittile(2) AS INTEGER
GOSUB generategamevalues
DIM maptiletype(maptilex * maptiley) AS INTEGER
DIM becontile(beconno) AS INTEGER
GOSUB generatemap
GOSUB setplayerlocation
LET setupboot = 0
GOTO playgame

updatechecker:
REM checks for update
LET downloadfilename$ = "checkupdate.ddf"
LET downloadfilelink$ = checkupdatelink$
GOSUB filedownloader
IF downloadresult = 0 THEN RETURN
OPEN "checkupdate.ddf" FOR INPUT AS #1
INPUT #1, newversionno$, updaterlinklnx$, updaterlinkmac$, updaterlinkwin$, downloadlink$, windownload$, lnxdownload$, macdownload$, unziplink$, updatetype, updatefolder$, updatewinexe$, updatelinuxexe$, updatemacexe$, updatereadme$, updatechangelog$, updatemanual$, updatesource$, updateupdatersource$, updateupdaterzip2$, updateupdaterzip$
CLOSE #1
IF newversionno$ = versionno$ THEN RETURN
IF ros$ = "mac" THEN
	LET downloadfilename$ = updateupdaterzip$ + "_macos"
    LET downloadfilelink$ = updaterlinkmac$
END IF
IF ros$ = "lnx" THEN
    LET downloadfilename$ = updateupdaterzip$ + "_linux"
    LET downloadfilelink$ = updaterlinklnx$
END IF
IF ros$ = "win" THEN
    LET downloadfilename$ = updateupdaterzip$ + "_win.exe"
    LET downloadfilelink$ = updaterlinkwin$
END IF
LET temp29$ = downloadfilename$
GOSUB filedownloader
IF downloadresult = 0 THEN RETURN
REM writes updater file
LET title$ = "moonlight"
LET filename$ = "moonlight"
LET engineversionno$ = versionno$
OPEN "updatevals.ddf" FOR OUTPUT AS #1
WRITE #1, versionno$, engineversionno$, installtype, title$, filename$, dloc$, mloc$, ploc$, floc$, sloc$, oloc$, scriptloc$, museloc$, sfxloc$, pocketloc$, uiloc$, tloc$, aloc$, menuloc$, downloadicon$, downloadiconresx, downloadiconresy, autoupdate, updatekey$
CLOSE #1
LET eventtitle$ = "UPDATE FOUND:"
LET eventdata$ = versionno$ + " -> " + newversionno$
LET eventnumber = 0
GOSUB consoleprinter
IF ros$ = "lnx" OR ros$ = "mac" THEN SHELL _HIDE "chmod +x " + temp29$: SHELL _DONTWAIT "./" + temp29$
IF ros$ = "win" THEN SHELL _DONTWAIT temp29$
_SCREENHIDE
SYSTEM

filedownloader:
REM downloads a requested file
LET downloadresult = 0
LET eventtitle$ = "DOWNLOAD REQUEST:"
LET eventdata$ = downloadfilename$
LET eventnumber = autoupdate
GOSUB consoleprinter
IF autoupdate = 1 OR autoupdate = 2 THEN
	REM normal download
	SHELL _HIDE "curl -L -o " + downloadfilename$ + " " + downloadfilelink$
END IF
IF autoupdate = 3 THEN
	REM dev download
	IF ros$ = "mac" OR ros$ = "lnx" THEN SHELL _HIDE "curl -H 'Authorization: token " + updatekey$ + "' \-H 'Accept: application/vnd.github.v3.raw' \-O \-L " + downloadfilelink$
	IF ros$ = "win" THEN 
		OPEN "vamedl.bat" FOR OUTPUT AS #99
		PRINT #99, "curl -H " + CHR$(34) + "Authorization: token " + updatekey$ + CHR$(34) + " ^-H " + CHR$(34) + "Accept: application/vnd.github.v3.raw" + CHR$(34) + " ^-O ^-L " + downloadfilelink$
		CLOSE #99
		SHELL _HIDE "vamedl.bat"
		SHELL _HIDE "del vamedl.bat"
	END IF
END IF
REM checks if download worked
IF _FILEEXISTS(downloadfilename$) THEN LET downloadresult = 1
REM tells console
IF downloadresult = 1 THEN
	LET eventtitle$ = "DOWNLOAD COMPLETE:"
ELSE
	LET eventtitle$ = "DOWNLOAD FAILED:"
END IF
LET eventdata$ = downloadfilename$
LET eventnumber = downloadresult
GOSUB consoleprinter
REM clears temp values
LET downloadfilename$ = ""
LET downloadfilelink$ = ""
RETURN

setplayerlocation:
REM sets players location
LET x = 0
DO
	LET x = x + 1
	LET playerlocx(x) = INT(RND * maptilex) + 1
	LET playerlocy(x) = INT(RND * maptiley) + 1
	IF playerlocy(x) = 1 THEN
		LET playerloctile(x) = playerlocx(x)
	ELSE
		LET playerloctile(x) = ((playerlocy(x) - 1) * maptilex) + playerlocx(x)
	END IF
	IF maptiletype(playerloctile(x)) <> 1 THEN 
		LET x = x - 1
	ELSE
		IF x = 5 THEN LET maptiletype(playerloctile(x)) = 13
		IF x = 1 THEN LET maptiletype(playerloctile(x)) = 14
		IF x = 2 THEN LET maptiletype(playerloctile(x)) = 18
		IF x = 3 THEN LET maptiletype(playerloctile(x)) = 22
		IF x = 4 THEN LET maptiletype(playerloctile(x)) = 26
	END IF
	IF x = 5 THEN
		LET eventtitle$ = heroname$ + " LOCATION SET:"
	ELSE
		LET eventtitle$ = demonname$(x) + " LOCATION SET:"
	END IF
	LET eventdata$ = LTRIM$(STR$(playerlocx(x))) + "," + LTRIM$(STR$(playerlocy(x)))
	LET eventnumber = playerloctile(x)
	GOSUB consoleprinter
LOOP UNTIL x >= 5
REM transfer location values from current player
LET locx = playerlocx(playerturn)
LET locy = playerlocy(playerturn)
LET currenttile = playerloctile(playerturn)
REM sets amount of moves in a turn
IF playerturn = 5 THEN 
	LET turnmoves = heromovetotal
ELSE
	LET turnmoves = demonmovetotal
END IF
RETURN

generategamevalues:
REM makes values required for game
LET tileresx = 25: REM tile x resolution
LET tileresy = 25: REM tile y resolution
LET maptilex = 25: REM number of tiles on map (x)
LET maptiley = 25: REM number of tiles on map (y)
LET beconno = 7: REM number of becons
LET beconexit = 5: REM number of becons to complete
LET trapno = 8: REM number of traps
LET exitno = 2: REM number of exits
LET herotrapno = 0: REM number of demons hero has trapped
LET playerturn = 1: REM player to start on. 1 = demon1. 2 = demon2. 3 = demon3. 4 = demon4. 5 = hero.
LET demonstruggletotal = 5: REM total amount of struggles needed to escape hero
LET demonrecovertotal = 10: REM total amont of recovery needed to restore a health state
LET becondamage = 5: REM amount of damage demon does to a becon 
LET becondamagecrit = 7: REM amount of damage demon does to a becon (critical hit)
LET beconhealthtotal = 100: REM total amount of health a becon has
LET trapstagelength = 10: REM amount of turns a trap stage takes
LET totaldemonesc = 3: REM number of attempts to escape first trap
LET gamestatus = 1: REM game status. 1 = main game. 2 = end game. 3 = end game collapse.
LET heromovetotal = 4: REM total number of moves per turn for heros
LET demonmovetotal = 3: REM total number of moves per turn for demons
LET exitgatetimertotal = 10: REM total number of moves needed to open exit gate
LET demonscore = 0: REM sets demon score
LET heroscore = 0: REM sets hero score
LET turn = 1: REM turn number
LET hud = 1: REM hud menu
LET messagetime = 2: REM length of messages in seconds
LET heroname$ = "Hero": REM hero name
LET herostatus = 1: REM hero status. 1 = normal. 2 = carrying demon 
REM demon names
LET demonname$(1) = "Demon 1"
LET demonname$(2) = "Demon 2"
LET demonname$(3) = "Demon 3"
LET demonname$(4) = "Demon 4"
REM demon health
FOR x = 1 TO 4
	LET demonhealth(x) = 3
NEXT x
REM demon play staus
FOR x = 1 TO 4
	LET demonstatus(x) = 1
NEXT x
REM demon struggle level
FOR x = 1 TO 4
	LET demonstruggle(x) = 0
NEXT x
REM demon recover level
FOR x = 1 TO 4
	LET demonrecover(x) = 0
NEXT x
DIM beconhealth(beconno) AS INTEGER
REM becon health
FOR x = 1 TO beconno
	LET beconhealth(x) = beconhealthtotal
NEXT x
REM tells console
LET eventtitle$ = "NEW GAME STARTED"
LET eventdata$ = ""
LET eventnumber = 0
GOSUB consoleprinter
LET eventtitle$ = "MAP SIZE:"
LET eventdata$ = LTRIM$(STR$(maptilex)) + "," + LTRIM$(STR$(maptiley))
LET eventnumber = maptilex * maptiley
GOSUB consoleprinter
LET eventtitle$ = "NUMBER OF BECONS:"
LET eventdata$ = LTRIM$(STR$(beconexit)) + " /"
LET eventnumber = beconno
GOSUB consoleprinter
LET eventtitle$ = "NUMBER OF TRAPS:"
LET eventdata$ = ""
LET eventnumber = trapno
GOSUB consoleprinter
LET eventtitle$ = "NUMBER OF EXITS:"
LET eventdata$ = ""
LET eventnumber = exitno
GOSUB consoleprinter
RETURN

endgame:
REM end game screen
CLS
PRINT "GAME OVER!"
PRINT
PRINT "HERO SCORE: " + LTRIM$(STR$(heroscore))
PRINT "DEMON SCORE: " + LTRIM$(STR$(demonscore))
PRINT
IF heroscore > demonscore THEN PRINT "HERO WINS!"
IF demonscore > heroscore THEN PRINT "DEMONS WIN!"
IF heroscore = demonscore THEN PRINT "DRAW!"
END

nextplayer:
REM moves onto next player
IF turncomplete = 1 THEN
	REM makes any final changes before player moves on
	REM checks if demons are alive
	LET y = 0
	LET yy = 0
	FOR x = 1 TO 4
		IF demonstatus(x) > 5 AND demonstatus(x) < 8 THEN LET y = y + 1
		IF demonstatus(x) = 8 THEN LET y = y + 1
	NEXT x
	IF y => 4 THEN GOTO endgame
	IF playerturn < 5 THEN 
		IF demonstatus(playerturn) = 6 THEN
			REM checks if final struggle happened
			IF demontraptime(playerturn) => trapstagelength THEN LET demonrecover(playerturn) = 0
			IF demonrecover(playerturn) = 1 THEN
				IF struggledtotrap2 = 0 THEN
					LET demonrecover(playerturn) = 0
					LET demontraptime(playerturn) = demontraptime(playerturn) + 1
					LET demonmessage(playerturn) = demonmessage(playerturn) + 1
					IF playerturn = 1 THEN LET demonmessage1$(demonmessage(playerturn)) = "trap stage 2 " + LTRIM$(STR$(demontraptime(playerturn))) + "/" + LTRIM$(STR$(trapstagelength))
					IF playerturn = 2 THEN LET demonmessage2$(demonmessage(playerturn)) = "trap stage 2 " + LTRIM$(STR$(demontraptime(playerturn))) + "/" + LTRIM$(STR$(trapstagelength))
					IF playerturn = 3 THEN LET demonmessage3$(demonmessage(playerturn)) = "trap stage 2 " + LTRIM$(STR$(demontraptime(playerturn))) + "/" + LTRIM$(STR$(trapstagelength))
					IF playerturn = 4 THEN LET demonmessage4$(demonmessage(playerturn)) = "trap stage 2 " + LTRIM$(STR$(demontraptime(playerturn))) + "/" + LTRIM$(STR$(trapstagelength))
				ELSE
					LET demonrecover(playerturn) = 0
					LET struggledtotrap2 = 0
					LET demonmessage(playerturn) = demonmessage(playerturn) + 1
					IF playerturn = 1 THEN LET demonmessage1$(demonmessage(playerturn)) = "trap stage 2 " + LTRIM$(STR$(demontraptime(playerturn))) + "/" + LTRIM$(STR$(trapstagelength))
					IF playerturn = 2 THEN LET demonmessage2$(demonmessage(playerturn)) = "trap stage 2 " + LTRIM$(STR$(demontraptime(playerturn))) + "/" + LTRIM$(STR$(trapstagelength))
					IF playerturn = 3 THEN LET demonmessage3$(demonmessage(playerturn)) = "trap stage 2 " + LTRIM$(STR$(demontraptime(playerturn))) + "/" + LTRIM$(STR$(trapstagelength))
					IF playerturn = 4 THEN LET demonmessage4$(demonmessage(playerturn)) = "trap stage 2 " + LTRIM$(STR$(demontraptime(playerturn))) + "/" + LTRIM$(STR$(trapstagelength))
				END IF
			ELSE
				REM demon dies
				LET demonrecover(playerturn) = 0
				LET demonstatus(playerturn) = 7
				LET maptiletype(currenttile) = 31
				LET demonhealth(playerturn) = 0
				LET demontraptime(playerturn) = 0
				LET heroscore = heroscore + 1
				LET eventtitle$ = demonname$(playerturn) + " HAS DIED!"
				LET eventdata$ = ""
				LET eventnumber = 0
				GOSUB consoleprinter
				LET message$ = "You have died"
				GOSUB displaymessage
			END IF
		END IF
		IF demonstatus(playerturn) = 5 THEN
			REM keeps track of time spent on first stage
			LET demontraptime(playerturn) = demontraptime(playerturn) + 1
			IF demontraptime(playerturn) >= trapstagelength THEN
				LET demonstatus(playerturn) = 6
				LET demontraptime(playerturn) = 0
				LET demonhealth(playerturn) = 1
			END IF
			LET demonmessage(playerturn) = demonmessage(playerturn) + 1
			IF playerturn = 1 THEN LET demonmessage1$(demonmessage(playerturn)) = "trap stage 1 " + LTRIM$(STR$(demontraptime(playerturn))) + "/" + LTRIM$(STR$(trapstagelength))
			IF playerturn = 2 THEN LET demonmessage2$(demonmessage(playerturn)) = "trap stage 1 " + LTRIM$(STR$(demontraptime(playerturn))) + "/" + LTRIM$(STR$(trapstagelength))
			IF playerturn = 3 THEN LET demonmessage3$(demonmessage(playerturn)) = "trap stage 1 " + LTRIM$(STR$(demontraptime(playerturn))) + "/" + LTRIM$(STR$(trapstagelength))
			IF playerturn = 4 THEN LET demonmessage4$(demonmessage(playerturn)) = "trap stage 1 " + LTRIM$(STR$(demontraptime(playerturn))) + "/" + LTRIM$(STR$(trapstagelength))
		END IF
	END IF
	REM changes player 
	LET playerturn = playerturn + 1
	LET turncomplete = 0
	IF playerturn >= 6 THEN LET playerturn = 1: LET turn = turn + 1: REM loops values, starts new turn
	IF playerturn <> 5 THEN IF demonstatus(playerturn) = 7 OR demonstatus(playerturn) = 8 THEN LET turncomplete = 1: GOTO nextplayer: REM demon is dead, move on
	LET locx = playerlocx(playerturn)
	LET locy = playerlocy(playerturn)
	LET currenttile = playerloctile(playerturn)
	IF playerturn = 5 THEN 
		LET turnmoves = heromovetotal
	ELSE
		IF demonstatus(playerturn) = 1 OR demonstatus(playerturn) = 2 THEN LET turnmoves = demonmovetotal
		IF demonstatus(playerturn) >= 3 THEN LET turnmoves = 1
	END IF
	REM tells console 
	IF playerturn <> 5 THEN 
		LET eventtitle$ = demonname$(playerturn) + " TURN BEGINS:"
		LET eventdata$ = demonname$(playerturn)
	ELSE
		LET eventtitle$ = heroname$ + " TURN BEGINS:"
		LET eventdata$ = heroname$
	END IF
	LET eventnumber = 0
	GOSUB consoleprinter
END IF
RETURN

startendgame:
REM begins the end game part of the game once enough becons are destoryed
LET gamestatus = 2
LET x = 0
DO
	LET x = x + 1
	IF maptiletype(x) = 2 THEN LET maptiletype(x) = 3
	IF maptiletype(x) = 11 THEN LET maptiletype(x) = 32
LOOP UNTIL x = (maptilex * maptiley)
LET eventtitle$ = "BECONS DESTORYED:"
LET eventdata$ = "end game stage begins"
LET eventnumber = 0
GOSUB consoleprinter
FOR xx = 1 TO 4
	LET demonmessage(xx) = demonmessage(xx) + 1
	IF xx = 1 THEN LET demonmessage1$(demonmessage(xx)) = "exits are now available"
	IF xx = 2 THEN LET demonmessage2$(demonmessage(xx)) = "exits are now available"
	IF xx = 3 THEN LET demonmessage3$(demonmessage(xx)) = "exits are now available"
	IF xx = 4 THEN LET demonmessage4$(demonmessage(xx)) = "exits are now available"
NEXT xx
RETURN

playgame:
REM game loop
DO
	REM keeps track of which number tile player is on
	IF locy = 1 THEN
		LET currenttile = locx
	ELSE
		LET currenttile = ((locy - 1) * maptilex) + locx
	END IF
	GOSUB drawmap
	GOSUB drawhud
	GOSUB displaystartmessage
	_DISPLAY
	GOSUB inputter
	GOSUB nextplayer
LOOP

displaystartmessage:
REM displays a message upon turn start
IF playerturn = 5 THEN RETURN
'IF turnmoves < demonmovetotal THEN RETURN
IF demonmessage(playerturn) = 0 THEN RETURN
FOR t = 1 TO demonmessage(playerturn)
	IF playerturn = 1 THEN LET message$ = demonmessage1$(t)
	IF playerturn = 2 THEN LET message$ = demonmessage2$(t)
	IF playerturn = 3 THEN LET message$ = demonmessage3$(t)
	IF playerturn = 4 THEN LET message$ = demonmessage4$(t)
	GOSUB displaymessage
	IF playerturn = 1 THEN LET demonmessage1$(t) = ""
	IF playerturn = 2 THEN LET demonmessage2$(t) = ""
	IF playerturn = 3 THEN LET demonmessage3$(t) = ""
	IF playerturn = 4 THEN LET demonmessage4$(t) = ""
NEXT t
LET demonmessage(playerturn) = 0
RETURN

settextcolour:
REM sets text colour
IF playerturn = 5 THEN LET bgcol1 = 172: LET bgcol2 = 247: LET bgcol3 = 136: LET bgcol4 = 127
IF playerturn < 5 THEN
	IF demonstatus(playerturn) = 1 THEN LET bgcol1 = 255: LET bgcol2 = 140: LET bgcol3 = 140: LET bgcol4 = 127
	IF demonstatus(playerturn) = 2 THEN LET bgcol1 = 127: LET bgcol2 = 0: LET bgcol3 = 0: LET bgcol4 = 127
	IF demonstatus(playerturn) = 3 THEN LET bgcol1 = 113: LET bgcol2 = 0: LET bgcol3 = 0: LET bgcol4 = 127
	IF demonstatus(playerturn) = 4 THEN LET bgcol1 = 113: LET bgcol2 = 0: LET bgcol3 = 0: LET bgcol4 = 127
	IF demonstatus(playerturn) = 6 THEN LET bgcol1 = 255: LET bgcol2 = 64: LET bgcol3 = 0: LET bgcol4 = 127
	IF demonstatus(playerturn) = 5 THEN LET bgcol1 = 255: LET bgcol2 = 153: LET bgcol3 = 0: LET bgcol4 = 127
	IF demonstatus(playerturn) = 7 THEN LET bgcol1 = 0: LET bgcol2 = 0: LET bgcol3 = 0: LET bgcol4 = 127
	IF demonstatus(playerturn) = 8 THEN LET bgcol1 = 172: LET bgcol2 = 247: LET bgcol3 = 136: LET bgcol4 = 127
END IF
COLOR _RGBA(255, 255, 255, 255), _RGBA(bgcol1, bgcol2, bgcol3, bgcol4)
RETURN

drawhud:
REM draws hud
REM sets colours
GOSUB settextcolour
IF playerturn = 5 THEN _PRINTSTRING (1, 1), heroname$ + " | " + LTRIM$(STR$(locx)) + "," + LTRIM$(STR$(locy)) + "," + LTRIM$(STR$(currenttile))
IF playerturn < 5 THEN _PRINTSTRING (1, 1), demonname$(playerturn) + " | " + LTRIM$(STR$(locx)) + "," + LTRIM$(STR$(locy)) + "," + LTRIM$(STR$(currenttile))
REM match status
LINE (0, 40)-(40, (resy - 40)), _RGBA(bgcol1, bgcol2, bgcol3, bgcol4), BF: REM hud box
REM becon status
_PUTIMAGE (1, 41), beconuncorrupttile
_PRINTSTRING (26, 45), LTRIM$(STR$(beconexit))
REM demon status
FOR x = 1 TO 4
	IF x = 1 THEN LET xx = 80
	IF x = 2 THEN LET xx = 110
	IF x = 3 THEN LET xx = 140
	IF x = 4 THEN LET xx = 170
	IF demonstatus(x) = 1 THEN 
		IF x = 1 THEN _PUTIMAGE (1, xx), demon1healthytile
		IF x = 2 THEN _PUTIMAGE (1, xx), demon2healthytile
		IF x = 3 THEN _PUTIMAGE (1, xx), demon3healthytile
		IF x = 4 THEN _PUTIMAGE (1, xx), demon4healthytile
	END IF
	IF demonstatus(x) = 2 THEN 
		IF x = 1 THEN _PUTIMAGE (1, xx), demon1hurttile
		IF x = 2 THEN _PUTIMAGE (1, xx), demon2hurttile
		IF x = 3 THEN _PUTIMAGE (1, xx), demon3hurttile
		IF x = 4 THEN _PUTIMAGE (1, xx), demon4hurttile
	END IF
	IF demonstatus(x) = 3 THEN 
		IF x = 1 THEN _PUTIMAGE (1, xx), demon1downtile
		IF x = 2 THEN _PUTIMAGE (1, xx), demon2downtile
		IF x = 3 THEN _PUTIMAGE (1, xx), demon3downtile
		IF x = 4 THEN _PUTIMAGE (1, xx), demon4downtile
	END IF
	IF demonstatus(x) = 4 THEN 
		IF x = 1 THEN _PUTIMAGE (1, xx), herocarrytile
		IF x = 2 THEN _PUTIMAGE (1, xx), herocarrytile
		IF x = 3 THEN _PUTIMAGE (1, xx), herocarrytile
		IF x = 4 THEN _PUTIMAGE (1, xx), herocarrytile
	END IF
	IF demonstatus(x) = 5 THEN 
		IF x = 1 THEN _PUTIMAGE (1, xx), demon1trappedtile
		IF x = 2 THEN _PUTIMAGE (1, xx), demon2trappedtile
		IF x = 3 THEN _PUTIMAGE (1, xx), demon3trappedtile
		IF x = 4 THEN _PUTIMAGE (1, xx), demon4trappedtile
	END IF
	IF demonstatus(x) = 6 THEN 
		IF x = 1 THEN _PUTIMAGE (1, xx), demon1trappedtile
		IF x = 2 THEN _PUTIMAGE (1, xx), demon2trappedtile
		IF x = 3 THEN _PUTIMAGE (1, xx), demon3trappedtile
		IF x = 4 THEN _PUTIMAGE (1, xx), demon4trappedtile
	END IF
	IF demonstatus(x) = 7 THEN 
		IF x = 1 THEN _PUTIMAGE (1, xx), deathtile
		IF x = 2 THEN _PUTIMAGE (1, xx), deathtile
		IF x = 3 THEN _PUTIMAGE (1, xx), deathtile
		IF x = 4 THEN _PUTIMAGE (1, xx), deathtile
	END IF
	IF demonstatus(x) = 8 THEN
		IF x = 1 THEN _PUTIMAGE (1, xx), exitopentile
		IF x = 2 THEN _PUTIMAGE (1, xx), exitopentile
		IF x = 3 THEN _PUTIMAGE (1, xx), exitopentile
		IF x = 4 THEN _PUTIMAGE (1, xx), exitopentile
	END IF
	IF playerturn < 5 THEN _PRINTSTRING (26, xx + 4), LTRIM$(STR$(demonhealth(x)))
NEXT x
LET xx = 0
REM trap status for hero
IF playerturn = 5 THEN
	_PUTIMAGE (1, resy - 65), traptile
	_PRINTSTRING (26, (resy -65) + 4), LTRIM$(STR$(herotrapno))
END IF
IF redrawonly = 1 THEN RETURN
REM possible actions
GOSUB calculatepossibleactions
LET movelist$ = "turn "+ LTRIM$(STR$(turn)) + " | "
LET movelist$ = movelist$ + "moves " + LTRIM$(STR$(turnmoves)) + " | "
IF hud = 1 THEN
	REM default hud menu
	IF turnmoves > 0 THEN
		IF playerturn = 5 OR demonstatus(playerturn) < 4 THEN LET movelist$ = movelist$ + "M=move | ": REM movement
		IF playerturn < 5 THEN
			IF demonstatus(playerturn) = 3 THEN LET movelist$ = movelist$ + "R=recover | ": REM demon recover when downed
			IF demonstatus(playerturn) = 4 THEN LET movelist$ = movelist$ + "S=struggle | ": REM demon struggle when carried
			IF demonstatus(playerturn) = 5 THEN LET movelist$ = movelist$ + "E=attempt escape (risky) | ": REM demon attempt escape when trapped (first stage)
			IF demonstatus(playerturn) = 6 THEN LET movelist$ = movelist$ + "S=struggle or die | ": REM demon struggles on last trap stage
			IF demonstatus(playerturn) < 3 THEN
				IF demonrecoverup > 0 OR demonrecoverdown > 0 OR demonrecoverleft > 0 OR demonrecoverright > 0 THEN LET movelist$ = movelist$ + "H=heal | "
				IF demondamageup > 0 OR demondamagedown > 0 OR demondamageleft > 0 OR demondamageright > 0 THEN LET movelist$ = movelist$ + "D=damage becon | "
				IF demonuntrapup > 0 OR demonuntrapdown > 0 OR demonuntrapleft > 0 OR demonuntrapright > 0 THEN LET movelist$ = movelist$ + "R=rescue | "
				IF exitopenup > 0 OR exitopendown > 0 OR exitopenleft > 0 OR exitopenright > 0 THEN LET movelist$ = movelist$ + "O=open exit | "
				IF demonexit > 0 THEN LET movelist$ = movelist$ + "E=exit game | "
			END IF
		END IF
	END IF
	REM hero hitting and grabbing demon 
	IF turnmoves > 0 AND playerturn = 5  AND herostatus = 1 THEN 
		IF herohitup > 0 OR herohitdown > 0 OR herohitleft > 0 OR herohitright > 0 THEN LET movelist$ = movelist$ + "H=hit | "
		IF herograbup > 0 OR herograbdown > 0 OR herogrableft > 0 OR herograbright > 0 THEN LET movelist$ = movelist$ + "G=grab | "
	END IF
	REM hero is in grab mode
	IF playerturn = 5 AND herostatus = 2 THEN 
		LET movelist$ = movelist$ + "D=drop | "
		IF turnmoves > 0 THEN IF herotrapup > 0 OR herotrapdown > 0 OR herotrapleft > 0 OR herotrapright > 0 THEN LET movelist$ = movelist$ + "T=trap | "
	END IF
	LET movelist$ = movelist$ + "X=end turn": REM end turn
END IF
IF hud = 2 THEN
	REM movement hud
	IF moveup = 1 THEN LET movelist$ = movelist$ + "W=up | "
	IF movedown = 1 THEN LET movelist$ = movelist$ + "S=down | "
	IF moveleft = 1 THEN LET movelist$ = movelist$ + "A=left | "
	IF moveright = 1 THEN LET movelist$ = movelist$ + "D=right | "
	LET movelist$ = movelist$ + "B=back"
END IF
IF hud = 4 THEN
	REM hero hitting demon 
	IF herohitup > 0 THEN LET movelist$ = movelist$ + "W=hit up | "
	IF herohitdown > 0 THEN LET movelist$ = movelist$ + "S=hit down | "
	IF herohitleft > 0 THEN LET movelist$ = movelist$ + "A=hit left | "
	IF herohitright > 0 THEN LET movelist$ = movelist$ + "D=hit right | "
	LET movelist$ = movelist$ + "B=back"
END IF
IF hud = 5 THEN
	REM hero grabbing demon 
	IF herograbup > 0 THEN LET movelist$ = movelist$ + "W=grab up | "
	IF herograbdown > 0 THEN LET movelist$ = movelist$ + "S=grab down | "
	IF herogrableft > 0 THEN LET movelist$ = movelist$ + "A=grab left | "
	IF herograbright > 0 THEN LET movelist$ = movelist$ + "D=grab right | "
	LET movelist$ = movelist$ + "B=back"
END IF
IF hud = 6 THEN
	REM hero trapping demon 
	IF herotrapup > 0 THEN LET movelist$ = movelist$ + "W=trap up | "
	IF herotrapdown > 0 THEN LET movelist$ = movelist$ + "S=trap down | "
	IF herotrapleft > 0 THEN LET movelist$ = movelist$ + "A=trap left | "
	IF herotrapright > 0 THEN LET movelist$ = movelist$ + "D=trap right | "
	LET movelist$ = movelist$ + "B=back"
END IF
IF hud = 7 THEN
	REM demon recovering/healing demon 
	IF demonrecoverup > 0 THEN LET movelist$ = movelist$ + "W=heal up | "
	IF demonrecoverdown > 0 THEN LET movelist$ = movelist$ + "S=heal down | "
	IF demonrecoverleft > 0 THEN LET movelist$ = movelist$ + "A=heal left | "
	IF demonrecoverright > 0 THEN LET movelist$ = movelist$ + "D=heal right | "
	LET movelist$ = movelist$ + "B=back"
END IF
IF hud = 8 THEN
	REM demon damaging becon
	IF demondamageup > 0 THEN LET movelist$ = movelist$ + "W=damage up | "
	IF demondamagedown > 0 THEN LET movelist$ = movelist$ + "S=damage down | "
	IF demondamageleft > 0 THEN LET movelist$ = movelist$ + "A=damage left | "
	IF demondamageright > 0 THEN LET movelist$ = movelist$ + "D=damage right | "
	LET movelist$ = movelist$ + "B=back"
END IF
IF hud = 9 THEN
	REM demon damaging becon
	IF demonuntrapup > 0 THEN LET movelist$ = movelist$ + "W=rescue up | "
	IF demonuntrapdown > 0 THEN LET movelist$ = movelist$ + "S=rescue down | "
	IF demonuntrapleft > 0 THEN LET movelist$ = movelist$ + "A=rescue left | "
	IF demonuntrapright > 0 THEN LET movelist$ = movelist$ + "D=rescue right | "
	LET movelist$ = movelist$ + "B=back"
END IF
IF hud = 10 THEN
	REM demon opening available exit
	IF exitopenup > 0 THEN LET movelist$ = movelist$ + "W=open exit up | "
	IF exitopendown > 0 THEN LET movelist$ = movelist$ + "S=open exit down | "
	IF exitopenleft > 0 THEN LET movelist$ = movelist$ + "A=open exit left | "
	IF exitopenright > 0 THEN LET movelist$ = movelist$ + "D=open exit right | "
	LET movelist$ = movelist$ + "B=back"
END IF
_PRINTSTRING (1, resy - 15), movelist$
COLOR _RGBA(255, 255, 255, 255), _RGBA(0, 0, 0, 255)
RETURN

calculatepossibleactions:
REM erases previous values
LET moveleft = 0
LET moveright = 0
LET moveup = 0
LET movedown = 0
LET herohitup = 0
LET herohitdown = 0
LET herohitleft = 0
LET herohitright = 0
LET herograbup = 0
LET herograbdown = 0
LET herogrableft = 0
LET herograbright = 0
LET herotrapup = 0
LET herotrapdown = 0
LET herotrapleft = 0
LET herotrapright = 0
LET demonrecoverup = 0
LET demonrecoverdown = 0
LET demonrecoverleft = 0
LET demonrecoverright = 0
LET demondamageup = 0
LET demondamagedown = 0
LET demondamageleft = 0
LET demondamageright = 0
LET demonuntrapup = 0
LET demonuntrapdown = 0
LET demonuntrapleft = 0
LET demonuntrapright = 0
LET exitopenup = 0
LET exitopendown = 0
LET exitopenleft = 0
LET exitopenright = 0
LET demonexit = 0
REM calculates any possible actions
REM movement
IF maptiletype(currenttile - 1) = 1 THEN LET moveleft = 1
IF maptiletype(currenttile + 1) = 1 THEN LET moveright = 1
IF maptiletype(currenttile - maptilex) = 1 THEN LET moveup = 1
IF maptiletype(currenttile + maptilex) = 1 THEN LET movedown = 1
REM demon moves
IF playerturn < 5 THEN
	REM checks for a healthy or hurt demon nearby
	FOR x = 13 TO 29
		IF maptiletype(currenttile - 1) = x THEN LET demonrecoverleft = x
		IF maptiletype(currenttile + 1) = x THEN LET demonrecoverright = x
		IF maptiletype(currenttile - maptilex) = x THEN LET demonrecoverup = x
		IF maptiletype(currenttile + maptilex) = x THEN LET demonrecoverdown = x
	NEXT x
	REM assigns which demon is where
	IF demonrecoverleft > 14 AND demonrecoverleft < 17 THEN LET demonrecoverleft = 1
	IF demonrecoverleft > 18 AND demonrecoverleft < 21 THEN LET demonrecoverleft = 2
	IF demonrecoverleft > 22 AND demonrecoverleft < 25 THEN LET demonrecoverleft = 3
	IF demonrecoverleft > 26 AND demonrecoverleft < 29 THEN LET demonrecoverleft = 4
	IF demonrecoverright > 14 AND demonrecoverright < 17 THEN LET demonrecoverright = 1
	IF demonrecoverright > 18 AND demonrecoverright < 21 THEN LET demonrecoverright = 2
	IF demonrecoverright > 22 AND demonrecoverright < 25 THEN LET demonrecoverright = 3
	IF demonrecoverright > 26 AND demonrecoverright < 29 THEN LET demonrecoverright = 4
	IF demonrecoverup > 14 AND demonrecoverup < 17 THEN LET demonrecoverup = 1
	IF demonrecoverup > 18 AND demonrecoverup < 21 THEN LET demonrecoverup = 2
	IF demonrecoverup > 22 AND demonrecoverup < 25 THEN LET demonrecoverup = 3
	IF demonrecoverup > 26 AND demonrecoverup < 29 THEN LET demonrecoverup = 4
	IF demonrecoverdown > 14 AND demonrecoverdown < 17 THEN LET demonrecoverdown = 1
	IF demonrecoverdown > 18 AND demonrecoverdown < 21 THEN LET demonrecoverdown = 2
	IF demonrecoverdown > 22 AND demonrecoverdown < 25 THEN LET demonrecoverdown = 3
	IF demonrecoverdown > 26 AND demonrecoverdown < 29 THEN LET demonrecoverdown = 4
	IF demonrecoverup > 4 THEN LET demonrecoverup = 0
	IF demonrecoverdown > 4 THEN LET demonrecoverdown = 0
	IF demonrecoverleft > 4 THEN LET demonrecoverleft = 0
	IF demonrecoverright > 4 THEN LET demonrecoverright = 0
	IF demonstatus(playerturn) < 3 THEN
		REM checks if working becon is nearby
		FOR x = 1 TO beconno
			IF currenttile - 1 = becontile(x) THEN LET demondamageleft = becontile(x)
			IF currenttile + 1 = becontile(x) THEN LET demondamageright = becontile(x)
			IF currenttile - maptilex = becontile(x) THEN LET demondamageup = becontile(x)
			IF currenttile + maptilex = becontile(x) THEN LET demondamagedown = becontile(x)
		NEXT x
	END IF
	REM checks for trapped demon nearby
	FOR x = 17 TO 29 STEP 4
		IF maptiletype(currenttile - 1) = x THEN LET demonuntrapleft = x
		IF maptiletype(currenttile + 1) = x THEN LET demonuntrapright = x
		IF maptiletype(currenttile - maptilex) = x THEN LET demonuntrapup = x
		IF maptiletype(currenttile + maptilex) = x THEN LET demonuntrapdown = x
	NEXT x
	REM checks for available exit nearby
	IF maptiletype(currenttile - 1) = 32 THEN LET exitopenleft = 1
	IF maptiletype(currenttile + 1) = 32 THEN LET exitopenright = 1
	IF maptiletype(currenttile - maptilex) = 32 THEN LET exitopenup = 1
	IF maptiletype(currenttile + maptilex) = 32 THEN LET exitopendown = 1
	REM checks for open exit nearby
	IF maptiletype(currenttile - 1) = 12 THEN LET demonexit = 1
	IF maptiletype(currenttile + 1) = 12 THEN LET demonexit = 1
	IF maptiletype(currenttile - maptilex) = 12 THEN LET demonexit = 1
	IF maptiletype(currenttile + maptilex) = 12 THEN LET demonexit = 1	
END IF
REM hero moves
IF playerturn = 5 THEN
	REM checks for a healthy or hurt demon nearby
	FOR x = 13 TO 29
		IF maptiletype(currenttile - 1) = x THEN LET herohitleft = x
		IF maptiletype(currenttile + 1) = x THEN LET herohitright = x
		IF maptiletype(currenttile - maptilex) = x THEN LET herohitup = x
		IF maptiletype(currenttile + maptilex) = x THEN LET herohitdown = x
	NEXT x
	REM assigns which demon is where
	IF herohitleft > 13 AND herohitleft < 16 THEN LET herohitleft = 1
	IF herohitleft > 17 AND herohitleft < 20 THEN LET herohitleft = 2
	IF herohitleft > 21 AND herohitleft < 24 THEN LET herohitleft = 3
	IF herohitleft > 25 AND herohitleft < 28 THEN LET herohitleft = 4
	IF herohitright > 13 AND herohitright < 16 THEN LET herohitright = 1
	IF herohitright > 17 AND herohitright < 20 THEN LET herohitright = 2
	IF herohitright > 21 AND herohitright < 24 THEN LET herohitright = 3
	IF herohitright > 25 AND herohitright < 28 THEN LET herohitright = 4
	IF herohitup > 13 AND herohitup < 16 THEN LET herohitup = 1
	IF herohitup > 17 AND herohitup < 20 THEN LET herohitup = 2
	IF herohitup > 21 AND herohitup < 24 THEN LET herohitup = 3
	IF herohitup > 25 AND herohitup < 28 THEN LET herohitup = 4
	IF herohitdown > 13 AND herohitdown < 16 THEN LET herohitdown = 1
	IF herohitdown > 17 AND herohitdown < 20 THEN LET herohitdown = 2
	IF herohitdown > 21 AND herohitdown < 24 THEN LET herohitdown = 3
	IF herohitdown > 25 AND herohitdown < 28 THEN LET herohitdown = 4
	IF herohitup > 4 THEN LET herohitup = 0
	IF herohitdown > 4 THEN LET herohitdown = 0
	IF herohitleft > 4 THEN LET herohitleft = 0
	IF herohitright > 4 THEN LET herohitright = 0
	REM checks for a downed demon nearby
	FOR x = 1 TO 4
		IF x = 1 THEN LET xx = 16
		IF x = 2 THEN LET xx = 20
		IF x = 3 THEN LET xx = 24
		IF x = 4 THEN LET xx = 28
		IF maptiletype(currenttile - 1) = xx THEN LET herogrableft = x
		IF maptiletype(currenttile + 1) = xx THEN LET herograbright = x
		IF maptiletype(currenttile - maptilex) = xx THEN LET herograbup = x
		IF maptiletype(currenttile + maptilex) = xx THEN LET herograbdown = x
	NEXT x
	REM checks for a trap nearby when hero is carrying a demon
	IF herostatus = 2 THEN
		IF maptiletype(currenttile - 1) = 4 THEN LET herotrapleft = 1
		IF maptiletype(currenttile + 1) = 4 THEN LET herotrapright = 1
		IF maptiletype(currenttile - maptilex) = 4 THEN LET herotrapup = 1
		IF maptiletype(currenttile + maptilex) = 4 THEN LET herotrapdown = 1
	END IF
END IF
RETURN

inputter:
REM gets input (temp)
DO
	_LIMIT hertz
	LET a = _KEYHIT
LOOP UNTIL a <> 0
IF hud = 1 THEN
	REM actions
	IF turnmoves > 0 THEN 
		IF playerturn = 5 OR demonstatus(playerturn) < 4 THEN IF a = 77 OR a = 109 THEN LET hud = 2: GOTO endinput: REM movement hud
		IF playerturn < 5 THEN
			IF demonstatus(playerturn) = 3 THEN IF a = 82 OR a = 114 THEN GOSUB demonrecoverself: GOTO endinput: REM demon recovery
			IF demonstatus(playerturn) = 4 THEN IF a = 83 OR a = 115 THEN GOSUB demonstruggle: GOTO endinput: REM demon struggles
			IF demonstatus(playerturn) = 6 THEN IF a = 83 OR a = 115 THEN GOSUB demontrap2struggle: GOTO endinput: REM demon struggles 2nd stage trap
			IF demonstatus(playerturn) < 3 THEN
				IF demonrecoverup > 0 OR demonrecoverdown > 0 OR demonrecoverleft > 0 OR demonrecoverright > 0 THEN IF a = 72 OR a = 104 THEN LET hud = 7: GOTO endinput: REM demon recovers/heals a demon
				IF demondamageup > 0 OR demondamagedown > 0 OR demondamageleft > 0 OR demondamageright > 0 THEN IF a = 68 OR a = 100 THEN LET hud = 8: GOTO endinput
				IF demonuntrapup > 0 OR demonuntrapdown > 0 OR demonuntrapleft > 0 OR demonuntrapright > 0 THEN IF a = 82 OR a = 114 THEN LET hud = 9: GOTO endinput
				IF exitopenup > 0 OR exitopendown > 0 OR exitopenleft > 0 OR exitopenright > 0 THEN IF a = 79 OR a = 111 THEN LET hud = 10: GOTO endinput
				IF demonexit > 0 THEN IF a = 69 OR a = 101 THEN GOSUB demonexitsgame: GOSUB endinput
			END IF
			IF demonstatus(playerturn) = 5 THEN IF a = 69 OR a = 101 THEN GOSUB demontrap1struggle: GOTO endinput: REM demon struggles (first stage trap)
		END IF
	END IF
	IF playerturn = 5 AND herostatus = 2 THEN 
		IF a = 68 OR a = 100 THEN GOSUB herodropdemon: REM drops demon
		IF turnmoves > 0 THEN IF herotrapup > 0 OR herotrapdown > 0 OR herotrapleft > 0 OR herotrapright > 0 THEN IF a = 84 OR a = 116 THEN hud = 6: GOTO endinput
	END IF
	IF a = 88 OR a = 120 THEN LET turncomplete = 1: GOTO endinput: REM end turn
	REM hero hitting or grabbing demon
	IF turnmoves > 0 AND playerturn = 5 THEN 
		IF herohitup > 0 OR herohitdown > 0 OR herohitleft > 0 OR herohitright > 0 THEN IF a = 72 OR a = 104 THEN LET hud = 4: GOTO endinput
		IF herograbup > 0 OR herograbdown > 0 OR herogrableft > 0 OR herograbright > 0 THEN IF a = 71 OR a = 103 THEN LET hud = 5: GOTO endinput
	END IF
	IF devmode = 1 THEN IF a = 90 OR a = 122 THEN LET hud = 3: GOTO endinput: REM developer movement (destructive)
	GOTO endinput
END IF
IF hud = 2 THEN
	REM movement
	IF moveup = 1 THEN IF a = 87 OR a = 119 THEN GOSUB moveplayerup: LET hud = 1: LET turnmoves = turnmoves - 1
	IF movedown = 1 THEN IF a = 83 OR a = 115 THEN GOSUB moveplayerdown: LET hud = 1: LET turnmoves = turnmoves - 1
	IF moveleft = 1 THEN IF a = 65 OR a = 97 THEN GOSUB moveplayerleft: LET hud = 1: LET turnmoves = turnmoves - 1
	IF moveright = 1 THEN IF a = 68 OR a = 100 THEN GOSUB moveplayerright: LET hud = 1: LET turnmoves = turnmoves - 1
	IF a = 66 OR a = 98 THEN LET hud = 1
	GOTO endinput
END IF
IF hud = 3 THEN
	REM developer movement (destructive)
	IF a = 87 OR a = 119 THEN GOSUB moveplayerup
	IF a = 83 OR a = 115 THEN GOSUB moveplayerdown
	IF a = 65 OR a = 97 THEN GOSUB moveplayerleft
	IF a = 68 OR a = 100 THEN GOSUB moveplayerright
	REM keeps within map tiles
	IF locx < 1 THEN LET locx = 1
	IF locx > maptilex THEN LET locx = maptilex
	IF locy < 1 THEN LET locy = 1
	IF locy > maptiley THEN LET locy = maptiley
	IF a = 90 OR a = 122 THEN LET hud = 1
	GOTO endinput
END IF
IF hud = 4 THEN
	REM hero hits demon 
	IF herohitup > 0 THEN IF a = 87 OR a = 119 THEN GOSUB herohitup
	IF herohitdown > 0 THEN IF a = 83 OR a = 115 THEN GOSUB herohitdown
	IF herohitleft > 0 THEN IF a = 65 OR a = 97 THEN GOSUB herohitleft
	IF herohitright > 0 THEN IF a = 68 OR a = 100 THEN GOSUB herohitright
	IF a = 66 OR a = 98 THEN LET hud = 1: REM back
	GOTO endinput
END IF
IF hud = 5 THEN
	REM hero grabs demon 
	IF herograbup > 0 THEN IF a = 87 OR a = 119 THEN GOSUB herograbup
	IF herograbdown > 0 THEN IF a = 83 OR a = 115 THEN GOSUB herograbdown
	IF herogrableft > 0 THEN IF a = 65 OR a = 97 THEN GOSUB herogrableft
	IF herograbright > 0 THEN IF a = 68 OR a = 100 THEN GOSUB herograbright
	IF a = 66 OR a = 98 THEN LET hud = 1: REM back
	GOTO endinput
END IF
IF hud = 6 THEN
	REM hero traps demon 
	IF herotrapup > 0 THEN IF a = 87 OR a = 119 THEN GOSUB herotrapup
	IF herotrapdown > 0 THEN IF a = 83 OR a = 115 THEN GOSUB herotrapdown
	IF herotrapleft > 0 THEN IF a = 65 OR a = 97 THEN GOSUB herotrapleft
	IF herotrapright > 0 THEN IF a = 68 OR a = 100 THEN GOSUB herotrapright
	IF a = 66 OR a = 98 THEN LET hud = 1: REM back
	GOTO endinput
END IF
IF hud = 7 THEN
	REM demon recovers/heals demon 
	IF demonrecoverup > 0 THEN IF a = 87 OR a = 119 THEN GOSUB demonrecoverdemon
	IF demonrecoverdown > 0 THEN IF a = 83 OR a = 115 THEN GOSUB demonrecoverdemon
	IF demonrecoverleft > 0 THEN IF a = 65 OR a = 97 THEN GOSUB demonrecoverdemon
	IF demonrecoverright > 0 THEN IF a = 68 OR a = 100 THEN GOSUB demonrecoverdemon
	IF a = 66 OR a = 98 THEN LET hud = 1: REM back
	GOTO endinput
END IF
IF hud = 8 THEN
	REM demon damages becon 
	IF demondamageup > 0 THEN IF a = 87 OR a = 119 THEN GOSUB demondamagebecon
	IF demondamagedown > 0 THEN IF a = 83 OR a = 115 THEN GOSUB demondamagebecon
	IF demondamageleft > 0 THEN IF a = 65 OR a = 97 THEN GOSUB demondamagebecon
	IF demondamageright > 0 THEN IF a = 68 OR a = 100 THEN GOSUB demondamagebecon
	IF a = 66 OR a = 98 THEN LET hud = 1: REM back
	GOTO endinput
END IF
IF hud = 9 THEN
	REM demon rescues demon from trap 
	IF demonuntrapup > 0 THEN IF a = 87 OR a = 119 THEN GOSUB demonuntrap
	IF demonuntrapdown > 0 THEN IF a = 83 OR a = 115 THEN GOSUB demonuntrap
	IF demonuntrapleft > 0 THEN IF a = 65 OR a = 97 THEN GOSUB demonuntrap
	IF demonuntrapright > 0 THEN IF a = 68 OR a = 100 THEN GOSUB demonuntrap
	IF a = 66 OR a = 98 THEN LET hud = 1: REM back
	GOTO endinput
END IF
IF hud = 10 THEN
	REM demon opens an exit
	IF exitopenup > 0 THEN IF a = 87 OR a = 119 THEN GOSUB demonopenexit
	IF exitopendown > 0 THEN IF a = 83 OR a = 115 THEN GOSUB demonopenexit
	IF exitopenleft > 0 THEN IF a = 65 OR a = 97 THEN GOSUB demonopenexit
	IF exitopenright > 0 THEN IF a = 68 OR a = 100 THEN GOSUB demonopenexit
	IF a = 66 OR a = 98 THEN LET hud = 1: REM back
	GOTO endinput
END IF
endinput:
_KEYCLEAR
RETURN

demonexitsgame:
REM demon exits a game
LET maptiletype(currenttile) = 1
LET demonstatus(playerturn) = 8
LET turnmoves = 0
LET demonscore = demonscore + 1
LET eventtitle$ = demonname$(playerturn) + " HAS ESCAPED"
LET eventdata$ = ""
LET eventnumber = 0
GOSUB consoleprinter
LET message$ = "you have escaped"
GOSUB displaymessage
RETURN

demonopenexit:
REM demon opens an available exit
IF a = 87 OR a = 119 THEN LET y = currenttile - maptilex
IF a = 83 OR a = 115 THEN LET y = currenttile + maptilex
IF a = 65 OR a = 97 THEN LET y = currenttile - 1
IF a = 68 OR a = 100 THEN LET y = currenttile + 1
FOR x = 1 TO 2
	IF y = exittile(x) THEN LET xx = x
NEXT x
LET exitlevel(xx) = exitlevel(xx) + 1
LET turnmoves = turnmoves - 1
LET hud = 1
IF exitlevel(xx) => exitgatetimertotal THEN
	REM exit opens!
	LET maptiletype(y) = 12
	LET eventtitle$ = demonname$(playerturn) + " HAS OPENED EXIT " + LTRIM$(STR$(xx)) + ":"
	LET eventdata$ = "exit " + LTRIM$(STR$(xx)) + " is open for all"
	LET eventnumber = 0
	GOSUB consoleprinter
	LET message$ = "exit " + LTRIM$(STR$(xx)) + " is now open"
	GOSUB displaymessage
	RETURN
END IF
LET eventtitle$ = demonname$(playerturn) + " IS OPENING EXIT " + LTRIM$(STR$(xx)) + ":"
LET eventdata$ = "exit progress is " + LTRIM$(STR$(exitlevel(xx))) + " out of " + LTRIM$(STR$(exitgatetimertotal))
LET eventnumber = 0
GOSUB consoleprinter
LET message$ = "exit " + LTRIM$(STR$(xx)) + " is now opening " + LTRIM$(STR$(exitlevel(xx))) + "/" + LTRIM$(STR$(exitgatetimertotal))
GOSUB displaymessage
RETURN

demontrap2struggle:
REM demon struggles to stay in the game
LET demonrecover(playerturn) = demonrecover(playerturn) + 1
LET turnmoves = turnmoves - 1
LET hud = 1
LET eventtitle$ = demonname$(playerturn) + " STRUGGLED TO STAY ALIVE:"
LET eventdata$ = demonname$(playerturn) + " has " + LTRIM$(STR$(demontraptime(playerturn))) + " out of " + LTRIM$(STR$(trapstagelength)) + " turns to be saved"
LET eventnumber = 0
GOSUB consoleprinter
LET message$ = "You struggled to remain alive " + LTRIM$(STR$(demontraptime(playerturn))) + "/" + LTRIM$(STR$(trapstagelength))
GOSUB displaymessage
RETURN

demontrap1struggle:
REM risky demon escape attempt
LET x = INT(RND * 100) + 1
LET turnmoves = turnmoves - 1
IF x < 5 THEN
	REM sucessful de-trap
	LET message$ = "Your escape attempt was succesful"
	GOSUB displaymessage
	LET eventtitle$ = demonname$(playerturn) + " UN-TRAPPED THEMSELVES:"
	LET eventdata$ = demonname$(playerturn) + " is now hurt"
	LET eventnumber = 0
	GOSUB consoleprinter
	LET selfuntrap = 1
	GOSUB demonuntrap
	LET selfuntrap = 0
	RETURN
ELSE
	REM failure!
	LET demonescapeattempt(playerturn) = demonescapeattempt(playerturn) + 1
	LET message$ = "Your escape attempt failed " + LTRIM$(STR$(demonescapeattempt(playerturn))) + "/" + LTRIM$(STR$(totaldemonesc))
	GOSUB displaymessage
	LET eventtitle$ = demonname$(playerturn) + " UN-TRAP ATTEMPT FAILED:"
	LET eventdata$ = demonname$(playerturn) + " is still trapped"
	LET eventnumber = 0
	GOSUB consoleprinter
	IF demonescapeattempt(playerturn) => totaldemonesc THEN
		REM you failed too many times
		LET demonhealth(playerturn) = demonhealth(playerturn) - 1
		LET demonstatus(playerturn) = 6
		LET struggledtotrap2 = 1
		LET demonrecover(playerturn) = 1
		LET eventtitle$ = demonname$(playerturn) + " IS NOW ON TRAP STAGE 2:"
		LET eventdata$ = demonname$(playerturn) + " will need saving in " + LTRIM$(STR$(trapstagelength)) + " turns"
		LET eventnumber = 0
		GOSUB consoleprinter
		LET message$ = "You are on trap stage 2"
		GOSUB displaymessage
	END IF
END IF
LET hud = 1
RETURN

demonuntrap:
REM demon is untrapped
IF selfuntrap = 0 THEN
	IF a = 87 OR a = 119 THEN LET y = demonuntrapup: LET maptiletype(currenttile - maptilex) = 4
	IF a = 83 OR a = 115 THEN LET y = demonuntrapdown: LET maptiletype(currenttile + maptilex) = 4
	IF a = 65 OR a = 97 THEN LET y = demonuntrapleft: LET maptiletype(currenttile - 1) = 4
	IF a = 68 OR a = 100 THEN LET y = demonuntrapright: LET maptiletype(currenttile + 1) = 4
	IF y = 17 THEN LET y = 1
	IF y = 21 THEN LET y = 2
	IF y = 25 THEN LET y = 3
	IF y = 29 THEN LET y = 4
ELSE
	LET y = playerturn
	LET maptiletype(currenttile) = 4
END IF
IF a1 + a2 + a3 + a4 <> 4 THEN
	REM drop on a nearby tile
	LET x = 0
	LET x = INT(RND * 4) + 1
	IF x = 1 THEN IF maptiletype(currenttile - maptilex) <> 1 THEN LET a1 = 1: GOTO demonuntrap
	IF x = 2 THEN IF maptiletype(currenttile + maptilex) <> 1 THEN LET a2 = 1: GOTO demonuntrap
	IF x = 3 THEN IF maptiletype(currenttile - 1) <> 1 THEN LET a3 = 1: GOTO demonuntrap
	IF x = 4 THEN IF maptiletype(currenttile + 1) <> 1 THEN LET a4 = 1: GOTO demonuntrap
	IF x = 1 THEN 
		IF y = 1 THEN LET maptiletype(currenttile - maptilex) = 15
		IF y = 2 THEN LET maptiletype(currenttile - maptilex) = 19
		IF y = 3 THEN LET maptiletype(currenttile - maptilex) = 23
		IF y = 4 THEN LET maptiletype(currenttile - maptilex) = 27
		LET playerlocy(y) = locy - 1
		LET playerlocx(y) = locx
		LET nexttile = currenttile - maptilex
	END IF
	IF x = 2 THEN 
		IF y = 1 THEN LET maptiletype(currenttile + maptilex) = 15
		IF y = 2 THEN LET maptiletype(currenttile + maptilex) = 19
		IF y = 3 THEN LET maptiletype(currenttile + maptilex) = 23
		IF y = 4 THEN LET maptiletype(currenttile + maptilex) = 27
		LET playerlocy(y) = locy + 1
		LET playerlocx(y) = locx
		LET nexttile = currenttile + maptilex
	END IF
	IF x = 3 THEN 
		IF y = 1 THEN LET maptiletype(currenttile - 1) = 15
		IF y = 2 THEN LET maptiletype(currenttile - 1) = 19
		IF y = 3 THEN LET maptiletype(currenttile - 1) = 23
		IF y = 4 THEN LET maptiletype(currenttile - 1) = 27
		LET playerlocx(y) = locx - 1
		LET playerlocy(y) = locy
		LET nexttile = currenttile - 1
	END IF
	IF x = 4 THEN 
		IF y = 1 THEN LET maptiletype(currenttile + 1) = 15
		IF y = 2 THEN LET maptiletype(currenttile + 1) = 19
		IF y = 3 THEN LET maptiletype(currenttile + 1) = 23
		IF y = 4 THEN LET maptiletype(currenttile + 1) = 27
		LET playerlocx(y) = locx + 1
		LET playerlocy(y) = locy
		LET nexttile = currenttile + 1
	END IF
	LET playerloctile(y) = nexttile
ELSE
	REM drop on a random tile somewhere
	LET x = 0
	LEt yy = 1
	LET x = INT(RND * (maptilex * maptiley)) + 1
	IF maptiletype(x) <> 1 THEN GOTO demonuntrap
	IF y = 1 THEN LET maptiletype(x) = 15
	IF y = 2 THEN LET maptiletype(x) = 19
	IF y = 3 THEN LET maptiletype(x) = 23
	IF y = 4 THEN LET maptiletype(x) = 27
	LET playerloctile(y) = x
	DO
		LET x = x - maptilex
		LET yy = yy + 1
	LOOP UNTIL x < maptilex
	LET playerlocx(y) = x
	LET playerlocy(y) = yy
END IF
IF selfuntrap = 1 THEN
	LET currenttile = nexttile
	LET locx = playerlocx(y)
	LET locy = playerlocy(y)
END IF
LET eventtitle$ = demonname$(playerturn) + " UN-TRAPS " + demonname$(y) + ":"
LET eventdata$ = demonname$(y) + " is now hurt"
LET eventnumber = 0
GOSUB consoleprinter
LET demonstatus(y) = 2
LET demonstruggle(y) = 0
LET demonrecover(y) = 0
IF turnmoves > 0 THEN LET turnmoves = turnmoves - 1
LET hud = 1
LET a1 = 0: LET a2 = 0: LET a3 = 0: LET a4 = 0: LET yy = 0: LET y = 0
RETURN

demondamagebecon:
REM demon damages a becon
IF a = 87 OR a = 119 THEN LET y = demondamageup
IF a = 83 OR a = 115 THEN LET y = demondamagedown
IF a = 65 OR a = 97 THEN LET y = demondamageleft
IF a = 68 OR a = 100 THEN LET y = demondamageright
FOR x = 1 TO beconno
	IF becontile(x) = y THEN LET currentbecon = x
NEXT x
LET crithit = INT(RND * 100) + 1
IF crithit > 90 THEN
	LET crithit = 1
ELSE
	LET crithit = 0
END IF
IF crithit = 1 THEN LET beconhealth(currentbecon) = beconhealth(currentbecon) - becondamagecrit
IF crithit = 0 THEN LET beconhealth(currentbecon) = beconhealth(currentbecon) - becondamage
LET turnmoves = turnmoves - 1
LET hud = 1
IF beconhealth(currentbecon) <= 0 THEN
	REM if becon is out of health and breaks
	LET becontile(currentbecon) = - 1
	LET beconexit = beconexit - 1
	LET maptiletype(y) = 3
	LET eventtitle$ = demonname$(playerturn) + " HAS BROKEN BECON " + LTRIM$(STR$(currentbecon)) + ":"
	LET eventdata$ = "becon " + LTRIM$(STR$(currentbecon)) + " is now broken"
	LET eventnumber = 0
	GOSUB consoleprinter
	LET message$ = "You broke the becon"
	GOSUB displaymessage
	REM checks if enough becons are active
	IF beconexit =< 0 THEN IF gamestatus = 1 THEN GOSUB startendgame
	RETURN
END IF
LET eventtitle$ = demonname$(playerturn) + " HAS DAMAGED BECON " + LTRIM$(STR$(currentbecon)) + ":"
LET eventdata$ = "becon " + LTRIM$(STR$(currentbecon)) + " health is now " + LTRIM$(STR$(beconhealth(currentbecon))) + "/" + LTRIM$(STR$(beconhealthtotal))
LET eventnumber = 0
GOSUB consoleprinter
LET message$ = "You damaged the becon " + LTRIM$(STR$(beconhealth(currentbecon))) + "/" + LTRIM$(STR$(beconhealthtotal))
GOSUB displaymessage
RETURN

demonstruggle:
REM demon struggles whilst being carried
LET demonstruggle(playerturn) = demonstruggle(playerturn) + 1
LET turnmoves = turnmoves - 1
LET eventtitle$ = demonname$(playerturn) + " HAS STRUGGLED:"
LET eventdata$ = LTRIM$(STR$(demonstruggle(playerturn))) + "/5"
LET eventnumber = 0
GOSUB consoleprinter
LET message$ = "You have struggled " + LTRIM$(STR$(demonstruggle(playerturn))) + "/" + LTRIM$(STR$(demonstruggletotal))
GOSUB displaymessage
IF demonstruggle(playerturn) < 5 THEN RETURN: REM returns for if demon needs to struggle more
REM demon has struggled enough to get away
LET demonstruggle(playerturn) = 0
LET turnmoves = demonmovetotal + 1
LET eventtitle$ = demonname$(playerturn) + " HAS BROKE FREE FROM " + heroname$ + ":"
LET eventdata$ = "5/5"
LET eventnumber = 0
GOSUB consoleprinter
LET struggledrop = 1
GOSUB herodropdemon
LET struggledrop = 0
LET message$ = "You broke free from " + heroname$
GOSUB displaymessage
LET message$ = "You gain " + LTRIM$(STR$(demonmovetotal + 1)) + " extra moves"
GOSUB displaymessage
RETURN

demonrecoverdemon:
REM demon recovers a demon
IF a = 87 OR a = 119 THEN LET y = currenttile - maptilex
IF a = 83 OR a = 115 THEN LET y = currenttile + maptilex
IF a = 65 OR a = 97 THEN LET y = currenttile - 1
IF a = 68 OR a = 100 THEN LET y = currenttile + 1
LET turnmoves = turnmoves - 1
IF maptiletype(y) = 15 OR maptiletype(y) = 16 THEN LET x = 1
IF maptiletype(y) = 19 OR maptiletype(y) = 20 THEN LET x = 2
IF maptiletype(y) = 23 OR maptiletype(y) = 24 THEN LET x = 3
IF maptiletype(y) = 27 OR maptiletype(y) = 28 THEN LET x = 4
LET demonrecover(x) = demonrecover(x) + 1
LET eventtitle$ = demonname$(playerturn) + " HAS RECOVERED " + demonname$(x) + ":"
LET eventdata$ = LTRIM$(STR$(demonrecover(x))) + "/" + LTRIM$(STR$(demonrecovertotal))
LET eventnumber = 0
GOSUB consoleprinter
REM if recover level is filled
IF demonrecover(x) > demonrecovertotal - 1 THEN
	IF demonstatus(x) = 3 THEN
		REM recovered down demon to hurt
		LET demonstatus(x) = 2
		LET demonrecover(x) = 0
		IF x = 1 THEN LET maptiletype(y) = 15
		IF x = 2 THEN LET maptiletype(y) = 19
		IF x = 3 THEN LET maptiletype(y) = 23
		IF x = 4 THEN LET maptiletype(y) = 27
		LET eventtitle$ = demonname$(playerturn) + " HAS HEALED " + demonname$(x) + ":"
		LET eventdata$ = demonname$(x) + " is now hurt"
		LET eventnumber = 0
		GOSUB consoleprinter
		LET demonmessage(x) = demonmessage(x) + 1
		IF x = 1 THEN LET demonmessage1$(demonmessage(x)) = "you have been half healed by " + demonname$(playerturn) 
		IF x = 2 THEN LET demonmessage2$(demonmessage(x)) = "you have been half healed by " + demonname$(playerturn) 
		IF x = 3 THEN LET demonmessage3$(demonmessage(x)) = "you have been half healed by " + demonname$(playerturn) 
		IF x = 4 THEN LET demonmessage4$(demonmessage(x)) = "you have been half healed by " + demonname$(playerturn) 
		LET message$ = "You have recovered " + demonname$(x) + " "+  + LTRIM$(STR$(demonrecovertotal)) + "/" +  LTRIM$(STR$(demonrecovertotal))
		GOSUB displaymessage
		LET hud = 1
		RETURN
	END IF
	IF demonstatus(x) = 2 THEN
		REM recovered hurt demon to healthy
		LET demonstatus(x) = 1
		LET demonrecover(x) = 0
		IF x = 1 THEN LET maptiletype(y) = 14
		IF x = 2 THEN LET maptiletype(y) = 18
		IF x = 3 THEN LET maptiletype(y) = 22
		IF x = 4 THEN LET maptiletype(y) = 26
		LET eventtitle$ = demonname$(playerturn) + " HAS HEALED " + demonname$(x) + ":"
		LET eventdata$ = demonname$(x) + " is now hurt"
		LET eventnumber = 0
		GOSUB consoleprinter
		LET demonmessage(x) = demonmessage(x) + 1
		IF x = 1 THEN LET demonmessage1$(demonmessage(x)) = "you have been fully healed by " + demonname$(playerturn) 
		IF x = 2 THEN LET demonmessage2$(demonmessage(x)) = "you have been fully healed by " + demonname$(playerturn) 
		IF x = 3 THEN LET demonmessage3$(demonmessage(x)) = "you have been fully healed by " + demonname$(playerturn) 
		IF x = 4 THEN LET demonmessage4$(demonmessage(x)) = "you have been fully healed by " + demonname$(playerturn) 
		LET message$ = "You have recovered " + demonname$(x) + " "+  + LTRIM$(STR$(demonrecovertotal)) + "/" + LTRIM$(STR$(demonrecovertotal))
		GOSUB displaymessage
		LET hud = 1
		RETURN
	END IF
END IF
LET demonmessage(x) = demonmessage(x) + 1
IF x = 1 THEN LET demonmessage1$(demonmessage(x)) = "you have been healed by " + demonname$(playerturn) + " " + LTRIM$(STR$(demonrecover(x))) + "/" + LTRIM$(STR$(demonrecovertotal))
IF x = 2 THEN LET demonmessage2$(demonmessage(x)) = "you have been healed by " + demonname$(playerturn) + " " + LTRIM$(STR$(demonrecover(x))) + "/" + LTRIM$(STR$(demonrecovertotal))
IF x = 3 THEN LET demonmessage3$(demonmessage(x)) = "you have been healed by " + demonname$(playerturn) + " " + LTRIM$(STR$(demonrecover(x))) + "/" + LTRIM$(STR$(demonrecovertotal))
IF x = 4 THEN LET demonmessage4$(demonmessage(x)) = "you have been healed by " + demonname$(playerturn) + " " + LTRIM$(STR$(demonrecover(x))) + "/" + LTRIM$(STR$(demonrecovertotal))
LET message$ = "You have recovered " + demonname$(x) + " " + LTRIM$(STR$(demonrecover(x))) + "/" + LTRIM$(STR$(demonrecovertotal))
GOSUB displaymessage
LET hud = 1
RETURN

demonrecoverself:
REM demon recovers itself
IF demonrecover(playerturn) < demonrecovertotal - 1 THEN
	LET demonrecover(playerturn) = demonrecover(playerturn) + 1
	LET turnmoves = turnmoves - 1
	LET message$ = "You have recovered " + LTRIM$(STR$(demonrecover(playerturn))) + "/" + LTRIM$(STR$(demonrecovertotal))
	LET eventtitle$ = demonname$(playerturn) + " HAS RECOVERED THEMSELVES: "
	LET eventdata$ = LTRIM$(STR$(demonrecover(playerturn))) + "/" + LTRIM$(STR$(demonrecovertotal))
	LET eventnumber = 0
	GOSUB consoleprinter
ELSE
	LET message$ = "Cannot recover! Find help!"
	LET eventtitle$ = demonname$(playerturn) + " CAN NOT RECOVER: "
	LET eventdata$ = LTRIM$(STR$(demonrecover(playerturn))) + "/" + LTRIM$(STR$(demonrecovertotal))
	LET eventnumber = 0
	GOSUB consoleprinter
END IF
GOSUB displaymessage
RETURN

displaymessage:
REM displays a message in the centre of the screen 
GOSUB settextcolour
REM calculates where on screen message is to be drawn
LET x = (resx / 2) - 4
LET y = (resy / 2) - 4
LET x = x - ((LEN(message$) * 6) / 2)
REM displays message
_PRINTSTRING (x, y), message$
_DISPLAY
_DELAY messagetime
IF playerturn < 5 THEN
	LET eventtitle$ = "MESSAGE DISPLAYED TO " + demonname$(playerturn) + ":"
ELSE
	LET eventtitle$ = "MESSAGE DISPLAYED TO " + heroname$ + ":"
END IF
LET eventdata$ = message$
LET eventnumber = 0
GOSUB consoleprinter
COLOR _RGBA(255, 255, 255, 255), _RGBA(0, 0, 0, 255)
LET x = 0: LET y = 0: LET message$ = ""
LET redrawonly = 1
GOSUB drawmap
GOSUB drawhud
LET redrawonly = 0
COLOR _RGBA(255, 255, 255, 255), _RGBA(0, 0, 0, 255)
RETURN

herotrapright:
REM traps a demon right
LET hooktile = currenttile + 1
IF grabbeddemon = 1 THEN LET maptiletype(hooktile) = 17
IF grabbeddemon = 2 THEN LET maptiletype(hooktile) = 21
IF grabbeddemon = 3 THEN LET maptiletype(hooktile) = 25
IF grabbeddemon = 4 THEN LET maptiletype(hooktile) = 29
LET maptiletype(currenttile) = 13
LET playerlocx(grabbeddemon) = playerlocx(grabbeddemon) + 1
LET herostatus = 1
LET herotrapno = herotrapno + 1
GOSUB demontrapstatus
LET eventtitle$ = heroname$ + " TRAPS " + demonname$(grabbeddemon) + ":"
LET eventdata$ = heroname$ + " now has " + LTRIM$(STR$(herotrapno)) + " traps"
LET eventnumber = 0
GOSUB consoleprinter
LET grabbeddemon = 0
LET hooktile = 0
LET turnmoves = turnmoves - 1
LET hud = 1
RETURN

herotrapleft:
REM traps a demon left
LET hooktile = currenttile - 1
IF grabbeddemon = 1 THEN LET maptiletype(hooktile) = 17
IF grabbeddemon = 2 THEN LET maptiletype(hooktile) = 21
IF grabbeddemon = 3 THEN LET maptiletype(hooktile) = 25
IF grabbeddemon = 4 THEN LET maptiletype(hooktile) = 29
LET maptiletype(currenttile) = 13
LET playerlocx(grabbeddemon) = playerlocx(grabbeddemon) - 1
LET herostatus = 1
LET herotrapno = herotrapno + 1
GOSUB demontrapstatus
LET eventtitle$ = heroname$ + " TRAPS " + demonname$(grabbeddemon) + ":"
LET eventdata$ = heroname$ + " now has " + LTRIM$(STR$(herotrapno)) + " traps"
LET eventnumber = 0
GOSUB consoleprinter
LET grabbeddemon = 0
LET hooktile = 0
LET turnmoves = turnmoves - 1
LET hud = 1
RETURN

herotrapdown:
REM traps a demon downwards
LET hooktile = currenttile + maptilex
IF grabbeddemon = 1 THEN LET maptiletype(hooktile) = 17
IF grabbeddemon = 2 THEN LET maptiletype(hooktile) = 21
IF grabbeddemon = 3 THEN LET maptiletype(hooktile) = 25
IF grabbeddemon = 4 THEN LET maptiletype(hooktile) = 29
LET maptiletype(currenttile) = 13
LET playerlocy(grabbeddemon) = playerlocy(grabbeddemon) + 1
LET herostatus = 1
LET herotrapno = herotrapno + 1
GOSUB demontrapstatus
LET eventtitle$ = heroname$ + " TRAPS " + demonname$(grabbeddemon) + ":"
LET eventdata$ = heroname$ + " now has " + LTRIM$(STR$(herotrapno)) + " traps"
LET eventnumber = 0
GOSUB consoleprinter
LET grabbeddemon = 0
LET hooktile = 0
LET turnmoves = turnmoves - 1
LET hud = 1
RETURN

herotrapup:
REM traps a demon upwards
LET hooktile = currenttile - maptilex
IF grabbeddemon = 1 THEN LET maptiletype(hooktile) = 17
IF grabbeddemon = 2 THEN LET maptiletype(hooktile) = 21
IF grabbeddemon = 3 THEN LET maptiletype(hooktile) = 25
IF grabbeddemon = 4 THEN LET maptiletype(hooktile) = 29
LET maptiletype(currenttile) = 13
LET playerlocy(grabbeddemon) = playerlocy(grabbeddemon) - 1
LET herostatus = 1
LET herotrapno = herotrapno + 1
GOSUB demontrapstatus
LET eventtitle$ = heroname$ + " TRAPS " + demonname$(grabbeddemon) + ":"
LET eventdata$ = heroname$ + " now has " + LTRIM$(STR$(herotrapno)) + " traps"
LET eventnumber = 0
GOSUB consoleprinter
LET grabbeddemon = 0
LET hooktile = 0
LET turnmoves = turnmoves - 1
LET hud = 1
RETURN

demontrapstatus:
REM makes changes to demon health and status
LET demonstruggle(grabbeddemon) = 0
LET demonrecover(grabbeddemon) = 0
IF demonhealth(grabbeddemon) = 3 THEN 
	REM first trap
	LET demonstatus(grabbeddemon) = 5
	LET demonhealth(grabbeddemon) = 2
	LET demontraptime(grabbeddemon) = 0
	LET eventtitle$ = demonname$(grabbeddemon) + " FIRST TRAP: "
	LET eventdata$ = demonname$(grabbeddemon) + " health is now 2"
	LET eventnumber = 0
	GOSUB consoleprinter
	RETURN
END IF
IF demonhealth(grabbeddemon) = 2 THEN
	REM second trap (if applicable)
	LET demonstatus(grabbeddemon) = 6
	LET demonhealth(grabbeddemon) = 1
	LET demontraptime(grabbeddemon) = 0
	LET eventtitle$ = demonname$(grabbeddemon) + " SECOND TRAP: "
	LET eventdata$ = demonname$(grabbeddemon) + " health is now 1"
	LET eventnumber = 0
	GOSUB consoleprinter
	RETURN
END IF
IF demonhealth(grabbeddemon) = 1 THEN
	REM death
	LET demonstatus(grabbeddemon) = 7
	LET demonhealth(grabbeddemon) = 0
	LET demontraptime(grabbeddemon) = 0
	LET maptiletype(hooktile) = 31
	LET heroscore = heroscore + 1
	LET eventtitle$ = demonname$(grabbeddemon) + " FINAL TRAP: "
	LET eventdata$ = demonname$(grabbeddemon) + " is now dead"
	LET eventnumber = 0
	GOSUB consoleprinter
	RETURN
END IF
RETURN

herodropdemon:
REM drops a demon
IF a1 + a2 + a3 + a4 <> 4 THEN
	REM drop on a nearby tile
	LET x = 0
	LET x = INT(RND * 4) + 1
	IF x = 1 THEN IF maptiletype(currenttile - maptilex) <> 1 THEN LET a1 = 1: GOTO herodropdemon
	IF x = 2 THEN IF maptiletype(currenttile + maptilex) <> 1 THEN LET a2 = 1: GOTO herodropdemon
	IF x = 3 THEN IF maptiletype(currenttile - 1) <> 1 THEN LET a3 = 1: GOTO herodropdemon
	IF x = 4 THEN IF maptiletype(currenttile + 1) <> 1 THEN LET a4 = 1: GOTO herodropdemon
	IF x = 1 THEN 
		IF grabbeddemon = 1 THEN LET maptiletype(currenttile - maptilex) = 16
		IF grabbeddemon = 2 THEN LET maptiletype(currenttile - maptilex) = 20
		IF grabbeddemon = 3 THEN LET maptiletype(currenttile - maptilex) = 24
		IF grabbeddemon = 4 THEN LET maptiletype(currenttile - maptilex) = 28
		IF struggledrop = 1 THEN LET maptiletype(currenttile - maptilex) = maptiletype(currenttile - maptilex) - 1
		LET playerlocy(grabbeddemon) = playerlocy(grabbeddemon) - 1
		LET nexttile = currentile - maptilex
	END IF
	IF x = 2 THEN 
		IF grabbeddemon = 1 THEN LET maptiletype(currenttile + maptilex) = 16
		IF grabbeddemon = 2 THEN LET maptiletype(currenttile + maptilex) = 20
		IF grabbeddemon = 3 THEN LET maptiletype(currenttile + maptilex) = 24
		IF grabbeddemon = 4 THEN LET maptiletype(currenttile + maptilex) = 28
		IF struggledrop = 1 THEN LET maptiletype(currenttile + maptilex) = maptiletype(currenttile + maptilex) - 1
		LET playerlocy(grabbeddemon) = playerlocy(grabbeddemon) + 1
		LET nexttile = currenttile + maptilex
	END IF
	IF x = 3 THEN 
		IF grabbeddemon = 1 THEN LET maptiletype(currenttile - 1) = 16
		IF grabbeddemon = 2 THEN LET maptiletype(currenttile - 1) = 20
		IF grabbeddemon = 3 THEN LET maptiletype(currenttile - 1) = 24
		IF grabbeddemon = 4 THEN LET maptiletype(currenttile - 1) = 28
		IF struggledrop = 1 THEN LET maptiletype(currenttile - 1) = maptiletype(currenttile - 1) - 1
		LET playerlocx(grabbeddemon) = playerlocx(grabbeddemon) - 1
		LET nexttile = currenttile - 1
	END IF
	IF x = 4 THEN 
		IF grabbeddemon = 1 THEN LET maptiletype(currenttile + 1) = 16
		IF grabbeddemon = 2 THEN LET maptiletype(currenttile + 1) = 20
		IF grabbeddemon = 3 THEN LET maptiletype(currenttile + 1) = 24
		IF grabbeddemon = 4 THEN LET maptiletype(currenttile + 1) = 28
		IF struggledrop = 1 THEN LET maptiletype(currenttile + 1) = maptiletype(currenttile + 1) - 1
		LET playerlocx(grabbeddemon) = playerlocx(grabbeddemon) + 1
		LET nexttile = currenttile + 1
	END IF
	LET playerloctile(grabbeddemon) = nexttile
ELSE
	REM drop on a random tile somewhere
	LET x = 0
	LEt y = 1
	LET x = INT(RND * (maptilex * maptiley)) + 1
	IF maptiletype(x) <> 1 THEN GOTO herodropdemon
	IF grabbeddemon = 1 THEN LET maptiletype(x) = 16
	IF grabbeddemon = 2 THEN LET maptiletype(x) = 20
	IF grabbeddemon = 3 THEN LET maptiletype(x) = 24
	IF grabbeddemon = 4 THEN LET maptiletype(x) = 28
	IF struggledrop = 1 THEN LET maptiletype(x) = maptiletype(x) - 1
	LET playerloctile(grabbeddemon) = x
	DO
		LET x = x - maptilex
		LET y = y + 1
	LOOP UNTIL x < maptilex
	LET playerlocx(grabbeddemon) = x
	LET playerlocy(grabbeddemon) = y
END IF
LET maptiletype(currenttile) = 13
LET eventtitle$ = heroname$ + " DROPS " + demonname$(grabbeddemon) + ":"
IF struggledrop = 0 THEN 
	LET eventdata$ = demonname$(grabbeddemon) + " is now down"
ELSE
	LET eventdata$ = demonname$(grabbeddemon) + " is now hurt"
END IF
LET eventnumber = 0
GOSUB consoleprinter
IF struggledrop = 0 THEN 
	LET demonstatus(grabbeddemon) = 3
ELSE
	LET demonstatus(grabbeddemon) = 2
	LET locx = playerlocx(grabbeddemon)
	LET locy = playerlocy(grabbeddemon)
	LET currenttile = nexttile
	LET demonstruggle(grabbeddemon) = 0
	LET demonrecover(grabbeddemon) = 0
END IF
LET herostatus = 1
LET grabbeddemon = 0
LET a1 = 0: LET a2 = 0: LET a3 = 0: LET a4 = 0: LET y = 0
RETURN

herograbup:
REM grabs a demon above hero
IF demonstatus(herograbup) = 3 THEN 
	LET demonstatus(herograbup) = 4
	LET herostatus = 2
	IF herograbup = 1 THEN LET maptiletype(currenttile - maptilex) = 1
	IF herograbup = 2 THEN LET maptiletype(currenttile - maptilex) = 1
	IF herograbup = 3 THEN LET maptiletype(currenttile - maptilex) = 1
	IF herograbup = 4 THEN LET maptiletype(currenttile - maptilex) = 1
	LET maptiletype(currenttile) = 30
	LET playerlocy(herograbup) = playerlocy(herograbup) + 1
	LET grabbeddemon = herograbup
	LET turnmoves = turnmoves - 1
	LET hud = 1
	LET eventtitle$ = heroname$ + " GRABS " + demonname$(herograbup) + ":"
	LET eventdata$ = demonname$(herograbup) + " is now grabbed"
	LET eventnumber = 0
	GOSUB consoleprinter
END IF
RETURN

herograbdown:
REM grabs a demon below hero
IF demonstatus(herograbdown) = 3 THEN 
	LET demonstatus(herograbdown) = 4
	LET herostatus = 2
	IF herograbdown = 1 THEN LET maptiletype(currenttile + maptilex) = 1
	IF herograbdown = 2 THEN LET maptiletype(currenttile + maptilex) = 1
	IF herograbdown = 3 THEN LET maptiletype(currenttile + maptilex) = 1
	IF herograbdown = 4 THEN LET maptiletype(currenttile + maptilex) = 1
	LET maptiletype(currenttile) = 30
	LET playerlocy(herograbdown) = playerlocy(herograbdown) - 1
	LET grabbeddemon = herograbdown
	LET turnmoves = turnmoves - 1
	LET hud = 1
	LET eventtitle$ = heroname$ + " GRABS " + demonname$(herograbdown) + ":"
	LET eventdata$ = demonname$(herograbdown) + " is now grabbed"
	LET eventnumber = 0
	GOSUB consoleprinter
END IF
RETURN

herogrableft:
REM grabs a demon to left of hero
IF demonstatus(herogrableft) = 3 THEN 
	LET demonstatus(herogrableft) = 4
	LET herostatus = 2
	IF herogrableft = 1 THEN LET maptiletype(currenttile - 1) = 1
	IF herogrableft = 2 THEN LET maptiletype(currenttile - 1) = 1
	IF herogrableft = 3 THEN LET maptiletype(currenttile - 1) = 1
	IF herogrableft = 4 THEN LET maptiletype(currenttile - 1) = 1
	LET maptiletype(currenttile) = 30
	LET playerlocx(herogrableft) = playerlocx(herogrableft) + 1
	LET grabbeddemon = herogrableft
	LET turnmoves = turnmoves - 1
	LET hud = 1
	LET eventtitle$ = heroname$ + " GRABS " + demonname$(herogrableft) + ":"
	LET eventdata$ = demonname$(herogrableft) + " is now grabbed"
	LET eventnumber = 0
	GOSUB consoleprinter
END IF
RETURN

herograbright:
REM grabs a demon to right of hero
IF demonstatus(herograbright) = 3 THEN 
	LET demonstatus(herograbright) = 4
	LET herostatus = 2
	IF herograbright = 1 THEN LET maptiletype(currenttile + 1) = 1
	IF herograbright = 2 THEN LET maptiletype(currenttile + 1) = 1
	IF herograbright = 3 THEN LET maptiletype(currenttile + 1) = 1
	IF herograbright = 4 THEN LET maptiletype(currenttile + 1) = 1
	LET maptiletype(currenttile) = 30
	LET playerlocx(herograbright) = playerlocx(herograbright) - 1
	LET grabbeddemon = herograbright
	LET turnmoves = turnmoves - 1
	LET hud = 1
	LET eventtitle$ = heroname$ + " GRABS " + demonname$(herograbright) + ":"
	LET eventdata$ = demonname$(herograbright) + " is now grabbed"
	LET eventnumber = 0
	GOSUB consoleprinter
END IF
RETURN

herohitup:
REM hits a demon above hero
IF demonstatus(herohitup) = 1 THEN 
	LET demonstatus(herohitup) = 2
	IF herohitup = 1 THEN LET maptiletype(currenttile - maptilex) = 15
	IF herohitup = 2 THEN LET maptiletype(currenttile - maptilex) = 19
	IF herohitup = 3 THEN LET maptiletype(currenttile - maptilex) = 23
	IF herohitup = 4 THEN LET maptiletype(currenttile - maptilex) = 27
	IF turnmoves = heromovetotal THEN 
		LET turnmoves = 2
	ELSE
		LET turnmoves = 0
	END IF
	LET hud = 1
	LET demonrecover(herohitup) = 0
	LET eventtitle$ = heroname$ + " HITS " + demonname$(herohitup) + ":"
	LET eventdata$ = demonname$(herohitup) + " is now hurt"
	LET eventnumber = 0
	GOSUB consoleprinter
	RETURN
END IF
IF demonstatus(herohitup) = 2 THEN 
	LET demonstatus(herohitup) = 3
	IF herohitup = 1 THEN LET maptiletype(currenttile - maptilex) = 16
	IF herohitup = 2 THEN LET maptiletype(currenttile - maptilex) = 20
	IF herohitup = 3 THEN LET maptiletype(currenttile - maptilex) = 24
	IF herohitup = 4 THEN LET maptiletype(currenttile - maptilex) = 28
	IF turnmoves = heromovetotal THEN 
		LET turnmoves = 2
	ELSE
		LET turnmoves = 0
	END IF
	LET hud = 1
	LET demonrecover(herohitup) = 0
	LET eventtitle$ = heroname$ + " HITS " + demonname$(herohitup) + ":"
	LET eventdata$ = demonname$(herohitup) + " is now down"
	LET eventnumber = 0
	GOSUB consoleprinter
	RETURN
END IF
RETURN

herohitdown:
REM hits a demon below hero
IF demonstatus(herohitdown) = 1 THEN 
	LET demonstatus(herohitdown) = 2
	IF herohitdown = 1 THEN LET maptiletype(currenttile + maptilex) = 15
	IF herohitdown = 2 THEN LET maptiletype(currenttile + maptilex) = 19
	IF herohitdown = 3 THEN LET maptiletype(currenttile + maptilex) = 23
	IF herohitdown = 4 THEN LET maptiletype(currenttile + maptilex) = 27
	IF turnmoves = heromovetotal THEN 
		LET turnmoves = 2
	ELSE
		LET turnmoves = 0
	END IF
	LET hud = 1
	LET demonrecover(herohitdown) = 0
	LET eventtitle$ = heroname$ + " HITS " + demonname$(herohitdown) + ":"
	LET eventdata$ = demonname$(herohitdown) + " is now hurt"
	LET eventnumber = 0
	GOSUB consoleprinter
	RETURN
END IF
IF demonstatus(herohitdown) = 2 THEN 
	LET demonstatus(herohitdown) = 3
	IF herohitdown = 1 THEN LET maptiletype(currenttile + maptilex) = 16
	IF herohitdown = 2 THEN LET maptiletype(currenttile + maptilex) = 20
	IF herohitdown = 3 THEN LET maptiletype(currenttile + maptilex) = 24
	IF herohitdown = 4 THEN LET maptiletype(currenttile + maptilex) = 28
	IF turnmoves = heromovetotal THEN 
		LET turnmoves = 2
	ELSE
		LET turnmoves = 0
	END IF
	LET hud = 1
	LET demonrecover(herohitdown) = 0
	LET eventtitle$ = heroname$ + " HITS " + demonname$(herohitdown) + ":"
	LET eventdata$ = demonname$(herohitdown) + " is now down"
	LET eventnumber = 0
	GOSUB consoleprinter
	RETURN
END IF
RETURN

herohitleft:
REM hits a demon left of hero
IF demonstatus(herohitleft) = 1 THEN 
	LET demonstatus(herohitleft) = 2
	IF herohitleft = 1 THEN LET maptiletype(currenttile - 1) = 15
	IF herohitleft = 2 THEN LET maptiletype(currenttile - 1) = 19
	IF herohitleft = 3 THEN LET maptiletype(currenttile - 1) = 23
	IF herohitleft = 4 THEN LET maptiletype(currenttile - 1) = 27
	IF turnmoves = heromovetotal THEN 
		LET turnmoves = 2
	ELSE
		LET turnmoves = 0
	END IF
	LET hud = 1
	LET demonrecover(herohitleft) = 0
	LET eventtitle$ = heroname$ + " HITS " + demonname$(herohitleft) + ":"
	LET eventdata$ = demonname$(herohitleft) + " is now hurt"
	LET eventnumber = 0
	GOSUB consoleprinter
	RETURN
END IF
IF demonstatus(herohitleft) = 2 THEN 
	LET demonstatus(herohitleft) = 3
	IF herohitleft = 1 THEN LET maptiletype(currenttile - 1) = 16
	IF herohitleft = 2 THEN LET maptiletype(currenttile - 1) = 20
	IF herohitleft = 3 THEN LET maptiletype(currenttile - 1) = 24
	IF herohitleft = 4 THEN LET maptiletype(currenttile - 1) = 28
	IF turnmoves = 3 THEN 
		LET turnmoves = 1
	ELSE
		LET turnmoves = 0
	END IF
	LET hud = 1
	LET demonrecover(herohitleft) = 0
	LET eventtitle$ = heroname$ + " HITS " + demonname$(herohitleft) + ":"
	LET eventdata$ = demonname$(herohitleft) + " is now down"
	LET eventnumber = 0
	GOSUB consoleprinter
	RETURN
END IF
RETURN

herohitright:
REM hits a demon right of hero
IF demonstatus(herohitright) = 1 THEN 
	LET demonstatus(herohitright) = 2
	IF herohitright = 1 THEN LET maptiletype(currenttile + 1) = 15
	IF herohitright = 2 THEN LET maptiletype(currenttile + 1) = 19
	IF herohitright = 3 THEN LET maptiletype(currenttile + 1) = 23
	IF herohitright = 4 THEN LET maptiletype(currenttile + 1) = 27
	IF turnmoves = heromovetotal THEN 
		LET turnmoves = 2
	ELSE
		LET turnmoves = 0
	END IF
	LET hud = 1
	LET demonrecover(herohitright) = 0
	LET eventtitle$ = heroname$ + " HITS " + demonname$(herohitright) + ":"
	LET eventdata$ = demonname$(herohitright) + " is now hurt"
	LET eventnumber = 0
	GOSUB consoleprinter
	RETURN
END IF
IF demonstatus(herohitright) = 2 THEN 
	LET demonstatus(herohitright) = 3
	IF herohitright = 1 THEN LET maptiletype(currenttile + 1) = 16
	IF herohitright = 2 THEN LET maptiletype(currenttile + 1) = 20
	IF herohitright = 3 THEN LET maptiletype(currenttile + 1) = 24
	IF herohitright = 4 THEN LET maptiletype(currenttile + 1) = 28
	IF turnmoves = 3 THEN 
		LET turnmoves = 1
	ELSE
		LET turnmoves = 0
	END IF
	LET hud = 1
	LET demonrecover(herohitright) = 0
	LET eventtitle$ = heroname$ + " HITS " + demonname$(herohitright) + ":"
	LET eventdata$ = demonname$(herohitright) + " is now down"
	LET eventnumber = 0
	GOSUB consoleprinter
	RETURN
END IF
RETURN

moveplayersprite:
REM moves player sprite after calculations
LET maptiletype(currenttile) = 1
IF playerturn = 5 THEN 
	IF herostatus = 1 THEN LET maptiletype(newtile) = 13
	IF herostatus = 2 THEN LET maptiletype(newtile) = 30
END IF
IF playerturn = 1 THEN
	IF demonstatus(playerturn) = 1 THEN LET maptiletype(newtile) = 14
	IF demonstatus(playerturn) = 2 THEN LET maptiletype(newtile) = 15
	IF demonstatus(playerturn) = 3 THEN LET maptiletype(newtile) = 16
END IF
IF playerturn = 2 THEN
	IF demonstatus(playerturn) = 1 THEN LET maptiletype(newtile) = 18
	IF demonstatus(playerturn) = 2 THEN LET maptiletype(newtile) = 19
	IF demonstatus(playerturn) = 3 THEN LET maptiletype(newtile) = 20
END IF
IF playerturn = 3 THEN
	IF demonstatus(playerturn) = 1 THEN LET maptiletype(newtile) = 22
	IF demonstatus(playerturn) = 2 THEN LET maptiletype(newtile) = 23
	IF demonstatus(playerturn) = 3 THEN LET maptiletype(newtile) = 24
END IF
IF playerturn = 4 THEN
	IF demonstatus(playerturn) = 1 THEN LET maptiletype(newtile) = 26
	IF demonstatus(playerturn) = 2 THEN LET maptiletype(newtile) = 27
	IF demonstatus(playerturn) = 3 THEN LET maptiletype(newtile) = 28
END IF
'LET newtile = 0
RETURN

moveplayerup:
REM moves a player up
LET locy = locy - 1
LET playerlocy(playerturn) = playerlocy(playerturn) - 1
LET newtile = currenttile - maptilex
GOSUB moveplayersprite
LET currenttile = newtile
IF playerturn = 5 AND herostatus = 2 THEN LET playerlocy(grabbeddemon) = playerlocy(playerturn): LET playerloctile(grabbeddemon) = newtile
REM tells console 
IF playerturn = 5 THEN 
	LET eventtitle$ = heroname$ + " MOVE:"
ELSE
	LET eventtitle$ = demonname$(playerturn) + " MOVE:"
END IF
LET eventdata$ = LTRIM$(STR$(playerlocx(playerturn))) + "," + LTRIM$(STR$(playerlocy(playerturn)))
LET eventnumber = 0
GOSUB consoleprinter
RETURN

moveplayerdown:
REM moves a player down
LET locy = locy + 1
LET playerlocy(playerturn) = playerlocy(playerturn) + 1
LET newtile = currenttile + maptilex
GOSUB moveplayersprite
LET currenttile = newtile
IF playerturn = 5 AND herostatus = 2 THEN LET playerlocy(grabbeddemon) = playerlocy(playerturn): LET playerloctile(grabbeddemon) = newtile
REM tells console 
IF playerturn = 5 THEN 
	LET eventtitle$ = heroname$ + " MOVE:"
ELSE
	LET eventtitle$ = demonname$(playerturn) + " MOVE:"
END IF
LET eventdata$ = LTRIM$(STR$(playerlocx(playerturn))) + "," + LTRIM$(STR$(playerlocy(playerturn)))
LET eventnumber = 0
GOSUB consoleprinter
RETURN

moveplayerright:
REM moves a player left
LET locx = locx + 1
LET playerlocx(playerturn) = playerlocx(playerturn) + 1
LET newtile = currenttile + 1
GOSUB moveplayersprite
LET currenttile = newtile
IF playerturn = 5 AND herostatus = 2 THEN LET playerlocx(grabbeddemon) = playerlocx(playerturn): LET playerloctile(grabbeddemon) = newtile
REM tells console 
IF playerturn = 5 THEN 
	LET eventtitle$ = heroname$ + " MOVE:"
ELSE
	LET eventtitle$ = demonname$(playerturn) + " MOVE:"
END IF
LET eventdata$ = LTRIM$(STR$(playerlocx(playerturn))) + "," + LTRIM$(STR$(playerlocy(playerturn)))
LET eventnumber = 0
GOSUB consoleprinter
RETURN

moveplayerleft:
REM moves a player right
LET locx = locx - 1
LET playerlocx(playerturn) = playerlocx(playerturn) - 1
LET newtile = currenttile - 1
GOSUB moveplayersprite
LET currenttile = newtile
IF playerturn = 5 AND herostatus = 2 THEN LET playerlocx(grabbeddemon) = playerlocx(playerturn): LET playerloctile(grabbeddemon) = newtile
REM tells console 
IF playerturn = 5 THEN 
	LET eventtitle$ = heroname$ + " MOVE:"
ELSE
	LET eventtitle$ = demonname$(playerturn) + " MOVE:"
END IF
LET eventdata$ = LTRIM$(STR$(playerlocx(playerturn))) + "," + LTRIM$(STR$(playerlocy(playerturn)))
LET eventnumber = 0
GOSUB consoleprinter
RETURN

drawmap:
REM draws the map
CLS
LET x = 0
LET carragereturn = 0
LET tilerow = 0
LET drawpass1 = 0
LET drawpass2 = 0
LET camerax = -(locx)
LET camerax = (camerax * tileresx) - (tileresx / 2)
LET cameray = -(locy)
LET cameray = (cameray * tileresy) - (tileresy / 2)
DO
	LET x = x + 1
	LET tilerow = tilerow + 1
	LET tilelocx = (camerax + (tileresx * (tilerow - 1))) + ((resx / 2) + (tileresx / 2))
	LET tilelocy = (cameray + (tileresy * carragereturn)) + ((resy / 2) + (tileresy / 2))
	IF tilelocx > 0 - tileresx AND tilelocx < resx THEN LET drawpass1 = 1
	IF tilelocy > 0 - tileresy AND tilelocy < resy THEN LET drawpass2 = 1
	IF drawpass1 = 1 AND drawpass2 = 1 THEN
		REM draws map tiles
		IF maptiletype(x) = 1 THEN _PUTIMAGE (tilelocx, tilelocy), emptytile
		IF maptiletype(x) = 2 THEN _PUTIMAGE (tilelocx, tilelocy), beconuncorrupttile
		IF maptiletype(x) = 3 THEN _PUTIMAGE (tilelocx, tilelocy), beconcorrupttile
		IF maptiletype(x) = 4 THEN _PUTIMAGE (tilelocx, tilelocy), traptile
		IF maptiletype(x) = 5 THEN _PUTIMAGE (tilelocx, tilelocy), wallhorizontaltile
		IF maptiletype(x) = 6 THEN _PUTIMAGE (tilelocx, tilelocy), wallverticaltile
		IF maptiletype(x) = 7 THEN _PUTIMAGE (tilelocx, tilelocy), walltoplefttile
		IF maptiletype(x) = 8 THEN _PUTIMAGE (tilelocx, tilelocy), walltoprighttile
		IF maptiletype(x) = 9 THEN _PUTIMAGE (tilelocx, tilelocy), wallbottomlefttile
		IF maptiletype(x) = 10 THEN _PUTIMAGE (tilelocx, tilelocy), wallbottomrighttile
		IF maptiletype(x) = 11 THEN _PUTIMAGE (tilelocx, tilelocy), exitclosedtile
		IF maptiletype(x) = 12 THEN _PUTIMAGE (tilelocx, tilelocy), exitopentile
		IF maptiletype(x) = 13 THEN _PUTIMAGE (tilelocx, tilelocy), herotile
		IF maptiletype(x) = 14 THEN _PUTIMAGE (tilelocx, tilelocy), demon1healthytile
		IF maptiletype(x) = 15 THEN _PUTIMAGE (tilelocx, tilelocy), demon1hurttile
		IF maptiletype(x) = 16 THEN _PUTIMAGE (tilelocx, tilelocy), demon1downtile
		IF maptiletype(x) = 17 THEN _PUTIMAGE (tilelocx, tilelocy), demon1trappedtile
		IF maptiletype(x) = 18 THEN _PUTIMAGE (tilelocx, tilelocy), demon2healthytile
		IF maptiletype(x) = 19 THEN _PUTIMAGE (tilelocx, tilelocy), demon2hurttile
		IF maptiletype(x) = 20 THEN _PUTIMAGE (tilelocx, tilelocy), demon2downtile
		IF maptiletype(x) = 21 THEN _PUTIMAGE (tilelocx, tilelocy), demon2trappedtile
		IF maptiletype(x) = 22 THEN _PUTIMAGE (tilelocx, tilelocy), demon3healthytile
		IF maptiletype(x) = 23 THEN _PUTIMAGE (tilelocx, tilelocy), demon3hurttile
		IF maptiletype(x) = 24 THEN _PUTIMAGE (tilelocx, tilelocy), demon3downtile
		IF maptiletype(x) = 25 THEN _PUTIMAGE (tilelocx, tilelocy), demon3trappedtile
		IF maptiletype(x) = 26 THEN _PUTIMAGE (tilelocx, tilelocy), demon4healthytile
		IF maptiletype(x) = 27 THEN _PUTIMAGE (tilelocx, tilelocy), demon4hurttile
		IF maptiletype(x) = 28 THEN _PUTIMAGE (tilelocx, tilelocy), demon4downtile
		IF maptiletype(x) = 29 THEN _PUTIMAGE (tilelocx, tilelocy), demon4trappedtile
		IF maptiletype(x) = 30 THEN _PUTIMAGE (tilelocx, tilelocy), herocarrytile
		IF maptiletype(x) = 31 THEN _PUTIMAGE (tilelocx, tilelocy), deathtile
		IF maptiletype(x) = 32 THEN _PUTIMAGE (tilelocx, tilelocy), exitavailabletile
		IF x = currenttile THEN _PUTIMAGE (tilelocx, tilelocy), highlighttile
	END IF
	IF tilerow => maptilex THEN
		REM move to next row of tiles
		LET carragereturn = carragereturn + 1
		LET tilerow = 0
	END IF
LOOP UNTIL x => (maptilex * maptiley)
RETURN

generatemap:
REM generates a new map
LET eventtitle$ = "GENERATING MAP:"
LET eventdata$ = LTRIM$(STR$(maptilex)) + "x" + LTRIM$(STR$(maptiley))
LET eventnumber = (maptilex * maptiley)
GOSUB consoleprinter
REM generate landscape
LET x = 0
DO
	LET x = x + 1
	LET maptiletype(x) = 1
LOOP UNTIL x => (maptilex * maptiley)
REM add walls
LET x = 0
LET xx = 1
DO
	LET x = x + 1
	IF x > (maptilex * xx) THEN LET xx = xx + 1
	IF x =< maptilex THEN LET maptiletype(x) = 5: REM top wall
	IF x > ((maptilex * maptiley) - maptilex) THEN LET maptiletype(x) = 5: REM bottom wall
	IF x / (maptilex * xx) = 1 THEN LET maptiletype(x) = 6: REM right wall
	IF x = (maptilex * (xx - 1)) + 1 THEN LET maptiletype(x) = 6: REM left wall
LOOP UNTIL x => (maptilex * maptiley)
REM add corner walls
LET maptiletype(1) = 7
LET maptiletype(maptilex) = 8
LET maptiletype((maptilex * maptiley) - (maptilex - 1)) = 9
LET maptiletype(maptilex * maptiley) = 10
REM add exits
LET x = 0
DO
	LET x = x + 1
	LET xx = INT(RND * (maptilex * maptiley)) + 1
	IF maptiletype(xx) = 5 OR maptiletype(xx) = 6 THEN
		LET maptiletype(xx) = 11
		LET exittile(x) = xx
		LET eventtitle$ = "EXIT LOCATION SET:"
		LET eventdata$ = ""
		LET eventnumber = exittile(x)
		GOSUB consoleprinter
	ELSE
		LET x = x - 1
	END IF
LOOP UNTIL x >= exitno
REM add becons
LET x = 0
DO
	LET x = x + 1
	LET xx = INT(RND * (maptilex * maptiley)) + 1
	IF maptiletype(xx) = 1 THEN
		LET maptiletype(xx) = 2
		LET becontile(x) = xx
		LET eventtitle$ = "BECON LOCATION SET:"
		LET eventdata$ = ""
		LET eventnumber = becontile(x)
		GOSUB consoleprinter
	ELSE
		LET x = x - 1
	END IF
LOOP UNTIL x => beconno
REM add traps
LET x = 0
DO
	LET x = x + 1
	LET xx = INT(RND * (maptilex * maptiley)) + 1
	IF maptiletype(xx) = 1 THEN
		LET maptiletype(xx) = 4
	ELSE
		LET x = x - 1
	END IF
LOOP UNTIL x => trapno
RETURN

assetload:
REM loads graphical assets
LET emptytile = _LOADIMAGE(dloc$ + "empty-tile.png")
LET beconcorrupttile = _LOADIMAGE(dloc$ + "becon-corrupt-tile.png")
LET beconuncorrupttile = _LOADIMAGE(dloc$ + "becon-uncorrupt-tile.png")
LET wallhorizontaltile = _LOADIMAGE(dloc$ + "wall-horizontal-tile.png")
LET wallverticaltile = _LOADIMAGE(dloc$ + "wall-vertical-tile.png")
LET walltoplefttile = _LOADIMAGE(dloc$ + "wall-top-left-tile.png")
LET walltoprighttile = _LOADIMAGE(dloc$ + "wall-top-right-tile.png")
LET wallbottomlefttile = _LOADIMAGE(dloc$ + "wall-bottom-left-tile.png")
LET wallbottomrighttile = _LOADIMAGE(dloc$ + "wall-bottom-right-tile.png")
LET exitclosedtile = _LOADIMAGE(dloc$ + "exit-closed-tile.png")
LET exitopentile = _LOADIMAGE(dloc$ + "exit-open-tile.png")
LET exitavailabletile = _LOADIMAGE(dloc$ + "exit-available-tile.png")
LET traptile = _LOADIMAGE(dloc$ + "trap-tile.png")
LET herotile = _LOADIMAGE(dloc$ + "hero-tile.png")
LET demon1healthytile = _LOADIMAGE(dloc$ + "demon1-healthy-tile.png")
LET demon1hurttile = _LOADIMAGE(dloc$ + "demon1-hurt-tile.png")
LET demon1downtile = _LOADIMAGE(dloc$ + "demon1-down-tile.png")
LET demon1trappedtile = _LOADIMAGE(dloc$ + "demon1-trapped-tile.png")
LET demon2healthytile = _LOADIMAGE(dloc$ + "demon2-healthy-tile.png")
LET demon2hurttile = _LOADIMAGE(dloc$ + "demon2-hurt-tile.png")
LET demon2downtile = _LOADIMAGE(dloc$ + "demon2-down-tile.png")
LET demon2trappedtile = _LOADIMAGE(dloc$ + "demon2-trapped-tile.png")
LET demon3healthytile = _LOADIMAGE(dloc$ + "demon3-healthy-tile.png")
LET demon3hurttile = _LOADIMAGE(dloc$ + "demon3-hurt-tile.png")
LET demon3downtile = _LOADIMAGE(dloc$ + "demon3-down-tile.png")
LET demon3trappedtile = _LOADIMAGE(dloc$ + "demon3-trapped-tile.png")
LET demon4healthytile = _LOADIMAGE(dloc$ + "demon4-healthy-tile.png")
LET demon4hurttile = _LOADIMAGE(dloc$ + "demon4-hurt-tile.png")
LET demon4downtile = _LOADIMAGE(dloc$ + "demon4-down-tile.png")
LET demon4trappedtile = _LOADIMAGE(dloc$ + "demon4-trapped-tile.png")
LET herocarrytile = _LOADIMAGE(dloc$ + "hero-carry-tile.png")
LET deathtile = _LOADIMAGE(dloc$ + "death-tile.png")
LET highlighttile = _LOADIMAGE(dloc$ + "highlight-tile.png")
LET eventtitle$ = "GRAPHICAL ASSETS LOADED"
LET eventdata$ = ""
LET eventnumber = 0
GOSUB consoleprinter
RETURN

mainmenu:
REM main menu
CLS
PRINT "Alive By Moonlight!"
PRINT "press a key"
DO: LOOP WHILE INKEY$ = ""
CLS
RETURN

screenmode:
REM sets screen mode
IF setupboot = 1 THEN
	_TITLE title$
	SCREEN _NEWIMAGE(resx, resy, 32)
END IF
$RESIZE:STRETCH
IF screenmode = 2 THEN _FULLSCREEN _OFF
IF screenmode = 1 THEN _FULLSCREEN _SQUAREPIXELS
LET eventtitle$ = "SCREEN MODE SET:"
IF screenmode = 2 THEN LET eventdata$ = "windowed"
IF screenmode = 1 THEN LET eventdata$ = "fullscreen"
LET eventnumber = screenmode
GOSUB consoleprinter
RETURN

errorhandler:
REM displays error to console
LET eventtitle$ = "ERROR:"
LET eventdata$ = _ERRORMESSAGE$
LET eventnumber = _ERRORLINE
GOSUB consoleprinter
RESUME NEXT

consoleprinter:
REM displays in console
_DEST _CONSOLE
IF eventnumber <> 0 THEN PRINT DATE$, TIME$, eventtitle$, eventdata$; eventnumber
IF eventnumber = 0 THEN PRINT DATE$, TIME$, eventtitle$, eventdata$
_DEST 0
LET eventtitle$ = ""
LET eventdata$ = ""
LET eventnumber = 0
RETURN




