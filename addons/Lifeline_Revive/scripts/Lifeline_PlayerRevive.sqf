	// PLAYER REVIVE OTHERS ACTION

	params ["_player","_actionId"];

	if (captive _player && !(_player getVariable ["Lifeline_Captive_Delay",false])) then {_player setVariable ["Lifeline_Captive",true,true]} else {_player setVariable ["Lifeline_Captive",false,true]}; diag_log format ["%1 [0005] _PlayerRevive.sqf !!!!!!!!! change var Lifeline_Captive = %2 !!!!!!!!!!!!!", name _player, captive _player];//2025


	//DEBUG
	if !(local _player) then {
		// ["Lifeline_PlayerReviveAI kkkkkkkkkkkkkkkkkkkk  Lifeline_PlayerRevive.sqf kkkkkkkkkkkkkkkkkkkkkkkkkkk"] remoteExec ["diag_log", 2];
		["Lifeline_PlayerReviveAI "] remoteExec ["diag_log", 2];
		[format ["Lifeline_PlayerRevive %1 | %2 uuuuuuuuuuuuuuuuu START PLAYER REVIVE Lifeline_PlayerRevive.sqf uuuuuuuuuuuuuuuuuuuu", name _player, (animationState _player)]] remoteExec ["diag_log", 2];	
		[format ["Lifeline_PlayerRevive %1 | %2 uuuuuuuuuuuuuuuuu START PLAYER REVIVE Lifeline_PlayerRevive.sqf uuuuuuuuuuuuuuuuuuuu", name _player, (animationState _player)]] remoteExec ["diag_log", 2];	
		[format ["Lifeline_PlayerRevive %1 | %2 uuuuuuuuuuuuuuuuu START PLAYER REVIVE Lifeline_PlayerRevive.sqf uuuuuuuuuuuuuuuuuuuu", name _player, (animationState _player)]] remoteExec ["diag_log", 2];	
		["Lifeline_PlayerRevive "] remoteExec ["diag_log", 2];
	} else {
		diag_log " ";
		diag_log format ["%1 | %2 uuuuuuuuuuuuuuuuu START PLAYER REVIVE Lifeline_PlayerRevive.sqf uuuuuuuuuuuuuuuuuuuu", name _player, (animationState _player)]; 
		diag_log format ["%1 | %2 uuuuuuuuuuuuuuuuu START PLAYER REVIVE Lifeline_PlayerRevive.sqf uuuuuuuuuuuuuuuuuuuu", name _player, (animationState _player)]; 
		diag_log format ["%1 | %2 uuuuuuuuuuuuuuuuu START PLAYER REVIVE Lifeline_PlayerRevive.sqf uuuuuuuuuuuuuuuuuuuu", name _player, (animationState _player)]; 
		diag_log " ";
	};
	//ENDDEBUG


	_exit = false;
	_Lifeline_AssignedMedic_AI = objNull;
	_timestamp = time;
	_incap = cursorObject;
	_bandages = 1; 		  //only appearing in debugging if RevMethod = 1
	_damagesubtract = 1;  //only appearing in debugging if RevMethod = 1
	_unitwounds = [];
	
	[_incap, _player] remoteExecCall ["disableCollisionWith", 0, _incap];
	
	_vcrew = [];


	if (Lifeline_RevMethod == 2 && Lifeline_BandageLimit > 1) then {
		_damagesubtract = _incap getVariable ["damagesubstr",0];
		_bandages = _incap getVariable ["num_bandages",0];
		_unitwounds =  _incap getVariable ["unitwounds",[]]; // important for deleting from array
	};


	_captive = _player getVariable ["Lifeline_Captive", false];//2025

	if (_bandages == 0) exitWith {		
		[_player, true] remoteExec ["allowDamage",0];diag_log format ["%1 | [0044][Lifeline_PlayerRevive.sqf] ALLOWDAMAGE SET: %2", name _player, isDamageAllowed _player];
		// [_player, false] remoteExec ["setCaptive",_player];diag_log format ["%1 [0044]!!!!!!!!! change var setcaptive = false !!!!!!!!!!!!!", name _player]; 
		[_player, _captive] remoteExec ["setCaptive",0];diag_log format ["%1 [0044]!!!!!!!!! change var setcaptive = %2 !!!!! ReviveInProgress: %3 !!!!!!!!", name _player, _captive, _player getVariable ["ReviveInProgress",0]]; 
		// _player setcaptive false;_player allowDamage true; diag_log format ["%1 | [0072][Lifeline_PlayerRevive.sqf] ALLOWDAMAGE SET: %2", name _player, isDamageAllowed _player];
		//DEBUG
		_diag_text = format ["Lifeline_PlayerRevive |%4|%5|kkkkkkkkkkkkkkkkkkkk 1 EXIT PLAYER BANDAGE %1 | DMG %2 | SUBTR %3 kkkkkkkkkkkkkkkkkkkkkkkkkkk", _bandages, damage _incap, _damagesubtract, name _incap, name _player];
		if !(local _player) then {[_diag_text] remoteExec ["diag_log", 2];} else {diag_log _diag_text};
		//ENDDEBUG
	};


	if (Lifeline_RevMethod == 2 && !(_incap getVariable ["Lifeline_Down",false])) exitWith {
		[_player, true] remoteExec ["allowDamage",0];diag_log format ["%1 | [0054][Lifeline_PlayerRevive.sqf] ALLOWDAMAGE SET: %2", name _player, isDamageAllowed _player];
		// [_player, false] remoteExec ["setCaptive",_player];diag_log format ["%1 [0054]!!!!!!!!! change var setcaptive = false !!!!!!!!!!!!!", name _player]; 
		[_player, _captive] remoteExec ["setCaptive",0];diag_log format ["%1 [0054]!!!!!!!!! change var setcaptive = %2 !!!!! ReviveInProgress: %3 !!!!!!!!", name _player, _captive, _player getVariable ["ReviveInProgress",0]]; 
		// _player setcaptive false;_player allowDamage true; diag_log format ["%1 | [0078][Lifeline_PlayerRevive.sqf] ALLOWDAMAGE SET: %2", name _player, isDamageAllowed _player];
		//DEBUG
		_diag_text = format ["Lifeline_PlayerRevive |%4|%5|kkkkkkkkkkkkkkkkkkkk 1.5 EXIT PLAYER BANDAGE %1 | DMG %2 | SUBTR %3 kkkkkkkkkkkkkkkkkkkkkkkkkkk", _bandages, damage _incap, _damagesubtract, name _incap, name _player];
		if !(local _player) then {[_diag_text] remoteExec ["diag_log", 2];} else {diag_log _diag_text};
		//ENDDEBUG
	};


	if (_bandages == 0 or (lifestate _incap !="INCAPACITATED")) exitWith {
		[_player, true] remoteExec ["allowDamage",0];diag_log format ["%1 | [0064][Lifeline_PlayerRevive.sqf] ALLOWDAMAGE SET: %2", name _player, isDamageAllowed _player];
		// [_player, false] remoteExec ["setCaptive",_player];diag_log format ["%1 [0064]!!!!!!!!! change var setcaptive = false !!!!!!!!!!!!!", name _player]; 
		[_player, _captive] remoteExec ["setCaptive",0];diag_log format ["%1 [0064]!!!!!!!!! change var setcaptive = %2 !!!!! ReviveInProgress: %3 !!!!!!!!", name _player, _captive, _player getVariable ["ReviveInProgress",0]]; 
		// _player setcaptive false;_player allowDamage true; diag_log format ["%1 | [0084][Lifeline_PlayerRevive.sqf] ALLOWDAMAGE SET: %2", name _player, isDamageAllowed _player];
		//DEBUG
		_diag_text = format ["Lifeline_PlayerRevive |%4|%5|kkkkkkkkkkkkkkkkkkkk 2 EXIT PLAYER BANDAGE %1 | DMG %2 | SUBTR %3 kkkkkkkkkkkkkkkkkkkkkkkkkkk", _bandages, damage _incap, _damagesubtract, name _incap, name _player];
		if !(local _player) then {[_diag_text] remoteExec ["diag_log", 2];} else {diag_log _diag_text};
		//ENDDEBUG
	};


	_incap setVariable ["Lifeline_canceltimer",true,true]; 

	//DEBUG
	_diag_text = format ["Lifeline_PlayerRevive |%4|%5|kkkkkkkkkkkkkkkkkkkk  PLAYER BANDAGE %1 | DMG %2 | SUBTR %3 kkkkkkkkkkkkkkkkkkkkkkkkkkk", _bandages, damage _incap, _damagesubtract, name _incap, name _player]; if !(local _player) then {[_diag_text] remoteExec ["diag_log", 2];} else {diag_log _diag_text};

	if (Lifeline_RevMethod == 2 && Lifeline_BandageLimit > 1) then {
		_diag_text = format ["Lifeline_PlayerRevive |%2|%3|kkkkkkkkkkkkkkkkkkkk  UNIT WOUNDS %1 kkkkkkkkkkkkkkkkkkkkkkkkkkk", _unitwounds, name _incap, name _player]; if !(local _player) then {[_diag_text] remoteExec ["diag_log", 2];} else {diag_log _diag_text};
	}; 
	//ENDDEBUG

				
			
	//ADD MORE TIMER. added to increase revive time limit on each loop pass (made to also work with old versions)
	_bleedoutincap = (_incap getvariable "LifelineBleedOutTime");
	_incap setVariable ["LifelineBleedOutTime", _bleedoutincap + 30, true];diag_log format ["%1 [080]!!!!!!!!! change var LifelinePairTimeOut +30 !!!!!!!!!!!!!", name _incap];

	_player setVariable ["ReviveInProgress",2,true]; 
	// _player setcaptive true;
	// _player allowDamage dmg_trig; diag_log format ["%1 | [0127][Lifeline_PlayerRevive.sqf] ALLOWDAMAGE SET: %2", name _player, isDamageAllowed _player];
	if (Lifeline_RevProtect != 3) then {
		[_player, dmg_trig] remoteExec ["allowDamage",0];diag_log format ["%1 | [0127][Lifeline_PlayerRevive.sqf] ALLOWDAMAGE SET: %2", name _player, isDamageAllowed _player];
		[_player, true] remoteExec ["setCaptive",0];diag_log format ["%1 [0509]!!!!!!!!! change var setcaptive = true !!!!! ReviveInProgress: %2 !!!!!!!!", name _player, _player getVariable ["ReviveInProgress",0]]; 	
	};

	//temporarily clear action menu while reviving	
	if (Lifeline_RevMethod == 2) then {
	// if (Lifeline_RevMethod == 2 && Lifeline_BandageLimit > 1) then {
		[[_incap,_actionId],{params ["_incap","_actionId"];_incap setUserActionText [_actionId, ""];}] remoteExec ["call", _incap, true];
	};


	// Unassign vehicle crew to prevent them getting back in after revive (reset fnc will conditionally reassign veh and allow getin)
	if (!isnull assignedVehicle _incap) then {
		_vehicle =  (assignedVehicle _incap);
		{_vcrew pushBack _x} foreach (Lifeline_All_Units select {assignedvehicle _x == _vehicle});
		// Unassign vehicle crew to prevent them getting back in after revive (reset fnc will conditionally reassign veh and allow getin)
		{unassignVehicle _x; [_x] allowGetIn false;} forEach _vcrew;
	};



	if (lifestate _incap == "INCAPACITATED") then {
		// {Lifeline_Process pushback _x} foreach [_incap, _player];
		// {Lifeline_Process pushBackUnique _x} foreach [_incap, _player];
		Lifeline_Process pushBackUnique _player; 
		// Lifeline_Process pushBackUnique _incap; 
		publicVariable "Lifeline_Process"; 
		
		// new text system for proc pairs
		_Lifeline_AssignedMedic = _incap getVariable ["Lifeline_AssignedMedic",[]];
		_Lifeline_AssignedMedic_AI = _Lifeline_AssignedMedic select 0; //this is the other AI medic already on its way. This needs to be cancelled.
		_Lifeline_AssignedMedic pushBackUnique _player;
		_incap setVariable ["Lifeline_AssignedMedic", _Lifeline_AssignedMedic, true];	
		

		waitUntil {_player distance _incap <2 or !alive _player};

		_EnemyCloseBy = _player findNearestEnemy _player;

		_waituntilHack = false;
		// if (_incap distance _EnemyCloseBy < 100 ||  animationState _player find "ppn" == 4 ) then {
		if (animationState _player find "ppn" == 4 ) then {
			_waituntilHack = true;	
			[_player,"ainvppnemstpslaywrfldnon_medicother"] remoteExec ["playMove", 0]; // ORIGINAL
			if (_bandages == 1) then {
				sleep 8;
			};
		} else { 
			_player setAnimSpeedCoef 1.5;
			[_player,"AinvPknlMstpSnonWnonDnon_medic4"] remoteExec ["playMoveNow", 0]; //ORIGINAL
			sleep 8.6; // HERE
		};

		waitUntil {
				sleep 0.1;
				(
				(animationState _player == "amovpknlmstpsraswrfldnon" || _waituntilHack == true || (time - _timestamp) >= 10)
				// (animationState _player == "amovpknlmstpsraswrfldnon" || animationState _player == "ainvppnemstpslaywrfldnon_medicdummyend" || (time - _timestamp) >= 10)
				)
		};
			
		
		_player setAnimSpeedCoef 1;
		sleep 1;
		

		if (Lifeline_RevMethod == 2 && Lifeline_BandageLimit > 1) then {
		
			_colour = "";
			_text = "";
			_damagesubtract = _incap getVariable ["damagesubstr",0];		
			_bandages = _incap getVariable ["num_bandages",0];
			
			//DEBUG
			_diag_text = format ["Lifeline_PlayerRevive |%4|%5|kkkkkkkkkkkkkkkkkkkk 3 EXIT PLAYER BANDAGE %1 | DMG %2 | SUBTR %3 kkkkkkkkkkkkkkkkkkkkkkkkkkk", _bandages, damage _incap, _damagesubtract, name _incap, name _player]; 
			//ENDDEBUG

			//remotecheck
			if (_bandages == 0 or (lifestate _incap !="INCAPACITATED")) exitWith {
				// _player setcaptive false; diag_log format ["%1 [0509]!!!!!!!!! change var setcaptive = false !!!!!!!!!!!!!", name _player]; 
				_player setcaptive _captive; diag_log format ["%1 [0509]!!!!!!!!! change var setcaptive = %2 !!!!! ReviveInProgress: %3 !!!!!!!!", name _player, _captive, _player getVariable ["ReviveInProgress",0]]; 
				_player allowDamage true; diag_log format ["%1 [0298][Lifeline_PlayerRevive.sqf] ALLOWDAMAGE SET: %2", name _player, isDamageAllowed _player];
				_exit = true;
				//DEBUG
				if !(local _player) then {[_diag_text] remoteExec ["diag_log", 2];} else {diag_log _diag_text};
				//ENDDEBUG
			};
			
			//DEBUG
			_diag_text = format ["Lifeline_PlayerRevive %3 kkkkkkkkkkkkkkkkkkkkkkkkk Lifeline_PlayerRevive.sqf getVariable num_bandages: %1 damagesubstr: %2", _bandages, _damagesubtract, name _incap]; if !(local _player) then {[_diag_text] remoteExec ["diag_log", 2];} else {diag_log _diag_text};
			//ENDDEBUG
			
			_newdamage = damage _incap - _damagesubtract; // added a 0.000001 just to make sure 
			_bandages = _bandages - 1;
				
			_text = _incap getVariable "unitwounds" select (_bandages -1) select 0;
			_colour = _incap getVariable "unitwounds" select (_bandages -1) select 1;		
			
			//add new text to action menu each bandage
			_incap setVariable ["num_bandages",_bandages,true];
			

			//DEBUG
			_diag_text = format ["%2 | %3 | TEXT |kkkkkkkkk BOO MINUS BEFORE: %1 ", _unitwounds, name _incap, name _player]; if !(local _player) then {[_diag_text] remoteExec ["diag_log", 2];} else {diag_log _diag_text};
			//ENDDEBUG
			
			_unitwounds deleteAt _bandages;
			
			//DEBUG
			_diag_text = format ["%2 | %3 | TEXT |kkkkkkkkk BOO MINUS AFTER_: %1 ", _unitwounds, name _incap, name _player]; if !(local _player) then {[_diag_text] remoteExec ["diag_log", 2];} else {diag_log _diag_text};
			//ENDDEBUG
			_incap setVariable ["unitwounds",_unitwounds,true];
			
			
			
			_actionId = _incap getVariable ["Lifeline_ActionMenuWounds",-1];
			
			//DEBUG
			_diag_text = format ["Lifeline_PlayerRevive %2 | %3 *************** get action ID: %1 *************** [303] (Player revive)", _actionId, name _incap, name _player]; if !(local _player) then {[_diag_text] remoteExec ["diag_log", 2];} else {diag_log _diag_text};
			//ENDDEBUG

			//setUserActionText
			[[_incap,_actionId,_colour,_bandages, _text],
					{params ["_incap", "_actionId", "_colour","_bandages","_text"];
					_incap setUserActionText [_actionId, format ["<t size='%4' color='#%1'>%3       ..%2</t>",_colour,_bandages,_text, Lifeline_textsize]];}
			] remoteExec ["call", 0, true];
			
			//BIS_fnc_dynamicText
			if (isPlayer _incap && Lifeline_HUD_medical) then {
				// [format ["<t align='right' size='%4' color='#%1'>%3	  ..%2</t>",_colour,_bandages,_text, 0.7],((safeZoneW - 1) * 0.48),1.3,5,0,0,Lifelinetxt2Layer] remoteExec ["BIS_fnc_dynamicText",_incap];
				_textright = format ["<t align='right' size='%4' color='#%1'>%3	  ..%2</t>",_colour,_bandages,_text, 0.7];
				[_textright,1.3,5,Lifelinetxt2Layer] remoteExec ["Lifeline_display_textright",_incap];				
			};
			
			
			//ADD MORE TIMER. added to increase revive time limit on each loop pass (made to also work with old versions)
			_bleedoutincap = (_incap getvariable "LifelineBleedOutTime");
			_incap setVariable ["LifelineBleedOutTime", _bleedoutincap + 30, true];diag_log format ["%1 [205]!!!!!!!!! change var LifelinePairTimeOut +30 !!!!!!!!!!!!!", name _incap];

			
			_incap setDamage _newdamage;
			//DEBUG
			_diag_text = format ["Lifeline_PlayerRevive  kkkkkkkkkkkkkkkkkkkkk NEW DMG on player revive %1", _newdamage]; if !(local _player) then {[_diag_text] remoteExec ["diag_log", 2];} else {diag_log _diag_text};
			_diag_text = format ["Lifeline_PlayerRevive |%4|%5|kkkkkkkkkkkkkkkkkkkk  PLAYER END BANDAGE %1 | DMG %2 | SUBTR %3 kkkkkkkkkkkkkkkkkkkkkkkkkkk", _bandages, damage _incap, _damagesubtract,name _incap,name _player]; if !(local _player) then {[_diag_text] remoteExec ["diag_log", 2];} else {diag_log _diag_text};
			//ENDDEBUG
		
		};
		
		
		if (_exit == true) exitWith {
			//DEBUG
			_diag_text = format ["%1 | %2 | if (_exit == true) TEXT |kkkkkkkkk EXIT Lifeline_PlayerRevive.sqf [391] ", name _incap, name _player]; 
			if !(local _player) then {[_diag_text] remoteExec ["diag_log", 2];} else {diag_log _diag_text};
			//ENDDEBUG
			if (_incap getVariable ["ReviveInProgress",0] == 3) then {; 
				[[_incap], format ["%1|%2| PlayerRevive456",name _incap,name _player]] remoteExec ["Lifeline_reset2", _incap];
			};
		};
				

		if (_bandages > 1) then {
			// _player setcaptive false;diag_log format ["%1 [0240]!!!!!!!!! change var setcaptive = false !!!!!!!!!!!!!", name _player]; 
			_player setcaptive _captive;diag_log format ["%1 [0240]!!!!!!!!! change var setcaptive = %2 !!!!! ReviveInProgress: %3 !!!!!!!!", name _player, _captive, _player getVariable ["ReviveInProgress",0]]; 
		};
		
		// ============ WAKE UP, FINISHED
		
		// if (damage _incap <= 0.2) then { 
		if (_bandages <= 0 || Lifeline_BandageLimit == 1) then { 

			_incap setVariable ["damagesubstr", nil, true]; //added
			
			if !((_incap getVariable ["Lifeline_IncapMark",""]) == "") then {
				deleteMarker (_incap getVariable "Lifeline_IncapMark");
				_incap setVariable ["Lifeline_IncapMark","",true];
			};
			_goupI = (_incap getVariable ["Lifeline_Grp",(group _incap)]);
			_teamcolour = assignedTeam _incap;diag_log format ["%1 PLAYER REVIVE ASSIGNED TEAM %2", name _incap, _teamcolour];
			[_incap] joinSilent _goupI;
			_incap assignTeam _teamcolour;
			[_incap, (leader _goupI)] remoteExec ["doFollow", 0];
			[_incap, false] remoteExec ["setUnconscious",0];
			// Reset bleedout time var
			_incap setVariable ["LifelineBleedOutTime", 0, true];diag_log format ["%1 [240]!!!!!!!!! change var LifelinePairTimeOut = 0 !!!!!!!!!!!!!", name _incap];
			
			
			[_incap] spawn {
			params ["_incap"];	
				sleep 5;
				_captivei = _incap getVariable ["Lifeline_Captive", false];
				// _incap setCaptive false;	
				// _incap allowdamage true; diag_log format ["%1 | [0431][Lifeline_PlayerRevive.sqf] ALLOWDAMAGE SET: %2", name _incap, isDamageAllowed _incap];
				[_incap, true] remoteExec ["allowDamage",0];diag_log format ["%1 | [0267][Lifeline_PlayerRevive.sqf] ALLOWDAMAGE SET: %2", name _incap, isDamageAllowed _incap];
				// [_incap, false] remoteExec ["setCaptive",_incap];diag_log format ["%1 [0268]!!!!!!!!! change var setcaptive = false !!!!!!!!!!!!!", name _incap]; 	
				[_incap, _captivei] remoteExec ["setCaptive",0];diag_log format ["%1 [0268]!!!!!!!!! change var setcaptive = %2 !!!!! ReviveInProgress: %3 !!!!!!!!", name _incap, _captivei, _incap getVariable ["ReviveInProgress",0]]; 	
			};
		

			//newline
			 [_incap, _player] remoteExecCall ["enableCollisionWith", 0, _incap];

			//these vars gotten again to prevent timing issues (such as change of medic during player medic animation
			_Lifeline_AssignedMedic = _incap getVariable ["Lifeline_AssignedMedic",[]];
			_Lifeline_AssignedMedic_AI = _Lifeline_AssignedMedic select 0; //this is the other AI medic already on its way. This needs to be cancelled.
			
			diag_log format ["%1 | %2 ============= [258 Lifeline_PlayerRevive.sqf] ========== _Lifeline_AssignedMedic: %3", name _incap, name _player, _Lifeline_AssignedMedic];
			if (_Lifeline_AssignedMedic_AI isNotEqualTo []) then {
				diag_log format ["%1 | %2 ============= [259 Lifeline_PlayerRevive.sqf] ========== _Lifeline_AssignedMedic_AI: %3", name _incap, name _player, _Lifeline_AssignedMedic_AI];
			};
			
			if (_incap getVariable ["ReviveInProgress",0] == 3) then { 
				[[_incap], format ["%1|%2| PlayerRevive456",name _incap,name _player]] remoteExec ["Lifeline_reset2", _incap];
			};
			
			if (_Lifeline_AssignedMedic_AI isNotEqualTo []) then {
				// if !(_Lifeline_AssignedMedic_AI getVariable ["Lifeline_reset_trig",false]) then { 
					// _Lifeline_AssignedMedic_AI setVariable ["Lifeline_reset_trig", true, true]; diag_log format ["%1 | [PlayerRevive459]!!!!!!!!! _Lifeline_AssignedMedic_AI change var Lifeline_reset_trig = true !!!!!!!!!!!!!", name _Lifeline_AssignedMedic_AI]; // to stop double reset.
				if (_Lifeline_AssignedMedic_AI getVariable ["ReviveInProgress",0] in [1,2]) then {
					[[_Lifeline_AssignedMedic_AI],format ["%1|%2| AssignedMedic_AI: %3 PlayerRevive456",name _incap,name _player,name _Lifeline_AssignedMedic_AI]] remoteExec ["Lifeline_reset2", _Lifeline_AssignedMedic_AI];
				};
			};
		};	
		
	}; // end lifestate incap == "INCAPACITATED"


	// if (damage _incap <= 0.2) then {
	if (_bandages <= 0  || Lifeline_RevMethod == 1 ||  Lifeline_BandageLimit == 1) then { 

		// just in case another AI is reviving at same time, this will prevent double firing of wake up animation
		if (alive _incap && ((animationState _incap find "unconscious" == 0 && animationState _incap != "unconsciousrevivedefault" && animationState _incap != "unconsciousoutprone") || animationState _incap == "unconsciousrevivedefault")) then {
			[_incap, "unconsciousrevivedefault"] remoteExec ["SwitchMove", 0];
		};


		// Not sure if this is needed. 
		if (rating _player <0) then {_player addrating ((abs rating _player)+1)};

		//Incap Markers
		if !((_incap getVariable ["Lifeline_IncapMark",""]) == "") then {
			deleteMarker (_incap getVariable "Lifeline_IncapMark");
			_incap setVariable ["Lifeline_IncapMark","",true];
		};
		
		// _incap setVariable ["Lifeline_RevActionAdded",false,true];
		_incap setVariable ["Lifeline_Down",false,true];// for Revive Method 3
		_incap setVariable ["Lifeline_allowdeath",false,true];
		_incap setVariable ["Lifeline_bullethits",0,true];
		_incap setVariable ["Lifeline_canceltimer",false,true]; // if showing, cancel it.
		_incap setVariable ["Lifeline_countdown_start",false,true]; // if showing, cancel it.
		_incap doFollow leader _incap;		
		_incap setDamage 0;
		_incap setVariable ["ReviveInProgress",0,true]; //added
		// Lifeline_Process = Lifeline_Process - [_incap]; // TEMPUNCOMMENT
		// publicVariable "Lifeline_Process";// TEMPUNCOMMENT
		

		_actionId = _incap getVariable "Lifeline_ActionMenuWounds";
		if (!isNil "_actionId") then {
		// if (!isNil "_actionId" && Lifeline_BandageLimit > 1) then {
				[[_incap,_actionId],{params ["_incap","_actionId"];_incap setUserActionText [_actionId, ""];}] remoteExec ["call", 0, true];
				//DEBUG
				_diag_text = format ["%4|%5| [313 Lifeline_PlayerRevive.sqf] kkkkkkkkkkkkkkkkkkkk  REMOVE DAMAGE AND WAKE UP | DMG %2 | SUBTR %3 kkkkkkkkkkkkkkkkkkkkkkkkkkk", _bandages, damage _incap, _damagesubtract,name _incap,name _player]; if !(local _player) then {[_diag_text] remoteExec ["diag_log", 2];} else {diag_log _diag_text};
				_diag_text = format ["%4|%5| [313 Lifeline_PlayerRevive.sqf] kkkkkkkkkkkkkkkkkkkk  REMOVE DAMAGE AND WAKE UP | DMG %2 | SUBTR %3 kkkkkkkkkkkkkkkkkkkkkkkkkkk", _bandages, damage _incap, _damagesubtract,name _incap,name _player]; if !(local _player) then {[_diag_text] remoteExec ["diag_log", 2];} else {diag_log _diag_text};
				_diag_text = format ["%4|%5| [313 Lifeline_PlayerRevive.sqf] kkkkkkkkkkkkkkkkkkkk  REMOVE DAMAGE AND WAKE UP | DMG %2 | SUBTR %3 kkkkkkkkkkkkkkkkkkkkkkkkkkk", _bandages, damage _incap, _damagesubtract,name _incap,name _player]; if !(local _player) then {[_diag_text] remoteExec ["diag_log", 2];} else {diag_log _diag_text};
				//ENDDEBUG
		};
					
		//DEBUG
		/* 	_nul = _incap remoteExec [ "RemoveAllActions", 0, true ]; 
		
		 _nul = [_incap,1] remoteExec [ "removeaction", 0, true ]; //Remove action for all clients and JIP
		 _nul = [_incap,0] remoteExec [ "removeaction", 0, true ]; //Remove action for all clients and JIP
		 
		 _incap removeAction _actionId;
		 removeAllActions _incap; */
		// _incap setVariable ["num_bandages",nil,true]; 
		//ENDDEBUG
		
		// Remove yellow marker
		if (Lifeline_Revive_debug) then {
			_incap call Lifeline_delYelMark;
		};
	};	


	Lifeline_Process = Lifeline_Process - [_player]; 
	publicVariable "Lifeline_Process"; 

	// _player allowDamage true;

	//regain control of group.
	[(group _player), _player] remoteExec ["selectLeader", _player];
	{
		if (alive _player && !(lifestate _player == "incapacitated")) then {		
			[(group _player), _player] remoteExec ["selectLeader", _player];
			_teamcolour = assignedTeam _x; // team colour deleted with JoinSilent. This fixes.
			[_x] joinSilent group _player;
			_x assignTeam _teamcolour;		// team colour deleted with JoinSilent. This fixes.
		};
	} foreach units group _player;

	//DEBUG
	// code for later. Check if pistol in hand to get right animation
	/* // Check if the player has a pistol in hand
	if (currentWeapon player == "hgun_Pistol_01_F" || currentWeapon player == "hgun_P07_F") then {
		// Player has a pistol in hand
		hint "You have a pistol in hand!";
	} else {
		// Player does not have a pistol in hand
		hint "You do not have a pistol in hand.";
	}; */
	//ENDDEBUG

	[_player,_incap,_captive] spawn {
		params ["_player","_incap","_captive"];	
		_player setVariable ["Lifeline_Captive_Delay",true,true];
		sleep 5;
		if (_player getVariable ["ReviveInProgress",0] != 2) then { 
		// _player allowdamage true; diag_log format ["%1 | [0388][Lifeline_PlayerRevive.sqf] ALLOWDAMAGE SET: %2", name _player, isDamageAllowed _player];
		// _player setCaptive false; diag_log format ["%1 | [0389]!!!!!!!!! change var setCaptive = false !!!!!!!!!!!!!", name _incap];
		[_player, true] remoteExec ["allowDamage",0]; diag_log format ["%1 | [0390][Lifeline_PlayerRevive.sqf] ALLOWDAMAGE SET: %2", name _player, isDamageAllowed _player];
		// [_player, false] remoteExec ["setCaptive",_player];	 diag_log format ["%1 | [0391]!!!!!!!!! change var setCaptive = false !!!!!!!!!!!!!", name _player];
		[_player, _captive] remoteExec ["setCaptive",0];	 diag_log format ["%1 | [0391]!!!!!!!!! change var setCaptive = %2 !!!!! ReviveInProgress: %3 !!!!!!!!", name _player, _captive, _player getVariable ["ReviveInProgress",0]];
		_player setVariable ["Lifeline_Captive_Delay",false,true];
		};
	};

	

	//DEBUG
	// diag_log format ["uuuuuuuuuuuuuuuu TIME TOOK FOR BANDAGE: %1 uuuuuuuuuuuuuuuuuu", time - _timestamp];
	_diag_text = format ["Lifeline_PlayerRevive %2 | %3 uuuuuuuuuuuuuuuu TIME TOOK FOR BANDAGE: %1 uuuuuuuuuuuuuuuuuu", time - _timestamp, name _incap, name _player]; if !(local _player) then {[_diag_text] remoteExec ["diag_log", 2];} else {diag_log _diag_text};
	_diag_text = format ["Lifeline_PlayerRevive %1 | %2  ", name _incap, name _player]; 
	if !(local _player) then {[_diag_text] remoteExec ["diag_log", 2];} else {diag_log _diag_text};
	if !(local _player) then {[_diag_text] remoteExec ["diag_log", 2];} else {diag_log _diag_text};
	if !(local _player) then {[_diag_text] remoteExec ["diag_log", 2];} else {diag_log _diag_text};
	//ENDDEBUG

	//split Lifeline_Process up now

	Lifeline_Process = Lifeline_Process - [_player]; 
	publicVariable "Lifeline_Process"; 
	
	// new text system for proc pairs
	_Lifeline_AssignedMedic = _incap getVariable ["Lifeline_AssignedMedic",[]];
	_Lifeline_AssignedMedic = _Lifeline_AssignedMedic - [_player];
	_incap setVariable ["Lifeline_AssignedMedic", _Lifeline_AssignedMedic, true];	

	_player setVariable ["ReviveInProgress",0,true]; 
	// _player removeEventHandler ["AnimDone", _animdoneID];
	// _player removeEventHandler ["AnimStateChanged", _AnimStateChangedID];


