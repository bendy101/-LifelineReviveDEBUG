 diag_log "                                                                                                "; 
 diag_log "                                                                                                "; 
 diag_log "                                                                                                "; 
diag_log "                                                                                                '"; 
diag_log "                                                                                                '"; 
diag_log "============================================================================================================='"; 
diag_log "============================================================================================================='"; 
diag_log "========================================== Lifeline_Global.sqf ================================================='"; 
diag_log "============================================================================================================='"; 
diag_log "============================================================================================================='"; 



// function to check revive pair and cancel the medic if needed
Lifeline_exit_travel = {
	params ["_incap","_medic","_diagtext","_linenumber"];

	// diag_log format ["%1 | %2 \%4\ [%3}============== FNC CHECK EXIT ==========", name _incap, name _medic, _linenumber,time];
	
	_pairtimeoutbaby = (_incap getVariable ["LifelinePairTimeOut",0]);
	_incapTL = (_incap getVariable ["LifelineBleedOutTime",0]);
	_distcalc = _medic distance2D _incap;
	_AssignedMedic = (_incap getVariable ["Lifeline_AssignedMedic",[]]); 
	_exit = false;

	_ifACEdragged = false;
	if (Lifeline_RevMethod == 3) then {
		// if ([_incap] call ace_medical_status_fnc_isBeingDragged || [_incap] call ace_medical_status_fnc_isBeingCarried) then {
		if ([_incap] call Lifeline_check_carried_dragged) then {
		_ifACEdragged = true;
		};
	};

	if ((_pairtimeoutbaby > 0 && time > _pairtimeoutbaby && (Lifeline_RevMethod == 2 && time < _incapTL || Lifeline_RevMethod == 3)) 
		|| _pairtimeoutbaby == 0 || _ifACEdragged == true || (lifestate _incap != "INCAPACITATED") || (lifestate _medic == "INCAPACITATED") 
		|| !(alive _medic) || (currentWeapon _medic == secondaryWeapon _medic && currentWeapon _medic != "") 
		|| (((assignedTarget _medic) isKindOf "Tank") && secondaryWeapon _medic != "") //check unit did not get order to hunt tank
		|| (((getAttackTarget _medic) isKindOf "Tank") && secondaryWeapon _medic != "")
		|| (!(_medic in _AssignedMedic) && count _AssignedMedic > 0 )
		|| _AssignedMedic isEqualTo []
		|| _medic getVariable ["Lifeline_ExitTravel", false] == true
		|| (_pairtimeoutbaby - time) < 0 //might not need
		) then {
			_exit = true;
			_medic setVariable ["Lifeline_ExitTravel", true, true];
			//DEBUG
			//just for debugging:
			if (Lifeline_Revive_debug && !isNil "_linenumber" && !isNil "_diagtext") then { 
				diag_log format ["%1 | %2 TRUETRUETRUE[%3]!!!!!!!!! change var Lifeline_ExitTravel = true !!!!!!!!!!!!!", name _incap, name _medic, _linenumber];
				_multimedic = ""; _pairtimezero = ""; _incapnotincap = ""; _paitimeunderzero = "";_pairtimeremain = "";
				if (!(_medic in _AssignedMedic) && count _AssignedMedic > 0 ) then {
					_multimedic = "MULTIPLE MEDIC";
					if (Lifeline_debug_soundalert) then {["multiplemedics"] remoteExec ["playSound",2]};
					};
				if (lifestate _incap != "INCAPACITATED") then {_incapnotincap = "INCAP NOT INCAPPED"};if ((_pairtimeoutbaby - time) > 0 || (_pairtimeoutbaby - time) < 0) then {_pairtimeremain = format ["LifelinePairTimeOut %1", (_pairtimeoutbaby - time)]};
				if (_pairtimeoutbaby == 0) then {_pairtimeremain = "LifelinePairTimeOut ZERO"};
				 // if (Lifeline_hintsilent) then {[format ["%7 [%3]\n%1|%2\n%4 | %4 | %5 | %6", name _incap, name _medic,_linenumber,_incapnotincap,_pairtimeremain,_multimedic,_diagtext]] remoteExec ["hintsilent", 2]};
				 diag_log format ["%1 | %2 | [%3] !!!!!!!!!!!!!!!! %4  | INCAPSTATE: %5 MEDICSTATE: %6 | %7 | %8 | %9 | Lifeline_ExitTravel:%10", name _incap, name _medic,_linenumber,_diagtext,lifestate _incap,lifestate _medic,_pairtimeremain,_multimedic,_incapnotincap,_medic getVariable ["Lifeline_ExitTravel", false]];
				 if (_multimedic == "MULTIPLE MEDIC") then {diag_log format ["%1 | %2 | [%3] !!!!!!!!!!!!!!!! %4  ASSIGNEDMEDIC: %5", name _incap, name _medic, _linenumber, _diagtext,name ((_incap getVariable ["Lifeline_AssignedMedic",[]]) select 0)];};
				 [_incap,format ["%2 [%1]", _linenumber,_diagtext]] call serverSide_unitstate;[_medic,format ["%2 [%1]", _linenumber,_diagtext]] call serverSide_unitstate;
			};	//ENDDEBUG
	};
_exit
};




// List of all incapped units and assigned medics in HUD. Needs to be used with "foreach"
Lifeline_incap_list_HUD = {
params ["_x","_diag_text"];

		// _diag_text = "";
		_underline = "";
		_underline2 = "";
		_colur =  "#EEEEEE"; //whiteish
		_colur2 = "#EEEEEE"; //whiteish
		_no = "";
		_medics = "";
		_tme = "";
		_distcalc = "";
		_incap = _x;

		if (lifestate _x == "INCAPACITATED" || !(alive _x)) then {
				_colur = "#FFBFA7"; //pinkish
				if (Lifeline_RevMethod == 2) then {
					if (Lifeline_BandageLimit > 1 && Lifeline_HUD_names in [2,4]) then {
						_bandges = (_x getVariable ["num_bandages",0]);
						if (_bandges != 0) then {
						
							// _no = " (" + str _bandges + ")";
							// _no = "<t size='0.3'> ("+str _bandges+")</t>";
							// _no = "  " + str _bandges;
							_no = "<t size='0.3'>  "+str _bandges+" </t>";
							// _no = "<t color='#ffffff'> ("+str _bandges+")</t>";
							 // _no = "<t color='#ffffff' size='0.3'> ("+str _bandges+")</t>";
						//DEBUG
							// _no = " |" + str _bandges + "|";
							// _no = " .." + str _bandges;
							// _no = " - " + str _bandges;
							// _no = "<t color='#ffffff'> - "+str _bandges+"</t>";
							// _no = "<t color='#ccffcc'> ("+str _bandges+")</t>";
						//ENDDEBUG				
						} else {
							_no = " "; 
						};
					};	
				};
		};
		
		if (isPlayer _x) then {_underline = "underline='1'";};

		// if (_x getVariable ["ReviveInProgress",0] == 0) then {
		if (_x getVariable ["ReviveInProgress",0] == 0 && lifestate _x == "INCAPACITATED") then {
			// _colur = "#EE5F09";
			// _colur = "#EE2809"; //red
			_colur = "#FFBFA7"; //pinkish
			_diag_text = _diag_text + (format ["<t color='%1' %2>", _colur,_underline]) + name _x + "</t>   <br />";
		};

		if (_x getVariable ["ReviveInProgress",0] == 3) then {
			_medic = (_x getVariable ["Lifeline_AssignedMedic", []]);
			{
				if (Lifeline_Revive_debug && isServer && Lifeline_HUD_names_pairtime) then {
					_tme = str round ((_incap getVariable ["LifelinePairTimeOut",0]) - time);
				};
				if (Lifeline_HUD_names in [2,3]) then {
					_distcalc = str round (_incap distance2D _x) + "m ";
				};
				if (_x getVariable ["ReviveInProgress",0] == 2) then {
					_colur2 = "#58D68D";
					_colur = "#58D68D";// COMMENT THIS OUT TO HAVE DIFF COLOURED INCAP / MEDIC PAIRS WHEN ACTUAL REVIVE
					_tme = "";
					_distcalc = "";
				};
				if (isPlayer _x) then {_underline2 = "underline='1'";};
				// _medics = _medics + (format ["<t color='%1' %2>", _colur2,_underline2]) + name _x + " " + _distcalc + _tme + "</t>   ";
				_medics = _medics + (format ["<t color='%1' %2>", _colur2,_underline2]) + name _x + " " + "<t size='0.3'>" +_distcalc + _tme + "</t></t>   ";
			} foreach _medic;

			// diag_log format ["uuuuuuuuuuuuuuu MEDIC TEXT %1 uuuuuuuuuuuuuu", _medic];
			
			_diag_text = _diag_text + (format ["<t color='%1' %2>", _colur,_underline]) + name _x + _no + "</t> - "  + _medics + "<br />";
			// _diag_text = _diag_text + (format ["<t color='%1' %2>", _colur,_underline]) + _no + " " + name _x + "</t> - "  + _medics + "<br />";
		};
_diag_text
};



Lifeline_Smoke = {
	params ["_incap", "_medic"];
	diag_log format ["%1 | %2 |!!!!!!!!!!!!! SMOKE FNC fired !!!!!!!!!!!!", name _incap, name _medic];
	_reldir = 0;
	_relpos = [];
	_col = "";
	_EnemyCloseBy = [_medic] call Lifeline_EnemyCloseBy;
	if (getPosATL _incap select 2 <1) then {
		if (!isNull _EnemyCloseBy && alive _EnemyCloseBy && _EnemyCloseBy isKindOf "CAManbase") then {
				_reldir = _incap getdir _EnemyCloseBy;
		} else {
			_reldir = _incap getdir _medic;
		};
		_relpos = _incap getPos [10, _reldir]; // 10 metres away
		_colors= ["yellow","red","purple","orange","green","white"];
		if (Lifeline_SmokeColour == "random") then {
			_col = selectRandom _colors;
		} else {
			_col = Lifeline_SmokeColour;
		};
		_percentchance = 0; _random = 0;
		if (isNull _EnemyCloseBy) then {_percentchance = Lifeline_SmokePerc; } else {_percentchance = Lifeline_EnemySmokePerc;  };
		if (_percentchance == 0) exitWith { };
		if (_percentchance != 100) then {  
			_random = [1,100] call BIS_fnc_randomInt; 
		};
		if (_percentchance == 100 OR _random <= _percentchance) then {
			if (_col=="white") then {_col = ""}; 
			_GrenadeSmokeCol = "SmokeShell"+_col;
			createVehicle [_GrenadeSmokeCol, _relpos, [], (random 6), "CAN_COLLIDE"];
		};	
	};
	true
};



Lifeline_EnemyCloseBy = {
	params ["_unit"];
	_EnemiesCloseBy = [];
	_EnemyCloseBy = objNull;
	_EnemySides = (Lifeline_Side call BIS_fnc_enemySides);
	_EnemyUnits = allunits select {side _x in _EnemySides};
	_EnemiesCloseBy = _EnemyUnits select {_x distance _unit <500 && simulationEnabled _x};
	if (count _EnemiesCloseBy >0) then {
		_EnemyCloseBy = _EnemiesCloseBy select 0;
	} else {
		_EnemyCloseBy = objNull;
	};
	_EnemyCloseBy
};



Lifeline_POSnexttoincap = {
params ["_incap", "_medic", "_distnextto"];	
	// Step 1: Get the positions of the units
	_posA = getPos _incap;
	_posB = getPos _medic;
	// _posA = getPosASL _incap;
	// _posB = getPosASL _medic;
	// Step 2: Calculate the direction vector from _unitA to _unitB
	_directionVector = _posB vectorDiff _posA;
	// Step 3: Normalize the direction vector
	_directionVectorNormalized = vectorNormalized _directionVector;
	// Step 4: Scale the direction vector by _distnextto meters
	_scaledDirectionVector = _directionVectorNormalized vectorMultiply _distnextto; //_distnextto = metres
	// Step 5: Calculate the new position _distnextto meters from _unitA in the direction of _unitB
	_newPosition = _posA vectorAdd _scaledDirectionVector;
	// testing, choose position that is safe
	// _newPosition = [_newPosition, 1, 5, 5, 0, 20, 0] call BIS_fnc_findSafePos; //experimental
	_newPosition
};



Lifeline_delYelMark = {
	params ["_unit"];
	if !(Lifeline_yellowmarker) exitWith {};
		_yelmark = _unit getVariable ["ymarker1", nil]; 
	if (!isNil "_yelmark") then {
		deleteVehicle _yelmark;
	};
	// _ymrkrs = nearestObjects [_unit,["Sign_Arrow_Yellow_F"], 2];
	// {deleteVehicle _x} foreach _ymrkrs;
};



Lifeline_delIncapMrk = {
	params ["_unit"];
	_allmarkers = allMapMarkers select {markerType _x == "loc_heal"};
	{
		_txt = markerText _x;
		if (alive _unit && (name _unit) in _txt) then {
			deleteMarker _x;
			_unit setVariable ["Lifeline_IncapMark","",true];
		};
	} foreach _allmarkers;
	true
};



Lifeline_reset2 = {
	params ["_units","_lineno"];
	
	{
		if (alive _x) then {
			[_x] spawn {
				params ["_unit"];
				sleep 2;
				_unit setVariable ["Lifeline_ExitTravel", false, true];diag_log format ["%1 [0242]!!!!!!!!! change var Lifeline_ExitTravel = false !!!!!!!!!!!!!", name _unit];
			};
			
			

			_x setVariable ["ReviveInProgress",0,true];diag_log format ["%1 [0245]!!!!!!!!! change var ReviveInProgress = 0 !!!!!!!!!!!!!", name _x];	
			_x setVariable ["Lifeline_AssignedMedic", [], true];diag_log format ["%1 [0246]!!!!!!!!! change var Lifeline_AssignedMedic = [] !!!!!!!!!!!!!", name _x];
			_x setvariable ["LifelinePairTimeOut",0,true];diag_log format ["%1 [0247]!!!!!!!!! change var LifelinePairTimeOut = 0 !!!!!!!!!!!!!", name _x];
			// _x setVariable ["Lifeline_ExitTravel", false, true];

			if (_x in Lifeline_Process) then {
				Lifeline_Process = Lifeline_Process - [_x];
				publicVariable "Lifeline_Process";
			};

			diag_log format ["%1 [%2]!!!!!!!!!!!!!!!!!!!!!! Lifeline_reset2: %1 !!!!!!!!!!!!!!!!!!!!!", name _x,_lineno];
			diag_log format ["%1 [%2]!!!!!!!!!!!!!!!!!!!!!! Lifeline_reset2: %1 !!!!!!!!!!!!!!!!!!!!!", name _x,_lineno];
			diag_log format ["%1 [%2]!!!!!!!!!!!!!!!!!!!!!! Lifeline_reset2: %1 !!!!!!!!!!!!!!!!!!!!!", name _x,_lineno];
			
			
			// _x enableAI "ANIM";
			_x enableAI "MOVE";
			_x enableAI "AUTOTARGET";
			_x enableAI "AUTOCOMBAT";
			_x enableAI "SUPPRESSION";
			_x enableAI "TARGET";
			group _x setSpeedMode "NORMAL";
			_x limitSpeed 100;
			_x doWatch objNull;
			doStop _x; //ADDED 
			
			// joinSilent deletes Teamcolour, so workaround here.
			_teamcolour = assignedTeam _x;
			[_x] joinSilent _x;
			_x assignTeam _teamcolour;
			

			if (alive leader _x && lifestate leader _x != "incapacitated") then {
				_x doFollow leader _x;
			};

			// _x setvariable ["LifelineBleedOutTime",0,true]; // must be OFF. Its called at end of revive loop even when 15 sec pair is cancelled.
			if (!isNull (_x getVariable ["AssignedVeh", objNull]) && !isPlayer leader _x && isNull assignedVehicle _x) then {
				(group _x) addVehicle (_x getVariable "AssignedVeh");
			};
			if (isplayer _x && alive _x && lifestate _x != "INCAPACITATED") then {
				[group _x, _x] remoteExec ["selectLeader", groupOwner group _x];
				{_teamcolour = assignedTeam _x;[_x] joinSilent group _x;_x assignTeam _teamcolour;} foreach units group _x; // joinSilent deletes Teamcolour, so workaround here.
			};
			

			// fix animation if animation if incap but unit is healthy
			if (lifestate _x != "INCAPACITATED" && alive _x && (animationState _x find "unconscious" == 0 && animationState _x != "unconsciousrevivedefault" && animationState _x != "unconsciousoutprone")) then {
					diag_log format ["%1 !!!!!!!!!!!!! FIRE CANCEL UNCON ANIM !!!!!!!!!!!!!!!!!!", name _x];
					[_x, "unconsciousrevivedefault"] remoteExec ["SwitchMove", 0];
			};

			//this should be completely turned off. 
			if (lifestate _x != "INCAPACITATED") then { 
				_captive = _x getVariable ["Lifeline_Captive", false];
				if !(local _x) then {
					[_x, true] remoteExec ["allowDamage",_x];diag_log format ["%1 | [506 Lifeline_reset2][Lifeline_ReviveEngine.sqf] ALLOWDAMAGE SET: %2", name _x, "true"];
					// [_x, false] remoteExec ["setCaptive",_x];diag_log format ["%1 | [507 Lifeline_reset2]!!!!!!!!! change var setCaptive = false !!!!!!!!!!!!!", name _x];
					[_x, _captive] remoteExec ["setCaptive",_x];diag_log format ["%1 | [507 Lifeline_reset2]!!!!!!!!! change var setCaptive = %2 !!!!!!!!!!!!!", name _x, _captive];
				} else {
					_x allowDamage true;diag_log format ["%1 | [509 Lifeline_reset2][Lifeline_ReviveEngine.sqf] ALLOWDAMAGE SET: %2", name _x, "true"];
					// _x setCaptive false;diag_log format ["%1 | [510 Lifeline_reset2][Lifeline_ReviveEngine.sqf]!!!!!!!!! change var setCaptive = false !!!!!!!!!!!!!", name _x]; 
					_x setCaptive _captive;diag_log format ["%1 | [510 Lifeline_reset2][Lifeline_ReviveEngine.sqf]!!!!!!!!! change var setCaptive = %2 !!!!!!!!!!!!!", name _x, _captive]; 
				};		
			};	
			
		};	//if (alive _x) then 
	} forEach _units;

	//DEBUG	
		// sleep 1;
	/* {
		// diag_log format ["%1 uuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuu lifestate %2 Lifeline_reset uuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuu", name _x, lifestate _x];
		if (lifestate _x != "INCAPACITATED" && alive _x) then { 	//added this line
		// diag_log format ["%1 uuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuu lifestate %2 Lifeline_reset THRU uuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuu", name _x, lifestate _x];	

			// [_x,true] remoteExec ["allowDamage",_x];diag_log format ["%1 | [0296 Lifeline_reset2][Lifeline_ReviveEngine.sqf] ALLOWDAMAGE SET: %2", name _x, isDamageAllowed _x];
			// [_x,false] remoteExec ["setCaptive",_x];

			//changed to non remoteExec.It didnt change one time for some reason. its global anyway.
			//method2
			// _x allowDamage true;diag_log format ["%1 | [490 Lifeline_reset2][Lifeline_ReviveEngine.sqf] ALLOWDAMAGE SET: %2", name _x, isDamageAllowed _x];
			// _x setCaptive false;diag_log format ["%1 | [491 Lifeline_reset2]!!!!!!!!! change var setCaptive = false !!!!!!!!!!!!!", name _x];			
			
			// if !(local _x) then {
				// [_x, true] remoteExec ["allowDamage",_x];diag_log format ["%1 | [506 Lifeline_reset2][Lifeline_ReviveEngine.sqf] ALLOWDAMAGE SET: %2", name _x, "true"];
				// [_x, false] remoteExec ["setCaptive",_x];diag_log format ["%1 | [507 Lifeline_reset2]!!!!!!!!! change var setCaptive = false !!!!!!!!!!!!!", name _x];
			// } else {
				_x allowDamage true;diag_log format ["%1 | [509 Lifeline_reset2][Lifeline_ReviveEngine.sqf] ALLOWDAMAGE SET: %2", name _x, "true"];
				_x setCaptive false;diag_log format ["%1 | [510 Lifeline_reset2]!!!!!!!!! change var setCaptive = false !!!!!!!!!!!!!", name _x];
			// };			
			
			//method2
			// [_x, true] remoteExec ["allowDamage",_x];
			// [_x, false] remoteExec ["setCaptive",_x];
			// waitUntil {isDamageAllowed _x == true};diag_log format ["%1 | [490 Lifeline_reset2][Lifeline_ReviveEngine.sqf] ALLOWDAMAGE SET: %2", name _x, isDamageAllowed _x];
			// waitUntil {captive _x == false};diag_log format ["%1 | [491 Lifeline_reset2]!!!!!!!!! change var setCaptive = false !!!!!!!!!!!!!", name _x];
		};	
	} forEach _units; */
	//ENDDEBUG

	true
};



