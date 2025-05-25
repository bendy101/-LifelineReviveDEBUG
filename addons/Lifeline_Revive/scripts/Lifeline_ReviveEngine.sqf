 diag_log "                                                                                 				           "; 
 diag_log "                                                                                  			               "; 
 diag_log "                                                                                    			               "; 
diag_log "                                                                                   		   	               '"; 
diag_log "                                                                                   			               '"; 
diag_log "============================================================================================================='";
diag_log "============================================================================================================='";
diag_log "========================================== Lifeline_ReviveEngine.sqf ja ==========================================='";
diag_log format ["========================================== %1     %2 ==========================================='", Lifeline_Version, Lifeline_Version_no];
diag_log "============================================================================================================='";



if (Lifeline_Voices == 1) then { Lifeline_UnitVoices = ["Adam", "Antoni", "Arnold", "Bill", "Callum", "Charlie", "Clyde", "Daniel", "Dave", "A006", "Alistair", "Allen", "Hugh", "Philemon","Bruce"]; };
if (Lifeline_Voices == 2) then { Lifeline_UnitVoices = ["A006", "Alistair", "Allen", "Bruce", "Charlie", "Daniel", "Dave", "Hugh", "Philemon"]; };
if (Lifeline_Voices == 3) then { Lifeline_UnitVoices = ["Adam", "Antoni", "Arnold", "Bill", "Callum", "Clyde"]; };

Lifeline_RevProtect_Set = {	
	if (Lifeline_RevProtect == 1) then {dmg_trig=false; cptv_trig=true};
	if (Lifeline_RevProtect == 2) then {dmg_trig=true; cptv_trig=true};
	if (Lifeline_RevProtect == 3) then {dmg_trig=true};//changed for antistasi
};

[] call Lifeline_RevProtect_Set;

if (Lifeline_Revive_debug) then {
	[] call serverSide_MissionSettings;//just diaglogs
};

//this forces Lifeline_RevMethod to value of 3 if ACE is loaded. Double checked.
if (!isNil "oldAce") then {
	Lifeline_RevMethod = 3;
};

publicVariable "Lifeline_Scope";
Lifeline_incapacitated = [];
publicVariable "Lifeline_incapacitated";
Lifeline_Process = [];
publicVariable "Lifeline_Process";
Lifeline_medics = [];
// Lifeline_LimitDist = 4000;
Lifeline_textsize = str 1.5;
Lifeline_players_autorev = [];
Lifeline_UnitVoices = Lifeline_UnitVoices call BIS_fnc_arrayShuffle;
Lifeline_UnitVoicesCount = count Lifeline_UnitVoices;
Lifeline_mascas = false;
Lifeline_Group_Mascal = [];
// Lifeline_PVPstatus = false;
// publicVariable "Lifeline_PVPstatus";






// RadioPartA = ["_hangtight1","_greetA1","_greetA2","_greetA3","_greetB2","_greetB3","_hanginthere1","_staybuddy1"];
RadioPartA = ["_hangtight1"];
RadioPartB = ["_coming1","_comingtogetyou1","_onmyway1","_theresoon1"];

if (Lifeline_Revive_debug) then {{[_x, 100000] remoteExec ["addRating", _x]} foreach allplayers;};





// PVP check
/* if (hasInterface) then {
	playerSide1 = side group player; 
	_currentSides = missionNamespace getVariable ["Lifeline_PVPcheckSides", []];
	_currentSides pushBackUnique playerSide1;
	missionNamespace setVariable ["Lifeline_PVPcheckSides", _currentSides, true];
	enemyUnitsJa = allUnits select {[playerSide1, side group _x] call BIS_fnc_sideIsEnemy};
	publicVariable "enemyUnitsJa";
};
_playersides = missionNamespace getVariable ["Lifeline_PVPcheckSides", []];
if (count _playersides > 1) then {
	Lifeline_PVPstatus = true;
};
if (count _playersides == 1) then {
	Lifeline_PVPstatus = false;
};
publicVariable "Lifeline_PVPstatus";

 */



// wait for players 
waitUntil {count (allPlayers - entities "HeadlessClient_F") >0};

// THIS IS AN ARRAY OF ENEMY SIDES

//added 2025-02-21 17:24:43 WIP for Opfor
// playerSide1 = side group player; //fix for dedicated
// enemyUnitsJa = allUnits select {[playerSide1, side group _x] call BIS_fnc_sideIsEnemy};


// if a teamswitch mission
if (teamSwitchEnabled) then {
	
	
	addMissionEventHandler ["TeamSwitch", {
		params ["_previousUnit", "_newUnit"];
		diag_log format ["xxxxxxxxxxxxxxxxxxxxxxxxx TEAM SWITCH baby prev %1 new %2 xxxxxxxxxxxxxxxxxxxxxxxx", name _previousUnit, name _newUnit];
		// diag_log format ["alldisplays %1", allDisplays];
		// playsound "siren1";
		onTeamSwitch { 
			_previousUnit enableAI "TeamSwitch";		
		};

		// _newUnit addEventHandler ["Respawn", { // do I need this?
		// 	params ["_unit", "_corpse"];
		// 	diag_log format ["%1 | %2 | [161]===================== RESPAWN +++++++++++++++++++++++++++++++", name _unit, name _corpse];
		// }];
		if (lifeState _newUnit == "INCAPACITATED" && Lifeline_RevMethod == 2) then { 
			if ((Lifeline_HUD_distance == true || Lifeline_cntdwn_disply != 0) && isPlayer _newUnit) then {
				_seconds = Lifeline_cntdwn_disply;
				// if (!(_newUnit getVariable ["Lifeline_countdown_start",false]) && Lifeline_cntdwn_disply != 0 && Lifeline_RevMethod != 3 && Lifeline_HUD_distance == false) then {
				// 	_newUnit setVariable ["Lifeline_countdown_start",true,true];
				// 	[[_newUnit,_seconds], Lifeline_countdown_timer2] remoteExec ["spawn",_newUnit, true];
				// }; 
				if (!(_newUnit getVariable ["Lifeline_countdown_start",false])) then {
					_newUnit setVariable ["Lifeline_countdown_start",true,true];
					[[_newUnit,_seconds], Lifeline_countdown_timer2] remoteExec ["spawn",_newUnit, true];
				};
				if ((_previousUnit getVariable ["Lifeline_countdown_start",false])) then {
					_previousUnit setVariable ["Lifeline_countdown_start",false,true];
				};
			};	
		};
	}];

	//change font colour in teamswitch pop-up for incap units
	if (hasInterface) then {
		fnc_teamSwitch = { 
		disableSerialization; 
		params ["_type","_ctrlDispl"]; 
		private _idc = ctrlIDC (_ctrlDispl select 0); 
		private _selectedIndex = _ctrlDispl param [1]; 
		_displ = findDisplay 632; 
		_ctrl101 = _displ displayCtrl 101; 
		_cnt = (lbsize 101) -1; 
		for "_i" from 0 to _cnt do { 
			_selectedUnit = switchableUnits param [_i,objNull]; 
			_unit = vehicle _selectedUnit; 
			/* if (lifeState _unit == "incapacitated") then { 
			//lbSetText [_idc,_i,"unconscious unit"]; 
			//lbSetTooltip [_idc, _i, "unconscious unit"]; 
			lbSetColor [_idc, _i,[1,0,0,1]];	// CHANGE COLOR HERE (R,G,B,A) 
			};  */
			if (_unit getVariable ["ReviveInProgress",0] == 0 && lifestate _unit == "INCAPACITATED") then {
				// lbSetColor [_idc, _i,[255,191,167,1]];	// CHANGE COLOR HERE (R,G,B,A) 
				lbSetColor [_idc, _i,[1,0,0,1]];	// CHANGE COLOR HERE (R,G,B,A) //RED
			};		
			if (_unit getVariable ["ReviveInProgress",0] == 3 && lifestate _unit == "INCAPACITATED") then {
				_medic = (_unit getVariable ["Lifeline_AssignedMedic", []]) select 0;
				if (_medic getVariable ["ReviveInProgress",0] == 1) then {
					// lbSetColor [_idc, _i,[0.98, 0.67, 0.23, 1]];	// CHANGE COLOR HERE (R,G,B,A) //ORANGE
					lbSetColor [_idc, _i,[0.996, 0.48, 0.48, 1]];	// CHANGE COLOR HERE (R,G,B,A) //LIGHT RED
					lbSetText [_idc, _i, format ["%1 ← ", lbText [_idc, _i]]]; 
				};			
				if (_medic getVariable ["ReviveInProgress",0] == 2) then {
					lbSetColor [_idc, _i,[0.345, 0.839, 0.553, 1]];	// CHANGE COLOR HERE (R,G,B,A) //GREEN
					// lbSetColor [_idc, _i,[0.99, 0.84, 0.63, 1]];	// CHANGE COLOR HERE (R,G,B,A) //LIGHT ORANGE
					lbSetText [_idc, _i, format ["%1 ↑ ", lbText [_idc, _i]]]; 
				};
			};
			if (_unit getVariable ["ReviveInProgress",0] == 1) then {
				// lbSetColor [_idc, _i,[0.39, 1, 0.43, 1]];
				lbSetColor [_idc, _i,[0.98, 0.94, 0.87, 1]];	// CHANGE COLOR HERE (R,G,B,A) //  light beige/cream color.
				lbSetText [_idc, _i, format ["%1 → ", lbText [_idc, _i]]]; // Add plus symbol to name
			}; 		
			if (_unit getVariable ["ReviveInProgress",0] == 2) then {
				// lbSetColor [_idc, _i,[0.39, 1, 0.43, 1]];	// CHANGE COLOR HERE (R,G,B,A) // GREEN
				lbSetColor [_idc, _i,[0.98, 0.94, 0.87, 1]];	// CHANGE COLOR HERE (R,G,B,A) // light beige/cream color.
				lbSetText [_idc, _i, format ["%1 + + +", lbText [_idc, _i]]]; // Add plus symbol to name
			}; 
		}; 
		if (_type == 1) then {true}; 
		//this turns of the button to switch into unit
		/* if (lifeState (vehicle (switchableUnits param [_selectedIndex,objNull])) == "incapacitated") then { 
			(_displ displayCtrl 1) ctrlShow false 
		} else { 
			(_displ displayCtrl 1) ctrlShow true 
		}  */
		}; 



		[] spawn { 
		while {true} do { 
			waituntil {sleep 0.2; !isnull findDisplay 632}; 
			(findDisplay 632 displayCtrl 101) ctrlAddEventHandler ["LBSelChanged", 
			"[0,_this] call fnc_teamSwitch" 
			]; 
			(findDisplay 632 displayCtrl 101) ctrlsetEventHandler ["LBDblClick", 
			"[1,_this] call fnc_teamSwitch" 
			]; 
			waitUntil {sleep 0.2; isNull findDisplay 632}; 
		}; 
		};
	}; // if (hasInterface) then {	


}; // if (BI_RespawnDetected in [4,5]) then {


// === NON-ACE FUNCTIONS
if (Lifeline_RevMethod != 3) then {  
	[] execvm "Lifeline_Revive\scripts\non_ace\Lifeline_Functions.sqf";
}; 
// === ACE FUNCTIONS
if (Lifeline_RevMethod == 3) then {  
	[] execvm "Lifeline_Revive\scripts\ace\Lifeline_ACE_Functions.sqf";
}; 	

// Add data to all units in scope - Damage Handler for non-ace version and settings for both






