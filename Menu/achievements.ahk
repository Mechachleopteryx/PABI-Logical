﻿

;Find all level sets and find out which levels are inside the level sets
loadLevelSets()
{
	_levels.levelsets:=criticalObject()
	loop, %a_scriptdir%\levels\*.ini
	{
		StringTrimRight,filename,A_LoopFileName,4
		GUIMainMenuLevelSet.="|" filename
		_levels.levelsets[filename]:=criticalObject()
		_levels.levelsets[filename].id:=filename
		_levels.levelsets[filename].levels:=criticalObject()
		_levels.levelsets[filename].levelsSorted:=criticalObject()
		IniRead, OutputVarSectionNames,%a_scriptdir%\levels\%filename%.ini
		loop,parse,OutputVarSectionNames,`n
		{
			_levels.levelsets[filename].levels[a_loopfield]:=criticalObject()
			_levels.levelsets[filename].levels[a_loopfield].id:=a_loopfield
			_levels.levelsets[filename].levels[a_loopfield].won:=false ;will be set later
			_levels.levelsets[filename].levels[a_loopfield].index:=a_index
			_levels.levelsets[filename].levelsSorted[a_index]:=_levels.levelsets[filename].levels[a_loopfield]
		}
		_levels.levelsets[filename].lastUnlockedLevelIndex:=1 ;will be set later if user has alredy solved some levels
		_levels.levelsets[filename].lastUnlockedLevelID:=_levels.levelsets[filename].levelsSorted[1].id ;will be set later if user has alredy solved some levels
	}
	loadAchievements()
}

;Load the achievements file, which records which level is unlocked
loadAchievements()
{
	iniread, levelsets, %a_appdata%\PABI Logical\achievements.ini
	
	loop,parse,levelsets,`n ;each ini section contains information about one levelset
	{
		oneLevelSet:=a_loopfield
		
		if (_levels.levelsets.haskey(oneLevelSet)) ;catch if the levelset does not exist
		{
			iniread, lastWonLevel, %a_appdata%\PABI Logical\achievements.ini,%oneLevelSet%,lastWonLevel
			if (_levels.levelsets[oneLevelSet].levels.haskey(lastWonLevel))  ;catch if the level does not exist in the levelset
			{
				for onelevelindex, onelevel in _levels.levelsets[oneLevelSet].levelsSorted
				{
					onelevel.won:=true
					
					;Find out which level is the last unlocked
					if (_levels.levelsets[oneLevelSet].levelsSorted.haskey(onelevelindex+1))
					{
						_levels.levelsets[oneLevelSet].lastUnlockedLevelIndex:=onelevelindex+1
						_levels.levelsets[oneLevelSet].lastUnlockedLevelID:=_levels.levelsets[oneLevelSet].levelsSorted[onelevelindex+1].id
					}
					
					if (onelevel.id = lastWonLevel)
						break
				}
			}
		}
	}
}

;Save the achievements after a win
saveAchievement()
{
	if (_levels.levelsets.haskey(_field.levelset))
	{
		if (_levels.levelsets[_field.levelset].levels.haskey(_field.levelid))
		{
			if (_levels.levelsets[_field.levelset].levels[_field.levelid].won !=true) ;only if user wins that level the first time
			{
				iniwrite,% _field.levelid,%a_appdata%\PABI Logical\achievements.ini,% _field.levelset,lastWonLevel
				_levels.levelsets[_field.levelset].levels[_field.levelid].won :=true
				
				;Find out which level is the last unlocked
				if (_levels.levelsets[_field.levelset].levelsSorted.haskey(_levels.levelsets[_field.levelset].levels[_field.levelid].index + 1))
				{
					_levels.levelsets[_field.levelset].lastUnlockedLevelIndex:=_levels.levelsets[_field.levelset].levels[_field.levelid].index+1
					_levels.levelsets[_field.levelset].lastUnlockedLevelID:=_levels.levelsets[_field.levelset].levelsSorted[_levels.levelsets[_field.levelset].levels[_field.levelid].index+1].id
				}
			}
		}
		else
		{
			MsgBox unexpected error in %a_thisfunc% - %A_LineNumber%
		}
	}
	else
	{
		MsgBox unexpected error in %a_thisfunc% - %A_LineNumber%
	}
	
}