Lifeline_SelfHeal = {
	params ["_unit"];

	_unit setVariable ["Lifeline_selfheal_progss",true,true];diag_log format ["%1 [0309]!!!!!!!!! change var Lifeline_selfheal_progss = true !!!!!!!!!!!!!", name _unit];
	
	if (_unit getVariable ["ReviveInProgress",0] == 0) then {
		sleep 3;
		sleep (random 2); // this must be BEFORE cheching incapacitated. Otherwise in these 5 secs it can happen, and bugs animation.
	};

	if (alive _unit && lifeState _unit != "INCAPACITATED" && Lifeline_RevMethod != 3 && (damage _unit > 0.2 || _unit getHitPointDamage "hitlegs" >= 0.5) && (isnull (objectParent _unit))) then {
	
		diag_log format ["%1 |!!!!!!!!!!!!!! HEAL SELF fnc Lifeline_SelfHeal !!!!!!!!!!!! DMG %2", name _unit, damage _unit];

		_EnemyCloseBy = [_unit] call Lifeline_EnemyCloseBy;

		if (_unit getVariable ["ReviveInProgress",0] in [1,2]) then {
			diag_log format ["%1 [0321] ========== SELF HEAL ADD 5 SECS (ReviveInProgress in 1 or 2)", name _unit];
			_unit setVariable ["LifelinePairTimeOut", (_unit getvariable "LifelinePairTimeOut") + 5, true];  diag_log format ["%1 [0322]!!!!!!!!! change var LifelinePairTimeOut = +5 sec !!!!!!!!!!!!!", name _unit];
		}; // add 5 secs to timeout

		// if (isnull _EnemyCloseBy or _unit distance _EnemyCloseBy >100) then {
		// if (isnull _EnemyCloseBy) then {
		if ((stance _unit == "STAND" || stance _unit == "CROUCH") && stance _unit != "UNDEFINED") then {
			[_unit,"AinvPknlMstpSlayWrflDnon_medic"] remoteExec ["playMoveNow", _unit];
			sleep 6;
		} else {
			[_unit,"ainvppnemstpslaywrfldnon_medic"] remoteExec ["playMoveNow",_unit];
			sleep 7;
		};

		if (lifeState _unit != "INCAPACITATED") then { //added again
			_unit setdamage 0;
		};		
	
	};
	

	if (alive _unit && lifeState _unit != "INCAPACITATED" && Lifeline_RevMethod == 3 && (isnull (objectParent _unit))) then {
		[_unit] call Lifeline_SelfHeal_ACE;
	};
	
	_unit setVariable ["Lifeline_selfheal_progss",false,true];diag_log format ["%1 [0338]!!!!!!!!! change var Lifeline_selfheal_progss = false !!!!!!!!!!!!!", name _unit];
	//DEBUG
	// if (_unit getVariable ["ReviveInProgress",0] == 1) then {
		// _revivePosX = _incap getVariable ["Lifeline_RevPosX",_revivePos];
		// [[_unit],"[466 Lifeline_SelfHeal]"] call Lifeline_reset2;	
	// };
	//ENDDEBUG 

	true
};



//========================== MAIN FUNCTION LOOP TO CHECK INCAP / MEDIC PAIR
Lifeline_PairLoop = {
	params ["_medic","_incap"];

	// if (Lifeline_Revive_debug && Lifeline_hintsilent) then {[format ["Incap: %1\nMedic: %2", name _incap, name _medic]] remoteExec ["hintsilent", 2]};

	_poscheck = getpos _medic; // for checking idle medic
	_idleMlimit = 7; // number of seconds an idle medic before resetting
	_repeatcount = _idleMlimit; // for checking idle medic
	_exit = false; // for exiting loop without using getVariable
	_idlemedic = false;
	_closermedic = false;

	while {alive _medic && lifestate _incap == "INCAPACITATED" && (_incap getVariable ["LifelinePairTimeOut",0])>0} do {
		
		//DEBUG
		// Add some ammo to medic - is this needed?
		// if (_medic ammo primaryWeapon _medic <30) then {_medic setammo [primaryWeapon _medic, 30]};
		//ENDDEBUG

		// check time limit
		_elapsedTimeToRevive = (_incap getVariable ["LifelinePairTimeOut",0]);
		_incapTL = (_incap getVariable ["LifelineBleedOutTime",0]);

		if (isNil "_incapTL" && Lifeline_Revive_debug) then {
			diag_log format ["%1 [0375]!!!!!!!!!!!!!!!!!!!!! _incapTL ISSUE: %2 !!!!!!!!!!!!!!!!!!!!!!!!", name _incap, _incapTL];
			[_incap,"_incapTL ISSUE"] remoteExec ["serverSide_unitstate", 2];
			["_incapTL ISSUE"] remoteExec ["serverSide_Globals", 2];
		};

		_distcalc = _medic distance2D _incap;
		
		if (animationstate _medic in ["aidlpercmstpsraswrfldnon_g01","aidlpercmstpsraswrfldnon_g02","aidlpercmstpsraswrfldnon_g03",
				"aidlpercmstpsraswrfldnon_g04","amovpknlmstpslowwrfldnon","aidlpercmstpsraswrfldnon_ai"]) then {
				diag_log format ["%1 [512] nnnnnnnnnnnnnnnnnnn MEDIC IDLE ANIM nnnnnnnnnnnnnnnnnnnnnnnnnn", name _medic];		
		};
		
		if (speed _medic == 0) then {
				diag_log format ["%1 [516] nnnnnnnnnnnnnnnnnnn MEDIC IDLE SPEED nnnnnnnnnnnnnnnnnnnnnnnnnn ANIM %2", name _medic, animationstate _medic];
				
		};
		

		// THIS IS TO STOP IDLE MEDICS. SOMETIMES HAPPENS.
		// if (Lifeline_Idle_Medic_Stop && (animationstate _medic in ["aidlpercmstpsraswrfldnon_g01","aidlpercmstpsraswrfldnon_g02","aidlpercmstpsraswrfldnon_g03","aidlpercmstpsraswrfldnon_g04","amovpknlmstpslowwrfldnon","aidlpercmstpsraswrfldnon_ai"] || _repeatcount != 6)) then { 
		if (Lifeline_Idle_Medic_Stop && (speed _medic == 0 || _repeatcount != 6) && (_medic getVariable ["ReviveInProgress",0] == 1) && _distcalc > 6) then { 
			if (_repeatcount < 4) then { // just beep for debugging
				if (Lifeline_Revive_debug) then {
					diag_log format ["%1 | %2 [0387]!!!!!!!!!!!!!!!!!!!!! IDLE MEDIC count %3 !!!!!!!!!!!!!!!!!!!!!!!!!!!!", name _incap, name _medic, _repeatcount]; 
					if (Lifeline_hintsilent) then {hintsilent format ["%1 IDLE MEDIC %2", name _medic, _repeatcount]}; 
					["beep_hi_1"] remoteExec ["playsound",2];
				};
			};
		   if (_repeatcount == _idleMlimit) then { _poscheck = getpos _medic; }; 
		   if (_repeatcount == 0 && _poscheck isEqualTo getpos _medic) exitWith { 
				if (Lifeline_Revive_debug) then {
				   if (Lifeline_debug_soundalert) then {["stop_idle_medic"] remoteExec ["playSound",2]}; 
				   diag_log format ["%1 | %2 [0396]!!!!!!!!!!!!!!!!!!!!! STOPPED IDLE MEDIC !!!!!!!!!!!!!!!!!!!!!!!!!!!!", name _incap, name _medic]; 
				   if (Lifeline_hintsilent) then {hintsilent format ["%1 STOPPED IDLE MEDIC", name _medic]}; 
			   };
			   _repeatcount = _idleMlimit; 
			   // _incap setVariable ["LifelinePairTimeOut", 0,true]; 
			   _exit = true; 
			   _idlemedic = true;			   
			   if (Lifeline_Revive_debug) then {[_medic,"IDLE MEDIC [0403]"] call serverSide_unitstate};
			   _medic call reset_idle_medics;			   
		   }; 
		   // if (_poscheck isEqualTo getpos _medic) then {_repeatcount = _repeatcount - 1}; 
		   _repeatcount = _repeatcount - 1;
		   if (_repeatcount < 0 || _poscheck isNotEqualTo getpos _medic) then {_repeatcount = _idleMlimit; if (Lifeline_hintsilent) then {hintsilent ""};}; 
		};

		 //check for closer medic
		 _closermedic_dist = 100;
		if (_distcalc > _closermedic_dist ) then {

			 Lifeline_healthy_units = Lifeline_All_Units - Lifeline_incapacitated;
			 // Lifeline_medics2choose = (Lifeline_healthy_units select {!(side _x == civilian) && !isPlayer _x && !(_x in Lifeline_Process) && ((_x distance _incap) < Lifeline_LimitDist) && (currentWeapon _x != secondaryWeapon _x )}); 
			 Lifeline_medics2choose = (Lifeline_healthy_units select {!(side _x == civilian) && !isPlayer _x && !(_x in Lifeline_Process) && ((_x distance _incap) < Lifeline_LimitDist) 
				&& !(currentWeapon _x == secondaryWeapon _x && currentWeapon _x != "")
			 	&& !(((assignedTarget _x) isKindOf "Tank") && secondaryWeapon _x != "") //check unit did not get order to hunt tank
				&& !(((getAttackTarget _x) isKindOf "Tank") && secondaryWeapon _x != "")			 
			 }); 
			 _closermedic = false;
			 {
				  _dis = _x distance2D _incap;
				 if (_dis < _closermedic_dist) then {
					 _closermedic = true;
					  diag_log format ["!!! %1 over 200 and medic distances %1 TRUE",  _dis, name _x];
				 };		 
			 } foreach Lifeline_medics2choose;

			 if (count Lifeline_medics2choose > 0 && _closermedic == true) then {
				if (Lifeline_Revive_debug) then {
					if (Lifeline_debug_soundalert && Lifeline_Revive_debug) then {["closermedic"] remoteExec ["playSound",2]}; 
					diag_log format ["%1 | %2 [0429]!!!!!!!!!!!!!!!!!!!!! CLOSER MEDIC !!!!!!!!!!!!!!!!!!!!!!!!!!!!", name _incap, name _medic]; 
					if (Lifeline_hintsilent && Lifeline_Revive_debug) then {hintsilent format ["%1  CLOSER MEDIC ", name _medic]}; 
				 };
				  _exit = true;
				  _medic setVariable ["Lifeline_ExitTravel", true, true];diag_log format ["%1 [0433]!!!!!!!!! change var Lifeline_ExitTravel = true !!!!!!!!!!!!!", name _medic];
			  };
		};

		//JUST DEBUGGING
		_formatedReviveTime = round(_elapsedTimeToRevive - time);
		if (Lifeline_RevMethod == 2 && Lifeline_Revive_debug) then {
			diag_log format [" %3 | %4 |xxxxxxxxxxxxxxxxxxx REVIVETIME %2 BLEEDOUT %5 DISTANCE %6 ReviveInProgress %7 autoRecover %8 |'", 0, if (_formatedReviveTime < 10) then {"0"+(str _formatedReviveTime)} else {_formatedReviveTime}, name _incap, name _medic, round(_incapTL - time), _distcalc toFixed 0, _medic getVariable ["ReviveInProgress",0], _incap getVariable ["Lifeline_autoRecover",false] ];
		};
		if (Lifeline_RevMethod == 3 && Lifeline_Revive_debug) then {
			diag_log format [" %3 | %4 |xxxxxxxxxxxxxxxxxxx REVIVETIME %2 DISTANCE %5 ReviveInProgress %6 |'", 0, if (_formatedReviveTime < 10) then {"0"+(str _formatedReviveTime)} else {_formatedReviveTime}, name _incap, name _medic, _distcalc toFixed 0, _medic getVariable ["ReviveInProgress",0] ];
		};
		// };		

		//DEBUG
		//BUG WARNINGS
		if (Lifeline_Revive_debug) then {
			if (_medic getVariable ["ReviveInProgress",0] == 2 && _distcalc > 10) then {
				diag_log format ["%1 | %2 is BUG!! REVIVE FROM OVER 10m uuuuuuuuuu BUG uuuuuuuuuu  distance: %3", name _incap, name _medic, round _distcalc];
				diag_log format ["%1 | %2 is BUG!! REVIVE FROM OVER 10m uuuuuuuuuu BUG uuuuuuuuuu  distance: %3", name _incap, name _medic, round _distcalc];
				diag_log format ["%1 | %2 is BUG!! REVIVE FROM OVER 10m uuuuuuuuuu BUG uuuuuuuuuu  distance: %3", name _incap, name _medic, round _distcalc];		
				_diagtext = format ["BUG REVIVE FROM OVER 10m dist:%1", round _distcalc]; 
				[_incap,_diagtext] call serverSide_unitstate;
				[_medic,_diagtext] call serverSide_unitstate;
				[_diagtext] call serverSide_Globals;
				hintsilent format ["BUG %1\n%2", name _incap,_diagtext];
				if (Lifeline_debug_soundalert) then {["siren1"] remoteExec ["playSound",2]};	
			};	
			_AssignedMedic = (_incap getVariable ["Lifeline_AssignedMedic",[]]) select 0;
			if (_AssignedMedic != _medic) then {
				diag_log format ["%1 | %2 is [0463] BUG!! Lifeline_AssignedMedic NOT SAME uuuuuuuuuu BUG uuuuuuuuuu  medic: %3", name _incap, name _medic, name _AssignedMedic];
				diag_log format ["%1 | %2 is [0463] BUG!! Lifeline_AssignedMedic NOT SAME uuuuuuuuuu BUG uuuuuuuuuu  medic: %3", name _incap, name _medic, name _AssignedMedic];
				diag_log format ["%1 | %2 is [0463] BUG!! Lifeline_AssignedMedic NOT SAME uuuuuuuuuu BUG uuuuuuuuuu  medic: %3", name _incap, name _medic, name _AssignedMedic];
				_diagtext = format ["[0463] Lifeline_AssignedMedic NOT SAME:%1", name _AssignedMedic]; 
				[_incap,_diagtext] call serverSide_unitstate;
				[_medic,_diagtext] call serverSide_unitstate;
				[_diagtext] call serverSide_Globals;
				hintsilent format ["BUG %1\n%2", name _incap,_diagtext];
				if (Lifeline_debug_soundalert) then {["siren1"] remoteExec ["playSound",2]};
			};
		};
		//ENDDEBUG

		_ifACEdragged = false;
		if (Lifeline_RevMethod == 3) then {
			// if ([_incap] call ace_medical_status_fnc_isBeingDragged || [_incap] call ace_medical_status_fnc_isBeingCarried) then {
			if ([_incap] call Lifeline_check_carried_dragged) then {
			_ifACEdragged = true;
			};
		};

		if ((_elapsedTimeToRevive > 0 && time > _elapsedTimeToRevive && (Lifeline_RevMethod == 2 && time < _incapTL || Lifeline_RevMethod == 3)) 
			|| _elapsedTimeToRevive == 0 || _ifACEdragged == true || (lifestate _incap != "INCAPACITATED") || (lifestate _medic == "INCAPACITATED") 
			|| !(alive _medic) || (currentWeapon _medic == secondaryWeapon _medic && currentWeapon _medic != "") 
			|| (((assignedTarget _medic) isKindOf "Tank") && secondaryWeapon _medic != "") //check unit did not get order to hunt tank
			|| (((getAttackTarget _medic) isKindOf "Tank") && secondaryWeapon _medic != "")			
			|| _exit == true) then {

				_medic setVariable ["Lifeline_ExitTravel", true, true];diag_log format ["%1 [0487]!!!!!!!!! change var Lifeline_ExitTravel = true !!!!!!!!!!!!!", name _medic];

				diag_log format ["==== time %1 _elapsedTimeToRevive %2 _incapTL %3 ====", time, _elapsedTimeToRevive, _incapTL];
				
				if (Lifeline_Revive_debug) then {
					diag_log format ["%3|%4| '", _incap, _medic,name _incap,name _medic];
					if (_elapsedTimeToRevive > 0 && time > _elapsedTimeToRevive && (Lifeline_RevMethod == 2 && time < _incapTL || Lifeline_RevMethod == 3))  then {
					if (Lifeline_hintsilent) then {["Medic reset\nTaking too long"] remoteExec ["hintsilent", 2]};
					diag_log format ["%3|%4|++++ DELETE YELLOW MARKER ++++ [0495] MEDIC RESET TAKING TOO LONG'", _incap, _medic,name _incap,name _medic];
					};
					if ((lifestate _medic == "INCAPACITATED") || (lifestate _medic == "DEAD") || (lifestate _medic == "DEAD-RESPAWN") || (lifestate _medic == "DEAD-SWITCHING")) then {
					if (Lifeline_hintsilent) then {[format ["Medic DOWN\n%1", name _medic]] remoteExec ["hintsilent", 2]};
					diag_log format ["%3|%4|++++ DELETE YELLOW MARKER ++++ [0499] MEDIC DOWN!!!'", _incap, _medic,name _incap,name _medic];
					};
					if (_closermedic == true && _exit == true) then {
					if (Lifeline_hintsilent) then {[format ["Medic Closer\n%1", name _medic]] remoteExec ["hintsilent", 2]};
					diag_log format ["%3|%4|++++ DELETE YELLOW MARKER ++++ [0503] CLOSER MEDIC !!!'", _incap, _medic,name _incap,name _medic];
					};				
					if (_idlemedic == true && _exit == true) then {
					if (Lifeline_hintsilent) then {[format ["Medic Idle\n%1", name _medic]] remoteExec ["hintsilent", 2]};
					diag_log format ["%3|%4|++++ DELETE YELLOW MARKER ++++ [0507] IDLE MEDIC !!!'", _incap, _medic,name _incap,name _medic];
					};
					if (lifestate _incap != "INCAPACITATED") then {
					if (Lifeline_hintsilent) then {[format ["Medic WOKE UP\n%1", name _medic]] remoteExec ["hintsilent", 2]};
					diag_log format ["%3|%4|++++ DELETE YELLOW MARKER ++++ [0511] INCAP WOKE UP!!!'", _incap, _medic,name _incap,name _medic];
					};
					if (currentWeapon _medic == secondaryWeapon _medic && currentWeapon _medic != ""
						|| (((assignedTarget _medic) isKindOf "Tank") && secondaryWeapon _medic != "") //check unit did not get order to hunt tank
						|| (((getAttackTarget _medic) isKindOf "Tank") && secondaryWeapon _medic != "")					
					) then {
						if (Lifeline_debug_soundalert) then {["medichaslauncher"] remoteExec ["playSound",2]};
						if (Lifeline_hintsilent) then {[format ["Medic w Launcher\n%1", name _medic]] remoteExec ["hintsilent", 2]};
						diag_log format ["%3|%4|++++ DELETE YELLOW MARKER ++++ [0516] MEDIC HAS LAUNCHER!!!'", _incap, _medic,name _incap,name _medic];				
					};
					diag_log format ["%3|%4| '", _incap, _medic,name _incap,name _medic];
					_incap call Lifeline_delYelMark;
				};

				_exit = false;

				// if (lifestate _medic != "INCAPACITATED") then { //added this conditional. sometimes when medic is hit and downed, this needs to stay as is.			
						// [_medic,false] remoteExec ["setCaptive",_medic];diag_log format ["%1 | [0759][Lifeline_Global.sqf] !!!!!!!!! change var setCaptive = %2 !!!!!!!!!!!!!", name _medic, "false"];
				// }; 
				
				_teamcolour = assignedTeam _medic; // joinSilent deletes Teamcolour, so workaround here.
				[_medic] joinSilent _medic;
				_medic assignTeam _teamcolour; // joinSilent deletes Teamcolour, so workaround here.
				
				_medic = objNull;

		}; // end time > _LifelinePairTimeOut 

		//if the medic switches to launcher, it means a tank needs to be taken out. Cancel medic then, more important is tank. - Lifeline
		if ((_incap getVariable ["LifelinePairTimeOut", 0]) == 0) exitWith {diag_log format ["%1 | %2 !!!!!!!!!!!!!!!!! [0533][LifelinePairTimeOut = 0] EXITWITH in FNC Lifeline_PairLoop", name _incap, name _medic];};
		if ((_medic getVariable ["Lifeline_ExitTravel", false]) == true) exitWith {diag_log format ["%1 | %2 !!!!!!!!!!!!!!!!! [0534][Lifeline_ExitTravel = true] EXITWITH in FNC Lifeline_PairLoop", name _incap, name _medic];};

		sleep 1;
	}; // end while

}; // END Fnc spawn recovery, recycle or death func