if (isServer) then {

	Lifeline_All_Units = [];
	publicVariable "Lifeline_All_Units";
	Lifelinecompletedinit = 1; //just for the hint showing units initializing
	Lifelineunitscount_pre = 0;

	if (hasInterface) then {
		Lifeline_Side = side group player;
		publicVariable "Lifeline_Side";
		diag_log format ["========================== SIDE GATE hasinterface Lifeline_Side: %1", Lifeline_Side];
	} else {
		_players = allPlayers - entities "HeadlessClient_F";
		Lifeline_Side = side (_players select 0); //
		publicVariable "Lifeline_Side"; // THIS IS A SINGLE SIDE. NEED TO UPDATE TO ARRAY VERSION  FOR ALLIES.
		diag_log format ["========================== SIDE GATE DEDI SERVER Lifeline_Side: %1", Lifeline_Side];
	};

	Lifeline_OPFOR_Sides = Lifeline_Side call BIS_fnc_enemySides;
	publicVariable "Lifeline_OPFOR_Sides"; 



	Lifeline_DH_update = {
		// IMPORTANT: Fix the initialization counter logic
		// This ensures the count values are synchronized properly
		Lifelineunitscount_pre = count Lifeline_All_Units;
		Lifelinecompletedinit = Lifelineunitscount_pre;

		// if (Lifelinecompletedinit > 1) then {	
		// 	Lifelineunitscount_pre = (count Lifeline_All_Units);
		// };

		if (Lifeline_PVPstatus) then {
				// GROUP
				if (Lifeline_Scope == 1) then {_groupsWPlayers = allGroups select {{isPlayer _x} count (units _x) > 0 }; Lifeline_All_Units = allunits select {(group _x) in _groupsWPlayers && simulationEnabled _x && rating _x > -2000}};
				// PLAYABLE SLOTS
				if (Lifeline_Scope == 2) then {Lifeline_All_Units = allunits select {simulationEnabled _x && ((_x in playableUnits) || (_x in switchableUnits)) && rating _x > -2000}};
				// SIDE	
				if (Lifeline_Scope == 3) then {Lifeline_All_Units = allunits select {simulationEnabled _x && rating _x > -2000}};
		};

		if (!Lifeline_PVPstatus) then {
			if (Lifeline_Include_OPFOR) then {
				// GROUP
				if (Lifeline_Scope == 1) then {_groupsWPlayers = allGroups select {{isPlayer _x} count (units _x) > 0 }; Lifeline_All_UnitBluFor = allunits select {(group _x) in _groupsWPlayers && side (group _x) == Lifeline_Side && simulationEnabled _x && rating _x > -2000}};
				// PLAYABLE SLOTS
				if (Lifeline_Scope == 2) then {Lifeline_All_UnitBluFor = allunits select {side (group _x) == Lifeline_Side && simulationEnabled _x && ((_x in playableUnits) || (_x in switchableUnits)) && rating _x > -2000}};
				// SIDE	
				if (Lifeline_Scope == 3) then {Lifeline_All_UnitBluFor = allunits select {side (group _x) == Lifeline_Side && simulationEnabled _x && rating _x > -2000}};
				// OPFOR
				Lifeline_All_UnitOpFor = allunits select {(side (group _x) in Lifeline_OPFOR_Sides && simulationEnabled _x )};
				// ALL UNITS
				Lifeline_All_Units = Lifeline_All_UnitBluFor + Lifeline_All_UnitOpFor;
			};
			if (!Lifeline_Include_OPFOR) then {
				// GROUP
				if (Lifeline_Scope == 1) then {_groupsWPlayers = allGroups select {{isPlayer _x} count (units _x) > 0 }; Lifeline_All_Units = allunits select {side (group _x) == Lifeline_Side && (group _x) in _groupsWPlayers && simulationEnabled _x && rating _x > -2000}};
				// PLAYABLE SLOTS
				if (Lifeline_Scope == 2) then {Lifeline_All_Units = allunits select {side (group _x) == Lifeline_Side && simulationEnabled _x && ((_x in playableUnits) || (_x in switchableUnits)) && rating _x > -2000}};				
				// SIDE	
				if (Lifeline_Scope == 3) then {Lifeline_All_Units = allunits select {side (group _x) == Lifeline_Side && simulationEnabled _x && rating _x > -2000}};
			};	
		};

		//version to exclude units that are invincible. npcs etc
		//DEBUG
		/* if (Lifeline_PVPstatus) then {
				// GROUP
				if (Lifeline_Scope == 1) then {_groupsWPlayers = allGroups select {{isPlayer _x} count (units _x) > 0 }; Lifeline_All_Units = allunits select {(group _x) in _groupsWPlayers && simulationEnabled _x && (isDamageAllowed _x && _x getVariable ["ReviveInProgress",0] == 0 || _x getVariable ["ReviveInProgress",0] != 0) && rating _x > -2000}};
				// PLAYABLE SLOTS
				if (Lifeline_Scope == 2) then {Lifeline_All_Units = allunits select {simulationEnabled _x && ((_x in playableUnits) || (_x in switchableUnits)) && (isDamageAllowed _x && _x getVariable ["ReviveInProgress",0] == 0 || _x getVariable ["ReviveInProgress",0] != 0) && rating _x > -2000}};
				// SIDE	
				if (Lifeline_Scope == 3) then {Lifeline_All_Units = allunits select {simulationEnabled _x && (isDamageAllowed _x && _x getVariable ["ReviveInProgress",0] == 0 || _x getVariable ["ReviveInProgress",0] != 0) && rating _x > -2000}};
		};
		if (!Lifeline_PVPstatus) then {
			if (Lifeline_Include_OPFOR) then {
				// GROUP
				if (Lifeline_Scope == 1) then {_groupsWPlayers = allGroups select {{isPlayer _x} count (units _x) > 0 }; Lifeline_All_UnitBluFor = allunits select {(group _x) in _groupsWPlayers && side (group _x) == Lifeline_Side && simulationEnabled _x && (isDamageAllowed _x && _x getVariable ["ReviveInProgress",0] == 0 || _x getVariable ["ReviveInProgress",0] != 0) && rating _x > -2000}};
				// PLAYABLE SLOTS
				if (Lifeline_Scope == 2) then {Lifeline_All_UnitBluFor = allunits select {side (group _x) == Lifeline_Side && simulationEnabled _x && ((_x in playableUnits) || (_x in switchableUnits)) && (isDamageAllowed _x && _x getVariable ["ReviveInProgress",0] == 0 || _x getVariable ["ReviveInProgress",0] != 0) && rating _x > -2000}};
				// SIDE	
				if (Lifeline_Scope == 3) then {Lifeline_All_UnitBluFor = allunits select {side (group _x) == Lifeline_Side && simulationEnabled _x && (isDamageAllowed _x && _x getVariable ["ReviveInProgress",0] == 0 || _x getVariable ["ReviveInProgress",0] != 0) && rating _x > -2000}};
				// OPFOR
				Lifeline_All_UnitOpFor = allunits select {(side (group _x) in Lifeline_OPFOR_Sides && simulationEnabled _x && (isDamageAllowed _x && _x getVariable ["ReviveInProgress",0] == 0 || _x getVariable ["ReviveInProgress",0] != 0))};
				// ALL UNITS
				Lifeline_All_Units = Lifeline_All_UnitBluFor + Lifeline_All_UnitOpFor;
			};
			if (!Lifeline_Include_OPFOR) then {
				// GROUP
				if (Lifeline_Scope == 1) then {_groupsWPlayers = allGroups select {{isPlayer _x} count (units _x) > 0 }; Lifeline_All_Units = allunits select {side (group _x) == Lifeline_Side && (group _x) in _groupsWPlayers && simulationEnabled _x && (isDamageAllowed _x && _x getVariable ["ReviveInProgress",0] == 0 || _x getVariable ["ReviveInProgress",0] != 0) && rating _x > -2000}};
				// PLAYABLE SLOTS
				if (Lifeline_Scope == 2) then {Lifeline_All_Units = allunits select {side (group _x) == Lifeline_Side && simulationEnabled _x && ((_x in playableUnits) || (_x in switchableUnits)) && (isDamageAllowed _x && _x getVariable ["ReviveInProgress",0] == 0 || _x getVariable ["ReviveInProgress",0] != 0) && rating _x > -2000}};				
				// SIDE	
				if (Lifeline_Scope == 3) then {Lifeline_All_Units = allunits select {side (group _x) == Lifeline_Side && simulationEnabled _x && (isDamageAllowed _x && _x getVariable ["ReviveInProgress",0] == 0 || _x getVariable ["ReviveInProgress",0] != 0) && rating _x > -2000}};
			};	
		}; */
		//ENDDEBUG

		
		/* if (Lifeline_Scope != 1) then {
			if (Lifeline_PVPstatus) then {			        
				// Lifeline_All_Units = Lifeline_All_Units select {(side (group _x) == Lifeline_Side) || (side (group _x) in Lifeline_OPFOR_Sides)};
				Lifeline_All_UnitBluFor = Lifeline_All_Units select {(side (group _x) == Lifeline_Side)};
				Lifeline_All_UnitOpFor = Lifeline_All_Units select {(side (group _x) in Lifeline_OPFOR_Sides)};
				Lifeline_All_Units = Lifeline_All_UnitBluFor + Lifeline_All_UnitOpFor;
			} else {
				Lifeline_All_Units = Lifeline_All_Units select {(side (group _x) == Lifeline_Side)};
			};
		}; */

		publicVariable "Lifeline_All_Units";
		waitUntil {count Lifeline_All_Units >0};
		Lifelineunitscount = (count Lifeline_All_Units); // added to indicate with a hint when all units are processed below	

		if (Lifelineunitscount != Lifelineunitscount_pre) then {
			Lifelinecompletedinit = Lifelineunitscount_pre + 1;
		};

		// Add needed settings to each unit.
		{
			if !(_x getVariable ["LifelineDHadded",false]) then {
					if (Lifeline_added_units_hint_trig) then {
						[format ["Lifeline Revive Units %1 of %2", Lifelinecompletedinit, Lifelineunitscount]] remoteExec ["hintsilent", allPlayers];
					};

					Lifelinecompletedinit = Lifelinecompletedinit + 1;

					// add voice identifiers (the orignal voiceover artists name)	
					if ((teamSwitchEnabled == false && !(isPlayer _x)) || teamSwitchEnabled == true) then {
						_x setVariable ["Lifeline_Voice", Lifeline_UnitVoices select (Lifeline_UnitVoicesCount - 1), true];
						// diag_log format ["kkkkkkkkkkkkkkkkk VOICE PAIRING. UNIT: %1 VOICE: %3", name _x, _x, Lifeline_UnitVoices select (Lifeline_UnitVoicesCount - 1)];
							if (Lifeline_UnitVoicesCount == 0) then {
							Lifeline_UnitVoicesCount = count Lifeline_UnitVoices;
							};
						Lifeline_UnitVoicesCount = Lifeline_UnitVoicesCount - 1;
					};				

				//set skill for your AI Units	
				if (Lifeline_AI_skill > 0) then {
                    if (!Lifeline_Include_OPFOR || Lifeline_PVPstatus) then {
						_x setSkill Lifeline_AI_skill;
					} else {
						if (side group _x == Lifeline_Side) then {
							_x setSkill Lifeline_AI_skill;
						};
					};
				};

				//set Fatigue for all units non-ACE. Bypass if 0
				if (Lifeline_RevMethod == 2) then {  
					if (Lifeline_Fatigue > 0) then {
						if (Lifeline_Fatigue == 2) then {
							if (local _x) then {_x enableFatigue false;} else {[_x, false] remoteExec ["enableFatigue", _x];};
						} else {
							if (local _x) then {_x enableFatigue true;} else {[_x, true] remoteExec ["enableFatigue", _x];};
						};				
					};
				};

				//make units "explosivespecialists" trait. Its annoying not being able to unset a bomb when accidently set. 
				if (Lifeline_ExplSpec) then {
					if (!Lifeline_Include_OPFOR || Lifeline_PVPstatus) then {
						if (local _x) then {_x setUnitTrait ["ExplosiveSpecialist", true];} else {[_x, ["ExplosiveSpecialist", true]] remoteExec ["setUnitTrait", _x]}
					} else {
						if (side group _x == Lifeline_Side) then {
							if (local _x) then {_x setUnitTrait ["ExplosiveSpecialist", true];} else {[_x, ["ExplosiveSpecialist", true]] remoteExec ["setUnitTrait", _x]}
						};
					};				
				};

				if (Lifeline_RevMethod == 2) then { 
					_x setVariable ["Lifeline_allowdeath",false,true];
				};

				// add Damage Handler for non-ace version
				if (Lifeline_RevMethod == 2) then {  
					if (Lifeline_PVPstatus == false && Lifeline_Include_OPFOR == true && (side group _X) in Lifeline_OPFOR_Sides) then {
						[_x] execvm "Lifeline_Revive\scripts\non_ace\Lifeline_DamageHandlerOPFOR.sqf";
					} else {
						[_x] execvm "Lifeline_Revive\scripts\non_ace\Lifeline_DamageHandler.sqf";
					};
				}; 

				// add groups 
				if ((_x getVariable ["Lifeline_Grp",""]) == "") then {
					_goup = group _x;
					_x setVariable ["Lifeline_Grp", _goup, true];
					_x setVariable ["LifelinePairTimeOut",0,true];//diag_log format ["%1 [304]!!!!!!!!! change var LifelinePairTimeOut = 0 !!!!!!!!!!!!!", name _x];
				};

				// Add vehicle to Lifeline_All_Units -- this should be OFF. Only need to know when medic is selected.
				/* if !(assignedvehicle _x isEqualTo (_x getVariable ["AssignedVeh", objNull])) then {
					_vehicle = assignedvehicle _x;
					_x setVariable ["AssignedVeh", _vehicle, true];
				}; */

				// add death event handler 
				_x addMPEventHandler ["MPKilled", {
						params ["_unit", "_killer", "_instigator", "_useEffects"];	
						[[_unit],"killed EH [320] _Global.sqf"] call Lifeline_reset2;
						if (Lifeline_Revive_debug && Lifeline_PVPstatus == false && Lifeline_Include_OPFOR == true && (side group _X) in Lifeline_OPFOR_Sides) then {
							if (Lifeline_RevProtect == 1) then {
								if (Lifeline_debug_soundalert && Lifeline_soundalert_died) then {["memberdied1"] remoteExec ["playSound",0];};
							};
							if (isNull (findDisplay 49)) then {
								[_unit,"KILLED"] remoteExec ["serverSide_unitstate", 2];
								["KILLED"] remoteExec ["serverSide_Globals", 2]
							};
						};
				}];


				// set "added" trigger 
				_x setVariable ["LifelineDHadded",true,true];

				// sleep 0.1;
				sleep 0.05;

			}; // end (_x getVariable ["LifelineDHadded",false]

		} foreach Lifeline_All_Units;


		publicVariable "Lifeline_All_Units";

		Lifeline_All_Units

	}; // end Lifeline_DH_update

	[] call Lifeline_DH_update; diag_log "kkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkk [330] [] call Lifeline_DH_update ";
	

	//DEBUG
	//====== BI REVIVE ADJUST
	/* if (Lifeline_RevMethod != 3) then {
		diag_log format ["========= woppity bits Lifeline_RevMethod %1 teamSwitchEnabled %2 BI_RespawnDetected %3",Lifeline_RevMethod,teamSwitchEnabled,BI_RespawnDetected];
		if (Lifeline_RevMethod == 1 && teamSwitchEnabled == false && BI_RespawnDetected != 0) then {
			diag_log "===========ENABLE BI REVIVE=============";
			bis_reviveParam_mode = 1;
			bis_reviveParam_bleedOutDuration = 99999;
			if (Lifeline_InstantDeath == 0) then {
				bis_reviveParam_unconsciousStateMode = 0;
			} else {
				bis_reviveParam_unconsciousStateMode = 1;
			};
			[] call BIS_fnc_reviveInit;
		};	
		// although not needed (according to tests), better to also do this for Lifeline_RevMethod 2, coz thats what its for.
		if (Lifeline_RevMethod == 2) then {
			bis_reviveParam_mode = 0;
			[] call BIS_fnc_reviveInit;
		};
	}; */
	//ENDDEBUG
	
}; // end isserver


//=================================================================================================================
//============================== LOOPS ============================================================================
//=================================================================================================================

if (isServer) then {
	[] spawn {

		//hackfix spawn switches
		hackfix_invincible_units = true; // fix bugged invincible units
		hackfix_captive_units = true; // fix bugged captive units
		hackfix_bleedout_time = true; // fix bugged bleedout time
		hackfix_captive_incap = true; // captive when incapitated, force it.
		

				
		while {true} do {
			// _alldown = true;  // no longer needed. was for old method MASCAL
			// _autorevive = false; // no longer needed. was for old method MASCAL
			_crouchtrig = false;
			// _incappos = nil;  // no idea what this was for

			{
				if (Lifeline_Idle_Crouch) then {
					_crouchtrig = _x getVariable ["Lifeline_crouchtrig",false];
				};
				
				//check if bleeding. both for ACE and non-ACE
				_isbleeding = false;
				if (Lifeline_RevMethod == 3) then {
					_isbleeding = [_x] call ace_medical_blood_fnc_isBleeding;
				} else {
					if (damage _x >=0.2 || _x getHitPointDamage "hitlegs" >= 0.5) then { 
						_isbleeding = true;
					};
				};

				// Self heal for AI
				if (!isPlayer _x && !(lifestate _x == "INCAPACITATED") && alive _x && _isbleeding == true 
					&& _x getVariable ["Lifeline_selfheal_progss",false] == false && Lifeline_SelfHeal_Cond > 0
					&& getSuppression _x < 0.5 //new line
				) then {
					diag_log format ["%1 [1936] !!!!!!!!!!!!!!!! spawn self heal !!!!!!!!!!!!! DMG %2 STATE %3 Lifeline_selfheal_progss %4", name _x, damage _x, lifestate _x, _x getVariable ["Lifeline_selfheal_progss",false]];
					_x spawn Lifeline_SelfHeal;
				};
				

				//DEBUG
				//================ foreach moved here
	
				//Remove from Lifeline_revive if unit has been a bad boy
				// if (rating _x <= -2000) then {Lifeline_All_Units = Lifeline_All_Units - [_x]; diag_log format ["%1 ===== REMOVE FOR Lifeline REVIVE> UNIT BAD BOY ==========", name _x];};
				//ENDDEBUG

				
				// Add Player incap to incap array
				//DEBUG
				// if (isplayer _x && lifeState _x == "INCAPACITATED" &&  !(_x in Lifeline_incapacitated)) then {
				//ENDDEBUG
				if (lifeState _x == "INCAPACITATED" &&  !(_x in Lifeline_incapacitated)) then {
					Lifeline_incapacitated pushBackUnique _x;
					publicVariable "Lifeline_incapacitated";
					/* if (_x in Lifeline_Process) then {
						Lifeline_Process = Lifeline_Process - [_x];
						publicVariable "Lifeline_Process";
					}; */
				};
				

				// Still in incap array - lifestate not incap = remove
				if (!(lifeState _x == "INCAPACITATED") && (_x in Lifeline_incapacitated)) then {
					Lifeline_incapacitated = Lifeline_incapacitated - [_x];
					publicVariable "Lifeline_incapacitated";
					Lifeline_Process = Lifeline_Process - [_x];
					publicVariable "Lifeline_Process";
				};
				
				//DEBUG
				// Remove captive state for medics and incaps
				// if (captive _x && !(_x in Lifeline_Process) && !(lifeState _x == "INCAPACITATED")) then {
					// [_x,false] remoteExec ["setCaptive",_x];diag_log format ["%1 | [0353]!!!!!!!!! change var setCaptive = false !!!!!!!!!!!!!", name _x];
				// };
				//ENDDEBUG

				// Clear processing if no incap
				if (count Lifeline_incapacitated == 0 && count Lifeline_Process >0) then {
					Lifeline_Process = [];
					publicVariable "Lifeline_Process";
				};

				// NON-ACE: These fixes are for when damage is applied but it hasnt gone through the damage event handler. (such as scripted damage)
				if (Lifeline_RevMethod == 2) then {
					if (Debug_unconsciouswithouthandler && lifestate _x == "INCAPACITATED" && alive _x && !(_x in Lifeline_incapacitated) && !(_x getVariable ["Lifeline_Down",false])) then {
						_damage = damage _x;
						diag_log format ["%1 | !!!!!!!!!!!!!! UNCONSC WITHOUT DAMAGE HANDLER !!!!!!!!!!!!!!!! TOTDMG %2'", name _x, _damage];
						diag_log format ["%1 | !!!!!!!!!!!!!! UNCONSC WITHOUT DAMAGE HANDLER !!!!!!!!!!!!!!!! TOTDMG %2", name _x, _damage];
						diag_log format ["%1 | !!!!!!!!!!!!!! UNCONSC WITHOUT DAMAGE HANDLER !!!!!!!!!!!!!!!! TOTDMG %2", name _x, _damage];
						if (Lifeline_Revive_debug) then {["unconsciouswithouthandler"] remoteExec ["playSound",2];
							if (Lifeline_hintsilent) then {hintsilent format ["%1 UNCONSC WITHOUT DAMAGE HANDLER", name _x]};
						};
							[_x,_damage,true] call Lifeline_Incapped; 
					};

					if (Debug_overtheshold && lifestate _x != "INCAPACITATED" && alive _x && damage _x > Lifeline_IncapThres && !(_x in Lifeline_incapacitated) && !(_x getVariable ["Lifeline_Down",false])) then {
						[_x] spawn {
							params ["_x"];
							// sleep 5;
							sleep 3;
							if (Debug_overtheshold && lifestate _x != "INCAPACITATED" && alive _x && damage _x > Lifeline_IncapThres && !(_x in Lifeline_incapacitated) && !(_x getVariable ["Lifeline_Down",false])) then {
								_damage = damage _x;
								diag_log format ["%1 | !!!!!!!!!!!!!! DAMAGE OVER THRESH WITHOUT HANDLER !!!!!!!!!!!!!!!! TOTDMG %2'", name _x, _damage];
								diag_log format ["%1 | !!!!!!!!!!!!!! DAMAGE OVER THRESH WITHOUT HANDLER !!!!!!!!!!!!!!!! TOTDMG %2", name _x, _damage];
								diag_log format ["%1 | !!!!!!!!!!!!!! DAMAGE OVER THRESH WITHOUT HANDLER !!!!!!!!!!!!!!!! TOTDMG %2", name _x, _damage];
								if (Lifeline_Revive_debug) then {
									if (Lifeline_debug_soundalert) then {["overtheshold"] remoteExec ["playSound",2]};
									if (Lifeline_hintsilent) then {hintsilent format ["%1 DAMAGE OVER THRESH WITHOUT HANDLER", name _x]};
								};
								[_x,_damage,true] call Lifeline_Incapped; 
							}; // if
						}; //spawn
					};
					
				};		

				//HEALED OUTSIDE SCRIPT - setUnconscious method:. this is to cover for 3rd party script healing - such as mission code or revived in debug console. It will reset whats needed.
				if (Debug_Lifeline_downequalstrue && lifestate _x != "INCAPACITATED" && alive _x && (_x in Lifeline_incapacitated || Lifeline_RevMethod == 2 && _x getVariable ["Lifeline_Down",false])) then {
						[_x] spawn {
						params ["_x"];
						sleep 5;
						if (Debug_Lifeline_downequalstrue && lifestate _x != "INCAPACITATED" && alive _x && (_x in Lifeline_incapacitated || Lifeline_RevMethod == 2 && _x getVariable ["Lifeline_Down",false])) then {
							diag_log format ["%1 | !!!!!!!!!!!!!! NOT DOWN, but Lifeline_Down = true (incincible) FIX !!!!!!!!!!!!!!!! TOTDMG %2'", name _x, damage _x];
							diag_log format ["%1 | !!!!!!!!!!!!!! NOT DOWN, but Lifeline_Down = true (incincible) FIX !!!!!!!!!!!!!!!! TOTDMG %2", name _x, damage _x];
							diag_log format ["%1 | !!!!!!!!!!!!!! NOT DOWN, but Lifeline_Down = true (incincible) FIX !!!!!!!!!!!!!!!! TOTDMG %2", name _x, damage _x];
							if (Lifeline_Revive_debug) then {
								if (Lifeline_debug_soundalert) then {["Lifeline_downequalstrue"] remoteExec ["playSound",2]};
								if (Lifeline_hintsilent) then {hintsilent format ["%1 NOT DOWN, but Lifeline_Down = true", name _x]};
							};
								_x setVariable ["Lifeline_Down",false,true];
								// _x allowDamage true; diag_log format ["%1 | [0409][Lifeline_ReviveEngine.sqf] ALLOWDAMAGE SET: %2", name _x, isDamageAllowed _x];
								// _x setCaptive false; diag_log format ["%1 | [0340]!!!!!!!!! change var setCaptive = false !!!!!!!!!!!!!", name _x];
								// [_x, true] remoteExec ["allowDamage",_x];diag_log format ["%1 | [0340][Lifeline_ReviveEngine.sqf] ALLOWDAMAGE SET: %2", name _x, isDamageAllowed _x];
								// [_x, false] remoteExec ["setCaptive",_x];diag_log format ["%1 | [0340]!!!!!!!!! change var setCaptive = false !!!!!!!!!!!!!", name _x];
								_captive = _x getVariable ["Lifeline_Captive", false];
								// if !(local _x) then {
									[_x, true] remoteExec ["allowDamage",0];diag_log format ["%1 | [0412][Lifeline_ReviveEngine.sqf] ALLOWDAMAGE SET: %2", name _x, isDamageAllowed _x];
									// [_x, false] remoteExec ["setCaptive",_x];diag_log format ["%1 | [0413]!!!!!!!!! change var setCaptive = false !!!!!!!!!!!!!", name _x];
									[_x, _captive] remoteExec ["setCaptive",0];diag_log format ["%1 | [0413]!!!!!!!!! change var setCaptive = %2 !!!!!! ReviveInProgress: %3 !!!!!!!", name _x, _captive, _x getVariable ["ReviveInProgress",0]];
							/* 	} else {
									_x allowDamage true; diag_log format ["%1 | [0415][Lifeline_ReviveEngine.sqf] ALLOWDAMAGE SET: %2", name _x, "true"];
									// _x setCaptive false; diag_log format ["%1 | [0416]!!!!!!!!! change var setCaptive = false !!!!!!!!!!!!!", name _x];								
									_x setCaptive _captive; diag_log format ["%1 | [0416]!!!!!!!!! change var setCaptive = %2 !!!!!!!!!!!!!", name _x, _captive];								
								}; */
						}; // if
					}; //spawn
				};					

				//HEALED OUTSIDE SCRIPT - Damage = 0 method. Zeus healing, or 3rd party script healing. If damage = 0 but the unit is unconcious, then revive.
				if (Debug_Zeusorthirdparty && (lifestate _x == "INCAPACITATED" && damage _x == 0) && ((Lifeline_RevMethod == 2 && (_x getVariable ["Lifeline_Down",false])) || Lifeline_RevMethod == 1 )) then {
					[_x] spawn {
						params ["_x"];
						sleep 3;
						if (Debug_Zeusorthirdparty && (lifestate _x == "INCAPACITATED" && damage _x == 0) && ((Lifeline_RevMethod == 2 && (_x getVariable ["Lifeline_Down",false])) || Lifeline_RevMethod == 1 )) then {
								// var dump
								_diagtext = "ZEUS, CONSOLE or SCRIPT HEAL [2]"; 
								if (Lifeline_Revive_debug) then {if !(local _x) then {[_x,_diagtext] remoteExec ["serverSide_unitstate", 2];[_diagtext] remoteExec ["serverSide_Globals", 2];
								} else {[_x,_diagtext] call serverSide_unitstate;[_diagtext] call serverSide_Globals;}};
							diag_log format ["%1!!!!!!!!!!!!! ZEUS, CONSOLE or 3RD PARTY SCRIPT HEAL !!!!!!!!!!!!!!!!!!'", name _x];
							diag_log format ["%1!!!!!!!!!!!!! ZEUS, CONSOLE or 3RD PARTY SCRIPT HEAL !!!!!!!!!!!!!!!!!!", name _x];
							diag_log format ["%1!!!!!!!!!!!!! ZEUS, CONSOLE or 3RD PARTY SCRIPT HEAL !!!!!!!!!!!!!!!!!!", name _x];
							if (Lifeline_Revive_debug) then {
								["Zeusorthirdparty"] remoteExec ["playSound",2];
								hintsilent format ["%1\n%2", name _x,_diagtext];
							};							
							[_x, false] remoteExec ["setUnconscious",_x];
							[_x, "unconsciousoutprone"] remoteExec ["SwitchMove", 0];
							_x setVariable ["LifelineBleedOutTime", 0, true];diag_log format ["%1 [365]!!!!!!!!! change var LifelinePairTimeOut = 0 !!!!!!!!!!!!!", name _x];
							_x call Lifeline_reset_variables;
							// diag_log format ["%1| _x [2003] !!!!!!!!!!!!!! Lifeline_RESET CALL FUNCTION. Lifeline_reset_trig: %2", name _x, (_x getVariable ["Lifeline_reset_trig",false])];
									if (_x getVariable ["ReviveInProgress",0] in [0,3]) then {
												
										[[_x],"ZEUS, CONSOLE or 3RD PARTY SCRIPT HEAL"] call Lifeline_reset2;														
									};	
						}; // if ((
					}; //spawn
				};

				// this is a backup to force unit out of unconcious animation if unit is healthy / revived. Although this switchmove already executes when medic revives, some missions in the workshop have custom scripts to revive without the medic (e.g. radiation heal etc etc). So this is backup to prevent stuck in unconcious anim. 
				if (lifestate _x != "INCAPACITATED" && alive _x && ((animationState _x find "unconscious" == 0 && animationState _x != "unconsciousrevivedefault" && animationState _x != "unconsciousoutprone") || animationState _x == "unconsciousrevivedefault")) then {
						[_x] spawn {
						params ["_x"];
							sleep 5;
							if (lifestate _x != "INCAPACITATED" && alive _x && ((animationState _x find "unconscious" == 0 && animationState _x != "unconsciousrevivedefault" && animationState _x != "unconsciousoutprone") || animationState _x == "unconsciousrevivedefault")) then {
								diag_log "!!!!!!!!!!!!! FIRE CANCEL UNCON ANIM !!!!!!!!!!!!!!!!!!";
								[_x, "unconsciousoutprone"] remoteExec ["SwitchMove", 0];
							}; // if
						}; //spawn
				};	

				if (Lifeline_Map_mark) then {[_x] call Lifeline_Map};

				// ONLY ACE . Some missions have a script that inflicts vanilla damage that bypasses ACE medical, such as radiation. 
				// This means with ACE medical you cannot heal and are stuck limping.  This will give option to fix.
				/* 	if (Lifeline_RevMethod == 3 && isPlayer _x && (_x getHit "legs") >= 0.5 && !(_x in Lifeline_incapacitated)) then { 
					if  (!(_x getVariable ["fixdamagebug",false]) || count (actionIDs _x) == 0) then {
							_x setVariable ["fixdamagebug",true,true];
							_x addAction ["<t color='#00FF0A'>vanilla damage fix</t>", {params ["_x"]; _x setVariable ["fixdamagebug",nil,true]; _x setDamage 0; _x removeAction (_this select 2)}, nil, 1, false];
					};
				};	 */

				if (Lifeline_Revive_debug) then {				
					[_x] call Lifeline_debug_unit_states;
				}; 

				// ========================= CROUCH SCRIPT. MAKE UNIT CROUCH WHEN STANDING AND IDLE. MORE IMMERSIVE. (ONLY IN "AWARE" BEHAVIOUR MODE) ============================

				if (Lifeline_Idle_Crouch) then {

					if (Lifeline_PVPstatus == false && Lifeline_Include_OPFOR == true && (side group _X) in Lifeline_OPFOR_Sides && !Lifeline_Idle_CrouchOPFOR) exitWith {};

					 [_x, _crouchtrig] remoteExec ["Lifeline_AutoCrouch", 0];
				};	


				// ========================= HACK FIX ====================== 
				// these are hacks to fix variables that sometimes dont get set, due to network errors etc.

				if (Lifeline_Revive_debug == false) then {

					
			
					// if (alive _x && lifestate _x == "INCAPACITATED" && captive _x == false && Lifeline_RevProtect != 3) then {
					if (alive _x && lifestate _x == "INCAPACITATED" && captive _x == false && Lifeline_RevProtect != 3) then {
						// if (Lifeline_debug_soundalert) then {["hackfix"] remoteExec ["playSound",2]};
						[_x,true] remoteExec ["setCaptive", 0];diag_log format ["%1 [0484 Lifeline_Debugging.sqf HACKFIX]!!!!!!!!! change var setcaptive = true !!!!! ReviveInProgress: %2 !!!!!!!!", name _x, _x getVariable ["ReviveInProgress",0]]; 
						_x setCaptive true;diag_log format ["%1 [0485 Lifeline_ReviveEngine.sqf HACKFIX]!!!!!!!!! change var setcaptive = true !!!!! ReviveInProgress: %2 !!!!!!!!", name _x, _x getVariable ["ReviveInProgress",0]]; 				
					};

					// if ((isDamageAllowed _x == false || captive _x == true) && alive _x && lifestate _x != "INCAPACITATED" &&  _x getVariable ["ReviveInProgress",0] == 0 && !(_x in Lifeline_Process) // deleted _x getVariable ["LifelineBleedOutTime",0] (unlike line above)
			      /*   if ((isDamageAllowed _x == false || (captive _x == true && _captive == false)) && alive _x && lifestate _x != "INCAPACITATED" &&  _x getVariable ["ReviveInProgress",0] == 0 && !(_x in Lifeline_Process) // deleted _x getVariable ["LifelineBleedOutTime",0] (unlike line above)
						&& (isNull findDisplay 60492) && (isNull findDisplay 47) && (isNull findDisplay 48) && (isNull findDisplay 50) && (isNull findDisplay 51) && (isNull findDisplay 58) && (isNull findDisplay 61) && (isNull findDisplay 312) && (isNull findDisplay 314)) then {
						[_x] spawn {
							params ["_x"];
							sleep 7;
							_captive = _x getVariable ["Lifeline_Captive", false];
							// if ((isDamageAllowed _x == false || captive _x == true) && alive _x && lifestate _x != "INCAPACITATED" && !(_x getVariable ["Lifeline_Down",false]) && _x getVariable ["ReviveInProgress",0] == 0 && (_x getVariable ["LifelineBleedOutTime",0]) == 0 && !(_x in Lifeline_Process)
							if ((isDamageAllowed _x == false || (captive _x == true && _captive == false)) && alive _x && lifestate _x != "INCAPACITATED" && !(_x getVariable ["Lifeline_Down",false]) && _x getVariable ["ReviveInProgress",0] == 0 && !(_x in Lifeline_Process)  // deleted _x getVariable ["LifelineBleedOutTime",0] (unlike line above)
								&& (isNull findDisplay 60492) && (isNull findDisplay 47) && (isNull findDisplay 48) && (isNull findDisplay 50) && (isNull findDisplay 51) && (isNull findDisplay 58) && (isNull findDisplay 61) && (isNull findDisplay 312) && (isNull findDisplay 314)) then {
									// if (Lifeline_debug_soundalert) then {["hackfix"] remoteExec ["playSound",2]};									
									if !(local _x) then {
										[_x, true] remoteExec ["allowDamage",_x];diag_log format ["%1 | [0496 HACKFIX][Lifeline_ReviveEngine.sqf] ALLOWDAMAGE SET: %2", name _x, "true"];
										// [_x, false] remoteExec ["setCaptive",0];diag_log format ["%1 | [0497 HACKFIX][Lifeline_ReviveEngine.sqf]!!!!!!!!! change var setCaptive = false !!!!!!!!!!!!!", name _x];	
										[_x, _captive] remoteExec ["setCaptive",0];diag_log format ["%1 | [0497 HACKFIX][Lifeline_ReviveEngine.sqf]!!!!!!!!! change var setCaptive = %2 !!!!!!!!!!!!!", name _x, _captive];	
									} else {
										_x allowDamage true;diag_log format ["%1 | [0499 HACKFIX][Lifeline_ReviveEngine.sqf] ALLOWDAMAGE SET: %2", name _x, isDamageAllowed _x];
										// _x setCaptive false;diag_log format ["%1 | [0500 HACKFIX][Lifeline_ReviveEngine.sqf]!!!!!!!!! change var setCaptive = false !!!!!!!!!!!!!", name _x];		
										_x setCaptive _captive;diag_log format ["%1 | [0500 HACKFIX][Lifeline_ReviveEngine.sqf]!!!!!!!!! change var setCaptive = %2 !!!!!!!!!!!!!", name _x, _captive];		
									};			
							};									
						};
					}; */	

				/* 	_captive = _x getVariable ["Lifeline_Captive", false];						
					if (hackfix_captive_units && !(_x getVariable ["Lifeline_Captive_Delay",false]) && captive _x == true && _captive == false && alive _x && lifestate _x != "INCAPACITATED" &&  _x getVariable ["ReviveInProgress",0] == 0 && !(_x in Lifeline_Process) // deleted _x getVariable ["LifelineBleedOutTime",0] (unlike line above)
						&& (!isPlayer _x || (isPlayer _x && (isNull findDisplay 60492) && (isNull findDisplay 47) && (isNull findDisplay 48) && (isNull findDisplay 50) && (isNull findDisplay 51) && (isNull findDisplay 58) && (isNull findDisplay 61) && (isNull findDisplay 312) && (isNull findDisplay 314)))) then {
						hackfix_captive_units = false;
						[_x] spawn {
							params ["_x"];
							sleep 7;
							hackfix_captive_units = true;
							_captive = _x getVariable ["Lifeline_Captive", false];
							// if ((isDamageAllowed _x == false || captive _x == true) && alive _x && lifestate _x != "INCAPACITATED" && !(_x getVariable ["Lifeline_Down",false]) && _x getVariable ["ReviveInProgress",0] == 0 && (_x getVariable ["LifelineBleedOutTime",0]) == 0 && !(_x in Lifeline_Process)
							if (!(_x getVariable ["Lifeline_Captive_Delay",false]) && captive _x == true && _captive == false && alive _x && lifestate _x != "INCAPACITATED" && _x getVariable ["ReviveInProgress",0] == 0 && !(_x in Lifeline_Process)  // deleted _x getVariable ["LifelineBleedOutTime",0] (unlike line above)
								&& (!isPlayer _x || (isPlayer _x && (isNull findDisplay 60492) && (isNull findDisplay 47) && (isNull findDisplay 48) && (isNull findDisplay 50) && (isNull findDisplay 51) && (isNull findDisplay 58) && (isNull findDisplay 61) && (isNull findDisplay 312) && (isNull findDisplay 314)))) then {
									// if (Lifeline_debug_soundalert) then {["hackfix"] remoteExec ["playSound",2]};									
									// if !(local _x) then {	
									// 	[_x, _captive] remoteExec ["setCaptive",0];diag_log format ["%1 | [0497 HACKFIX][Lifeline_ReviveEngine.sqf]!!!!!!!!! change var setCaptive = %2 !!!!!!!!!!!!!", name _x, _captive];	
									// } else {	
									// 	_x setCaptive _captive;diag_log format ["%1 | [0500 HACKFIX][Lifeline_ReviveEngine.sqf]!!!!!!!!! change var setCaptive = %2 !!!!!!!!!!!!!", name _x, _captive];		
									// };
									
									// [format["Bug: Unit %1 is captive", name _x]] remoteExec ["hint", 0];												
							};									
						};
					}; 	 */

					// FIX bugged invincible units.
			        // if (hackfix_invincible_units && isDamageAllowed _x == false && alive _x && lifestate _x != "INCAPACITATED" &&  _x getVariable ["ReviveInProgress",0] == 0 && !(_x in Lifeline_Process) // deleted _x getVariable ["LifelineBleedOutTime",0] (unlike line above)
			        if (hackfix_invincible_units && !(isNil {_x getVariable "ReviveInProgress"}) && isDamageAllowed _x == false && alive _x && lifestate _x != "INCAPACITATED" &&  _x getVariable ["ReviveInProgress",0] == 0 && !(_x in Lifeline_Process) // deleted _x getVariable ["LifelineBleedOutTime",0] (unlike line above)
						&& (!isPlayer _x || (isPlayer _x && (isNull findDisplay 60492) && (isNull findDisplay 47) && (isNull findDisplay 48) && (isNull findDisplay 50) && (isNull findDisplay 51) && (isNull findDisplay 58) && (isNull findDisplay 61) && (isNull findDisplay 312) && (isNull findDisplay 314)))) then {
						hackfix_invincible_units = false;
						[_x] spawn {
							params ["_x"];
							sleep 7;
							hackfix_invincible_units = true;
							if (isDamageAllowed _x == false && alive _x && lifestate _x != "INCAPACITATED" && _x getVariable ["ReviveInProgress",0] == 0 && !(_x in Lifeline_Process)  // deleted _x getVariable ["LifelineBleedOutTime",0] (unlike line above)
								&& (!isPlayer _x || (isPlayer _x && (isNull findDisplay 60492) && (isNull findDisplay 47) && (isNull findDisplay 48) && (isNull findDisplay 50) && (isNull findDisplay 51) && (isNull findDisplay 58) && (isNull findDisplay 61) && (isNull findDisplay 312) && (isNull findDisplay 314)))) then {
									// if (Lifeline_debug_soundalert) then {["hackfix"] remoteExec ["playSound",2]};									
									if !(local _x) then {
										[_x, true] remoteExec ["allowDamage",_x];diag_log format ["%1 | [0496 HACKFIX][Lifeline_ReviveEngine.sqf] ALLOWDAMAGE SET: %2", name _x, "true"];											
									} else {
										_x allowDamage true;diag_log format ["%1 | [0499 HACKFIX][Lifeline_ReviveEngine.sqf] ALLOWDAMAGE SET: %2", name _x, isDamageAllowed _x];		
									};			
							};									
						};
					};		 		

					// FIX bugged bleedout times
					if (hackfix_bleedout_time && lifestate _x != "INCAPACITATED" && alive _x && (_x getVariable ["LifelineBleedOutTime",0]) != 0 && !(_x in Lifeline_Process)) then {
						hackfix_bleedout_time = false;
						[_x] spawn {
							params ["_x"];
							sleep 7;
							hackfix_bleedout_time = true;
							if (lifestate _x != "INCAPACITATED" && alive _x && (_x getVariable ["LifelineBleedOutTime",0]) != 0 && !(_x in Lifeline_Process) ) then {
								// if (Lifeline_debug_soundalert) then {["hackfix"] remoteExec ["playSound",2]};							
								_x setVariable ["LifelineBleedOutTime",0,true];diag_log format ["%1 | [0491 HACKFIX][Lifeline_ReviveEngine.sqf]!!!!!!!!! change var LifelineBleedOutTime = 0 !!!!!!!!!!!!!", name _x];									
							};
						};
					};	
					
					// Captive state not staying true when down. Only for dedicated servers. But might need to be added to other servers.				
					if (hackfix_captive_incap && isDedicated && alive _x && lifestate _x == "INCAPACITATED" && captive _x == false && Lifeline_RevProtect != 3) then {
						hackfix_captive_incap = false;
						[_x] spawn {
								params ["_x"];
								sleep 5;
								hackfix_captive_incap = true;
								if (alive _x && lifestate _x == "INCAPACITATED" && captive _x == false && Lifeline_RevProtect != 3) then {
									//hackfix here...								
									 [_x,true] remoteExec ["setCaptive", 0];diag_log format ["%1 [0537 Lifeline_ReviveEngine.sqf HACKFIX]!!!!!!!!! change var setcaptive = true !!!!!! ReviveInProgress: %2 !!!!!!!", name _x, _x getVariable ["ReviveInProgress",0]]; 																
								};
						};
					};	
					
				}; // END if (Lifeline_Revive_debug == false) then {

				//========================= END Hack fixes ==================


			} foreach Lifeline_All_Units;



			sleep 2;
		}; // end while
	}; // end spawn


	//=== ACE ONLY, LIMIT BLEEDOUT FOR OPFOR WHEN PVE MISSION, IF MISSION NOT DESIGNED FOR ACE.
	/* Workshop missions often require certain number of enemies killed to 
	complete a task or trigger a script. If you have ACE loaded and 
	the mission is not designed for ACE, you have to wait sometimes ages 
	for enemies to bleedout before the task is triggered.
	This setting limits bleedout time for enemy with ACE medical.
	Set to zero to disable.
	If the mission is PVP, this is bypassed.*/

	//method 1
	/* if (Lifeline_RevMethod == 3) then {
		[] spawn { 
			while {Lifeline_ACE_OPFORlimitbleedtime != 0} do {  
				playerSide1 = side group player;//this needs to be updated for dedicated servers.
				// Filter allUnits to only include enemies
				if (Lifeline_ACE_CIVILIANlimitbleedtime == false) then {
					enemyUnitsJa = allUnits select {
						[playerSide1, side group _x] call BIS_fnc_sideIsEnemy
					};
				} else {
					enemyUnitsJa = allUnits select {
						[playerSide1, side group _x] call BIS_fnc_sideIsEnemy || side group _x == CIVILIAN 
					};
				};
				pve = true; 
				{  
					if (isPlayer _x) then {
						pve = false;
					};
					// Check if unit is incapacitated  
					if (lifeState _x == "INCAPACITATED" && pve == true) then {  
						[_x] spawn { 
							params ["_x"];
							diag_log format ["trigger first gate autokill OPFOR: %1", name _x];
							sleep (random (Lifeline_ACE_OPFORlimitbleedtime)); 
							// if (alive _x && lifeState _x == "INCAPACITATED") then {
							if (alive _x && lifeState _x == "INCAPACITATED" && _x getVariable ["ReviveInProgress",0] != 3) then {
								// [_x, "LifeLine Revive Timer", _x, _x] call ace_common_fnc_setDead;
								_x setDamage 1;
								diag_log format ["auto kill OPFOR: %1",name _x];
								diag_log format ["auto kill OPFOR: %1",name _x];
								diag_log format ["auto kill OPFOR: %1",name _x];
							};
						};  
					};  
				} forEach enemyUnitsJa;  
				sleep 60;  
				diag_log "==================================================== 60 sec loop for auto kill opfor";
			}; 
		};
	}; */


	//method 2
	if (Lifeline_RevMethod == 3 && !Lifeline_PVPstatus) then {
		diag_log "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!gate 1 apples";
		[] spawn { 
			while {Lifeline_ACE_OPFORlimitbleedtime != 0 && !Lifeline_PVPstatus} do { 
				diag_log "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!gate 2 apples"; 
				// Filter allUnits to only include enemies
				if (Lifeline_ACE_CIVILIANlimitbleedtime == false) then {
					enemyUnitsJa = allUnits select {
						[Lifeline_Side, side group _x] call BIS_fnc_sideIsEnemy
					};
				} else {
					enemyUnitsJa = allUnits select {
						[Lifeline_Side, side group _x] call BIS_fnc_sideIsEnemy || side group _x == CIVILIAN 
					};
				};

				{  
					// Check if unit is incapacitated  
					if (lifeState _x == "INCAPACITATED" && !Lifeline_PVPstatus) then {  
						[_x] spawn { 
							params ["_x"];
							diag_log format ["trigger first gate autokill OPFOR: %1", name _x];
							sleep (random (Lifeline_ACE_OPFORlimitbleedtime)); 
							// if (alive _x && lifeState _x == "INCAPACITATED") then {
							if (alive _x && lifeState _x == "INCAPACITATED" && _x getVariable ["ReviveInProgress",0] != 3) then {
								// [_x, "LifeLine Revive Timer", _x, _x] call ace_common_fnc_setDead;
								_x setDamage 1;
								diag_log format ["auto kill OPFOR: %1",name _x];
								diag_log format ["auto kill OPFOR: %1",name _x];
								diag_log format ["auto kill OPFOR: %1",name _x];
							};
						};  
					};  
				} forEach enemyUnitsJa;  
				sleep 60;  
				diag_log "============================ 60 sec loop for auto kill opfor";
			}; 
		};
	};



	//DEBUG
	// UPDATE ALLUNITS
	/* [] spawn {
		while {true} do {
			[] call Lifeline_DH_update; 
			// allows proximity for revive when vehicles there
			Lifeline_deadVehicle = [];
			{if (damage _x == 1 && simulationEnabled _x && isTouchingGround _x) then {Lifeline_deadVehicle pushBackUnique _x}} forEach vehicles;
			sleep 5;
		};
	}; */
	//ENDDEBUG

	[] spawn {
	
		_freq = 1; //frequency counter. Some functions we want less frequent than others
		_sizetext = str 0.4;
	
		while {true} do {		

				_diag_text = "";
				

						// timer for bleedout or autorecover
						{	
							//DEBUG
								//======= Sometimes teamswitch screws up Lifeline_incapacitated with ghost units. This fixes that.
							/* 	if !(_x in Lifeline_All_Units) then {
									// hackfix8 = false;
									[_x] spawn {
										params ["_x"];
										sleep 5;
										// hackfix8 = true;
										if (!(_x in Lifeline_All_Units) && _x in Lifeline_incapacitated) then {									
										Lifeline_incapacitated = Lifeline_incapacitated - [_x];
										diag_log format ["%1 [0454]uuuuuuuuuuuu HACK FIX. UNIT NOT IN Lifeline_All_Units uuuuuuuuuuuuu", name _x];	
										_x setVariable ["ReviveInProgress",0,true];	diag_log format ["%1 [2544]!!!!!!!!! change var ReviveInProgress = 0 !!!!!!!!!!!!!", name _x];							
										if (Lifeline_debug_soundalert) then {["hackfix"] remoteExec ["playSound",2]};
										if (Lifeline_hintsilent) then {hintsilent format ["HACK FIX %1\n%2", name _x,"HACK FIX. UNIT NOT IN Lifeline_All_Units"]};									
										};
									}; // spawn 
								}; //if !(_x in Lifeline_All_Units) then { */
							//ENDDEBUG

							if (Lifeline_RevMethod != 3) then {

								if ((_x getVariable ["LifelineBleedOutTime",0])>0) then {

										//DEBUG
										if (time > ((_x getVariable "LifelineBleedOutTime") - 30) && lifeState _x == "INCAPACITATED" && Lifeline_Revive_debug) then {
											diag_log format ["==                  GETTING CLOSE          %2 | %1 | ", name _x, round((_x getVariable "LifelineBleedOutTime") - time)];
										}; //ENDDEBUG	
	
										//DEBUG
										/* if ((Lifeline_RevMethod != 3 || Lifeline_HUD_distance == true || Lifeline_cntdwn_disply != 0) && isPlayer _x) then {
											_seconds = Lifeline_cntdwn_disply;
											if (time > ((_x getVariable "LifelineBleedOutTime") - (_seconds+3)) && lifeState _x == "INCAPACITATED" && !(_x getVariable ["Lifeline_countdown_start",false]) 
												&& Lifeline_cntdwn_disply != 0 && Lifeline_RevMethod != 3 && Lifeline_HUD_distance == false) then {
												_x setVariable ["Lifeline_countdown_start",true,true];
												[_x,_seconds] remoteExec ["Lifeline_countdown_timer2",_x,true];
												// [[_x], Lifeline_countdown_timer2] remoteExec ["call",_x, true];
											}; 
											if (lifeState _x == "INCAPACITATED" && !(_x getVariable ["Lifeline_countdown_start",false])) then {
												_x setVariable ["Lifeline_countdown_start",true,true];
												[_x,_seconds] remoteExec ["Lifeline_countdown_timer2",_x,true];
												// [[_x], Lifeline_countdown_timer2] remoteExec ["call",_x, true];
											};
										}; */
										
										// if (Lifeline_RevMethod != 3) then {
										
										// _bleedout_adjust = 0;
										
										//ENDDEBUG
	
										_bleedout = ""; // this is just for diag_log
										// _bleedouttime = _x getVariable "LifelineBleedOutTime";
										_bleedouttime = (_x getVariable "LifelineBleedOutTime") + 1; // with extra second so happens on 0
										_autoRecover = _x getVariable ["Lifeline_autoRecover",false];	
										_bleedout_half = Lifeline_BleedOutTime / 2; //auto revover half way through bleedout.								
										
										//DEBUG
										// if (_x getVariable ["Lifeline_autoRecover",false]) then {_bleedout_adjust = Lifeline_BleedOutTime / 2}; //if autorecover = true then adjust when to revive, at halfway
							
											// if (time > ((_x getVariable "LifelineBleedOutTime") - _bleedout_adjust) && lifeState _x == "INCAPACITATED") then {
										//ENDDEBUG	


										if ((time > _bleedouttime && _autoRecover == false || time > (_bleedouttime - _bleedout_half) && _autoRecover == true ) && lifeState _x == "INCAPACITATED") then {
											diag_log format ["%1 !!!!!!!!!!!! BLED OUT vars. _autoRecover: %2 _bleedout_half: %3 time - adjusted: %4", name _x, _autoRecover, _bleedout_half, time - (_bleedouttime - _bleedout_half) ];
											// _autoRecover = _x getVariable "Lifeline_autoRecover";
											// DIES
											// if !(Lifeline_autoRecover) then {
											if (_autoRecover == false) then {
												_x setDamage 1; diag_log format ["%1 [0509]!!!!!!!!! change var setdamage = 1 !!!!!!!!!!!!!", name _x];
												if (Lifeline_Revive_debug && Lifeline_hintsilent) then {[format ["%1 bled out. Dead.", name _x]] remoteExec ["hintSilent",2]};
												if (Lifeline_Revive_debug && Lifeline_hintsilent) then {["diedbleedout1"] remoteExec ["playSound",2]};
												diag_log " ";
												diag_log format ["[0496] !!!!!!!!!!!! %1 BLED OUT !!!!!!!!!!!!!!", name _x];
												diag_log " ";
												//DEBUG
												_bleedout = "BLED OUT";
												_Lifeline_Down = (_x getVariable ["Lifeline_Down",false]);
												_allowdeath = (_x getVariable ["Lifeline_allowdeath",false]);
												_bullethits = (_x getVariable ["Lifeline_bullethits",0]);
												_countdowntimer = (_x getVariable ["countdowntimer",false]);
												_ReviveInProgress = (_x getVariable ["ReviveInProgress",0]);
												diag_log format ["%1 [523]====// !!!!!!!!!!!!!!!! //==== %2|%3|%4|%5|%6|", name _x, _Lifeline_Down, _allowdeath, _bullethits, _countdowntimer, _ReviveInProgress]; //ENDDEBUG
											} else {
											// AUTORECOVERS	
												// _x setUnconscious false;
												[_x, false] remoteExec ["setUnconscious",_x];
												_x setVariable ["Lifeline_Down",false,true];  		// for Revive Method 2

												if (isMultiplayer && isPlayer _x) then {
													["#rev", 1, _x] remoteExecCall ["BIS_fnc_reviveOnState", _x];																		
												};

												diag_log format ["%1 [0515] !!!!!!!!!!! AUTO RECOVER !!!!!!!!!!!!!!'", name _x];
												diag_log format ["%1 [0515] !!!!!!!!!!! AUTO RECOVER !!!!!!!!!!!!!!", name _x];
												diag_log format ["%1 [0515] !!!!!!!!!!! AUTO RECOVER !!!!!!!!!!!!!!", name _x];
												
												//remove wounds action ID
												if (Lifeline_RevMethod == 2) then {
													_actionId = _x getVariable "Lifeline_ActionMenuWounds"; 
													if (!isNil "_actionId") then {
															[[_x,_actionId],{params ["_unit","_actionId"];_unit setUserActionText [_actionId, ""];}] remoteExec ["call", 0, true];
															//DEBUG
															if (Lifeline_Revive_debug) then {
																_diagtext = format ["%1 TRACE !!!!!!!!!!!!!!!!!!! [1835] AUTO RECOVER REMOVE setUserActionText !!!!!!!!!!!!!!!!!!!! ", name _x];if !(local _x) then {[_diagtext] remoteExec ["diag_log", 2];} else {diag_log _diagtext};
															}; //ENDDEBUG
													};
												};

												_captive = _x getVariable ["Lifeline_Captive", false];
												[_x, true] remoteExec ["allowDamage",0]; diag_log format ["%1 | [0662][Lifeline_ReviveEngine.sqf] ALLOWDAMAGE SET: %2", name _x, "true"];//added 
												// [_x, false] remoteExec ["setCaptive",_x]; diag_log format ["%1 | [0662]!!!!!!!!! change var setCaptive = false !!!!!!!!!!!!!", name _x];
												[_x, _captive] remoteExec ["setCaptive",0]; diag_log format ["%1 | [0662]!!!!!!!!! change var setCaptive = %2 !!!!! ReviveInProgress: %3 !!!!!!!!", name _x, _captive, _x getVariable ["ReviveInProgress",0]];
												//_x allowDamage true; diag_log format ["%1 | [573][Lifeline_ReviveEngine.sqf] ALLOWDAMAGE SET: %2", name _x, isDamageAllowed _x];//added 

												//added
												// _x setVariable ["Lifeline_Down",false,true];  		// for Revive Method 2
												_x setVariable ["Lifeline_allowdeath",false,true]; 	// for Revive Method 2
												_x setVariable ["Lifeline_bullethits",0,true];			// for Revive Method 2
												// _x setVariable ["Lifeline_autoRecover",false,true];
												// _x setdamage 0;
												_x setdamage 0.5; diag_log format ["%1 [0556]!!!!!!!!! change var setdamage = 0.5 !!!!!!!!!!!!!", name _x];
												[_x] remoteExec ["Lifeline_reset", _x]; diag_log format ["%1 [1651] !!!!!!!!!!!!!!!! RESET AI !!!!!!!!!!!!!!!!!!", name _x];
												_x addItemToBackpack "Medikit";
												_x setVariable ["LifelinePairTimeOut", 0, true];
												_x setVariable ["LifelineBleedOutTime", 0, true];diag_log format ["%1 [585]!!!!!!!!! change var LifelinePairTimeOut = 0 !!!!!!!!!!!!!", name _x];
												_x setVariable ["Lifeline_selfheal_progss",false,true];diag_log format ["%1 [1773]!!!!!!!!! change var Lifeline_selfheal_progss = false !!!!!!!!!!!!!", name _x];

												if (Lifeline_hintsilent && Lifeline_Revive_debug) then {[format ["%1\nRecovered,", name _x]] remoteExec ["hintSilent",2]};
												if (alive leader _x && lifestate leader _x != "incapacitated") then {
													[_x] joinsilent _x;
													_x doFollow leader group _x;
												};
												_bleedout = "AUTO RECOVER";
											};

											Lifeline_incapacitated = Lifeline_incapacitated - [_x];
											publicVariable "Lifeline_incapacitated";
											Lifeline_Process = Lifeline_Process - [_x];
											publicVariable "Lifeline_Process";

											if (Lifeline_Revive_debug) then {_x call Lifeline_delYelMark;
												diag_log format ["%1|   [1598]", name _x,_bleedout];
												diag_log format ["%1| ++++ DELETE YELLOW MARKER %2 ++++ [1598]", name _x,_bleedout];
												diag_log format ["%1|   [1598]", name _x,_bleedout];
											};
											_x setVariable ["ReviveInProgress",0,true]; diag_log format ["%1 [983]!!!!!!!!! change var ReviveInProgress = 0 !!!!!!!!!!!!!", name _x];
											_x setVariable ["Lifeline_AssignedMedic", [], true]; // added
											//these two variables below are just for SOG AI to avoid clashes. 										
											_x setVariable ["isInjured",false,true]; 											
											// _x setVariable ["isMedic",false,true]; // keep off
											// -------- 
										};
									// }; //if (Lifeline_RevMethod != 3) then {

								} else {
										if (lifeState _x == "INCAPACITATED") then {
											_BleedOut = (time + Lifeline_BleedOutTime); 
											if (Lifeline_RevMethod == 2 && _x getVariable ["LifelineBleedOutTime",0] == 0) then {
												_x setVariable ["LifelineBleedOutTime", _BleedOut, true];diag_log format ["%1 [615]!!!!!!!!! change var LifelinePairTimeOut = %2 !!!!!!!!!!!!!", name _x, _BleedOut];
											}; //adjusted for ace
											_Lifeline_Down = (_x getVariable ["Lifeline_Down",false]);
											_allowdeath = (_x getVariable ["Lifeline_allowdeath",false]);
											_bullethits = (_x getVariable ["Lifeline_bullethits",0]);
											_countdowntimer = (_x getVariable ["countdowntimer",false]);
											_ReviveInProgress = (_x getVariable ["ReviveInProgress",0]);
											diag_log format ["%1 [596]====// !!!!!!!!!!!!!!!! //==== %2|%3|%4|%5|%6|", name _x, _Lifeline_Down, _allowdeath, _bullethits, _countdowntimer, _ReviveInProgress];
										};
								};
							}; // if (Lifeline_RevMethod != 3) then {	

							if (Lifeline_HUD_names > 0 && hasInterface) then {
						
								// if (!Lifeline_Include_OPFOR || (side group _x == Lifeline_Side && (!Lifeline_Revive_debug || !Lifeline_ShowOpfor_HUDlist))) then {
								if ((side group _x == Lifeline_Side || (Lifeline_Revive_debug && Lifeline_ShowOpfor_HUDlist)) && (alive _x)) then {
									_diag_text = [_x,_diag_text] call Lifeline_incap_list_HUD;
								};

							};

							//DEBUG
							/* if (Lifeline_HUD_names) then {
								_underline = "";
								_underline2 = "";
								_colur =  "#EEEEEE";
								_colur2 = "#EEEEEE";
								_no = "";
								_medics = "";
								_tme = "";
								_distcalc = "";
								_incap = _x;

								if (lifestate _x == "INCAPACITATED" || !(alive _x)) then {
										_colur = "#FFBFA7";
										if (Lifeline_RevMethod == 2 && Lifeline_BandageLimit > 1) then {
											_bandges = (_x getVariable ["num_bandages",0]);
											if (_bandges != 0) then {
												_no = " (" + str _bandges + ")";
												// _no = " .." + str _bandges;
											} else {
											_no = " (?)"; 
											// _no = " ..?"; 
											};
										};
								};
								
								if (isPlayer _x) then {_underline = "underline='1'";};

								if (_x getVariable ["ReviveInProgress",0] == 0) then {
									// _colur = "#EE5F09";
									_colur = "#EE2809";
									// _diag_text = _diag_text + (format ["<t color='%1' %2>", _colur,_underline]) + name _x + _no + "</t><br />";
									_diag_text = _diag_text + (format ["<t color='%1' %2>", _colur,_underline]) + name _x + "</t>   <br />";
								};

								if (_x getVariable ["ReviveInProgress",0] == 3) then {
									_medic = (_x getVariable ["Lifeline_AssignedMedic", []]);
									{
										if (Lifeline_Revive_debug && isServer) then {
											_tme = str round ((_incap getVariable ["LifelinePairTimeOut",0]) - time);
										};
										_distcalc = str round (_incap distance2D _x) + "m ";
										if (_x getVariable ["ReviveInProgress",0] == 2) then {
											_colur2 = "#58D68D";
											_colur = "#58D68D";// COMMENT THIS OUT TO HAVE DIFF COLOURED INCAP / MEDIC PAIRS WHEN ACTUAL REVIVE
											_tme = "";
											_distcalc = "";
										};
										if (isPlayer _x) then {_underline2 = "underline='1'";};
									_medics = _medics + (format ["<t color='%1' %2>", _colur2,_underline2]) + name _x + " " + _distcalc + _tme + "</t>   ";
									} foreach _medic;

									// diag_log format ["uuuuuuuuuuuuuuu MEDIC TEXT %1 uuuuuuuuuuuuuu", _medic];
									
									_diag_text = _diag_text + (format ["<t color='%1' %2>", _colur,_underline]) + name _x + _no + "</t> - "  + _medics + "<br />";
								};
							}; */
							//ENDDEBUG
							
							// diag_log format [">>>>>>>>>>>>>>>> _diag_text: %1 >>>>>>>>>>>>>>",  _diag_text];
												

						} foreach Lifeline_incapacitated;
			//checkthis
			if (Lifeline_HUD_namesize == 1) then {_sizetext = str 0.4;};
			if (Lifeline_HUD_namesize == 2) then {_sizetext = str 0.36;};
			if (Lifeline_HUD_namesize == 3) then {_sizetext = str 0.3;};

			[format ["<t align='right' size='%2'>%1</t>",_diag_text,_sizetext],((safeZoneW - 1) * 0.48),-0.03,3,0,0,LifelinetxtdebugLayer1] spawn BIS_fnc_dynamicText;	

			//adds units to Lifeline_DH_update
			if (_freq == 1) then {
				[] call Lifeline_DH_update; diag_log "kkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkk [1097] [] call Lifeline_DH_update ";
				diag_log format ["+++++++++++++++++ alldisplays %1", allDisplays];
				// allows proximity for revive when vehicles there
				Lifeline_deadVehicle = [];
				{if (damage _x == 1 && simulationEnabled _x && isTouchingGround _x) then {Lifeline_deadVehicle pushBackUnique _x}} forEach vehicles;
			};

			if (_freq == 3) then {_freq = 1} else {_freq = _freq +1};	

			sleep 2;

		}; // end while

	}; // end spawn - Update INCAPACITATED and Incap Time up - die or autorecover


}; // Isserver