//========================== MAIN REVIVE FUNCTION STARTING MEDIC TRAVEL
Lifeline_StartRevive = {
	params ["_medic", "_incap"];

	//DEBUG
	// AI functions to make travel easier
	// _medic setSkill ["COURAGE", 1];
	// _medic allowFleeing 0.2;
	// _medic disableAI "AUTOTARGET";
	// _medic disableAI "AUTOCOMBAT";
	// _medic disableAI "SUPPRESSION";
	// _medic disableAI "TARGET";
	//ENDDEBUG
	
	[_medic,["COURAGE", 1]] remoteExec ["setSkill",0];
	[_medic,"AUTOTARGET"] remoteExec ["disableAI",0];
	[_medic,"AUTOCOMBAT"] remoteExec ["disableAI",0];
	[_medic,"SUPPRESSION"] remoteExec ["disableAI",0];
	[_medic,"TARGET"] remoteExec ["disableAI",0];
	[_medic,0.2] remoteExec ["allowFleeing",0];
	[_medic,"TARGET"] remoteExec ["disableAI",0];

	_linenumber = "0744";
	_exit = [_incap,_medic,"EXIT REVIVE TRAVEL [root]",_linenumber] call Lifeline_exit_travel;

	_voice = _medic getVariable "Lifeline_Voice";
	_B = "";
	_EnemyCloseBy = objNull;
	_yelmark = objNull;	
	_goup = group _medic;	// check group 4 medic
	_revivePos = [];
	_distnextto = 0;
	_dir = 0;
	_revtime = time;
	_shortorigdist = false;
	_shortorigdist6 = false;
	_stance = UnitPos _medic;diag_log format ["%1 [720] uuuuuuuuuuuuuuuuuuuuuuuuu STANCE %2 uuuuuuuuuuuuuuuuuuuuuuuuuuu", name _medic, _stance];

	if !(_exit) then {
		_linenumber = "0757";
		_exit = [_incap,_medic,"EXIT REVIVE TRAVEL [root]",_linenumber] call Lifeline_exit_travel;
	};	
	
	if (_medic getVariable ["Lifeline_ExitTravel", false] == false && _exit == false) then {
	
		diag_log format ["%1 | %2 [0766]nnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnn ORIGNAL DISTANCE %3", name _incap, name _medic, _medic distance2D _incap];

		//if original distance is short, the medic overshoots the incap (goes too far). This var for adjusting anim.
		if ((_medic distance2D _incap) <= 10) then {
			_shortorigdist = true;
			// _medic limitSpeed 2;
			// sleep 4;			
				diag_log format ["%1 | %2 [731] nnnnnnnnnnnnnnnnnnnnnnnnnnnnn _shortorigdisty = true nnnnnnnnnnnnnnnnnnnnnnnnnn", name _incap, name _medic];
				if (Lifeline_debug_soundalert && Lifeline_Revive_debug) then {playsound "shortdistance"};
				if (Lifeline_hintsilent && Lifeline_Revive_debug) then {hint format ["%1 SHORT DISTANCE ", name _medic]};
		};

		
		//TEMP NEW
		if ((_medic distance2D _incap) <= 6)  then {
			_shortorigdist6 = true;
			if (stance _medic == "STAND") then {
				_medic setUnitPos "MIDDLE";
			};
		};
		

		// unassign vehicle if lost group status
		if (!isplayer (leader group _medic) && isPlayer _incap) then {
			{if (!isplayer _x) then {_x leaveVehicle (assignedVehicle _x)}} foreach (units leader _incap);
		};

		//check if bleeding. both for ACE and non-ACE
		_isbleeding = false;
		if (Lifeline_RevMethod == 3) then {
			_isbleeding = [_medic] call ace_medical_blood_fnc_isBleeding;
		} else {
			if (damage _medic >=0.2 || _medic getHitPointDamage "hitlegs" >= 0.5) then { 
			_isbleeding = true;
			};
		};
		if (!isPlayer _medic && !(lifestate _medic == "INCAPACITATED") && alive _medic && _isbleeding == true 
			&& _medic getVariable ["Lifeline_selfheal_progss",false] == false
		) then {
			diag_log format ["%1 [0591] !!!!!!!!!!!!!!!! MEDIC self heal !!!!!!!!!!!!! DMG %2 STATE %3 Lifeline_selfheal_progss %4", name _medic, damage _medic, lifestate _medic, _medic getVariable ["Lifeline_selfheal_progss",false]];
			_medic call Lifeline_SelfHeal;
		};
	
		//DEBUG
		//old spot for AI disable

		// remove collision //moved
		// if (alive _incap && alive _medic) then {
			// [_medic, _incap] remoteExecCall ["disableCollisionWith", 0, _medic];diag_log format ["%1 | [0785] nnnnnnnnnnnnnnnnn REMOVE COLLISION nnnnnnnnnnnnnnnn", name _medic];
		// };
		//ENDDEBUG

		// ========== Start travel ===========

		// update this later. bad method for making sure animation works when not having primary weapon. 
		if (alive _medic && primaryWeapon _medic == "") then {_medic addWeapon "arifle_MX_F"};
		if (alive _medic && currentWeapon _medic != (primaryWeapon _medic)) then {_medic selectWeapon (primaryWeapon _medic)};

		_EnemyCloseBy = [_medic] call Lifeline_EnemyCloseBy;
		
		_cpr = false;
		
		if (Lifeline_RevMethod == 3) then {
				_cpr = [_medic, _incap] call ace_medical_treatment_fnc_canCPR;
		};

		// calc position depending on enemy proximity
		// if (!isnull _EnemyCloseBy) then {
		if (!isnull _EnemyCloseBy && _cpr == false) then {
			_distnextto = 1.5;
		} else {
			_distnextto = 0.8;
		};

		_revivePos = [_incap, _medic, _distnextto] call Lifeline_POSnexttoincap;	
		
		// _revivePos set [2,0]; // Set height. Maybe turn this off
		
		//TEMP // maybe this whole block should move as a waitUntil {_medic distance2D _revivePos < 10} further down this function
		[_incap,_medic,_revivePos,_EnemyCloseBy] spawn {
			params ["_incap","_medic","_revivePos","_EnemyCloseBy"];
			

			// sleep 4;
			_revivePosCheck = "";
			_cpr = false;
			_medicpos = getPos _medic;
			_medicpos2 = [];
			_directioncount = 3; //re-align direction only 3 times, to prevent a loop of constant direction glitch
			_checkdegrees = 0;
			_teleptrig = false; //this is to make sure teleport is only triggered once. Teleport is a micro teleport of under 5 metres to make sure medic is in right spot.
			_telepcheck = nil; // this var is to check medic position against revive position for potential teleport

			diag_log "nnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnn START";
			while {alive _medic && alive _incap && _medic getVariable ["ReviveInProgress",0] in [1,2] && lifestate _incap == "INCAPACITATED"} do {
				if (_medic distance2D _revivePos < 10) then { 
					

					if (Lifeline_RevMethod == 3) then {
						_cpr = [_medic, _incap] call ace_medical_treatment_fnc_canCPR;
					};
/* 					if (!isnull _EnemyCloseBy && _cpr == false) then {
						_revivePosCheck = [_incap, _medic, 1.5] call Lifeline_POSnexttoincap;
					} else {
						_revivePosCheck = [_incap, _medic, 0.8] call Lifeline_POSnexttoincap; 
						diag_log "nnnnnnnnnnnnnn CPR nnnnnnnnnnnnnnn";					
					}; */
					if (!isnull _EnemyCloseBy && _cpr == false) then {
							// _revivePosCheck = [_incap, _medic, 0.5] call Lifeline_POSnexttoincap;
							_revivePosCheck = [_incap, _medic, 0.8] call Lifeline_POSnexttoincap;
					} else {
						// _revivePosCheck  = _incap;				
							// _revivePosCheck  = [_incap, _medic, 0.1] call Lifeline_POSnexttoincap;			
							_revivePosCheck  = [_incap, _medic, 0.5] call Lifeline_POSnexttoincap;			
					};

					if (Lifeline_Revive_debug && Lifeline_yellowmarker) then {

						//============== MARKERS ======
						//DEBUG
						// _medicpossy = (getPos _medic);
						// _purplmark = _medic getVariable ["purplmarker1", nil]; 
						// if (!isNil "_purplmark") then {deleteVehicle _purplmark};				
						// _purplmark = createVehicle ["Sign_Arrow_Pink_F", _medicpossy,[],0,"can_collide"];
						// _medic setVariable ["purplmarker1", _purplmark, true]; 						
						
						// _cyanmark = _incap getVariable ["cyanmarker1", nil]; 
						// if (!isNil "_cyanmark") then {deleteVehicle _cyanmark};				
						// _cyanmark = createVehicle ["Sign_Arrow_Cyan_F", _revivePosCheck,[],0,"can_collide"];
						// _incap setVariable ["cyanmarker1", _cyanmark, true]; 
						// diag_log format ["nnnnn MEDIC %1 _revivePos %2 _revivePosCheck %3 nnnnnnn", _medicpossy, _revivePos, _revivePosCheck];
						//ENDDEBUG
						_incap call Lifeline_delYelMark;
						_yelmark = createVehicle ["Sign_Arrow_Yellow_F", _revivePos,[],0,"can_collide"];
						_incap setVariable ["ymarker1", _yelmark, true]; 							
						//================================
					};


					_telepcheck = _revivePos;


					// if (_revivePos isNotEqualTo _revivePosCheck) then {
					if (_revivePos distance2D _revivePosCheck > 0.2 && _medic distance2D _incap > 4) then {
					// if (_revivePos distance2D _revivePosCheck > 0.5) then {	

						_revivePos = _revivePosCheck; // commenting out this line, gets diff results. Test/											
						_incap setVariable ["Lifeline_RevPosX",_revivePos,true];

						if (_medic getVariable ["ReviveInProgress",0] == 1) then {
							//_teamcolour = assignedTeam _medic;[_medic] joinSilent _medic;_medic assignTeam _teamcolour; // joinSilent deletes Teamcolour, so workaround here.
							_medic domove position _medic;
							_medic moveto position _medic;
							_medic domove _revivePos;
							_medic moveto _revivePos;
							diag_log format ["%1 | [893] nnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnn DOMOVE MEDIC TO REVIVEPOS [LOOP] ========== DIST: %2 =====================", name _medic, _medic distance2D _incap];
							if (Lifeline_Revive_debug) then {
								if (Lifeline_debug_soundalert) then {playsound "beep_hi_1"};
								if (Lifeline_hintsilent) then {hint format ["%1 DOMOVE MEDIC", name _medic]};
							};
						};

						if (Lifeline_yellowmarker && Lifeline_Revive_debug) then {
							_incap call Lifeline_delYelMark;
							_yelmark = createVehicle ["Sign_Arrow_Yellow_F", _revivePos,[],0,"can_collide"];
							_incap setVariable ["ymarker1", _yelmark, true]; 	
						};
						//DEBUG
						// _direction = _medic getDir _incap;
						// _direction = _medic getDir _revivePos;
						// _medic setDir _direction;
						//ENDDEBUG
					};
					
					//DEBUG
					// if (_medic getVariable ["ReviveInProgress",0] == 2 && _medic distance2D _revivePosCheck > 0.3 && _cpr == false && _medicpos isEqualTo _medicpos2) then {
					// if (_medic getVariable ["ReviveInProgress",0] == 2 && (getpos _medic) isNotEqualTo _revivePosCheck && _cpr == false && _medicpos isEqualTo _medicpos2) then {
					/* if (_medic getVariable ["ReviveInProgress",0] == 2 && _medicpossy isNotEqualTo _revivePosCheck && _cpr == false && _medicpos isEqualTo _medicpos2) then {
						diag_log format ["%1 | nnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnn TRANSPORT MEDIC TO REVIVEPOS ===============================", name _medic];
						if (Lifeline_Revive_debug) then {
							if (Lifeline_debug_soundalert) then {playsound "beep_hi_1"};
							if (Lifeline_hintsilent) then {hint format ["%1 TRANSPORT MEDIC", name _medic]};
						};
						_medic setPos _revivePosCheck;
						// _medic setPos _revivePos;
						// _direction = _medic getDir _incap;
						// _medic setDir _direction;
					}; */
					//ENDDEBUG
					// make sure medic is facing right direction. Only for ACE at the moment
					if (Lifeline_RevMethod == 3) then {
						// if (_directioncount > 0) then {_checkdegrees = [_incap,_medic,30] call Lifeline_checkdegrees;};
						_checkdegrees = [_incap,_medic,20] call Lifeline_checkdegrees;diag_log format ["%1 | nnnnnnnnnnnnnnn  WTF DIRECTION MEDIC _checkdegrees %2 _directioncount %3  nnnnnnnnnnnnnnn", name _medic, _checkdegrees, _directioncount];
						if (_medic getVariable ["ReviveInProgress",0] == 2 && _checkdegrees == false && _directioncount > 0) then {
							// if (_medic getVariable ["ReviveInProgress",0] == 2 && _checkdegrees == false) then {
							diag_log format ["%1 | nnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnn DIRECTION MEDIC TO REVIVEPOS ====== count %2 =========================", name _medic, _directioncount];
							if (Lifeline_Revive_debug) then {
								if (Lifeline_debug_soundalert) then {playsound "forcedirection"};
								if (Lifeline_hintsilent) then {hint format ["%1 FORCE DIRECTION", name _medic]};
							};
							_direction = _medic getDir _incap;
							_medic setDir _direction;diag_log format ["%1 | [0938] nnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnn FORCE DIRECTION ===============================", name _medic];
							// _directioncount = _directioncount - 1;
						};
					};
				}; //if (_medic distance2D _revivePos < 10) then { 

				//DEBUG
				// This is a tiny teleport if medic is not on revive position.
				/* if (_teleptrig == false && _medic distance2D _revivePos < 10 && _medic distance2D _revivePos > 0.2 && _medic getVariable ["ReviveInProgress",0] == 2) then { 
					if (!isNil "_telepcheck") then {
						_teleptrig == true;
						[_medic,_revivePos,_telepcheck] spawn {
							params ["_medic","_revivePos","_telepcheck"];
							sleep 2;
							if (_medic distance2D _revivePos < 10 && _medic distance2D _revivePos > 0.2 && _medic getVariable ["ReviveInProgress",0] == 2) then { 
								_medic setPos _telepcheck; 
								diag_log format ["%1 | nnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnn TELEPORT MEDIC TO REVIVEPOS ===============================", name _medic];
							};
						}
					};
				};	 */			
				// This is a tiny teleport if medic is not on revive position. METHOD 2
				/* if (_teleptrig == false && speed _medic < 0.1 && _medic distance2D _incap > 2 && _medic distance2D _incap < 6 && _medic getVariable ["ReviveInProgress",0] == 1) then { 
					if (!isNil "_telepcheck") then {
						_teleptrig == true;
						[_incap,_medic,_revivePos,_telepcheck] spawn {
							params ["_incap","_medic","_revivePos","_telepcheck"];
							sleep 2;
							if (speed _medic < 0.1 && _medic distance2D _incap > 2 && _medic distance2D _incap < 6 && _medic getVariable ["ReviveInProgress",0] == 1) then { 
								_medic setPos _telepcheck; 
								diag_log format ["%1 | nnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnn TELEPORT MEDIC TO REVIVEPOS METHOD 2 ===============================", name _medic];
							};
						}
					};
				}; */
				//ENDDEBUG

				sleep 2;
				_medicpos2 = getPos _medic;

				//DEBUG
				if (Lifeline_Revive_debug && Lifeline_yellowmarker) then {
					_purplmark = _medic getVariable ["purplmarker1", nil]; 
					if (!isNil "_purplmark") then {deleteVehicle _purplmark};
					_cyanmark = _incap getVariable ["cyanmarker1", nil]; 
					if (!isNil "_cyanmark") then {deleteVehicle _cyanmark};	
				};
				//ENDDEBUG				
			}; // end WHILE

			_incap setVariable ["Lifeline_RevPosX",nil,true];
			if (Lifeline_Revive_debug && Lifeline_yellowmarker) then {
				_greenmark = _medic getVariable ["_greenmark1", nil]; 
				if (!isNil "_greenmark") then {deleteVehicle _greenmark};				
				_greenmark = _medic getVariable ["_greenmark2", nil]; 
				if (!isNil "_greenmark") then {deleteVehicle _greenmark};
			};
			
		};
		

		// [center, minDist, maxDist, objDist, waterMode, maxGrad, shoreMode, blacklistPos, defaultPos] call BIS_fnc_findSafePos

	}; // END IF (_medic getVariable ["Lifeline_ExitTravel", false] == false && _exit == false) then {


	if !(_exit) then {
		_linenumber = "0817";
		_exit = [_incap,_medic,"EXIT REVIVE TRAVEL [root]",_linenumber] call Lifeline_exit_travel;
	};

	if (Lifeline_Revive_debug) then {
		if (_medic getVariable ["Lifeline_ExitTravel", false] == false && _exit == false) then {
				diag_log format ["|%3|%4| ", _incap, _medic,name _incap,name _medic];
				diag_log format ["|%1|%2|++++ YELLOW MARKER ++++ [0632] '", name _incap,name _medic];
				diag_log format ["|%3|%4| ", _incap, _medic,name _incap,name _medic];
				if (Lifeline_yellowmarker) then {
					_yelmark = createVehicle ["Sign_Arrow_Yellow_F", _revivePos,[],0,"can_collide"];
					_incap setVariable ["ymarker1", _yelmark, true]; 	
				};
		} else {
				diag_log format ["|%3|%4| ", _incap, _medic,name _incap,name _medic];
				diag_log format ["|%1|%2|++++ BYPASS YELLOW MARKER ++++ [0640] '", name _incap,name _medic];
				diag_log format ["|%3|%4| ", _incap, _medic,name _incap,name _medic];	
		};
	};

	_waypoint = [];

						

	if (alive _medic && alive _incap && (lifestate _incap == "INCAPACITATED") && (lifestate _medic != "INCAPACITATED") && _medic getVariable ["Lifeline_ExitTravel", false] == false && _exit == false) then {
			//DEBUG
			// update this later - hack to stop medic using binoculars (dowatch)
			// [_medic, (binocular _medic)] remoteExec ["removeWeapon", _medic];
			//ENDDEBUG
			
			_revivePos = [_incap, _medic, _distnextto] call Lifeline_POSnexttoincap;	
			
			
			_teamcolour = assignedTeam _medic;// joinSilent deletes Teamcolour, so workaround here.

			// good for getting confused in buildings - confirm later
			[_medic] joinSilent _medic; // THIS AFFECTS SPEED
					
			_medic assignTeam _teamcolour;// joinSilent deletes Teamcolour, so workaround here.
			
			if (_shortorigdist6) then {
				_medic limitSpeed 2;
				// group _medic setSpeedMode "LIMITED";
				// playsound "testC";
				diag_log format ["%1 ===================== LIMITED SPEED due to _shortorigdist6", name _medic];
			};

			
			//DEBUG
			// _medic domove position _medic;
			// _medic domove _revivePos;
			// _medic moveto _revivePos;
			//ENDDEBUG
			//remoteExec version. Even though documentation says doMove and MoveTo is global, was getting errors, so remoteExec seemed to fix it. 
				
			[_medic, position _medic] remoteExec ["moveTo", _medic];
			[_medic, position _medic] remoteExec ["doMove", _medic];
			[_medic, _revivePos] remoteExec ["moveTo", _medic];
			[_medic, _revivePos] remoteExec ["doMove", _medic];
			diag_log format ["%1 | [1085] nnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnn DOMOVE MEDIC TO REVIVEPOS ========== DIST: %2 =====================", name _medic, _medic distance2D _incap];
	
			//DEBUG
			// good for getting confused in buildings - confirm later
			/* if (_medic distance2D _incap >8) then {
				for "_i" from 0 to (count waypoints _goup - 1) do {deleteWaypoint [_goup, 0]};
				group _medic setSpeedMode "NORMAL";
				_waypoint = (group _medic) addWaypoint [_revivePos, 0];
				if (_shortorigdist == false) then {
					_waypoint setWaypointSpeed "FULL";
				} else {
					_waypoint setWaypointSpeed "LIMITED"
				};
				_waypoint setWaypointType "MOVE";
			}; */
			//ENDDEBUG

			_linenumber = "0868";
			_exit = [_incap,_medic,"EXIT REVIVE TRAVEL",_linenumber] call Lifeline_exit_travel;
			if (_exit == true) exitWIth {diag_log format ["%1 | %2 | !!!!! exitWith Lifeline_exit_travel [%3]",name _incap,name _medic,_linenumber];};
			
			// diag_log format ["%1 | %2 \%5\====// WAITUNTIL REVIVE JOURNEY [0900] //==== AssignedMedic: %3 _exit: %4 DIST: %6 SPEED: %7", name _incap, name _medic, name (_incap getVariable ["Lifeline_AssignedMedic",[]] select 0), _exit,time,_medic distance2D _incap,_medic distance2D _incap, speed _medic];
			waitUntil {
				sleep 0.1;
				(_medic distance2D _revivePos <=100 || !alive _medic || !alive _incap || (_incap getvariable ["LifelinePairTimeOut",0] == 0) || lifestate _incap != "INCAPACITATED" || _exit == true || _shortorigdist == true
				// || (_incap getVariable ["Lifeline_AssignedMedic",[]]) isEqualTo []
				|| lifestate _medic == "INCAPACITATED"
				|| _medic getVariable ["Lifeline_ExitTravel", false] == true
				)
			};

			_linenumber = "0882";
			_exit = [_incap,_medic,"EXIT REVIVE TRAVEL",_linenumber] call Lifeline_exit_travel;
			if (_exit == true) exitWIth {diag_log format ["%1 | %2 | !!!!! exitWith Lifeline_exit_travel [%3]",name _incap,name _medic,_linenumber];};

			if (_medic distance2D _revivePos > 97 && Lifeline_radio && lifeState _medic != "INCAPACITATED" && lifeState _incap == "INCAPACITATED" && _exit == false 
			&& _medic getvariable ["ReviveInProgress",0] == 1 && _incap getvariable ["ReviveInProgress",0] == 3 && _incap getvariable ["LifelinePairTimeOut",0] !=0 
			) then {
					if (isPlayer _incap) then {
					[_incap, [_voice+"_100m1", 50, 1, true]] remoteExec ["say3D", _incap];
					};
					diag_log format ["| %1 | %2 | 1475 kkkkkkkkkkkkk SAY3D 100M | voice: %3", name _incap, name _medic, _voice];
			};	
			diag_log format ["%1 | %2 \%5\====// [1090] WAITUNTIL REVIVE JOURNEY 100m sample //==== AssignedMedic: %3 _exit: %4 DIST: %6 SPEED: %7", name _incap, name _medic, name (_incap getVariable ["Lifeline_AssignedMedic",[]] select 0), _exit,time,_medic distance2D _incap,_medic distance2D _incap, speed _medic];			

			_linenumber = "0896";
			_exit = [_incap,_medic,"EXIT REVIVE TRAVEL",_linenumber] call Lifeline_exit_travel;
			if (_exit == true) exitWIth {diag_log format ["%1 | %2 | !!!!! exitWith Lifeline_exit_travel [%3]",name _incap,name _medic,_linenumber];};

			waitUntil {
				sleep 0.1;
				(_medic distance2D _revivePos <=50 || !alive _medic || !alive _incap || (_incap getvariable ["LifelinePairTimeOut",0] == 0) || lifestate _incap != "INCAPACITATED" || _exit == true || _shortorigdist == true
				// || (_incap getVariable ["Lifeline_AssignedMedic",[]]) isEqualTo []
				|| lifestate _medic == "INCAPACITATED"
				|| _medic getVariable ["Lifeline_ExitTravel", false] == true
				)
			};

			_linenumber = "0909";
			_exit = [_incap,_medic,"EXIT REVIVE TRAVEL",_linenumber] call Lifeline_exit_travel;
			if (_exit == true) exitWIth {diag_log format ["%1 | %2 | !!!!! exitWith Lifeline_exit_travel [%3]",name _incap,name _medic,_linenumber];};

			if (_medic distance2D _revivePos > 47 && Lifeline_radio && lifeState _medic != "INCAPACITATED" && lifeState _incap == "INCAPACITATED" && _exit == false 
				&& _medic getvariable ["ReviveInProgress",0] == 1 && _incap getvariable ["ReviveInProgress",0] == 3 && _incap getvariable ["LifelinePairTimeOut",0] !=0 
			) then {
					if (isPlayer _incap) then {
						[_incap, [_voice+"_50m1", 50, 1, true]] remoteExec ["say3D", _incap];
					};
					diag_log format ["| %1 | %2 | 1475 kkkkkkkkkkkkk SAY3D 50M | voice: %3", name _incap, name _medic, _voice];
			};		
			diag_log format ["%1 | %2 \%5\====// [1117] WAITUNTIL REVIVE JOURNEY 50m sample //==== AssignedMedic: %3 _exit: %4 DIST: %6 SPEED: %7", name _incap, name _medic, name (_incap getVariable ["Lifeline_AssignedMedic",[]] select 0), _exit,time,_medic distance2D _incap, speed _medic];

			_linenumber = "0923";
			_exit = [_incap,_medic,"EXIT REVIVE TRAVEL",_linenumber] call Lifeline_exit_travel;
			if (_exit == true) exitWIth {diag_log format ["%1 | %2 | !!!!! exitWith Lifeline_exit_travel [%3]",name _incap,name _medic,_linenumber];};
			
			_revivePosX = _incap getVariable ["Lifeline_RevPosX",_revivePos];
			_revivePos = _revivePosX;


			// DISTANCE RADIUS <=10 || 	// DISTANCE RADIUS <=15

			// _revivePos = [_incap, _medic, _distnextto] call Lifeline_POSnexttoincap;	
			// diag_log format ["%1 | %2 \%5\====// WAITUNTIL REVIVE JOURNEY [0955] //==== AssignedMedic: %3 _exit: %4 DIST: %6 SPEED: %7", name _incap, name _medic, name (_incap getVariable ["Lifeline_AssignedMedic",[]] select 0), _exit,time,_medic distance2D _incap, speed _medic];
			waitUntil {
				sleep 0.1;
				//DEBUG
				// (_medic distance2D _revivePos <=10 || !alive _medic || !alive _incap || (_incap getvariable ["LifelinePairTimeOut",0] == 0) || lifestate _incap != "INCAPACITATED" || _exit == true
				// ((_medic distance2D _revivePos <=10 && speed _medic < 17) || (_medic distance2D _revivePos <=15 && speed _medic >= 17) || !alive _medic || !alive _incap || (_incap getvariable ["LifelinePairTimeOut",0] == 0) || lifestate _incap != "INCAPACITATED" || _exit == true
				//ENDDEBUG
				((_medic distance2D _revivePos <=10 && speed _medic < 14) || (_medic distance2D _revivePos <=15 && speed _medic >= 14) || !alive _medic || !alive _incap || (_incap getvariable ["LifelinePairTimeOut",0] == 0) || lifestate _incap != "INCAPACITATED" || _exit == true || _shortorigdist == true
				// ((_medic distance2D _revivePos <=10 && speed _medic < 17) || (_medic distance2D _revivePos <=15 && speed _medic > 17) || (_shortorigdist == true) || !alive _medic || !alive _incap || (_incap getvariable ["LifelinePairTimeOut",0] == 0) || lifestate _incap != "INCAPACITATED" || _exit == true
				// || (_incap getVariable ["Lifeline_AssignedMedic",[]]) isEqualTo []
				|| lifestate _medic == "INCAPACITATED"
				|| _medic getVariable ["Lifeline_ExitTravel", false] == true
				)
			};
			
			diag_log format ["%1 | %2 \%5\====// [1145] WAITUNTIL REVIVE JOURNEY [DISTANCE RADIUS <=10 | DISTANCE RADIUS <=15] //==== AssignedMedic: %3 _exit: %4 DIST: %6 SPEED: %7", name _incap, name _medic, name (_incap getVariable ["Lifeline_AssignedMedic",[]] select 0), _exit,time,_medic distance2D _incap, speed _medic];			
			//DEBUG
		/* 	// randomized greeting as medic approaches incap
			if (lifestate _medic != "INCAPACITATED" && (alive _medic) && lifestate _incap == "INCAPACITATED" && (alive _incap) && (_incap getvariable ["LifelinePairTimeOut",0] != 0)) then {
					_pairtimebaby = "LifelinePairTimeOut";
					_incap setVariable [_pairtimebaby, (_incap getvariable _pairtimebaby) + 5, true]; 
					_medic setVariable [_pairtimebaby, (_medic getvariable _pairtimebaby) + 5, true]; 
				if (Lifeline_MedicComments) then {
					_A = str ([1, 3] call BIS_fnc_randomInt);
					_B = str ([1, 6] call BIS_fnc_randomInt);
					if (lifestate _medic != "INCAPACITATED" && (alive _medic)) then {[_medic, [_voice+"_greetA"+_A, 20, 1, true]] remoteExec ["say3D", 0]};
					if (lifestate _medic != "INCAPACITATED" && (alive _medic)) then {[_medic, [_voice+"_greetB"+_B, 20, 1, true]] remoteExec ["say3D", 0]};		
					diag_log format ["| %1 | %2 | [0756] kkkkkkkkkkkkk SAY3D GREETING | voice: %3", name _incap, name _medic, _voice];
				};
			}; */
			//ENDDEBUG

			_linenumber = "0953";
			_exit = [_incap,_medic,"EXIT REVIVE TRAVEL",_linenumber] call Lifeline_exit_travel;
			if (_exit == true) exitWIth {diag_log format ["%1 | %2 | !!!!! exitWith Lifeline_exit_travel [%3]",name _incap,name _medic,_linenumber];};

			// _revivePos = [_incap, _medic, _distnextto] call Lifeline_POSnexttoincap;	
			_revivePosX = _incap getVariable ["Lifeline_RevPosX",_revivePos];
			_revivePos = _revivePosX;


			// DISTANCE RADIUS <=8 || 	// DISTANCE RADIUS <=15

			// diag_log format ["%1 | %2 \%5\====// WAITUNTIL REVIVE JOURNEY [0986] //==== AssignedMedic: %3 _exit: %4 DIST: %6 SPEED: %7", name _incap, name _medic, name (_incap getVariable ["Lifeline_AssignedMedic",[]] select 0), _exit,time,_medic distance2D _incap, speed _medic];
			waitUntil {
				sleep 0.1;
				//DEBUG
				// ((_medic distance2D _revivePos <= 6) || !alive _medic || !alive _incap || (_incap getvariable ["LifelinePairTimeOut",0] == 0) || lifestate _incap != "INCAPACITATED")
				// ((_medic distance2D _revivePos <= 6) || !alive _medic || !alive _incap || (_incap getvariable ["LifelinePairTimeOut",0] == 0) || lifestate _incap != "INCAPACITATED" || _exit == true
				// (((_medic distance2D _incap <=6 && speed _medic < 17) || (_medic distance2D _incap <=15 && speed _medic >= 17)) || !alive _medic || !alive _incap || (_incap getvariable ["LifelinePairTimeOut",0] == 0) || lifestate _incap != "INCAPACITATED" || _exit == true
				//ENDDEBUG
				(((_medic distance2D _incap <=8 && speed _medic < 14) || (_medic distance2D _incap <=15 && speed _medic >= 14)) || !alive _medic || !alive _incap || (_incap getvariable ["LifelinePairTimeOut",0] == 0) || lifestate _incap != "INCAPACITATED" || _exit == true  || _shortorigdist == true
				// (((_medic distance2D _incap <=6 && speed _medic < 17) || (_medic distance2D _incap <=15 && speed _medic > 17)) || (_shortorigdist == true) || !alive _medic || !alive _incap || (_incap getvariable ["LifelinePairTimeOut",0] == 0) || lifestate _incap != "INCAPACITATED" || _exit == true
				// || (_incap getVariable ["Lifeline_AssignedMedic",[]]) isEqualTo []
				|| lifestate _medic == "INCAPACITATED"
				|| _medic getVariable ["Lifeline_ExitTravel", false] == true		
				)
			};
			diag_log format ["%1 | %2 \%5\====// [1188] WAITUNTIL REVIVE JOURNEY [DISTANCE RADIUS <=8 | DISTANCE RADIUS <=15] //==== AssignedMedic: %3 _exit: %4 DIST: %6 SPEED: %7", name _incap, name _medic, name (_incap getVariable ["Lifeline_AssignedMedic",[]] select 0), _exit,time,_medic distance2D _incap, speed _medic];			


			if (lifestate _medic != "INCAPACITATED" && (alive _medic) && lifestate _incap == "INCAPACITATED" && (alive _incap) && (_incap getvariable ["LifelinePairTimeOut",0] != 0)) then {
				_pairtimebaby = "LifelinePairTimeOut";
				_incap setVariable [_pairtimebaby, (_incap getvariable _pairtimebaby) + 5, true]; 
				_medic setVariable [_pairtimebaby, (_medic getvariable _pairtimebaby) + 5, true];
				
				//DEBUG				
				// _medic allowDamage dmg_trig;diag_log format ["%1 | [0983][Lifeline_Functions.sqf] ALLOWDAMAGE SET: %2", name _medic, isDamageAllowed _medic];
				// _medic setCaptive cptv_trig;diag_log format ["%1 | [1023][Lifeline_Functions.sqf] !!!!!!!!! change var setCaptive = %2 !!!!!!!!!!!!!", name _medic, cptv_trig];
				// [_medic,dmg_trig] remoteExec ["allowDamage",_medic]; diag_log format ["%1 | [0781][Lifeline_ReviveEngine.sqf] ALLOWDAMAGE SET: %2", name _medic, isDamageAllowed _medic];
				// [_medic,cptv_trig] remoteExec ["setCaptive",_medic];diag_log format ["%1 | [1023][Lifeline_Functions.sqf] !!!!!!!!! change var setCaptive = %2 !!!!!!!!!!!!!", name _medic, cptv_trig];
				//ENDDEBUG

				if (captive _medic) then {_medic setVariable ["Lifeline_Captive",true,true]} else {_medic setVariable ["Lifeline_Captive",false,true]}; diag_log format ["%1 | [1177]==== UNCONC captive medic: %2 [_Global.sqf]", name _medic, captive _medic];//2025

				if (Lifeline_RevProtect != 3) then {
					if !(local _medic) then {
						[_medic,dmg_trig] remoteExec ["allowDamage",_medic];diag_log format ["%1 | [1020][Lifeline_Functions.sqf] ALLOWDAMAGE SET: %2", name _medic, dmg_trig];
						[_medic,cptv_trig] remoteExec ["setCaptive",_medic];diag_log format ["%1 | [1021][Lifeline_Functions.sqf] !!!!!!!!! change var setCaptive = %2 !!!!!!!!!!!!!", name _medic,cptv_trig];
					} else {
						_medic allowDamage dmg_trig;diag_log format ["%1 | [1024][Lifeline_Functions.sqf] ALLOWDAMAGE SET: %2", name _medic, dmg_trig];
						_medic setCaptive cptv_trig;diag_log format ["%1 | [1023][Lifeline_Functions.sqf] !!!!!!!!! change var setCaptive = %2 !!!!!!!!!!!!!", name _medic, cptv_trig];
					};
				};							
			};

			_linenumber = "0978";
			_exit = [_incap,_medic,"EXIT REVIVE TRAVEL",_linenumber] call Lifeline_exit_travel;
			if (_exit == true) exitWIth {diag_log format ["%1 | %2 | !!!!! exitWith Lifeline_exit_travel [%3]",name _incap, name _medic,_linenumber];};

			_unblockwtime = time;

			// diag_log format ["%1 | %2 \%5\====// WAITUNTIL REVIVE JOURNEY [1014] //==== AssignedMedic: %3 _exit: %4 DIST: %6 SPEED: %7", name _incap, name _medic, name (_incap getVariable ["Lifeline_AssignedMedic",[]] select 0), _exit,time,_medic distance2D _incap, speed _medic];
			
			// _revivePos = [_incap, _medic, _distnextto] call Lifeline_POSnexttoincap;	
			// some medics were getting stuck waiting for this. Added a timer to unblock.
			_revivePosX = _incap getVariable ["Lifeline_RevPosX",_revivePos];
			_revivePos = _revivePosX;


			// DISTANCE RADIUS <=6 || 	// DISTANCE RADIUS <=8

			waitUntil {
				//DEBUG
				// if (!(speedmode group _medic == "Limited") && _medic distance2D _incap <=6) then {group _medic setSpeedMode "Limited"};
				// if (!(speedmode group _medic == "Limited") && ((_medic distance2D _incap <=6 && speed _medic < 17) || (_medic distance2D _incap <=10 && speed _medic > 17))) then {group _medic setSpeedMode "Limited"}; //TEMP OFF
				//ENDDEBUG
				_medic domove _revivePos;
				sleep 0.7;
				//DEBUG
				// ((_medic distance2D _revivePos <=2.5 && speed _medic < 17) || (_medic distance2D _revivePos <=5 && speed _medic > 17) || !alive _medic || !alive _incap || (time - _unblockwtime > 8) || (_incap getvariable ["LifelinePairTimeOut",0] == 0) || lifestate _incap != "INCAPACITATED" || _exit == true
				// ((_medic distance2D _revivePos <=2.5 && speed _medic < 17) || (_medic distance2D _revivePos <= SelectRandom [6,7,8] && speed _medic >= 17) || !alive _medic || !alive _incap || (time - _unblockwtime > 8) || (_incap getvariable ["LifelinePairTimeOut",0] == 0) || lifestate _incap != "INCAPACITATED" || _exit == true
				// ((_medic distance2D _revivePos <=2.5 && speed _medic < 15) || (_medic distance2D _revivePos <= SelectRandom [6,7,8] && speed _medic >= 15) || !alive _medic || !alive _incap || (time - _unblockwtime > 8) || (_incap getvariable ["LifelinePairTimeOut",0] == 0) || lifestate _incap != "INCAPACITATED" || _exit == true
				//ENDDEBUG
				// ((_medic distance2D _revivePos <=2.5 && speed _medic < 14) || (_medic distance2D _revivePos <= 8 && speed _medic >= 14) || !alive _medic || !alive _incap || (time - _unblockwtime > 8) || (_incap getvariable ["LifelinePairTimeOut",0] == 0) || lifestate _incap != "INCAPACITATED" || _exit == true || _shortorigdist == true
				((_medic distance2D _revivePos <=6 && speed _medic < 14) || (_medic distance2D _revivePos <= 8 && speed _medic >= 14) || !alive _medic || !alive _incap || (time - _unblockwtime > 8) || (_incap getvariable ["LifelinePairTimeOut",0] == 0) || lifestate _incap != "INCAPACITATED" || _exit == true || _shortorigdist == true
				//DEBUG
				// ((_medic distance2D _revivePos <=2.5 && speed _medic < 17) || (_medic distance2D _revivePos <= SelectRandom [6,7,8] && speed _medic > 17) || (_shortorigdist == true) || !alive _medic || !alive _incap || (time - _unblockwtime > 8) || (_incap getvariable ["LifelinePairTimeOut",0] == 0) || lifestate _incap != "INCAPACITATED" || _exit == true
				// ((_medic distance2D _revivePos <=2.5 && speed _medic < 17) || (_medic distance2D _revivePos <=12 && speed _medic > 17) || !alive _medic || !alive _incap || (time - _unblockwtime > 8) || (_incap getvariable ["LifelinePairTimeOut",0] == 0) || lifestate _incap != "INCAPACITATED" || _exit == true
				//ENDDEBUG
				// || (_incap getVariable ["Lifeline_AssignedMedic",[]]) isEqualTo []
				|| lifestate _medic == "INCAPACITATED"
				|| _medic getVariable ["Lifeline_ExitTravel", false] == true
				) 
			};			
			
			diag_log format ["%1 | %2 \%5\====// [1252] WAITUNTIL REVIVE JOURNEY [DISTANCE RADIUS <=6 | DISTANCE RADIUS <=8] //==== AssignedMedic: %3 _exit: %4 DIST: %6 SPEED: %7 unblockwtime: %8", name _incap, name _medic, name (_incap getVariable ["Lifeline_AssignedMedic",[]] select 0), _exit,time,_medic distance2D _incap, speed _medic, time - _unblockwtime];

			//DEBUG
			//slow down to stop overshoot.. This should not be needed if I get the distance right for hitting the deck. This is a temp fix.
			/* if (speed _medic >= 15) then {
				_medic limitSpeed 5;	
				diag_log format ["%1 | %2 nnnnnnnnnnnnnnnnnnnnnnnnnnnnn SLOW DOWN nnnnnnnnnnnnnnnnnnnnnnnnnn", name _incap, name _medic];
			}; */
			//ENDDEBUG
			
			// group _medic setspeedMode "FULL";

			if (lifestate _medic != "INCAPACITATED" && (alive _medic) && lifestate _incap == "INCAPACITATED" && (alive _incap) && (_incap getvariable ["LifelinePairTimeOut",0] != 0)) then {
				_pairtimebaby = "LifelinePairTimeOut";
				_incap setVariable [_pairtimebaby, (_incap getvariable _pairtimebaby) + 5, true]; 
				_medic setVariable [_pairtimebaby, (_medic getvariable _pairtimebaby) + 5, true]; 
			};

			// _revivePos = [_incap, _medic, _distnextto] call Lifeline_POSnexttoincap;
			_revivePosX = _incap getVariable ["Lifeline_RevPosX",_revivePos];
			_revivePos = _revivePosX;			

			_animMove = "";
			_animStop = "";
			_dist = _medic distance _revivePos;
			_timer = time;
			_newrevpos = nil; //distance of yellow marker from incap
			_posture = nil;

			if (!isnull _EnemyCloseBy) then {
				// commando crawl
				// _revivePos = [_incap, _medic, 1.9] call Lifeline_POSnexttoincap;
				_animMove = "amovppnemsprslowwrfldf"; // move
				_animStop = "amovppnemstpsraswrfldnon"; // stop
				_newrevpos = [_incap, _medic, 0.5] call Lifeline_POSnexttoincap;
				_posture = "DOWN";
			} else {
				// crouch
				// _revivePos = [_incap, _medic, 0.9] call Lifeline_POSnexttoincap;
				_animMove = "amovpknlmwlkslowwrfldf"; //"amovpknlmwlkslowwrfldf"; "amovpknlmrunslowwrfldf" "amovpercmrunsraswrfldf"
				_animStop = "amovpknlmstpslowwrfldnon";
				// _newrevpos = _incap;
				_newrevpos = [_incap, _medic, 0.1] call Lifeline_POSnexttoincap;				
				_posture = "MIDDLE";
			};
	
			//DEBUG
			//ADDED DUE TO _revivePos = 
			/* if (Lifeline_yellowmarker) then {
				_incap call Lifeline_delYelMark;
				_yelmark = createVehicle ["Sign_Arrow_Yellow_F", _revivePos,[],0,"can_collide"];
				_incap setVariable ["ymarker1", _yelmark, true]; 	
			}; */
			/* _maxD = _revivePos distance2D _incap;
			_medic disableAI "ANIM";
			_maxIncapD = _medic distance2D _incap;

			while {(_medic distance2D _incap) > _maxD && (_medic distance _revivePos) > 0.1 && alive _medic && lifestate _incap == "incapacitated"} do {
				if (Lifeline_Revive_debug) then {hintSilent format ["MdistI: %1\n_MdistRpos: %2", (_medic distance2D _incap), (_medic distance2D _revivePos)]};
				_medic setdir (_medic getDir (position _incap));diag_log format ["%1 [1262] uuuuuuuuuuuuuuuuuuu ADJUST DIRECTION uuuuuuuuuuuuu", name _medic];
				[_medic, _animMove] remoteexec ["playMoveNow",0];
				sleep 1;
				// Stop overshoot
				if (_medic distance _incap >= _maxIncapD) exitWith {
					[_medic, _animStop] remoteExec ["playMoveNow",0];
					diag_log format ["%1 nnnnnnnnnnnnnn OVERSHOOT nnnnnnnnnnnnnnn", name _medic];
					dostop _medic;
					_medic doTarget _incap;
				};
			}; */
			//ENDDEBUG

			// GREEN MARKER BEFORE ANIM CHANGE
			if (Lifeline_Revive_debug && Lifeline_yellowmarker) then {
				_greenmark = createVehicle ["Sign_Arrow_green_F", getPos _medic,[],0,"can_collide"];
				_medic setVariable ["_greenmark1", _greenmark, true]; 
			};
			
			diag_log format ["%1 | %2 \%5\====// [1330] GREEN MARKER BEFORE ANIM CHANGE //==== AssignedMedic: %3 _exit: %4 DIST: %6", name _incap, name _medic, name (_incap getVariable ["Lifeline_AssignedMedic",[]] select 0), _exit,time,_medic distance2D _incap];


			//this is vital and must be kept, otherwise anim stands up
			if (alive _medic && !(lifestate _medic == "INCAPACITATED")) then {
			
				_medic lookAt _newrevpos;diag_log format ["%1 [1287] uuuuuuuuuuuuuuuuuuu LOOKAT DIRECTION uuuuuuuuuuuuu", name _medic];
				// _medic doWatch _newrevpos;diag_log format ["%1 [1287] uuuuuuuuuuuuuuuuuuu DOWATCH DIRECTION uuuuuuuuuuuuu", name _medic];
				_timechc = time;
				diag_log format ["%1 [1292] call Lifeline_checkdegrees  target %3 current %2 ", name _medic, getDir _medic, _medic getDir _newrevpos];
				_checkdegrees = [_newrevpos,_medic,15] call Lifeline_checkdegrees;
				if (_checkdegrees == false) then {				
					waitUntil {						
						_medic lookAt _newrevpos;
						_checkdegrees = [_newrevpos,_medic,30] call Lifeline_checkdegrees;
						if (time - _timechc > 5) then {
							_medic lookAt _newrevpos;
							_medic disableAI "ANIM"; 
							_medic setDir (_medic getDir _newrevpos);diag_log format ["%1 | [1361] nnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnn FORCE DIRECTION ===============================", name _medic];
							if (Lifeline_debug_soundalert && Lifeline_Revive_debug) then {playsound "forcedirection"};
							if (Lifeline_hintsilent && Lifeline_Revive_debug) then {hint format ["%1 FORCE DIR MEDIC dist: %2", name _medic, _medic distance2d _newrevpos]};
						};
						(_checkdegrees == true)				
						// (_checkdegrees == true || time - _timechc > 5)				
					};
					diag_log format ["%1 [1296] uuuuuuuuuuuuuuuuuuu LOOKAT DIRECTION WAITUNTIL FINISH uuuuuuuuuuuuu", name _medic];
				};
				if (Lifeline_travel_meth == 0) then {
					_medic disableAI "ANIM"; //TEMP
					_medic playMoveNow _animMove;//diag_log format ["%1 [1295] uuuuuuuuuuuuuuuuuuu PLAYMOVENOW uuuuuuuuuuuuu", name _medic];
					[_medic,_animMove] remoteExec ["playMoveNow",_medic];
				};
				if (Lifeline_travel_meth == 1) then {
					_medic setUnitPos _posture; //posture
					//DEBUG
					// [_medic, position _medic] remoteExec ["doMove", _medic];
					// [_medic, _newrevpos] remoteExec ["moveTo", _medic];
					// [_medic, _newrevpos] remoteExec ["doMove", _medic];					
					// [_medic, position _incap] remoteExec ["moveTo", _medic];
					// [_medic, position _incap] remoteExec ["doMove", _medic];
					//ENDDEBUG
				};				
			};

			_rposDist = _revivePos distance2D _incap;

			_linenumber = "1031";
			_exit = [_incap,_medic,"EXIT REVIVE TRAVEL",_linenumber] call Lifeline_exit_travel;
			if (_exit == true) exitWIth {diag_log format ["%1 | %2 | !!!!! exitWith Lifeline_exit_travel [%3]",name _incap,name _medic,_linenumber];};			
			
			// diag_log format ["%1 | %2 \%5\====// WAITUNTIL REVIVE JOURNEY [1065] //==== AssignedMedic: %3 _exit: %4 DIST: %6", name _incap, name _medic, name (_incap getVariable ["Lifeline_AssignedMedic",[]] select 0), _exit,time,_medic distance2D _incap];
			_unblockwtime = time;
			_selfheal_trig = false; //one time trigger to stop repeated spamming of the check to see if self-revive is active, in the "waitUntil" below
			_trig1 = false;
			_diag_texty2 = ""; //only for diag_log

			//check its right direction 
			// [_medic,_newrevpos] call Lifeline_align_dir;

			// DISTANCE RADIUS <=4

			waitUntil {
				// sleep 0.1;
				sleep 0.2;
				//DEBUG
				_diag_texty = format ["%1 | %2 [waituntil 1414] >>>>>>>>>>>>>>>>>>>>>>>> MEDIC SPEED %3 DIST %5 Lifeline_selfheal_progss %4", name _incap, name _medic, speed _medic, _medic getVariable ["Lifeline_selfheal_progss",false],_medic distance2D _newrevpos];
				sleep 1;if (_diag_texty != _diag_texty2) then {diag_log _diag_texty;};
				_diag_texty2 = format ["%1 | %2 [waituntil 1414] >>>>>>>>>>>>>>>>>>>>>>>> MEDIC SPEED %3 DIST %5 Lifeline_selfheal_progss %4", name _incap, name _medic, speed _medic, _medic getVariable ["Lifeline_selfheal_progss",false],_medic distance2D _newrevpos];
				if (speed _medic == 0 && Lifeline_Revive_debug) then {
					[_medic,_newrevpos,_trig1] spawn {
						params ["_medic","_newrevpos","_trig1"];
						sleep 5;
						if (speed _medic == 0) then {
							diag_log format ["%1 | [1451 RADIUS <=4] >>>>>>>>>>>>>>>>>>>>>>>> MEDIC SPEED ZERO | DIST %2 selfheal_progss %3 trig1 %4 >>>>>>>>>>>>>>>>", name _medic, _medic distance2D _newrevpos, _medic getVariable ["Lifeline_selfheal_progss",false], _trig1];
							if (Lifeline_debug_soundalert) then {["speediszero"] remoteExec ["playSound",2]};
						};
					};				
				};
				//ENDDEBUG
				
				if (speed _medic == 0 && _medic getVariable ["Lifeline_selfheal_progss",false] == false && _medic distance2D _newrevpos > 4 && _medic distance2D _newrevpos < 10 && _medic getVariable ["ReviveInProgress",0] == 1 && _trig1 == false) then { 
					_trig1 = true;
					[_incap,_medic,_newrevpos,_animMove] spawn {
						params ["_incap","_medic","_newrevpos","_animMove"];
						sleep 2;
						if (speed _medic == 0 && _medic getVariable ["Lifeline_selfheal_progss",false] == false && _medic distance2D _newrevpos > 4 && _medic distance2D _newrevpos < 10 && _medic getVariable ["ReviveInProgress",0] == 1) then { 
							diag_log format ["%1 | [1407] nnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnn SETDIR MEDIC dist: %2 ===============================", name _medic, _medic distance2d _newrevpos];
							// _medic setPos _newrevpos;
							_medic disableAI "ANIM";
							_medic setDir (_medic getDir _incap);diag_log format ["%1 | [1436] nnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnn FORCE DIRECTION ===============================", name _medic];
							if (Lifeline_debug_soundalert && Lifeline_Revive_debug) then {playsound "forcedirection"};
							if (Lifeline_hintsilent && Lifeline_Revive_debug) then {hint format ["%1 FORCE DIR MEDIC dist: %2", name _medic, _medic distance2d _newrevpos]};
							[_medic,_animMove] remoteExec ["playMoveNow",_medic];diag_log format ["%1 [1411] uuuuuuuuuuuuuuuuuuu PLAYMOVENOW uuuuuuuuuuuuu", name _medic];
							_trig1 = false;
						};
					};
				};

				//DEBUG				
				//this unblocks medic stuck and not moving
				/* if (speed _medic == 0 && _medic getVariable ["Lifeline_selfheal_progss",false] == false && _medic distance2D _newrevpos > 4 && _medic distance2D _newrevpos < 10 && _medic getVariable ["ReviveInProgress",0] == 1) then { 
					[_medic,_newrevpos] spawn {
						params ["_medic","_newrevpos"];
						sleep 3;
						if (speed _medic == 0 && _medic getVariable ["Lifeline_selfheal_progss",false] == false && _medic distance2D _newrevpos > 4 && _medic distance2D _newrevpos < 10 && _medic getVariable ["ReviveInProgress",0] == 1) then { 
							if (Lifeline_debug_soundalert && Lifeline_Revive_debug) then {playsound "teleportmedic"};
							if (Lifeline_hintsilent && Lifeline_Revive_debug) then {hint format ["%1 TELEPORT MEDIC dist: %2", name _medic, _medic distance2d _newrevpos]};
							diag_log format ["%1 | [1304] nnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnn TELEPORT MEDIC dist: %2 ===============================", name _medic, _medic distance2d _newrevpos];
							_medic setPos _newrevpos; 
						};
					};
				};	 */

				// if (time - _unblockwtime > 4 && _medic distance2D _newrevpos > 4 && _medic distance2D _newrevpos < 10 && _medic getVariable ["ReviveInProgress",0] == 1) then { 
					// _medic setPos _newrevpos; 
				// };
				//ENDDEBUG
				if (_medic getVariable ["Lifeline_selfheal_progss",false] == true && _selfheal_trig == false) then {
					_selfheal_trig = true;
					[_incap,_medic,_newrevpos,_animMove] spawn {
						params ["_incap","_medic","_newrevpos","_animMove"];
						waitUntil {
							(_medic getVariable ["Lifeline_selfheal_progss",false] == false)
						};
						// _medic playMoveNow _animMove;
						[_medic,_animMove] remoteExec ["playMoveNow",_medic];diag_log format ["%1 [1342] uuuuuuuuuuuuuuuuuuu PLAYMOVENOW uuuuuuuuuuuuu", name _medic];
						// _medic setdir (_medic getDir _newrevpos);diag_log format ["%1 [1332] uuuuuuuuuuuuuuuuuuu ADJUST DIRECTION uuuuuuuuuuuuu", name _medic];	
						_medic lookAt _incap;diag_log format ["%1 [1344] uuuuuuuuuuuuuuuuuuu LOOKAT DIRECTION uuuuuuuuuuuuu", name _medic];						
					};
				};

				(_medic distance2D _revivePos <= 4 || !alive _medic || !alive _incap || (_incap getvariable ["LifelinePairTimeOut",0] == 0) || lifestate _incap != "INCAPACITATED" || _exit == true || time - _unblockwtime > 8
				// || (_incap getVariable ["Lifeline_AssignedMedic",[]]) isEqualTo []
				|| lifestate _medic == "INCAPACITATED"
				|| _medic getVariable ["Lifeline_ExitTravel", false] == true
				)
			};	
			
			diag_log format ["%1 | %2 \%5\====// [1471] WAITUNTIL REVIVE JOURNEY [DISTANCE RADIUS <=4] //==== AssignedMedic: %3 _exit: %4 DIST: %6", name _incap, name _medic, name (_incap getVariable ["Lifeline_AssignedMedic",[]] select 0), _exit,time,_medic distance2D _incap];


			// GREEN MARKER FOR APPROACH GREETING
			if (Lifeline_Revive_debug && Lifeline_yellowmarker) then {
				_greenmark = createVehicle ["Sign_Arrow_green_F", getPos _medic,[],0,"can_collide"];
				_medic setVariable ["_greenmark2", _greenmark, true]; 
			};
			
			diag_log format ["%1 | %2 \%5\====// [1490] GREEN MARKER FOR APPROACH GREETING //==== AssignedMedic: %3 _exit: %4 DIST: %6", name _incap, name _medic, name (_incap getVariable ["Lifeline_AssignedMedic",[]] select 0), _exit,time,_medic distance2D _incap];


			// remove collision //moved
			if (alive _incap && alive _medic) then {
				[_medic, _incap] remoteExecCall ["disableCollisionWith", 0, _medic];diag_log format ["%1 | [1492] nnnnnnnnnnnnnnnnn REMOVE COLLISION nnnnnnnnnnnnnnnn", name _medic];
			};

			// randomized greeting as medic approaches incap
			if (lifestate _medic != "INCAPACITATED" && (alive _medic) && lifestate _incap == "INCAPACITATED" && (alive _incap) 
				&& (_incap getvariable ["LifelinePairTimeOut",0] != 0) && _exit == false && _medic getvariable ["ReviveInProgress",0] == 1 && _incap getvariable ["ReviveInProgress",0] == 3 
				) then {
					_pairtimebaby = "LifelinePairTimeOut";
					_incap setVariable [_pairtimebaby, (_incap getvariable _pairtimebaby) + 5, true]; 
					_medic setVariable [_pairtimebaby, (_medic getvariable _pairtimebaby) + 5, true]; 
				if (Lifeline_MedicComments) then {
					_A = str ([1, 3] call BIS_fnc_randomInt);
					_B = str ([1, 6] call BIS_fnc_randomInt);
					if (lifestate _medic != "INCAPACITATED" && (alive _medic)) then {[_medic, [_voice+"_greetA"+_A, 20, 1, true]] remoteExec ["say3D", 0]};
					if (lifestate _medic != "INCAPACITATED" && (alive _medic)) then {[_medic, [_voice+"_greetB"+_B, 20, 1, true]] remoteExec ["say3D", 0]};		
					diag_log format ["| %1 | %2 | [1341] kkkkkkkkkkkkk SAY3D GREETING | voice: %3", name _incap, name _medic, _voice];
				};
			};

			//check its right direction 
			_checkdegrees = [_revivepos,_medic,25] call Lifeline_checkdegrees;
			if (_checkdegrees == false) then {
				[_medic,_newrevpos] call Lifeline_align_dir;
				if (Lifeline_debug_soundalert && Lifeline_Revive_debug) then {playsound "adjust_direction"};
				if (Lifeline_hintsilent && Lifeline_Revive_debug) then {hint format ["%1 ADJUST DIRECTION ", name _medic]};
				diag_log format ["%1 | [1383] nnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnn ADJUST DIRECTION ===============================", name _medic];
			};
			//DEBUG
		/* 	checkdegrees = [_incap,_medic,15] call Lifeline_checkdegrees;//diag_log format ["%1 | nnnnnnnnnnnnnnn  WTF DIRECTION MEDIC _checkdegrees %2  nnnnnnnnnnnnnnn", name _medic, _checkdegrees];
			if (_medic getVariable ["ReviveInProgress",0] == 2 && _checkdegrees == false) then {
				diag_log format ["%1 | [1340]nnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnn DIRECTION MEDIC TO REVIVEPOS ====== count %2 =========================", name _medic, _directioncount];
				_direction = _medic getDir _incap;
				_medic setDir _direction;diag_log format ["%1 | [1535] nnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnn FORCE DIRECTION ===============================", name _medic];
				if (Lifeline_debug_soundalert && Lifeline_Revive_debug) then {playsound "forcedirection"};
				if (Lifeline_hintsilent && Lifeline_Revive_debug) then {hint format ["%1 FORCE DIR MEDIC dist: %2", name _medic, _medic distance2d _newrevpos]};
			}; */
			//ENDDEBUG

			_selfheal_trig = false;			
			_unblockwtime = time;
			_trig1 = false;
			_diag_texty2 = "";

			// DISTANCE RADIUS <=2

			waitUntil {
				// _medic playMoveNow _animMove;
				// [_medic,_animMove] remoteExec ["playMoveNow",_medic];
				sleep 0.2;
				_medic doWatch _newrevpos;
				//DEBUG
				_diag_texty = format ["%1 | %2 [waituntil 1414] >>>>>>>>>>>>>>>>>>>>>>>> MEDIC SPEED %3 DIST %5 Lifeline_selfheal_progss %4", name _incap, name _medic, speed _medic, _medic getVariable ["Lifeline_selfheal_progss",false],_medic distance2D _newrevpos];
				sleep 1;if (_diag_texty != _diag_texty2) then {diag_log _diag_texty;};
				_diag_texty2 = format ["%1 | %2 [waituntil 1414] >>>>>>>>>>>>>>>>>>>>>>>> MEDIC SPEED %3 DIST %5 Lifeline_selfheal_progss %4", name _incap, name _medic, speed _medic, _medic getVariable ["Lifeline_selfheal_progss",false],_medic distance2D _newrevpos];
				if (speed _medic == 0 && Lifeline_Revive_debug) then {
					[_medic,_newrevpos,_trig1] spawn {
						params ["_medic","_newrevpos","_trig1"];
						sleep 5;
						if (speed _medic == 0) then {
							diag_log format ["%1 | [1542 RADIUS <=2] >>>>>>>>>>>>>>>>>>>>>>>> MEDIC SPEED ZERO | DIST %2 selfheal_progss %3 trig1 %4 >>>>>>>>>>>>>>>>", name _medic, _medic distance2D _newrevpos, _medic getVariable ["Lifeline_selfheal_progss",false], _trig1];
							if (Lifeline_debug_soundalert) then {["speediszero"] remoteExec ["playSound",2]};
						};
					};				
				};
				//ENDDEBUG
				//DEBUG
				/* if (speed _medic == 0 && _medic getVariable ["Lifeline_selfheal_progss",false] == false && _medic distance2D _newrevpos > 2 && _medic distance2D _newrevpos < 6 && _medic getVariable ["ReviveInProgress",0] == 1) then { 					
					[_medic,_newrevpos,_animMove] spawn {
						params ["_medic","_newrevpos","_animMove"];
						sleep 5;
						if (speed _medic == 0 && _medic getVariable ["Lifeline_selfheal_progss",false] == false && _medic distance2D _newrevpos > 2 && _medic distance2D _newrevpos < 6 && _medic getVariable ["ReviveInProgress",0] == 1) then { 
						diag_log format ["%1 | [waituntil 1378] >>>>>>>>>>>>>>>>>>>>>>>> MEDIC SPEED %2 DIST %4 Lifeline_selfheal_progss %3", name _medic, speed _medic, _medic getVariable ["Lifeline_selfheal_progss",false],_medic distance2D _newrevpos];							
							diag_log format ["%1 | [1378] nnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnn TELEPORT MEDIC dist: %2 ===============================", name _medic, _medic distance2d _newrevpos];
							// _medic setPos _newrevpos;
							_medic setDir (_medic getDir _newrevpos);diag_log format ["%1 | [1582] nnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnn FORCE DIRECTION ===============================", name _medic];
							if (Lifeline_debug_soundalert && Lifeline_Revive_debug) then {playsound "forcedirection"};
							if (Lifeline_hintsilent && Lifeline_Revive_debug) then {hint format ["%1 FORCE DIR MEDIC dist: %2", name _medic, _medic distance2d _newrevpos]};
							[_medic,_animMove] remoteExec ["playMoveNow",_medic];diag_log format ["%1 [1433] uuuuuuuuuuuuuuuuuuu PLAYMOVENOW uuuuuuuuuuuuu", name _medic];
						};
					};
				}; */
				//ENDDEBUG

				if (speed _medic == 0 && _medic getVariable ["Lifeline_selfheal_progss",false] == false && _medic distance2D _newrevpos > 2 && _medic distance2D _newrevpos < 4 && _medic getVariable ["ReviveInProgress",0] == 1 && _trig1 == false) then { 
					_trig1 = true;
					[_incap,_medic,_newrevpos,_animMove] spawn {
						params ["_incap","_medic","_newrevpos","_animMove"];
						sleep 2;
						if (speed _medic == 0 && _medic getVariable ["Lifeline_selfheal_progss",false] == false && _medic distance2D _newrevpos > 2 && _medic distance2D _newrevpos < 4 && _medic getVariable ["ReviveInProgress",0] == 1) then { 
							// _medic setPos _newrevpos;
							_medic disableAI "ANIM";
							_medic setDir (_medic getDir _incap);diag_log format ["%1 | [1599] nnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnn FORCE DIRECTION ===============================", name _medic];
							if (Lifeline_debug_soundalert && Lifeline_Revive_debug) then {playsound "forcedirection"};
							if (Lifeline_hintsilent && Lifeline_Revive_debug) then {hint format ["%1 FORCE DIR MEDIC dist: %2", name _medic, _medic distance2d _newrevpos]};
							[_medic,_animMove] remoteExec ["playMoveNow",_medic];diag_log format ["%1 [1458] uuuuuuuuuuuuuuuuuuu PLAYMOVENOW uuuuuuuuuuuuu", name _medic];
							_trig1 = false;
						};
					};
				};
				//DEBUG
				// ((_medic distance2D _revivePos <=0.1) || (_medic distance2D _incap <= _rposDist) || (!alive _medic) || (!alive _incap) || (lifestate _medic == "INCAPACITATED") || (lifestate _incap != "INCAPACITATED") || (_exit == true)
				// ((_medic distance2D _revivePos <=2) || (_medic distance2D _incap <= _rposDist) || (!alive _medic) || (!alive _incap) || (lifestate _medic == "INCAPACITATED") || (lifestate _incap != "INCAPACITATED") || (_exit == true)
				// ((_medic distance2D _revivePos <=2) || (!alive _medic) || (!alive _incap) || (lifestate _medic == "INCAPACITATED") || (lifestate _incap != "INCAPACITATED") || (_exit == true)
				//ENDDEBUG

				((_medic distance2D _newrevpos <=2 ) || (!alive _medic) || (!alive _incap) || (lifestate _medic == "INCAPACITATED") || (lifestate _incap != "INCAPACITATED") || (_exit == true) 
				// || (_incap getVariable ["Lifeline_AssignedMedic",[]]) isEqualTo []
				|| _medic getVariable ["Lifeline_ExitTravel", false] == true				
				)
			};	

			if (Lifeline_travel_meth == 1) then {
				[_medic,_animMove] remoteExec ["playMoveNow",_medic];diag_log format ["%1 [1433] uuuuuuuuuuuuuuuuuuu PLAYMOVENOW uuuuuuuuuuuuu", name _medic];
			};
			
			diag_log format ["%1 | %2 \%5\====// [1607] WAITUNTIL REVIVE JOURNEY [DISTANCE RADIUS <=2] //==== AssignedMedic: %3 _exit: %4 DIST: %6", name _incap, name _medic, name (_incap getVariable ["Lifeline_AssignedMedic",[]] select 0), _exit,time,_medic distance2D _incap];

			//TEMP ADD BELOW
			_medic disableAI "ANIM";
			_medic setDir (_medic getDir _incap);diag_log format ["%1 | [1628] nnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnn FORCE DIRECTION ===============================", name _medic];
			if (Lifeline_debug_soundalert && Lifeline_Revive_debug) then {playsound "forcedirection"};
			if (Lifeline_hintsilent && Lifeline_Revive_debug) then {hint format ["%1 FORCE DIR MEDIC dist: %2", name _medic, _medic distance2d _newrevpos]};
			[_medic,_animMove] remoteExec ["playMoveNow",_medic];diag_log format ["%1 [1515] uuuuuuuuuuuuuuuuuuu PLAYMOVENOW uuuuuuuuuuuuu", name _medic];
			//
			
			//DEBUG
			// remove collision new location
			// if (alive _incap && alive _medic && _medic distance2D _newrevpos <=2) then {
				// [_medic, _incap] remoteExecCall ["disableCollisionWith", 0, _medic];diag_log format ["%1 | [1627] nnnnnnnnnnnnnnnnn REMOVE COLLISION nnnnnnnnnnnnnnnn", name _medic];
			// };
			//ENDDEBUG

			_unblockwtime = time;
			_trig1 = false;

			// DISTANCE RADIUS <=1

			waitUntil {
				sleep 0.2;
				//DEBUG
				_diag_texty = format ["%1 | %2 [waituntil 1588] >>>>>>>>>>>>>>>>>>>>>>>> MEDIC SPEED %3 DIST %5 Lifeline_selfheal_progss %4", name _incap, name _medic, speed _medic, _medic getVariable ["Lifeline_selfheal_progss",false],_medic distance2D _newrevpos];
				sleep 1;if (_diag_texty != _diag_texty2) then {diag_log _diag_texty;};
				_diag_texty2 = format ["%1 | %2 [waituntil 1588] >>>>>>>>>>>>>>>>>>>>>>>> MEDIC SPEED %3 DIST %5 Lifeline_selfheal_progss %4", name _incap, name _medic, speed _medic, _medic getVariable ["Lifeline_selfheal_progss",false],_medic distance2D _newrevpos];
				if (speed _medic == 0 && Lifeline_Revive_debug) then {
					[_medic,_newrevpos,_trig1] spawn {
						params ["_medic","_newrevpos","_trig1"];
						sleep 5;
						if (speed _medic == 0) then {
							diag_log format ["%1 | [1656 RADIUS <=1] >>>>>>>>>>>>>>>>>>>>>>>> MEDIC SPEED ZERO | DIST %2 selfheal_progss %3 trig1 %4 >>>>>>>>>>>>>>>>", name _medic, _medic distance2D _newrevpos, _medic getVariable ["Lifeline_selfheal_progss",false], _trig1];
							if (Lifeline_debug_soundalert) then {["speediszero"] remoteExec ["playSound",2]};							
						};
					};				
				};
				
				// if (alive _incap && alive _medic && _medic distance2D _incap <=2) then {
					// [_medic, _incap] remoteExecCall ["disableCollisionWith", 0, _medic];diag_log format ["%1 | [1661] nnnnnnnnnnnnnnnnn REMOVE COLLISION nnnnnnnnnnnnnnnn", name _medic];
				// };
				//ENDDEBUG
				//DEBUG
				// if (speed _medic == 0 && _medic distance2D _newrevpos > 1 && _medic distance2D _newrevpos < 2 && _medic getVariable ["ReviveInProgress",0] == 1) then { 
				// if (speed _medic == 0 && _medic getVariable ["Lifeline_selfheal_progss",false] == false && _medic distance2D _newrevpos > 1 && _medic distance2D _newrevpos < 2 && _medic getVariable ["ReviveInProgress",0] == 1) then { 
				/* if (speed _medic == 0 && _medic getVariable ["Lifeline_selfheal_progss",false] == false && _medic distance2D _newrevpos > 1 && _medic distance2D _newrevpos < 2 && _medic getVariable ["ReviveInProgress",0] == 1 && _trig1 == false) then { 
					_trig1 = true;
					[_incap,_medic,_newrevpos,_animMove] spawn {
						params ["_incap","_medic","_newrevpos","_animMove"];
						sleep 3;
						if (speed _medic == 0 && _medic getVariable ["Lifeline_selfheal_progss",false] == false && _medic distance2D _newrevpos > 1 && _medic distance2D _newrevpos < 2 && _medic getVariable ["ReviveInProgress",0] == 1) then { 
							if (Lifeline_debug_soundalert && Lifeline_Revive_debug) then {playsound "teleportmedic"};
							if (Lifeline_hintsilent && Lifeline_Revive_debug) then {hint format ["%1 TELEPORT MEDIC dist: %2", name _medic, _medic distance2d _newrevpos]};
							diag_log format ["%1 | [1415] nnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnn TELEPORT MEDIC dist: %2 ===============================", name _medic, _medic distance2d _newrevpos];
							_medic setPos _newrevpos;
							_medic setDir (_medic getDir _incap);diag_log format ["%1 | [1683] nnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnn FORCE DIRECTION ===============================", name _medic];
							[_medic,_animMove] remoteExec ["playMoveNow",_medic];diag_log format ["%1 [1433] uuuuuuuuuuuuuuuuuuu PLAYMOVENOW uuuuuuuuuuuuu", name _medic];
						};
					};
				};*/
				//ENDDEBUG 

				if (speed _medic == 0 && _medic getVariable ["Lifeline_selfheal_progss",false] == false && _medic distance2D _newrevpos > 1 && _medic distance2D _newrevpos < 2 && _medic getVariable ["ReviveInProgress",0] == 1 && _trig1 == false) then { 
					_trig1 = true;
					[_incap,_medic,_newrevpos,_animMove] spawn {
						params ["_incap","_medic","_newrevpos","_animMove"];
						sleep 2;
						if (speed _medic == 0 && _medic getVariable ["Lifeline_selfheal_progss",false] == false && _medic distance2D _newrevpos > 1 && _medic distance2D _newrevpos < 2 && _medic getVariable ["ReviveInProgress",0] == 1) then { 
							if (Lifeline_debug_soundalert && Lifeline_Revive_debug) then {playsound "forcedirection"};
							if (Lifeline_hintsilent && Lifeline_Revive_debug) then {hint format ["%1 FORCE DIR MEDIC dist: %2", name _medic, _medic distance2d _newrevpos]};
							diag_log format ["%1 | [1511] nnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnn SETDIR MEDIC dist: %2 ===============================", name _medic, _medic distance2d _newrevpos];
							// _medic setPos _newrevpos;
							_medic disableAI "ANIM";
							_medic setDir (_medic getDir _incap);diag_log format ["%1 | [1701] nnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnn FORCE DIRECTION ===============================", name _medic];
							[_medic,_animMove] remoteExec ["playMoveNow",_medic];diag_log format ["%1 [1515] uuuuuuuuuuuuuuuuuuu PLAYMOVENOW uuuuuuuuuuuuu", name _medic];
							_trig1 = false;
						};
					};
				};

				 // if (time - _unblockwtime > 4 && _medic distance2D _newrevpos > 1 && _medic getVariable ["ReviveInProgress",0] == 1) then { 
				 if (_medic distance2D _newrevpos > 3 && _medic getVariable ["ReviveInProgress",0] == 1) then { 
					if (Lifeline_debug_soundalert && Lifeline_Revive_debug) then {playsound "forcedirection"};
					if (Lifeline_hintsilent && Lifeline_Revive_debug) then {hint format ["%1 FORCE DIRECTION dist: %2", name _medic, _medic distance2d _newrevpos]};
					//DEBUG
					// diag_log format ["%1 | [1423] nnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnn TELEPORT MEDIC dist: %2 ===============================", name _medic, _medic distance2d _newrevpos];
					// diag_log format ["%1 | [1561] nnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnn SETDIR MEDIC dist: %2 ===============================", name _medic, _medic distance2d _newrevpos];					
					// _medic setPos _newrevpos;
					//ENDDEBUG
					_medic setDir (_medic getDir _incap);diag_log format ["%1 | [1715] nnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnn FORCE DIRECTION ===============================", name _medic];
					[_medic,_animMove] remoteExec ["playMoveNow",_medic];diag_log format ["%1 [1515] uuuuuuuuuuuuuuuuuuu PLAYMOVENOW uuuuuuuuuuuuu", name _medic];
					//DEBUG
					// [_medic,_newrevpos] call Lifeline_align_dir;
					// if (Lifeline_debug_soundalert) then {playsound "adjust_direction"};
					// if (Lifeline_hintsilent) then {hint format ["%1 ADJUST DIRECTION ", name _medic]};
					// diag_log format ["%1 | [1492] nnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnn ADJUST DIRECTION ===============================", name _medic];
					// _medic setDir (_medic getDir _newrevpos);diag_log format ["%1 | [1721] nnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnn FORCE DIRECTION ===============================", name _medic];
					//ENDDEBUG
					[_medic,_animMove] remoteExec ["playMoveNow",_medic];diag_log format ["%1 [1433] uuuuuuuuuuuuuuuuuuu PLAYMOVENOW uuuuuuuuuuuuu", name _medic];					
				}; 
				//DEBUG
				// ((_medic distance2D _revivePos <=0.1) || (_medic distance2D _incap <= _rposDist) || (!alive _medic) || (!alive _incap) || (lifestate _medic == "INCAPACITATED") || (lifestate _incap != "INCAPACITATED") || (_exit == true)
				// ((_medic distance2D _revivePos <=2) || (_medic distance2D _incap <= _rposDist) || (!alive _medic) || (!alive _incap) || (lifestate _medic == "INCAPACITATED") || (lifestate _incap != "INCAPACITATED") || (_exit == true)
				// ((_medic distance2D _revivePos <=2) || (!alive _medic) || (!alive _incap) || (lifestate _medic == "INCAPACITATED") || (lifestate _incap != "INCAPACITATED") || (_exit == true)
				//ENDDEBUG
				((_medic distance2D _newrevpos <=1) || (!alive _medic) || (!alive _incap) || (lifestate _medic == "INCAPACITATED") || (lifestate _incap != "INCAPACITATED") || (_exit == true) 
				// || (_incap getVariable ["Lifeline_AssignedMedic",[]]) isEqualTo []
				|| _medic getVariable ["Lifeline_ExitTravel", false] == true				
				)
			};
			
			diag_log format ["%1 | %2 \%7\====// [1718] WAITUNTIL REVIVE JOURNEY [DISTANCE RADIUS <=1] //==== AssignedMedic: %3 _exit: %4 selfheal_progss: %5 Lifeline_ExitTravel: %6  DIST: %8", name _incap, name _medic, name (_incap getVariable ["Lifeline_AssignedMedic",[]] select 0), _exit,_medic getVariable ["Lifeline_selfheal_progss",false],_medic getVariable ["Lifeline_ExitTravel", false], time,_medic distance2D _incap];


			// if (alive _medic && !(lifestate _medic == "INCAPACITATED")) then {
			if (alive _medic && !(lifestate _medic == "INCAPACITATED") && (_exit == false && _medic getVariable ["Lifeline_ExitTravel", false] == false)) then {
				// _medic doWatch _incap;
				_medic playMoveNow _animStop;
				[_medic,_animStop] remoteExec ["playMoveNow",_medic];diag_log format ["%1 [1676] uuuuuuuuuuuuuuuuuuu PLAYMOVENOW STOP uuuuuuuuuuuuu", name _medic];
				//DEBUG
				//this bit commented out, stop weird direction change
				/* _inrange = [position _medic, getDir _medic, 7, position _incap] call BIS_fnc_inAngleSector;
				if (!_inrange) then {
					_medic setdir (_medic getDir (position _incap));
					diag_log format ["%1 | [1698] nnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnn FORCE DIRECTION ===============================", name _medic];playsound "forcedirection";
				}; */
				// _medic doWatch _incap;
				//ENDDEBUG
			};

			_linenumber = "1056";
			_exit = [_incap,_medic,"EXIT REVIVE TRAVEL",_linenumber] call Lifeline_exit_travel;
			if (_exit == true) exitWIth {diag_log format ["%1 | %2 | !!!!! exitWith Lifeline_exit_travel [%3]",name _incap,name _medic,_linenumber];};
			

			//wait until fully stopped forward momentum and wait until finished self-healing
			waitUntil {
				(speed _medic == 0) || (_medic getVariable ["Lifeline_selfheal_progss",false] == false || (!alive _medic) || (!alive _incap) || (lifestate _medic == "INCAPACITATED") || (lifestate _incap != "INCAPACITATED") || (_exit == true)
				// || (_incap getVariable ["Lifeline_AssignedMedic",[]]) isEqualTo []
				|| _medic getVariable ["Lifeline_ExitTravel", false] == true
				)
			};			

			diag_log format ["%1 | %2 \%5\====// [1747] WAITUNTIL REVIVE JOURNEY [FINAL BEFORE HEAL] //==== AssignedMedic: %3 _exit: %4 DIST: %6", name _incap, name _medic, name (_incap getVariable ["Lifeline_AssignedMedic",[]] select 0), _exit,time,_medic distance2D _incap];

	};		// end (alive _medic && (lifestate _incap == "incapacitated")


	//======= END IF  end (alive _medic && (lifestate _incap == "incapacitated")


	sleep 0.2;

	diag_log format ["%1 | %2 \%5\====// JUST BEFORE 'Medic animation and revive' IF [0887] //==== AssignedMedic: %3 _exit: %4", name _incap, name _medic, name (_incap getVariable ["Lifeline_AssignedMedic",[]] select 0), _exit,time];
	//DEBUG
	// _linenumber = "1082";
	// _exit = [_incap,_medic,"EXIT REVIVE TRAVEL",_linenumber] call Lifeline_exit_travel;
	// if (_exit == true) exitWIth {diag_log format ["%1 | %2 | !!!!! exitWith Lifeline_exit_travel [%3]",name _incap,name _medic,_linenumber];};
	//ENDDEBUG

	if (alive _incap && alive _medic && lifestate _incap == "INCAPACITATED" && lifestate _medic != "INCAPACITATED" && _exit == false && _medic getVariable ["Lifeline_ExitTravel", false] == false ) then {
	
		diag_log format ["%1 | %2 ====// Medic animation and revive //====", name _incap, name _medic];

		//DEBUG
		//TEMP==========================================
		/* if (!isnull _EnemyCloseBy) then {
			// commando crawl
			_revivePos = [_incap, _medic, 1.5] call Lifeline_POSnexttoincap;
		} else {
			// crouch
			_revivePos = [_incap, _medic, 0.5] call Lifeline_POSnexttoincap;
		};
				
		if (Lifeline_yellowmarker) then {
			_incap call Lifeline_delYelMark;
			_yelmark = createVehicle ["Sign_Arrow_Yellow_F", _revivePos,[],0,"can_collide"];
			_incap setVariable ["ymarker1", _yelmark, true]; 	
		}; */
		
		
		//====METHOD 1, transport to incap
		// _revivePos
		/* [_medic,_revivePos] spawn {
			params ["_medic","_revivePos"];
			// sleep 3;
			if (_medic distance2D _revivePos > 1) then { 
				diag_log format ["%1 | nnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnn TRANSPORT MEDIC TO REVIVEPOS ===============================", name _medic];
				_medic setPos _revivePos;
				playsound "beep_hi_1";
			};
		}; */
		
/* 		[_incap,_medic,_revivePos,_EnemyCloseBy] spawn {
			params ["_incap","_medic","_revivePos","_EnemyCloseBy"];
			sleep 4;
			_revivePosCheck = "";
			while {alive _medic && alive _incap && _medic getVariable ["ReviveInProgress",0] == 2 && lifestate _incap == "INCAPACITATED"} do {
				if (!isnull _EnemyCloseBy) then {_revivePosCheck = [_incap, _medic, 1.5] call Lifeline_POSnexttoincap;} else {_revivePosCheck = [_incap, _medic, 0.8] call Lifeline_POSnexttoincap;};
				if (_revivePos isNotEqualTo _revivePosCheck) then {
				// if (_revivePos distance2D _revivePosCheck > 0.3) then {
				// if (_revivePos distance2D _revivePosCheck > 0.5) then {					
					if (Lifeline_yellowmarker) then {
						_incap call Lifeline_delYelMark;
						_yelmark = createVehicle ["Sign_Arrow_Yellow_F", _revivePos,[],0,"can_collide"];
						_incap setVariable ["ymarker1", _yelmark, true]; 	
					};
				};
				if (_medic distance2D _revivePosCheck > 0.3) then {
					playsound "beep_hi_1";
					diag_log format ["%1 | nnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnn TRANSPORT MEDIC TO REVIVEPOS ===============================", name _medic];
					_medic setPos _revivePosCheck;
				};
				_direction = _medic getDir _incap;
				_medic setDir _direction;diag_log format ["%1 | [1863] nnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnn FORCE DIRECTION ===============================", name _medic];
	
				sleep 2;
			};
		}; */
		
		

		/* //====METHOD 2, walk to incap
		// _revivePos
		
			// if (_medic distance2D _revivePos > 0.3) then { 
				diag_log format ["%1 | [1845] nnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnn DOMOVE MEDIC TO REVIVEPOS ===============================", name _medic];
				_medic domove position _medic;
				_medic domove _revivePos;
				_medic moveto _revivePos;
				// playsound "beep_hi_1";
			// };
		
		// waitUntil {((moveToCompleted _medic) == true)};
		waitUntil {(_medic distance2D _revivePos <= 1)}; */
		
		//===============================================================
		//ENDDEBUG
		// if (Lifeline_travel_meth == 1) then {
			_medic disableAI "ANIM";
		// };

		_medic setVariable ["ReviveInProgress",2,true];diag_log format ["%1 [0897]!!!!!!!!! [MEDIC] change var ReviveInProgress = 2 !!!!!!!!!!!!!", name _medic];
		diag_log format ["%1 uuuuuuuuuuuuuu [0898] [FNC Lifeline_StartRevive] 'ReviveInProgress = 2' ADDED TO MEDIC. test, should be two: %2", name _medic, _medic getVariable ["ReviveInProgress",0]];

		_incap setVariable ["Lifeline_canceltimer",true,true]; // if showing, cancel it.
		diag_log format ["%1 !!!!!!!!!!!!! CANCEL TIMER canceltimer var: %2 !!!!!!!!!!!!!!", name _incap, _incap getVariable ["Lifeline_canceltimer",false]];

		// smoke
		diag_log format ["%1 | %2 |!!!!!!!!!!!!!!! ADD SMOKE !!!!!!!!!!!!!!!!!!!!", name _incap, name _medic];
		[_incap, _medic] spawn Lifeline_Smoke; 

		_medic dowatch objNull;

		if (lifestate _medic != "INCAPACITATED" && alive _medic) then {_medic setdir (_medic getDir _incap);};
		// diag_log format ["%1 | %2 ====// WAITUNTIL REVIVE JOURNEY [1133] //==== AssignedMedic: %3 _exit: %4 DIST: %5", name _incap, name _medic, name (_incap getVariable ["Lifeline_AssignedMedic",[]] select 0), _exit,_medic distance2D _incap];

		_exitanim = false;

		//call animations and medic hands-on revive
		if (Lifeline_RevMethod != 3) then {
			_exitanim = [_incap,_medic,_EnemyCloseBy,_voice,_B] call Lifeline_Medic_Anim_and_Revive; 
		};

		if (Lifeline_RevMethod == 3) then {
			[_incap,_medic,_EnemyCloseBy,_voice,_B] call Lifeline_ACE_Revive;
		};

		//explaination of variables. _voice is the voice actor. _B is the randomized second half of greeting. We pass this variable to avoid repeated samples.

		if (_exitanim == true) exitWith {
			diag_log format ["%1 | %2 |[0925] EXIT BABY _exitanim == true", name _incap, name _medic];
			diag_log format ["%1 | %2 |[0925] EXIT BABY _exitanim == true", name _incap, name _medic];
			diag_log format ["%1 | %2 |[0925] EXIT BABY _exitanim == true", name _incap, name _medic];		
		};


		// ========= WAKE UP (IF)
		if (lifestate _medic != "INCAPACITATED" && alive _medic && alive _incap) then {
			//DEBUG
			// if (isMultiplayer && isPlayer _incap) then {
				// ["#rev", 1, _incap] remoteExecCall ["BIS_fnc_reviveOnState", _incap];
			// };
			//ENDDEBUG

			_incap setdamage 0;	

			if !(local _incap) then {
				[_incap, false] remoteExec ["setUnconscious",_incap,true]; //remoteexec version
			} else {
				_incap setUnconscious false; // non remote exec version
			};			

			waitUntil {
				(lifestate _incap != "INCAPACITATED") //Cannot go past until awake. Needed for slower remoteExec delay		
			};
		};		

	}; // END IF alive medic and incap unit and lifestate incap == "incapacitated" 



	//=====================================================================================================
	//========= EITHER WAKE UP OR BYPASS ==================================================================
	//=====================================================================================================


	// Debug get total revive time and remove debug path marker
	if (Lifeline_Revive_debug) then {
		_incap call Lifeline_delYelMark;
		if (lifestate _incap != "incapacitated" && alive _incap && _exit == false) then {
			diag_log format ["%3|%4| ", _incap, _medic,name _incap,name _medic];
			diag_log format ["%3|%4|++++ DELETE YELLOW MARKER ++++ SUCCESS REVIVED // [0952] revive completed'", _incap, _medic,name _incap,name _medic];
			diag_log format ["%3|%4| ", _incap, _medic,name _incap,name _medic];
		};
		if (lifestate _incap == "incapacitated" && lifestate _medic != "incapacitated" && alive _incap) then {
			// if (Lifeline_hintsilent) then {["Incap not revived"] remoteExec ["hintsilent",2]};
			diag_log format ["%1|%2|  ", name _incap,name _medic,_medic getvariable "LifelinePairTimeOut"];
			diag_log format ["%1|%2|++++ DELETE YELLOW MARKER ++++ FAILED TRAVEL // [0958] Incap not revived | LifelinePairTimeOut %3 | '", name _incap,name _medic,((_medic getvariable "LifelinePairTimeOut") - time)];
			diag_log format ["%1|%2|  ", name _incap,name _medic,_medic getvariable "LifelinePairTimeOut"];
		};
		if (lifestate _medic == "incapacitated" || !alive _medic ) then {
			diag_log format ["%3|%4| ", _incap, _medic,name _incap,name _medic];
			diag_log format ["%3|%4|++++ DELETE YELLOW MARKER ++++ FAILED TRAVEL // [0963] MEDIC DOWN'", _incap, _medic,name _incap,name _medic];
			diag_log format ["%3|%4| ", _incap, _medic,name _incap,name _medic];
			if (Lifeline_hintsilent) then {[format ["MEDIC DOWN: %1", name _medic]] remoteExec ["hintsilent",2]};
		};
		if !(alive _incap) then {
			diag_log format ["%3|%4| ", _incap, _medic,name _incap,name _medic];
			diag_log format ["%3|%4|++++ DELETE YELLOW MARKER ++++ INCAP DEAD // [0969]'", _incap, _medic,name _incap,name _medic];
			diag_log format ["%3|%4| ", _incap, _medic,name _incap,name _medic];
		};
		if (lifestate _incap != "INCAPACITATED" && alive _incap && (_exit == true)) then {
			if (Lifeline_hintsilent) then {[format ["Medic WOKE UP\n%1", name _medic]] remoteExec ["hintsilent", 2]};
			diag_log format ["%3|%4| ", _incap, _medic,name _incap,name _medic];
			diag_log format ["%3|%4|++++ DELETE YELLOW MARKER ++++ [0975] INCAP WOKE UP!!!'", _incap, _medic,name _incap,name _medic];
			diag_log format ["%3|%4| ", _incap, _medic,name _incap,name _medic];
		};
	};

	//back to original stance
	if (Lifeline_travel_meth == 1) then {
		diag_log format ["%1 [1729] uuuuuuuuuuuuuuuuuuu STANCE %2 uuuuuuuuuuuuu", name _medic, _stance];
		// _medic setUnitPos _stance;
		_medic setUnitPos "AUTO";
	};
	//DEBUG
	// cancel domove and set speed back to normal
	/* if (_medic == leader _medic) then {
		group _medic setspeedMode "FULL";
	} else {
		group _medic setspeedMode "NORMAL";
	}; */
	//ENDDEBUG
	
	_medic limitSpeed 100;
	_medic dofollow leader _medic;

	// Bleedout timer reset
	if (lifestate _incap != "INCAPACITATED") then {
		_incap doFollow leader _incap;
		_incap setVariable ["LifelineBleedOutTime", 0, true];diag_log format ["%1 [1187]!!!!!!!!! change var LifelinePairTimeOut = 0 !!!!!!!!!!!!!", name _incap];
		_incap setVariable ["Lifeline_selfheal_progss",false,true];diag_log format ["%1 [0993]!!!!!!!!! change var Lifeline_selfheal_progss = false !!!!!!!!!!!!!", name _incap];
	};

	// clear wayppoints for medic
	for "_i" from 0 to (count waypoints _goup - 1) do {deleteWaypoint [_goup, 0]};

	if (lifestate _medic != "INCAPACITATED") then { //added this conditional. if the medic gets downed, then we dont want to reset these
		//DEBUG
		// [_medic,true] remoteExec ["allowDamage",_medic];diag_log format ["%1 | [1264][Lifeline_Functions.sqf] ALLOWDAMAGE SET: %2", name _medic, "true"];
		// [_medic,false] remoteExec ["setCaptive",_medic];diag_log format ["%1 | [1264]!!!!!!!!! change var setCaptive = false !!!!!!!!!!!!!", name _medic];
		// _medic allowDamage true;diag_log format ["%1 | [1202][Lifeline_Functions.sqf] ALLOWDAMAGE SET: %2", name _medic, isDamageAllowed _medic];
		// _medic setCaptive false;diag_log format ["%1 | [1203]!!!!!!!!! change var setCaptive = false !!!!!!!!!!!!!", name _medic];
		//ENDDEBUG

		_captive = _medic getVariable ["Lifeline_Captive", false];
		if !(local _medic) then {
				[_medic,true] remoteExec ["allowDamage",_medic];diag_log format ["%1 | [1264][Lifeline_Functions.sqf] ALLOWDAMAGE SET: %2", name _medic, "true"];
				// [_medic,false] remoteExec ["setCaptive",_medic];diag_log format ["%1 | [1264]!!!!!!!!! change var setCaptive = false !!!!!!!!!!!!!", name _medic];
				[_medic,_captive] remoteExec ["setCaptive",_medic];diag_log format ["%1 | [1264]!!!!!!!!! change var setCaptive = %2 !!!!!!!!!!!!!", name _medic, _captive];
			} else {
				_medic allowDamage true;diag_log format ["%1 | [1267][Lifeline_Functions.sqf] ALLOWDAMAGE SET: %2", name _medic, "true"];
				// _medic setCaptive false;diag_log format ["%1 | [1267]!!!!!!!!! change var setCaptive = false !!!!!!!!!!!!!", name _medic];
				_medic setCaptive _captive;diag_log format ["%1 | [1267]!!!!!!!!! change var setCaptive = %2 !!!!!!!!!!!!!", name _medic, _captive];
			};
		[_medic, objNull] remoteExec ["doWatch",_medic];
	};

	if (Lifeline_Revive_debug && Lifeline_hintsilent && alive _medic && !alive _incap) then {[format ["Incap dead: %1",name _incap]] remoteExec ["hintsilent", 2]};

	// Delete Incap marker
	if !(_incap getVariable ["Lifeline_IncapMark",""] == "") then {
		deleteMarker (_incap getVariable "Lifeline_IncapMark");
		_incap setVariable ["Lifeline_IncapMark","",true];
	};

	// turn on collision
	[_medic, _incap] remoteExecCall ["enableCollisionWith", 0, _medic];

	// Player control group
	if (isplayer _incap && alive _incap && lifestate _incap != "INCAPACITATED") then {
		[group _incap, _incap] remoteExec ["selectLeader", groupOwner group _incap];diag_log format ["%1 | [1476]!!!!!!!!! change var PLAYER CONTROL GROUP !!!!!!!!!!!!!", name _incap];
	}; 

	diag_log format ["%1|%2 [1021] // REVIVE TRAVEL COMPLETED // !!!!!!!!!!!!!!!!!!!!!! _medic ReviveInProgress %3", name _incap, name _medic, (_medic getVariable ["ReviveInProgress",0])];
	// diag_log format ["%1|%2 [1022] !!!!!!!!!!!!!! Lifeline_RESET CALL FUNCTION. Lifeline_reset_trig: %3", name _incap, name _medic,(_medic getVariable ["Lifeline_reset_trig",false])];
	_AssignedMedic = (_incap getVariable ["Lifeline_AssignedMedic",[]]); 

	// if ( !(_medic getVariable ["Lifeline_reset_trig",false]) 
	if (_incap getVariable ["ReviveInProgress",0] == 3 || _AssignedMedic isEqualTo [] || _medic getVariable ["Lifeline_ExitTravel", false] == true ) then {
			// _medic setVariable ["Lifeline_reset_trig", true, true]; diag_log format ["%1 | [1232]!!!!!!!!! change var Lifeline_reset_trig = true !!!!!!!!!!!!!", name _medic];
		 [[_incap,_medic],"1232 VERY END TRAVEL"] call Lifeline_reset2;	
	};	
	sleep 5; //delay enableing "ANIM" for 5 secs to stop unit spinning on the ground
	_medic enableAI "ANIM";


}; // End AIReviveUnits Fnc