// ===== FOR NON-HOSTING PLAYERS (hoster don't need this, already in a loop) 
// list of incaps and medics in realtime on HUD.
if (!isServer) then {	
	//DEBUG

	_diag_textbaby = format [">>>>>>>[0798]>>>>>>>>>>>>>>> REMOTE PLAYER:%1 SCRIPT VERSION: %2  %3 >>>>>>>>>>>>>>>>>>>>>>> loaded HUD loop", name player, Lifeline_Version, Lifeline_Version_no];
	[_diag_textbaby] remoteExec ["diag_log", 2];
	//ENDDEBUG
	[] spawn {
		while {true} do {
			_diag_textp = "";
			if (Lifeline_HUD_names != 0) then {
				{
					// _diag_textp = [_x,_diag_textp] call Lifeline_incap_list_HUD; // ORIGINAL
					if ((side group _x == Lifeline_Side || (Lifeline_Revive_debug && Lifeline_ShowOpfor_HUDlist)) && (alive _x)) then {
						_diag_textp = [_x,_diag_textp] call Lifeline_incap_list_HUD;
					};
			
				} foreach Lifeline_incapacitated;			
				
				[format ["<t align='right' size='0.4'>%1</t>",_diag_textp],((safeZoneW - 1) * 0.48),-0.03,3,0,0,LifelinetxtdebugLayer3] spawn BIS_fnc_dynamicText;
			};
			sleep 2;
		}; 
	};
};




// ===== SELECTION LOOP ==============================================================

if (isServer) then {

	_unitbaby = "";
	if (isDedicated) then {
		_unitbaby == "DEDICATED"
	} else {
		_unitbaby == name player;
	};

	_diag_textbaby = format [">>>>>>>[0821]>>>>>>>>>>>>>>> Lifeline Revive initialized. HOST: %1 SCRIPT VERSION: %2  %3 >>>>>>>>>>>>>>>>>>>>>>> ", _unitbaby, Lifeline_Version, Lifeline_Version_no];
	[_diag_textbaby] remoteExec ["diag_log", 2];

	Lifeline_incaps2choose = [];
	Lifeline_medics2choose = [];
	Lifeline_side_switch = 0; // side switch will be used to determine which sides incapacitated units are processed to find a medic. We need to 'unblock' the process queue getting stuck when a side runs out of medics and switch to other side.
	_opforUnits = []; 
	_bluforUnits = [];
	_check_both_sides = [];
	_incap_side = [];
	_groupindex = 0;
	_selectGroup = [];
	


	Lifeline_mascal_autorevive_timer = 0; // when all units are down (MASCAL) but a unit has the auto-revive flag, then a timer will start before player is informed a unit is recovering.

	["Lifeline Revive initialized"] remoteExec ["hintsilent", allplayers];
	if (Lifeline_added_units == 1) then {
		Lifeline_added_units_hint_trig = false;
	};
	// [] execvm "Lifeline_Revive\scripts\temp.sqf"; 

	while {true} do {

		// sound alert for scope update loop
		// if (Lifeline_debug_soundalert && Lifeline_Revive_debug && Lifeline_soundalert_updatescope) then {playsound "updatescope";};
		diag_log format ["================================== [1264] PRIMARY LOOP  | START LOOP"];

		scopeName "main";

		diag_log format ["================================== [1268] PRIMARY LOOP  | START LOOP"];

		Lifeline_incaps2choose = [];
		Lifeline_medics2choose = [];
		Lifeline_healthy_units = [];
		Lifeline_incaps2chooseGROUPS = [];
		Lifeline_medics = [];
		_incap = objNull;
		_medic = objNull;
		_dedi_in_action = false;
		_dedi_medic_available = false;
		
		_sleep = 0.2;

		diag_log format ["================================== [1270] PRIMARY LOOP  | SORT INCAPACITATED UNITS"];

		// Sort incapacitated units based on the selected limit
		// if (Lifeline_Medic_Limit == -1) then {
			[6] call Lifeline_sort_order_incapacitated;
		// } else {
			// [3] call Lifeline_sort_order_incapacitated;
		// };


		diag_log format ["================================== [1273] PRIMARY LOOP  | SORT INCAPACITATED UNITS"];


		Lifeline_incaps2choose = Lifeline_incapacitated select {!(_x in Lifeline_Process) && (lifestate _x == "INCAPACITATED") && (rating _x > -2000)};
		

		_diag_array = ""; {_diag_array = _diag_array + name _x + ":" + str group _x + ", " } foreach Lifeline_incaps2choose; diag_log format ["================ [1285] PRIMARY LOOP  %1 Lifeline_incaps2choose: %2", "temp", _diag_array];




		
		//DEBUG // JUST FOR DIAGLOG  
		if (count Lifeline_incaps2choose > 0) then {diag_log format ["uuuuuuuuuuuuuu [2931] PRIMARY LOOP Lifeline_incaps2choose: %1",Lifeline_incaps2choose];}; //ENDDEBUG

		if (count Lifeline_incaps2choose > 0 ) then {


			// ======================== SELECT INCAP UNIT ==========================
			// ======================== SELECT INCAP UNIT ==========================
			// ======================== SELECT INCAP UNIT ==========================


			// ====== GROUP SWITCHING LOGIC ========
			{
				Lifeline_incaps2chooseGROUPS pushBackUnique group _x;
			} foreach Lifeline_incaps2choose;
			
			// Select first unit from first group in Lifeline_incaps2chooseGROUPS



			// to fix when number of groups changes mid loop
			if (_groupindex > (count Lifeline_incaps2chooseGROUPS - 1)) then {
					_groupindex = 0;
					// Don't set _sleep = 3 here, as we want the sleep after going through all groups
			};

			diag_log format ["PRIMARY LOOP [1321] uuuuuuuuuuuuuuuuuuuuuuuuuu COUNT INDEX Lifeline_incaps2chooseGROUPS: %1 _groupindex: %2", count Lifeline_incaps2chooseGROUPS, _groupindex];
			
			if (count Lifeline_incaps2chooseGROUPS > 0) then {
				_selectGroup = Lifeline_incaps2chooseGROUPS select _groupindex;
				diag_log format ["PRIMARY LOOP [1333] uuuuuuuuuuuuuuuuuuuuuuuuuu SELECTED GROUP: %1 _groupindex: %2", _selectGroup, _groupindex];
				_groupUnits = Lifeline_incaps2choose select {group _x == _selectGroup};

				
				if (Lifeline_Dedicated_Medic) then {
					_dedi_in_action = [_selectGroup] call Lifeline_check_dedimedic select 0;
					_dedi_medic_available = [_selectGroup] call Lifeline_check_dedimedic select 1;
					// if no dedicated medic is available, then put dedi medic at the front of the list
					if (!_dedi_medic_available) then {
						_realMedics = _groupUnits select {_x getUnitTrait "medic"};
						_nonMedics = _groupUnits select {!(_x getUnitTrait "medic")};
						_groupUnits = _realMedics + _nonMedics;
					};
				};


				
				if (count _groupUnits > 0) then {
					_incap = _groupUnits select 0;
					_incap_side = side group _incap;
				};
				
				// Set longer sleep if we've processed the last group
				if (_groupindex == (count Lifeline_incaps2chooseGROUPS - 1)) then {
					_sleep = 3;
				};
			};


			
			// Create arrays for side switching logic
			// private _opforUnits = Lifeline_incaps2choose select {side group _x in Lifeline_OPFOR_Sides};
			// private _bluforUnits = Lifeline_incaps2choose select {side group _x == Lifeline_Side};


			/* if (Lifeline_side_switch == 0) then {
			 _incap = (Lifeline_incaps2choose select 0);
			 _incaptemp = _incap;
			 _incap_side = side group _incap; // even though this is declared again below, it is need for the conditionals here.
			}; */

			

			// diag_log format ["PRIMARY LOOP [1253] uuuuuuuuuuuuuuuuuuuuuuuuuu BEFORE SWITCH incap: %1 side: %2 Lifeline_side_switch %3", name _incap, _incap_side, Lifeline_side_switch];
			

			//=================================================

			

		/* 	if (Lifeline_side_switch > 0) then {
				if (_incap_side == Lifeline_Side) then {
						// Find first unit from OPFOR side
						if (count _opforUnits > 0) then {
							_incap = _opforUnits select 0;
							diag_log format ["PRIMARY LOOP %2 uuuuuuuuuuuuuuuuuuuuuuuuuu CHOOSE OPFOR %1", side group _incap, name _incap];
						};
				};
				if (_incap_side in Lifeline_OPFOR_Sides) then {
					// Find first unit from BLUFOR side
					if (count _bluforUnits > 0) then {
						_incap = _bluforUnits select 0;
						diag_log format ["PRIMARY LOOP %2 uuuuuuuuuuuuuuuuuuuuuuuuuu CHOOSE BLUFOR %1", side group _incap, name _incap];
					};
				};
				Lifeline_side_switch = 0;
			}; */


			_incap_side = side group _incap; 


			diag_log format ["PRIMARY LOOP [1383]uuuuuuuuuuuuuuuuuuuuuuuuuu SELECTED INCAP %1  INDEX:%5 GROUP: %6 uuuuuuuuuuuuuuuuuuuuuuuuuuuuu ReviveInProgress %2 Lifeline_AssignedMedic %3 SIDE %4", name _incap, _incap getVariable ["ReviveInProgress",0], (_incap getVariable ["Lifeline_AssignedMedic",[]]), _incap_side, _groupindex, group _incap];
			if (Lifeline_Revive_debug) then {[_incap,"SELECTED INCAP"] call serverSide_unitstate};
			// _incap setVariable ["ReviveInProgress",3,true]; // added
			
			moveOut _incap; //added, dunno why, but needed in this version
				

			// ======================== SELECT MEDIC UNIT ================================
			// ======================== SELECT MEDIC UNIT ================================
			// ======================== SELECT MEDIC UNIT ================================
			
		 	//Lifeline_healthy_units = Lifeline_All_Units - Lifeline_incapacitated;

			// Check if medic limit is reached. 
			_medic_under_limit = true;



			/*  // ======= MEDIC NUMERICAL LIMITS LOGIC ======== 
			
			if (Lifeline_Medic_Limit >= 0 && !(group _incap in Lifeline_Group_Mascal)) then {
				diag_log format ["PRIMARY LOOP [1349] uuuuuuuuuuuuuuuuuuuuuuuuuu incap: %1 MEDIC LIMIT GATE 1 CHECK %2", name _incap, Lifeline_Medic_Limit];
				// Subtract both incapacitated units and players from the group
				_incap_group_units = (units group _incap) - Lifeline_incapacitated - (units group _incap select {isPlayer _x || !alive _x || lifeState _x == "DEAD"}); // exclude dead units
				_diag_array = ""; {_diag_array = _diag_array + name _x + ", " } foreach _incap_group_units; diag_log format ["PRIMARY LOOP [1351] uuuuuuuuuuuuuuuuuuuuuuuuuu incap: %1 MEDIC LIMIT GATE 2 CHECK _incap_group_units %2", name _incap, _diag_array];

				if (count _incap_group_units > 0) then {
					Lifeline_healthy_units = _incap_group_units;
					diag_log format ["PRIMARY LOOP [1355] uuuuuuuuuuuuuuuuuuuuuuuuuu incap: %1 MEDIC LIMIT GATE 3 CHECK _incap_group_units %2", name _incap, _incap_group_units];
				};
				_diag_array = ""; {_diag_array = _diag_array + name _x + ", " } foreach Lifeline_healthy_units; diag_log format ["PRIMARY LOOP [1355] uuuuuuuuuuuuuuuuuuuuuuuuuu incap: %1 MEDIC LIMIT GATE 3 CHECK _incap_group_units %2", name _incap, _diag_array];

				_count_current_medics = [group _incap] call Lifeline_count_group_medics;
				
				// Standard group limits (1, 2, 3)
				if (Lifeline_Medic_Limit == 1 && _count_current_medics > 0) then {
					_medic_under_limit = false;	
				};
				if (Lifeline_Medic_Limit == 2 && _count_current_medics > 1) then {
					_medic_under_limit = false;
				};
				if (Lifeline_Medic_Limit == 3 && _count_current_medics > 2) then {
					_medic_under_limit = false;
				};
				
				// Group limits plus unsuppressed units (4, 5, 6)
				if (Lifeline_Medic_Limit >= 4 && Lifeline_Medic_Limit <= 6) then {
					_limit_per_group = Lifeline_Medic_Limit - 3; // Convert 4->1, 5->2, 6->3
					
					// Check for the count of medics and if we've reached the base limit
					if (_count_current_medics >= _limit_per_group) then {
						// When we've reached the base limit, we'll only allow unsuppressed units to be medics
						_suppressed_units = Lifeline_healthy_units select {getSuppression _x > 0.1};
						// _suppressed_units = Lifeline_healthy_units select {_x getVariable ["testbaby",true] == true}; // TESTER
						_unsuppressed_units = Lifeline_healthy_units - _suppressed_units;
						
						if (Lifeline_Revive_debug) then {
							diag_log format ["PRIMARY LOOP [1387] Lifeline_Medic_Limit %1 reached (%2 group medics). %3 suppressed units excluded, %4 unsuppressed units still eligible.", 
								Lifeline_Medic_Limit, _count_current_medics, count _suppressed_units, count _unsuppressed_units];
						};
						
						// If there are no unsuppressed units, we'll check if all units are suppressed
						if (count _unsuppressed_units == 0 && count _suppressed_units > 0) then {
							// All units are suppressed, so we'll still use the first setting logic
							if (Lifeline_Revive_debug) then {
								diag_log format ["PRIMARY LOOP [1395] No unsuppressed units available - using fallback logic for setting %1", Lifeline_Medic_Limit];
							};
							
							// Match the behavior of settings 1-3
							if (_limit_per_group == 1 && _count_current_medics > 0) then {
								_medic_under_limit = false;
							};
							if (_limit_per_group == 2 && _count_current_medics > 1) then {
								_medic_under_limit = false;
							};
							if (_limit_per_group == 3 && _count_current_medics > 2) then {
								_medic_under_limit = false;
							};
						} else {
							// We have unsuppressed units available, use those
							Lifeline_healthy_units = _unsuppressed_units;
							_diag_array = ""; {_diag_array = _diag_array + name _x + ", " } foreach _unsuppressed_units; diag_log format ["PRIMARY LOOP [1403] uuuuuuuuuuuuuuuuuuuuuuuuuu MEDIC LIMIT GATE CHECK ELSE [1] _unsuppressed_units %2", name _incap, _diag_array];
						};
					};
				};
			} else {
				Lifeline_healthy_units = Lifeline_All_Units - Lifeline_incapacitated;
				_diag_array = ""; {_diag_array = _diag_array + name _x + ", " } foreach Lifeline_healthy_units; diag_log format ["PRIMARY LOOP [1403] uuuuuuuuuuuuuuuuuuuuuuuuuu MEDIC LIMIT GATE CHECK ELSE [2] Lifeline_healthy_units %2", name _incap, _diag_array];
			}; 

			_diag_array = ""; {_diag_array = _diag_array + name _x + ", " } foreach Lifeline_healthy_units; diag_log format ["PRIMARY LOOP [1410] uuuuuuuuuuuuuuuuuuuuuuuuuu incap: %1 MEDIC LIMIT GATE 2 CHECK _incap_group_units %2", name _incap, _diag_array];

			// =========================== END OF MEDIC NUMERICAL LIMITS LOGIC ================================  */


			_medic_under_limit = [_incap,false] call Lifeline_Medic_Num_Limit;
			_dedicated_medic = false;
			
			// diag_log format ["PRIMARY LOOP [1485] uuuuuuuu FUCKING MEDIC LIMIT _medic_under_limit %2 incap: %1 ", name _incap, _medic_under_limit];


			
			

			// Lifeline_medicsMASCALcheck = Lifeline_healthy_units select {(side group _x) == (_incap_side)}; //added to only select units on the same side as the incap
			// Lifeline_medicsMASCALcheck = Lifeline_healthy_units select {(side group _x) == (_incap_side) && [_x,_incap] call Lifeline_check_available_medic};
	
			//DEBUG
			// _diag_array = ""; {_diag_array = _diag_array + name _x + ", " } foreach Lifeline_All_Units; diag_log format ["====== [1202] PRIMARY LOOP || Lifeline_All_Units: %1",_diag_array];
			// _diag_array = ""; {_diag_array = _diag_array + name _x + ", " } foreach Lifeline_incapacitated; diag_log format ["====== [1203] PRIMARY LOOP || Lifeline_incapacitated: %1",_diag_array];
			// _diag_array = ""; {_diag_array = _diag_array + name _x + ", " } foreach Lifeline_healthy_units; diag_log format ["====== [1204] PRIMARY LOOP || Lifeline_healthy_units: %1",_diag_array];
			// _diag_array = ""; {_diag_array = _diag_array + name _x + ", " } foreach Lifeline_Process; diag_log format ["====== [1205] PRIMARY LOOP || Lifeline_Process: %1",_diag_array];
			//ENDDEBUG

			_AssignedMedic = (_incap getVariable ["Lifeline_AssignedMedic",[]]); // is this actually needed?
			// diag_log format ["=========================== INCAP'S ASSIGNED Lifeline_AssignedMedic %1 =============================", _AssignedMedic];
			// _count_healthy_group = [group _incap] call Lifeline_count_group_medics;
			// _count_healthy_group = [group _incap] call Lifeline_count_group_medics2;



			// ==== CONDITIONS FOR CHOOSING MEDIC:
			{
				// _blacklist = _x call Lifeline_Blacklist_Check;
				if (
					// !(side group _x == civilian) 
					// && !isPlayer _x 
					// && !([_x] call Lifeline_Blacklist_Check)
					// && !(_x in Lifeline_Process) 
					// && ((_x distance _incap) < Lifeline_LimitDist) 
					// && !(currentWeapon _x == secondaryWeapon _x && currentWeapon _x != "") //make sure unit is not about to fire launcher. This comes first.
					// && !(((assignedTarget _x) isKindOf "Tank") && secondaryWeapon _x != "") //check unit did not get order to hunt tank
					// && !(((getAttackTarget _x) isKindOf "Tank") && secondaryWeapon _x != "") //check unit is not hunting a tank
					// && (_x getVariable ["ReviveInProgress",0]) == 0 
					// && _x getVariable ["Lifeline_AssignedMedic",[]] isEqualTo []
					// && (_x getVariable ["LifelinePairTimeOut", 0]) == 0
					// && (lifestate _x != "INCAPACITATED")
					// && _x getVariable ["Lifeline_ExitTravel", false] == false
					// && (side (group _x) == side (group _incap)) // TEST FOR OPFOR
					// (!Lifeline_Dedicated_Medic || (Lifeline_Dedicated_Medic && (_x getUnitTrait "medic" || _count_healthy_group > 0))) &&
					(!Lifeline_Dedicated_Medic || (Lifeline_Dedicated_Medic && (_x getUnitTrait "medic" || _dedi_in_action || !_dedi_medic_available))) &&
					_medic_under_limit &&
					[_x,_incap] call Lifeline_check_available_medic
				) then {
					Lifeline_medics2choose pushBackUnique _x;
				};
			} foreach Lifeline_healthy_units;




			// } foreach Lifeline_medicsMASCALcheck;
			
			// _diag_array = ""; {_diag_array = _diag_array + name _x + ", " } foreach Lifeline_healthy_units; diag_log format ["%3 |uuuuuuuuuuu [1240] PRIMARY LOOP || Lifeline_healthy_units: %1 _medic_under_limit %2",_diag_array, _medic_under_limit, name _incap];
			_diag_array = ""; {_diag_array = _diag_array + name _x + ", " } foreach Lifeline_medics2choose; diag_log format ["%3 |uuuuuuuuuuu [1241] PRIMARY LOOP || Lifeline_medics2choose: %1 _medic_under_limit %2",_diag_array, _medic_under_limit, name _incap];

			
           	// _diag_array = ""; {_diag_array = _diag_array + name _x + ", " } foreach Lifeline_medicsMASCALcheck; diag_log format ["====== [1241] PRIMARY LOOP || Lifeline_medicsMASCALcheck: %1",_diag_array];
            // _Lifeline_medicsMASCALcheck = Lifeline_medicsMASCALcheck select {(side group _x) == (_incap_side)};
			// _diag_array = ""; {_diag_array = _diag_array + name _x + ", " } foreach _Lifeline_medicsMASCALcheck; diag_log format ["====== [1242] PRIMARY LOOP || _Lifeline_medicsMASCALcheck: %1",_diag_array];

            //DEBUG
			// CONSOLEincap = str format ["%1|%2",name _incap, _incap_side];		// console debugging temp	
			//ENDDEBUG

			// diag_log format ["uuuuuuuuuuuuuu [2963] PRIMARY LOOP || Lifeline_medics2choose: %1",Lifeline_medics2choose];

			_voice = "";

			diag_log format ["%1 [1469] PRIMARY LOOP uuuuuuuuuuuuuuuuuuuuuuuuuuuuuuu COUNT Lifeline_medics2choose: %2 uuuuuuuuuuuuuuuuuuuuuuu", name _incap, count Lifeline_medics2choose];





			if (alive _incap && count Lifeline_medics2choose >0) then { // medic available


			   //SORTING MEDICS TO CHOOSE. FIRST BY DISTANCE, THEN BY SUPPRESSION
				
				// 1. First sort all medics by distance
				Lifeline_medics = [Lifeline_medics2choose, [], {_incap distance _x}, "ASCEND"] call BIS_fnc_sortBy;

				// diag_log format ["%1 | [1516] PRIMARY LOOP || Lifeline_medics: %2 count: %3", name _incap, Lifeline_medics, count Lifeline_medics];

				// 2. Create an array of all groups in sorted order
				_medicGroups = [];
				{
					_grp = group _x;
					if !(_grp in _medicGroups) then {
						_medicGroups pushBack _grp;
					};
				} forEach Lifeline_medics;

				// 3. Create a new sorted array, processing each group's members by suppression
				_sortedMedics = [];
				{
					_currentGroup = _x;
					// Get all medics from current group
					_groupMedics = Lifeline_medics select {group _x == _currentGroup};
					// Sort them by suppression
					_groupMedics = [_groupMedics, [], {getSuppression _x}, "ASCEND"] call BIS_fnc_sortBy;
					// Add them to final array
					_sortedMedics append _groupMedics;
				} forEach _medicGroups;
				//DEBUG
				/* if (_sortedMedics isNotEqualTo Lifeline_medics) then {
					playSound "siren1";
					diag_log format ["%1 | [1541] =============================================", name _incap];
					diag_log format ["%1 | [1541] PRIMARY LOOP || Lifeline_medics: %2 count: %3", name _incap, Lifeline_medics, count Lifeline_medics];
					diag_log format ["%1 | [1541] PRIMARY LOOP ||   _sortedMedics: %2 count: %3", name _incap, _sortedMedics, count _sortedMedics];
				}; */
				//ENDDEBUG

				// Update the Lifeline_medics array with our new sorted order
				Lifeline_medics = _sortedMedics;


				_arraynum = 0;
				_numMedics = count Lifeline_medics;
				_arraynum = [0]; // MAKE IT ALWAYS CLOSEST
				_medic = Lifeline_medics select (selectRandom _arraynum);

				// If Group MASCAL happened and medics from another group are en route, then limit the number of other group medics  (option is Lifeline_Medic_Limit)
				if (group _incap in Lifeline_Group_Mascal) then {
					_count_current_medics = [group _medic] call Lifeline_count_group_medics;
					if (Lifeline_Medic_Limit == 1 && _count_current_medics > 0) then {
						_medic_under_limit = false;	
					};
					if (Lifeline_Medic_Limit == 2 && _count_current_medics > 1) then {
						_medic_under_limit = false;
					};
					if (Lifeline_Medic_Limit == 3 && _count_current_medics > 2) then {
						_medic_under_limit = false;
					};
					if !(_medic_under_limit) then {
						_medic = objNull;
					};
				};

				_check_both_sides = [];

				// _sleep = 1; // faster queue when found medic
				// _sleep = 0.5; // faster queue when found medic
				_sleep = 0.2; // faster queue when found medic


				/* if (_medic == objNull) then {			// SWITCH LOGIC IN REJECT MEDIC 

					if ((!Lifeline_PVPstatus && Lifeline_Include_OPFOR) || Lifeline_PVPstatus) then {
						
						if (_incap_side == Lifeline_Side) then {
							_check_both_sides pushBackUnique 1;
							// Find first unit from OPFOR side
							_opforUnits = Lifeline_incaps2choose select {side group _x in Lifeline_OPFOR_Sides};
							if (count _opforUnits > 0) then {
								Lifeline_side_switch = 2;
								// _sleep = 0.2;
								_sleep = 1;
							};
						};
						if (_incap_side in Lifeline_OPFOR_Sides) then {
							_check_both_sides pushBackUnique 2;
							// Find first unit from BLUFOR side
							_bluforUnits = Lifeline_incaps2choose select {side group _x == Lifeline_Side};
							if (count _bluforUnits > 0) then {
								Lifeline_side_switch = 1;
								// _sleep = 0.2;
								_sleep = 1;
							};
						};
					};
				}; */





				
				
				// sleep 0.2;

				diag_log format ["PRIMARY LOOP uuuuuuuuuuuuuuuuuuuuuuuuuu SELECTED MEDIC %1  uuuuuuuuuuuuuuuuuuuuuuuuuuuuu ReviveInProgress %2 Lifeline_AssignedMedic %3", name _medic, _medic getVariable ["ReviveInProgress",0], (_medic getVariable ["Lifeline_AssignedMedic",[]])];
				if (Lifeline_Revive_debug) then {[_medic,"SELECTED MEDIC"] call serverSide_unitstate};

				_medic setVariable ["Lifeline_ExitTravel", false, true];diag_log format ["%1 [3081]!!!!!!!!! [MEDIC] change var Lifeline_ExitTravel = false !!!!!!!!!!!!!", name _medic];
				
				diag_log format ["%1|%2",name _incap, name _medic];
				diag_log format ["%1|%2 PRIMARY LOOP uuuuuuuuuuuuuuuuuuuuuuuuuu SELECT| INCAP: %1 | MEDIC: %2 |uuuuuuuuuuuuuu", name _incap, name _medic];
				diag_log format ["%1|%2",name _incap, name _medic];
				
				//DEBUG
				if (_incap getVariable ["ReviveInProgress",0] == 3 || _medic getVariable ["ReviveInProgress",0] != 0  || (_incap getVariable ["Lifeline_AssignedMedic",[]]) isNotEqualTo []) exitWith {
					diag_log format ["%1 | %2 | PRIMARY LOOP uuuuuuuuuuuuuuuuuuuu MEDIC ALREADY ASSIGNED uuuuuuuuuuuuuuuuuuuuuu incap ReviveInProgress %3 medic ReviveInProgress %4 AssignedMedic %5", name _incap, name _medic,_incap getVariable ["ReviveInProgress",0],_medic getVariable ["ReviveInProgress",0],name (_incap getVariable ["Lifeline_AssignedMedic",[]] select 0)];
					diag_log format ["%1 | %2 | PRIMARY LOOP uuuuuuuuuuuuuuuuuuuu MEDIC ALREADY ASSIGNED uuuuuuuuuuuuuuuuuuuuuu incap ReviveInProgress %3 medic ReviveInProgress %4 AssignedMedic %5", name _incap, name _medic,_incap getVariable ["ReviveInProgress",0],_medic getVariable ["ReviveInProgress",0],name (_incap getVariable ["Lifeline_AssignedMedic",[]] select 0)];
					diag_log format ["%1 | %2 | PRIMARY LOOP uuuuuuuuuuuuuuuuuuuu MEDIC ALREADY ASSIGNED uuuuuuuuuuuuuuuuuuuuuu incap ReviveInProgress %3 medic ReviveInProgress %4 AssignedMedic %5", name _incap, name _medic,_incap getVariable ["ReviveInProgress",0],_medic getVariable ["ReviveInProgress",0],name (_incap getVariable ["Lifeline_AssignedMedic",[]] select 0)];
					if (Lifeline_Revive_debug) then {
						if (Lifeline_hintsilent) then {hintsilent format ["MEDIC ALREADY ASSIGNED\nfor incap: %1", name _incap]};
						// if (Lifeline_debug_soundalert) then {["siren1"] remoteExec ["playSound",2];};
					};
					_medic setVariable ["ReviveInProgress",0,true];diag_log format ["%1 [3089]!!!!!!!!! [MEDIC] change var ReviveInProgress = 0 !!!!!!!!!!!!!", name _incap];				
					_medic setVariable ["isMedic",false,true]; //just for SOG AI to avoid clashes. 
					_medic = objNull;
				}; // exitwith
				//ENDDEBUG

				diag_log format ["%1 uuuuuuuuuuuuuu [2963] PRIMARY LOOP 'ReviveInProgress = 3' ADDED TO INCAP. test, should be three: %2", name _incap, _incap getVariable ["ReviveInProgress",0]];				
				// sleep 0.5;				

				diag_log " ";
				
				// _voice = _medic getVariable "Lifeline_Voice";
				_voice = _medic getVariable ["Lifeline_Voice", selectRandom Lifeline_UnitVoices];

		
			} else { // no medic available

				// ============================  'ELSE' REJECTED NO MEDIC ================================
				// ============================  'ELSE' REJECTED NO MEDIC ================================
				// ============================  'ELSE' REJECTED NO MEDIC ================================

				diag_log format ["%1 [1674] PRIMARY LOOP 'ELSE' REJECTED NO MEDIC _groupindex: %2 (count Lifeline_incaps2chooseGROUPS - 1): %3", name _incap, _groupindex, (count Lifeline_incaps2chooseGROUPS - 1)];
				// if (_groupindex < (count Lifeline_incaps2chooseGROUPS - 1)) then {
					
				// if (!isPlayer _incap) then { // players always put to front of list, so we dont want to switch groups if incap is player, next unit might also be player.
					_groupindex = _groupindex + 1;  
				// };



				diag_log format ["%1 [1650] PRIMARY LOOP 'ELSE' REJECTED NO MEDIC  ", name _incap];
				diag_log format ["%1 [1650] PRIMARY LOOP 'ELSE' REJECTED NO MEDIC (incap is %1) !!!!!!!!!!!! PRIMARY LOOP [ELSE] //if (alive _incap && count Lifeline_medics2choose >0) ", name _incap];
				diag_log format ["%1 [1650] PRIMARY LOOP 'ELSE' REJECTED NO MEDIC  ", name _incap];

				



				// ================ CHECK FOR MASCAL (Mass Casualty Event) ================================

				Lifeline_medicsMASCALcheck = Lifeline_healthy_units select {(side group _x) == (_incap_side) && [_x,_incap] call Lifeline_check_medics_MASCAL};
				Lifeline_medicsMASCALcheckTOTAL = (Lifeline_All_Units - Lifeline_incapacitated) select {(side group _x) == (_incap_side) && [_x,_incap] call Lifeline_check_medics_MASCAL};
				_diag_array = ""; {_diag_array = _diag_array + name _x + ", " } foreach Lifeline_healthy_units; diag_log format ["uuuuuuuuuuu [1654] PRIMARY LOOP || Lifeline_healthy_units: %1",_diag_array];
				_diag_array = ""; {_diag_array = _diag_array + name _x + ", " } foreach Lifeline_medicsMASCALcheck; diag_log format ["uuuuuuuuuuu [1654] PRIMARY LOOP || Lifeline_medicsMASCALcheck: %1",_diag_array];



									//TEST
				/* 	if (count Lifeline_incapacitated > 1) then {
						private _firstUnit = Lifeline_incapacitated select 0;
						Lifeline_incapacitated deleteAt 0;
						Lifeline_incapacitated pushBack _firstUnit;
						publicVariable "Lifeline_incapacitated";
						
						// Optional: Log the change
						diag_log format ["Moved unit %1 from front to back of Lifeline_incapacitated array", name _firstUnit];
					}; */

				// diag_log format ["%1 uuuuuuuuuuu [1641] PRIMARY LOOP || Lifeline_medicsMASCALcheck: %2 _incap_side %3", name _incap, Lifeline_medicsMASCALcheck, _incap_side];
				
				//DEBUG
				
				// ================ METHOD 1. WITH AUTO RECOVER TEXT CHANGE ================================

				// deleted for now. Resurect later


				// ================ METHOD 2. SIMPLE METHOD WITHOUT AUTO RECOVER TEXT CHANGE ================================
				//ENDDEBUG

				
				//Check if GROUP MASCAL  
				if (count Lifeline_medicsMASCALcheck == 0) then {

					if (Lifeline_Revive_debug && Lifeline_debug_soundalert) then {
						["mascalya"] remoteExec ["playSound", 0];
					};

					diag_log format ["%1 Group %4 +++++++++++++ [1757] PRIMARY LOOP || GROUP MASCAL || Lifeline_medicsMASCALcheck: %2 _incap_side %3", name _incap, Lifeline_medicsMASCALcheck, _incap_side, group _incap];
					diag_log format ["%1 Group %4 +++++++++++++ [1757] PRIMARY LOOP || GROUP MASCAL || Lifeline_medicsMASCALcheck: %2 _incap_side %3", name _incap, Lifeline_medicsMASCALcheck, _incap_side, group _incap];
					diag_log format ["%1 Group %4 +++++++++++++ [1757] PRIMARY LOOP || GROUP MASCAL || Lifeline_medicsMASCALcheck: %2 _incap_side %3", name _incap, Lifeline_medicsMASCALcheck, _incap_side, group _incap];

					//send group to mascal list		
					Lifeline_Group_Mascal pushBackUnique group _incap;
					
					
				} else {
					Lifeline_Group_Mascal = Lifeline_Group_Mascal - [group _incap];
					// _groupindex = _groupindex + 1;
				};

				//Check if TOTAL MASCAL 
				if (count Lifeline_medicsMASCALcheckTOTAL == 0) then {

					diag_log format ["%1 Group %4 !!!!!!!!!!!!!!!! [1772] PRIMARY LOOP || TOTAL MASCAL || Lifeline_medicsMASCALcheck: %2 _incap_side %3", name _incap, Lifeline_medicsMASCALcheck, _incap_side, group _incap];
					diag_log format ["%1 Group %4 !!!!!!!!!!!!!!!! [1772] PRIMARY LOOP || TOTAL MASCAL || Lifeline_medicsMASCALcheck: %2 _incap_side %3", name _incap, Lifeline_medicsMASCALcheck, _incap_side, group _incap];
					diag_log format ["%1 Group %4 !!!!!!!!!!!!!!!! [1772] PRIMARY LOOP || TOTAL MASCAL || Lifeline_medicsMASCALcheck: %2 _incap_side %3", name _incap, Lifeline_medicsMASCALcheck, _incap_side, group _incap];


					// Determine if this side matters for MASCAL notification for players
					private _isRelevantSide = false;					
					// In PVP, we care about any side that has players
					if (Lifeline_PVPstatus) then {
						_isRelevantSide = true;
					} else {
						// In PVE with OPFOR included, we care about player side and possibly OPFOR
						if (Lifeline_Include_OPFOR) then {
							// Check if this is the player side or if we should notify about OPFOR too
							_isRelevantSide = (_incap_side == Lifeline_Side);
						} else {
							// In PVE without OPFOR included, we only care about player side
							_isRelevantSide = true;
						};
					};
					
					// If this is a side we care about, check for MASCAL
					if (_isRelevantSide) then {

						// Filter incapacitated units on this side
						private _sideIncaps = Lifeline_incapacitated select {side group _x == _incap_side};
						private _sideIncapsPlayers = _sideIncaps select {isPlayer _x};
    					{							       
							   _statusText = "all units down";							   
							    // Create formatted text for right-aligned message
								private _colour = "EF5736"; // Your existing red color
								// private _textright = format ["<t align='right' size='%3' color='#%1'>MASCAL</t><br /><t align='right' size='%4' color='#%1'>%2</t>", _colour, _statusText,0.7,0.4];								
								// private _textright = format ["<t align='right' size='%3' color='#%1'>MASCAL</t><br /><t align='right' size='%4' color='#%1'>%2</t>", _colour, _statusText,0.75,0.55];
								private _textright = format ["<t align='right' size='%3' color='#%1'>MASCAL</t><br/><t align='right' size='%4' color='#%1'>%2 </t>", _colour, _statusText,0.85,0.52]; 								
								// Call your existing display function for this specific player
								[_textright, 1.15, 7] remoteExec ["Lifeline_display_textright2", _x];						
								// Play sound for this specific player
								// ["siren1"] remoteExec ["playSound", _x];								
								// Log each player notification
								diag_log format ["MASCAL: Notified player %1, Side %2 - %3", name _x, _incap_side, _statusText];

						} forEach _sideIncapsPlayers;				
					};
				};

				// =========================== END OF MASCAL NOTIFICATION METHODS ================================


                
				/* if (Lifeline_Revive_debug && Lifeline_debug_soundalert) then {
					// ["no_medic"] remoteExec ["playSound", 0];
					if (_incap_side == WEST) then {["west_no_medic"] remoteExec ["playSound", 0];};
					if (_incap_side == EAST) then {["east_no_medic"] remoteExec ["playSound", 0];};
					if (_incap_side == RESISTANCE) then {["ind_no_medic"] remoteExec ["playSound", 0];};
				}; */

				_incap setVariable ["ReviveInProgress",0,true];diag_log format ["%1 [3140]!!!!!!!!! [INCAP] change var ReviveInProgress = 0 !!!!!!!!!!!!!", name _incap];
				_incap setVariable ["isInjured",false,true]; //just for SOG AI to avoid clashes. 
				

				diag_log format ["%1 | [1607] !!!!!!!!!!!! PRIMARY LOOP. JUST BEFORE SWITCH IN REJECT MEDIC Lifeline_side_switch %2 _incap_side %3", name _incap, Lifeline_side_switch, _incap_side];

				// SWITCH LOGIC IN REJECT MEDIC 

			/* 	if ((!Lifeline_PVPstatus && Lifeline_Include_OPFOR) || Lifeline_PVPstatus) then {
					
					if (_incap_side == Lifeline_Side) then {
						_check_both_sides pushBackUnique 1;
						// Find first unit from OPFOR side
						_opforUnits = Lifeline_incaps2choose select {side group _x in Lifeline_OPFOR_Sides};
						if (count _opforUnits > 0) then {
							Lifeline_side_switch = 2;
							// _sleep = 0.2;
							// _sleep = 1;
						};
						diag_log format ["%1 [1832] PRIMARY LOOP | OTHER SIDE SWITCH | LIST -> OPFOR | _opforUnits %2 Lifeline_side_switch %3 _check_both_sides %4", name _incap, count _opforUnits, Lifeline_side_switch, _check_both_sides];
					};
					if (_incap_side in Lifeline_OPFOR_Sides) then {
						_check_both_sides pushBackUnique 2;
						// Find first unit from BLUFOR side
						_bluforUnits = Lifeline_incaps2choose select {side group _x == Lifeline_Side};
						if (count _bluforUnits > 0) then {
							Lifeline_side_switch = 1;
							// _sleep = 0.2;
							// _sleep = 1;
						};
						diag_log format ["%1 [1832] PRIMARY LOOP | OTHER SIDE SWITCH | OPFOR -> LIST | _opforUnits %2 Lifeline_side_switch %3 _check_both_sides %4", name _incap, count _opforUnits, Lifeline_side_switch, _check_both_sides];
					};
				}; */

				

				_medic = objNull;
			};


			// =========================== END OF INCAP AND MEDIC SELECTION ================================


			if (!isNull _medic) then {
		

				// medic leave vehicle
				if (alive _incap && alive _medic && !(isNull objectParent _medic) && isTouchingGround (vehicle _medic)) then {
					diag_log format ["%1 | %2 | [1835] !!!!!!!!!!!! PRIMARY LOOP. medic leave vehicle GATE 1 assignedVehicle %3", name _incap, name _medic, assignedVehicle _medic];
					_vehicle = objectParent _medic;
					if (_medic distance2D _incap < 200) then {
						_medic setVariable ["AssignedVeh", _vehicle, true];
						unassignVehicle _medic;
						// [_medic] remoteExec ["unassignVehicle", 0];
						moveOut _medic;
						[_medic] allowGetIn false;
						diag_log format ["%1 | %2 | [1938] !!!!!!!!!!!! PRIMARY LOOP. check assignedVehicle %3", name _incap, name _medic, assignedVehicle _medic];
					} else {
						diag_log format ["%1 | %2 | [1940] !!!!!!!!!!!! PRIMARY LOOP. medic leave vehicle GATE 2", name _incap, name _medic];
						if (_vehicle isKindOf "car") exitWith {
							_pos = [_incap, 10, 20, 5, 0, 20, 0] call BIS_fnc_findSafePos;
							_vehicle domove _pos;
							
						};
					};
				};

				// Medic group position
				if (alive _incap && alive _medic && count units group _medic ==1) then {
					if (_medic getVariable ["Lifeline_medicOrigPos",[]] isEqualTo []) then {
						_pos = (getPosATL _medic);
						_dir = (getdir _medic);
						_medic setVariable ["Lifeline_medicOrigPos", _pos, true];
						_medic setVariable ["Lifeline_medicOrigDir", _dir, true];
					};
				};
				
				diag_log format ["%1 | %2 | [1877] !!!!!!!!!!!! PRIMARY LOOP. JUST BEFORE DISPATCH MEDIC", name _incap, name _medic];

				// Dispatch medic
				if (alive _incap && alive _medic && !(_medic in Lifeline_Process) && !(_incap in Lifeline_Process)) then {

					_pairloopsetting = 25;
					// _pairloopsetting = 15;
					_dist = (_medic distance2D _incap);diag_log format ["%1 | %2 [2915] PRIMARY LOOP uuuuuuuuuuuuuuuuuuuuuuuuuu distance %3 uuuuuuuuuuuuuuuuuuuuuuuuuuuu", name _incap, name _medic, _dist];
					_pairloopsetting = _pairloopsetting + (_dist/4);diag_log format ["%1 | %2 [2915] PRIMARY LOOP uuuuuuuuuuuuuuuuuuuuuuuuuu _pairloopsetting %3 uuuuuuuuuuuuuuuuuuuuuuuuuuuu", name _incap, name _medic, _pairloopsetting];
					_pairlooptimeout = (time + _pairloopsetting);diag_log format ["%1 | %2 [2915] PRIMARY LOOP uuuuuuuuuuuuuuuuuuuuuuuuuu _pairlooptimeout %3 secs %4 uuuuuuuuuuuuuuuuuuuuuuuuuuuu", name _incap, name _medic, _pairlooptimeout, _pairlooptimeout - time];
					_incap setVariable ["LifelinePairTimeOut", _pairlooptimeout, true]; diag_log format ["%1 [3209]!!!!!!!!! [INCAP] change var LifelinePairTimeOut = +15 sec !!!!!!!!!!!!!", name _incap];
					_medic setVariable ["LifelinePairTimeOut", _pairlooptimeout, true]; diag_log format ["%1 [3209]!!!!!!!!! [MEDIC] change var LifelinePairTimeOut = +15 sec !!!!!!!!!!!!!", name _medic];
					//DEBUG	
					// diag_log format ["%1 uuuuuuuuuuuuuu [3258] PRIMARY LOOP 'ReviveInProgress = 1'     ADDED TO MEDIC. test, should be one: %2", name _medic, _medic getVariable ["ReviveInProgress",0]];
					// diag_log format ["%1 PRIMARY LOOP uuuuuuuuuuuuuu [3258] PRIMARY LOOP 'Lifeline_reset_trig = false' ADDED TO MEDIC. test, should be false: %2", name _medic, _medic getVariable ["Lifeline_reset_trig",false]];

					// _IDinSquad = groupId _incap; 
					// [_voice,_medic] spawn Lifeline_radio_how_copy;					
					// [_voice,_medic] remoteExec ["Lifeline_radio_how_copy"]; 
					//ENDDEBUG

					//original version
					if (Lifeline_radio && _medic distance2D _incap > 55 && _medic getVariable ["Lifeline_ExitTravel", false] == false && _medic getVariable ["ReviveInProgress",0] != 0 && alive _medic && alive _incap && lifestate _medic != "INCAPACITATED"
						&& lifestate _incap == "INCAPACITATED"
					) then {
						[_incap,_voice,_medic] spawn {
							params ["_incap","_voice","_medic"];
							sleep 1;
							if (isPlayer _incap && _medic getVariable ["ReviveInProgress",0] != 0) then {
							[_incap, [_voice+"_hangtight1", 50, 1, true]] remoteExec ["say3D", _incap];
							diag_log format ["| %1 | %2 | [2734] kkkkkkkkkkkkk SAY3D HANGTIGHT | voice: %3", name _incap, name _medic, _voice];
							};
						};
					};

					Lifeline_Process pushBackUnique _incap;
					Lifeline_Process pushBackUnique _medic;
					publicVariable "Lifeline_Process";
					_incap setVariable ["ReviveInProgress",3,true]; diag_log format ["%1 [1773]!!!!!!!!! [INCAP] change var ReviveInProgress = 3 !!!!!!!!!!!!!", name _incap];
					_medic setVariable ["ReviveInProgress",1,true]; diag_log format ["%1 [1774]!!!!!!!!! [MEDIC] change var ReviveInProgress = 1 !!!!!!!!!!!!!", name _medic];
					//these two variables below are just for SOG AI to avoid clashes. 
					_incap setVariable ["isInjured",true,true]; 
					_medic setVariable ["isMedic",true,true]; 
                    // -------- 
					if (lifestate _medic != "INCAPACITATED" && !(_medic getVariable ["Lifeline_Captive_Delay",false])) then {
						_medic setVariable ["Lifeline_Captive",(captive _medic),true]; diag_log format ["%1 [1775]!!!!!!!!! [MEDIC] change var Lifeline_Captive = %2 !!!!!!!!!!!!!", name _medic, captive _medic];//2025
					};

					// _medic setVariable ["Lifeline_reset_trig",false,true]; diag_log format ["%1 [983]!!!!!!!!! [MEDIC] change var Lifeline_reset_trig = false !!!!!!!!!!!!!", name _medic];
					_incap setVariable ["Lifeline_AssignedMedic", [_medic], true];	diag_log format ["%1 [983]!!!!!!!!! [INCAP] change var Lifeline_AssignedMedic = %2 !!!!!!!!!!!!!", name _incap, name _medic];			
					diag_log format ["%1 uuuuuuuuuuuuuu [3057] PRIMARY LOOP 'ReviveInProgress = 1'     ADDED TO MEDIC. test, should be one: %2", name _medic, _medic getVariable ["ReviveInProgress",0]];
					// diag_log format ["%1 uuuuuuuuuuuuuu [3057] PRIMARY LOOP 'Lifeline_reset_trig = false' ADDED TO MEDIC. test, should be false: %2", name _medic, _medic getVariable ["Lifeline_reset_trig",false]];

					// Call Functions. Start revive travel and incap / medic pair monitoring loop
					[_medic, _incap] spawn Lifeline_PairLoop; diag_log format ["%1 | %2 [3217] PRIMARY LOOP !!!!!!!!!!! spawn Lifeline_PairLoop !!!!!!!!!!!", name _incap, name _medic];
					if (Lifeline_StartReviveBETA == true) then {
						[_medic, _incap] spawn Lifeline_StartRevive; diag_log format ["%1 | %2 [3217] PRIMARY LOOP !!!!!!!!!!! spawn Lifeline_StartRevive !!!!!!!!!!!", name _incap, name _medic];
					} else {
						[_medic, _incap] spawn Lifeline_StartReviveOLD; diag_log format ["%1 | %2 [3217] PRIMARY LOOP !!!!!!!!!!! spawn Lifeline_StartReviveOLD !!!!!!!!!!!", name _incap, name _medic];
					};

				}; // end if alive && !(_medic in Lifeline_Process) && !(_incap in Lifeline_Process)

			};

			// }; // end count Lifeline_incaps2choose >0 && count Lifeline_healthy_units >0

		} else { 
			diag_log format ["+++++++++++++++++++++ PRIMARY LOOP ELSE. NO INCAPS!!  [2017] SLEEP %1", _sleep];
			_sleep = 3;	
		};



		// diag_log format ["%1 | %2 | [1719] !!!!!!!!!!! _check_both_sides: %3", name _incap, name _medic, _check_both_sides];

	/* 	if (count _check_both_sides == 2) then {
			_sleep = 3;		
		}; */

		//DEBUG
		if (_sleep == 3) then {
			// playsound "siren1";
			diag_log format ["++++++++++++++++++++++++++++++++++++++++++++++ [1922] +++++++++++++++++++++++++++++++++++++++++!", _sleep];
			diag_log format ["+++++++++++++++++++++ PRIMARY LOOP end of loop [1922] SLEEP IS THREE SECONDS !!!!!!!!!!!!!!!!!!!", _sleep];
			// diag_log format ["+++++++++++++++++++++ PRIMARY LOOP end of loop [1922] SLEEP IS THREE SECONDS !!!!!!!!!!!!!!!!!!!", _sleep];
			// diag_log format ["+++++++++++++++++++++ PRIMARY LOOP end of loop [1922] SLEEP IS THREE SECONDS !!!!!!!!!!!!!!!!!!!", _sleep];
		};
		//ENDDEBUG

		sleep _sleep;
		// sleep 0.2;
		// playsound "beep_hi_1";
		diag_log format ["+++++++++++++++++++++ PRIMARY LOOP end of loop [1926] SLEEP %1", _sleep];

	}; // end while

}; // isserver


//=======================================================================================================================================