Lifeline_Map = {
	params ["_unit"];
	// Add marker
	if (lifestate _unit == "INCAPACITATED" && isTouchingGround _unit && vehicle _unit == _unit) then {
		if ((_unit getVariable ["Lifeline_IncapMark",""]) == "") then {
			_markerName = "Marker" + (name _unit);
			_marker = createMarker [_markerName, position _unit];
			_marker setMarkerShape "ICON";
			_marker setMarkerType "loc_heal";
			_marker setmarkerText (name _unit);
			_marker setMarkerColor "ColorRed";
			// _marker setMarkerSize [0.5,0.5];
			// _marker setMarkerSize [0.8,0.8];
			_marker setMarkerSize [1,1];
			_unit setVariable ["Lifeline_IncapMark",_markerName,true];
		};
	};

	// Remove marker
	if (alive _unit && lifestate _unit != "INCAPACITATED") then {
		if !(_unit getVariable ["Lifeline_IncapMark",""] == "") then {
			deleteMarker (_unit getVariable "Lifeline_IncapMark");
			_unit setVariable ["Lifeline_IncapMark","",true];
		};
	};

	// Add dead marker
	if (lifeState _unit == "DEAD" || lifeState _unit == "DEAD-RESPAWN" || lifeState _unit == "DEAD-SWITCHING") then {
		
		if ((_unit getVariable ["Lifeline_IncapMark",""]) != "Dead") then {
			diag_log format [">>>>>>>>>> DEAD MARKER %1 >>>>>>>>>>>", name _unit];
			_markerName = "Dead";
			_marker = createMarker [_markerName, position _unit];
			_marker setMarkerShape "ICON";
			_marker setMarkerType "KIA";
			_marker setmarkerText (name _unit);
			_marker setMarkerColor "ColorBlack";
			// _marker setMarkerSize [0.5,0.5];
			// _marker setMarkerSize [0.8,0.8];
			_marker setMarkerSize [0.7,0.7];
			_unit setVariable ["Lifeline_IncapMark",_markerName,true];
		};
	};
};



Lifeline_checkdegrees = {
	params ["_incap", "_medic","_range"];

	_direction1 = _medic getDir _incap;
	_direction2 = getDir _medic;

	// Calculate the absolute difference
	_difference = abs(_direction1 - _direction2);

	// Adjust for circular nature
	if (_difference > 180) then {
		_difference = 360 - _difference;
	};

	// Check if the difference is within the range
	_isWithinRange = _difference <= _range;
	
	diag_log format ["%1 | _direction1 %2 _direction2 %3 _difference %4 |%5", name _medic, _direction1, _direction2, _difference, if (_isWithinRange) then {"TARGET!!!!"} else {"out of range"}];
//DEBUG
	/* if (_isWithinRange) then {
		hint "Direction is within range!";
	} else {
		hint "Direction is not within range.";
	};
	 */	 
//ENDDEBUG
	_isWithinRange

};



Lifeline_align_dir = {
params ["_unit","_revivepos"];
	//check its right direction 
	_checkdegrees = [_revivepos,_medic,15] call Lifeline_checkdegrees;//diag_log format ["%1 | nnnnnnnnnnnnnnn  WTF DIRECTION MEDIC _checkdegrees %2  nnnnnnnnnnnnnnn", name _medic, _checkdegrees];
	if (_medic getVariable ["ReviveInProgress",0] == 2 && _checkdegrees == false) then {
		diag_log format ["%1 [1840 FNC Lifeline_align_dir] uuuuuuuuuuuuuuuuuuu CHANGE DIRECTION uuuuuuuuuuuuu", name _medic];
		if (Lifeline_Revive_debug) then {
			if (Lifeline_debug_soundalert) then {playsound "adjust_direction"};
			if (Lifeline_hintsilent) then {hint format ["%1 DIRECTION MEDIC", name _medic]};
		};
		// _direction = _medic getDir _revivepos;
		// _medic setDir _direction;
		_medic enableAI "ANIM";
		_medic lookAt _revivepos;diag_log format ["%1 [1862] uuuuuuuuuuuuuuuuuuu LOOKAT DIRECTION uuuuuuuuuuuuu", name _medic];
		_timechk = time;
		waitUntil {
			_checkdegrees = [_revivepos,_medic,5] call Lifeline_checkdegrees;
			(_checkdegrees == true || (time - _timechk) > 5)				
		};
		// diag_log format ["%1 [1292] uuuuuuuuuuuuuuuuuuu LOOKAT DIRECTION WAITUNTIL FINISH uuuuuuuuuuuuu", name _medic];
	};
};

//just testing
reset_idle_medics = {
    params ["_unit"];

    // Remove all waypoints
    {
        deleteWaypoint _x;
    } forEach waypoints (group _unit);

    // Reset position and direction
    // _unit setPos (position _unit);
    _unit setDir (direction _unit);
	//DEBUG
    // Reset skill
    // _unit setSkill ["aimingAccuracy", 0.5];
    // _unit setSkill ["aimingShake", 0.5];
    // _unit setSkill ["aimingSpeed", 0.5];
    // _unit setSkill ["endurance", 0.5];
    // _unit setSkill ["spotDistance", 0.5];
    // _unit setSkill ["spotTime", 0.5];    
    // _unit setSkill ["reloadSpeed", 0.5];
    // _unit setSkill ["commanding", 0.5];
    // _unit setSkill ["general", 0.5];
	//ENDDEBUG
	_unit setSkill ["courage", 1];
    // Reset behaviour
    _unit setBehaviour "SAFE";
    _unit setCombatMode "YELLOW";
    _unit setSpeedMode "LIMITED";
    _unit disableAI "ALL";
	sleep 0.1;
    _unit enableAI "ALL";
	sleep 0.1;
	if (Lifeline_Revive_debug) then {[_unit,"IDLE MEDIC reset_idle_medics [Lifeline_Functions.sqf]"] call serverSide_unitstate;};
};

//DEBUG
/* 
Lifeline_Incap_Marker = {
params ["_unit","_cpr"];
	deleteMarker (_unit getVariable "Lifeline_IncapMark");
	_markername = "mkr" + (name _unit);
	_marker = createMarker [_markerName, position _unit];
	_marker setMarkerShape "ICON";
	_marker setMarkerType "loc_heal";
	_marker setmarkerText (name _unit);
	if (_cpr) then {
		_marker setMarkerColor "ColorRed";
	} else {
		_marker setMarkerColor "ColorOrange";
	};
	// _marker setMarkerSize [0.5,0.5];
	// _marker setMarkerSize [0.8,0.8];
	// _marker setMarkerSize [1,1];
	_marker setMarkerSize [1.3,1.3];
	_unit setVariable ["Lifeline_MapMark",_marker,true];
};




Lifeline_Dead_Marker = {
params ["_unit"];
	deleteMarker (_unit getVariable "Lifeline_IncapMark");
	_markername = "mkr" + (name _unit);
	_marker = createMarker [_markerName, position _unit];
	_marker setMarkerShape "ICON";
	_marker setMarkerType "KIA";
	_marker setmarkerText (name _unit);
	_marker setMarkerColor "ColorBlack";
	// _marker setMarkerSize [0.5,0.5];
	// _marker setMarkerSize [0.8,0.8];
	_marker setMarkerSize [0.7,0.7];
	_unit setVariable ["Lifeline_MapMark",_marker,true];
};
 */
 //ENDDEBUG
 

 