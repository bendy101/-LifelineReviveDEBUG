 diag_log "                                                                                                "; 
 diag_log "                                                                                                "; 
 diag_log "                                                                                                "; 
diag_log "                                                                                                '"; 
diag_log "                                                                                                '"; 
diag_log "============================================================================================================='"; 
diag_log "============================================================================================================='"; 
diag_log "========================================== Lifeline_ACE_Functions.sqf =========================================='"; 
diag_log "============================================================================================================='"; 
diag_log "============================================================================================================='"; 

ace_medical_ai_enabledFor = 0; // disable the ACE medical ai

["ace_unconscious", {
	params ["_unit",  "_status"];

		if (_unit in Lifeline_All_Units)	then {

			if (_status == true) then {
				diag_log format ["%1 =========++++++++++ ace_unconscious TRUE ==============", name _unit];
				diag_log _unit;

				if (captive _unit) then {_unit setVariable ["Lifeline_Captive",true,true]} else {_unit setVariable ["Lifeline_Captive",false,true]}; diag_log format ["%1 | [0021]==== UNCONC captive: %2", name _unit, captive _unit];//2025

				
				_unit setVariable ["Lifeline_selfheal_progss",false,true]; //clear var if it was in middle of self healing

				// diag_log _status;						
				// ================= added the killed event handler
				_unit addEventHandler ["Killed", {
					params ["_unit2", "_killer2", "_instigator2", "_useEffects2"];									
					diag_log format ["%1 =========================== KILLED =============================", name _unit2];
					_unit call Lifeline_reset;
					Lifeline_Process = Lifeline_Process - [_unit];
					Lifeline_incapacitated = Lifeline_incapacitated - [_unit]; 
					publicVariable "Lifeline_Process";	
					_unit enableSimulationGlobal false;//myedit test		
				}];
				//===============================================

				//	if !(lifestate _unit == "INCAPACITATED") then {
					[_unit] spawn {
						params ["_unit"];
						// if (damage _unit <0.9) then {
							// _unit setDamage 0.8;

							if (!isnull objectParent _unit) then {
								_vehicle = objectParent _unit;
								_pos = _unit getPos [(4 + random 3), (getdir _vehicle) + (60 + random 20)];
								sleep 3 + random 3;
								moveOut _unit;
								_unit setPosATL _pos
							};
							_unit setcaptive true;diag_log format ["%1 [049 Lifeline_ACE_Functions.sqf]!!!!!!!!! change var setcaptive = true !!!!!!!!!!!!!", name _unit]; 
							// _unit allowdamage false; //zdo

							diag_log "==_unit setVariable [ace_medical_injury, false] [219]";
							//_unit setUnconscious true; //old line
							//[_unit, true] call ace_medical_fnc_setUnconscious; //NEW line
							Lifeline_incapacitated pushBackUnique _unit;
							publicVariable "Lifeline_incapacitated";
							if (count units group _unit ==1) then {
								if (_unit getVariable ["Lifeline_OrigPos",[]] isEqualTo []) then {
									_pos = (getPosATL _unit);
									_dir = (getdir _unit);
									_unit setVariable ["Lifeline_OrigPos", _pos, true];
									_unit setVariable ["Lifeline_OrigDir", _dir, true];
								};
							};
						//DEBUG	
						// } else {
							// _unit setdamage 1;
							// _damage = 1;
						// };
						//ENDDEBUG
						// =========== ADD THE DISTANCE DISPLAY ==============
						// moved here, start display
						if ((Lifeline_HUD_distance == true) && isPlayer _unit) then {
							_seconds = 999;
							if (lifeState _unit == "INCAPACITATED" && !(_unit getVariable ["Lifeline_countdown_start",false])) then {
								_unit setVariable ["Lifeline_countdown_start",true,true];
								[[_unit,_seconds], Lifeline_countdown_timerACE] remoteExec ["spawn",_unit, true];
							};
						};
						
					};
			//	};
			} else {
				_unit setVariable ["Lifeline_selfheal_progss",false,true];diag_log format ["%1 [065 ACE]!!!!!!!!! change var Lifeline_selfheal_progss = false !!!!!!!!!!!!!", name _unit];
			diag_log format ["%1 =========++++++++++ ace_unconscious AWAKE ==============", name _unit];
			diag_log format ["%1 =========++++++++++ ace_unconscious AWAKE ==============", name _unit];
			diag_log format ["%1 =========++++++++++ ace_unconscious AWAKE ==============", name _unit];
			diag_log _unit;
			_AssignedMedic = (_unit getVariable ["Lifeline_AssignedMedic",[]]); 
			if (_AssignedMedic isNotEqualTo [] || _unit getVariable ["ReviveInProgress",0] == 3) then {
			// _unit setVariable ["Lifeline_ExitTravel", true, true];
			(_AssignedMedic select 0) setVariable ["Lifeline_ExitTravel", true, true];//medic set Lifeline_ExitTravel
			diag_log format ["%1 =========++++++++++ ace_unconscious AWAKE IN PAIR LOOP ==============", name _unit];
			diag_log format ["%1 =========++++++++++ ace_unconscious AWAKE IN PAIR LOOP ==============", name _unit];
			diag_log format ["%1 =========++++++++++ ace_unconscious AWAKE IN PAIR LOOP ==============", name _unit];
			} else {	

			[[_unit],"72 ACE WAKEUP"] spawn Lifeline_reset2;

			};
			
			
			};		
		};	//	if (_unit in Lifeline_All_Units)	
						
}] call CBA_fnc_addEventHandler; 
					

//DEBUG
/* ["ace_treatmentSucceded", {
params ["_medic", "_incap", "_selectionName", "_className"];


 diag_log format ["=====FIRED TREATMENT SUCCEEDED %1 %2 %3 %4", name _medic, name _incap, _selectionName, _className];
 diag_log format ["=====FIRED TREATMENT SUCCEEDED %1 %2 %3 %4", name _medic, name _incap, _selectionName, _className];
 diag_log format ["=====FIRED TREATMENT SUCCEEDED %1 %2 %3 %4", name _medic, name _incap, _selectionName, _className];



}] call CBA_fnc_addEventHandler; */
//ENDDEBUG


Lifeline_ACE_Anims_Voice = {
params ["_incap", "_medic","_EnemyCloseBy","_voice","_switch", "_againswitch", "_encourage","_enc_count"];
		diag_log "=========FNC Lifeline_ACE_Anims_Voice";
		diag_log "=========FNC Lifeline_ACE_Anims_Voice";
		diag_log "=========FNC Lifeline_ACE_Anims_Voice";

		// Kneeling revive - no near enemy
		if (isNull _EnemyCloseBy) then {
		[_medic, "AinvPknlMstpSnonWnonDnon_medic4"] remoteExec ["playMove", _medic]; // ORIGNAL
			diag_log "2264 ==== ANIMATION AinvPknlMstpSnonWnonDnon_medic4";
			 // sleep 8;
					sleep 4;
						_rando = selectRandom[1,2,3,4];
						diag_log format ["==== MID ANIM RANDO %1 count %2 VOICE %3", _rando, _enc_count, _voice];
						if (_rando == 1) then { 
						[_medic, [_voice+(_encourage select _enc_count), 20, 1, true]] remoteExec ["say3D", 0];
						diag_log format ["| %1 | %2 | 2266 kkkkkkkkkkkkk SAY3D MID ANIM | voice: %3", name _incap, name _medic, str (_voice+(_encourage select _enc_count))];
						if (_enc_count == 2) then {_enc_count = 0} else {_enc_count = _enc_count + 1};
						diag_log "====1926 half anim encouragment voice====";
						};
					sleep 4;
		};

		// Lying down revive - near enemy. Alternating between two anims to fix an Arma bug
		if (!isNull _EnemyCloseBy) then {
					if (_switch == 0) then {
						[_medic, "ainvppnemstpslaywrfldnon_medicother"] remoteExec ["playMove", _medic];
			diag_log "2271 ==== ANIMATION ainvppnemstpslaywrfldnon_medicother";
						_switch = 1;
						// sleep 9;
						sleep 4.5;
							_rando = selectRandom[1,2,3,4];
							diag_log format ["==== MID ANIM RANDO %1 count %2 VOICE %3", _rando, _enc_count, _voice];
							if (_rando == 1) then { 
							[_medic, [_voice+(_encourage select _enc_count), 20, 1, true]] remoteExec ["say3D", 0];
							diag_log format ["| %1 | %2 | 2284 kkkkkkkkkkkkk SAY3D MID ANIM | voice: %3", name _incap, name _medic, str (_voice+(_encourage select _enc_count))];
							if (_enc_count == 2) then {_enc_count = 0} else {_enc_count = _enc_count + 1};
							diag_log "====1926 half anim encouragment voice====";
							};
						sleep 4.5;
					} else {
						[_medic, "AinvPpneMstpSlayWpstDnon_medicOther"] remoteExec ["playMove", _medic];
			diag_log "2285 ==== ANIMATION AinvPpneMstpSlayWpstDnon_medicOther";
						_switch = 0;
						// sleep 9.5;
						sleep 4.75;
							_rando = selectRandom[1,2,3,4];
							diag_log format ["==== MID ANIM RANDO %1 count %2 VOICE %3", _rando, _enc_count, _voice];
							if (_rando == 1) then { 
							[_medic, [_voice+(_encourage select _enc_count), 20, 1, true]] remoteExec ["say3D", 0];
							diag_log format ["| %1 | %2 | 2299 kkkkkkkkkkkkk SAY3D MID ANIM | voice: %3", name _incap, name _medic, str (_voice+(_encourage select _enc_count))];
							if (_enc_count == 2) then {_enc_count = 0} else {_enc_count = _enc_count + 1};
							diag_log "====1926 half anim encouragment voice====";
							};
						sleep 4.75;
					}; 
		};	
[_switch, _againswitch, _enc_count]

};



Lifeline_ACE_Revive = {
params ["_incap", "_medic","_EnemyCloseBy","_voice"];
		
		_switch = 0;
		_againswitch = 1; // this is so the voice sample "and again" alternates samples and not sound robotic
		_encourage = ["_greetB5", "_greetB2", "_almostthere1"];	//different voices of encouragement
		_enc_count = 0;											//round-robin counter for above	
		_cprcount = 1;
		_cpr = [_medic, _incap] call ace_medical_treatment_fnc_canCPR;

		while {_cpr == true && _cprcount < 6 && alive _medic && alive _incap && lifestate _incap == "INCAPACITATED"} do {

					if (lifestate _incap == "DEAD" || !(alive _incap) ) exitWith {};

					// [_medic, [_voice+"_CPR1", 50, 1, true]] remoteExec ["say3D", 0];
					[_medic, [_voice+"_CPR1", 20, 1, true]] remoteExec ["say3D", 0]; //softer
					diag_log format ["| %1 | %2 | 1475 kkkkkkkkkkkkk SAY3D CPR | voice: %3", name _incap, name _medic, _voice];

					if (_cprcount == 1) then {
						//DEBUG // [_medic, "UnconsciousReviveMedic_B"] remoteExec ["playMove", _medic];
						// [_medic, "AinvPknlMstpSnonWrflDnon_medic5"] remoteExec ["playMove", _medic]; //kind of press, but static //ENDDEBUG
						[_medic, "AinvPknlMstpSnonWnonDr_medic0"] remoteExec ["playMove", _medic]; //kind of press, but static
						//DEBUG // [_medic, "UnconsciousReviveMedic_B"] remoteExec ["switchMove", _medic]; //ENDDEBUG
						diag_log "1662 ==== ANIMATION AinvPknlMstpSnonWrflDnon_medic5";
					};

					//added to increase revive time limit on each loop pass
					_timelimitincap = (_incap getvariable "LifelinePairTimeOut");
					_timelimitmedic = (_medic getvariable "LifelinePairTimeOut");
					_incap setVariable ["LifelinePairTimeOut", _timelimitincap + 12, true]; 
					_medic setVariable ["LifelinePairTimeOut", _timelimitmedic + 12, true]; 

					diag_log format ["%1 ========CPR======= PASS %2", name _incap, _cprcount];
					diag_log format ["%1 ========CPR======= PASS %2", name _incap, _cprcount];
					diag_log format ["%1 ========CPR======= PASS %2", name _incap, _cprcount];
					diag_log format ["%1 ========CPR======= PASS %2", name _incap, _cprcount];
					
					if (isPlayer _incap && Lifeline_HUD_medical) then {
						_colour = "F9CAA7";
						[format ["<t align='right' size='%2' color='#%1'>CPR</t>",_colour, 0.5],((safeZoneW - 1) * 0.48),1.3,5,0,0,Lifelinetxt2Layer] remoteExec ["BIS_fnc_dynamicText",_incap];
					};

					_cprcount = _cprcount + 1;
					[_medic, _incap, "RightArm", "Epinephrine", objNull, "ACE_epinephrine"] call ace_medical_treatment_fnc_medication;
					sleep 2;
					[_medic, _incap] call ace_medical_treatment_fnc_cprStart;
					 sleep 10;
					// [_medic, _incap] call ace_medical_treatment_fnc_cprSuccess;
					// sleep 2;
					_cpr = [_medic, _incap] call ace_medical_treatment_fnc_canCPR;
					diag_log "=============== LAST LINE IN CPR LOOP ===============";
		};

		if (_cprcount > 1 && alive _incap) then {
			[_medic, [_voice+"_pulse1", 20, 1, true]] remoteExec ["say3D", 0]; //softer
			diag_log format ["| %1 | %2 | 1475 kkkkkkkkkkkkk SAY3D PULSE | voice: %3", name _incap, name _medic, _voice];
		};


		if (Lifeline_ACE_Bandage_Method == 1) then {		

					// ================= BANDAGE ACTION LOOP ================
				diag_log "// ================= BANDAGE ACTION LOOP ================";	
				diag_log "// ================= BANDAGE ACTION LOOP ================";
				diag_log "// ================= BANDAGE ACTION LOOP ================";
				diag_log "// ================= BANDAGE ACTION LOOP ================";

				// _bandages = (_countw + _countf);		
				
				//DEBUG
				if ([_medic, _incap, "leftleg", "BasicBandage"] call ace_medical_treatment_fnc_canBandage) then {
					diag_log format ["==============CAN BANDAGE  key %1 =================", "leftleg"];
				};
				if ([_medic, _incap, "rightleg", "BasicBandage"] call ace_medical_treatment_fnc_canBandage) then {
					diag_log format ["==============CAN BANDAGE  key %1 =================", "rightleg"];
				};
				if ([_medic, _incap, "body", "BasicBandage"] call ace_medical_treatment_fnc_canBandage) then {
					diag_log format ["==============CAN BANDAGE  key %1 =================", "body"];
				};
				if ([_medic, _incap, "leftarm", "BasicBandage"] call ace_medical_treatment_fnc_canBandage) then {
					diag_log format ["==============CAN BANDAGE  key %1 =================", "leftarm"];
				};
				if ([_medic, _incap, "rightarm", "FieldDreBasicBandagessing"] call ace_medical_treatment_fnc_canBandage) then {
					diag_log format ["==============CAN BANDAGE  key %1 =================", "rightarm"];
				};
				if ([_medic, _incap, "head", "BasicBandage"] call ace_medical_treatment_fnc_canBandage) then {
					diag_log format ["==============CAN BANDAGE  key %1 =================", "head"];
				};
				//ENDDEBUG

				_countbaby = 0;
				_enc_count = 0;
				_notrepeat = "";
				_key1 = "head";

				// while {([_medic, _incap, _key1, "FieldDressing"] call ace_medical_treatment_fnc_canBandage)} do {
				while {(_incap call ace_medical_blood_fnc_isBleeding)} do {

					diag_log format ["%1 [0290 ACE_Functions.sqf]================IS BLEEDING==================", name _incap];
					if (lifestate _incap != "INCAPACITATED") exitWith {diag_log format ["%1 ==== EXIT BANDAGE LOOP (KEY) 1280 ====", name _incap];};
					if (lifestate _medic == "INCAPACITATED") exitWith {diag_log format ["%1 ==== EXIT MEDIC INCAP BANDAGE LOOP (KEY) 1281", name _incap];}; //with other players healing simultaneously, this can happen
					//if ([_incap] call ace_medical_status_fnc_isBeingDragged || [_incap] call ace_medical_status_fnc_isBeingCarried) exitWith {diag_log "1627 xxxxxx DRAGGED CARRIED XXXX";};
					if ([_incap] call Lifeline_check_carried_dragged) exitWith {diag_log "1627 xxxxxx DRAGGED CARRIED XXXX";};

					if ([_medic, _incap, _key1, "BasicBandage"] call ace_medical_treatment_fnc_canBandage) then {

						_bleedingwounds = [];
						_other = [];

						//==================== COUNT BNADAGES ===================

						if (oldACE == false) then {
							_jsonStr = _incap call ace_medical_fnc_serializeState; 		
							_jsonhash = [_jsonStr, 2] call CBA_fnc_parseJSON;  diag_log "[0299] ==== CBA_fnc_parseJSON"; // 2nd arg will get native hashMaps
							_woundsHash = _jsonhash get "ace_medical_openwounds";
							diag_log format ["589 kkkkkkkkkkkkkkk _woundshash %1", _woundsHash];
							_countw = 0;									
							{ 	
								private _woundsOnLimb = _y; 
								{ 
									if (_x select 0 == 20 || _x select 0 == 21 || _x select 0 == 22 || _x select 0 == 80 || _x select 0 == 81 || _x select 0 == 82 ||  _x select 1 == 0 ) then {
										_other = _other + [_x];
									} else {
										_bleedingwounds = _bleedingwounds + [_x];
									};
								} forEach _woundsOnLimb; 
							} forEach _woundsHash; 	
						};

						if (oldACE == true) then {	
							 _jsonStr = _incap call ace_medical_fnc_serializeState; 		
							 _json = [_jsonStr] call CBA_fnc_parseJSON;	 diag_log "[0317] ==== CBA_fnc_parseJSON"; 
							 _wounds = _json getVariable ["ace_medical_openwounds", false];
							 diag_log format ["605 kkkkkkkkkkkkkkk _wounds %1", _wounds];
							{
								diag_log format ["wounds %1", _x];
								if (_x select 0 == 20 || _x select 0 == 21 || _x select 0 == 22 || _x select 0 == 80 || _x select 0 == 81 || _x select 0 == 82 ||  _x select 2 == 0 ) then {
									_other = _other + [_x];
								} else {
									_bleedingwounds = _bleedingwounds + [_x];
								};
							} forEach _wounds;
						};

						diag_log format ["==============CAN BANDAGE  key %1 =================", _key1];
						diag_log format ["==============CAN BANDAGE  key %1 =================", _key1];
						diag_log format ["==============CAN BANDAGE  key %1 =================", _key1];
						diag_log format ["==============BLEEDING %1", _bleedingwounds];

						//HINT	
						if (isPlayer _incap && Lifeline_HUD_medical) then {
							_colour = "F9CAA7";
							[format ["<t align='right' size='%2' color='#%1'>%3 Wound%4</t>",_colour, 0.5,count _bleedingwounds,if (count _bleedingwounds == 1) then {""} else {"s"}],((safeZoneW - 1) * 0.48),1.3,5,0,0,Lifelinetxt2Layer] remoteExec ["BIS_fnc_dynamicText",_incap];
						};	

						// dont voice empty keys
						diag_log format ["| %1 | %2 | 1540 kkkkkkkkkkkkk SAY3D BANDAGE | voice: %3", name _incap, name _medic, _voice];

						if (_key1 != _notrepeat) then {
							if (_key1 == "leftleg") then {
								[_medic, [_voice+"_leftleg1", 20, 1, true]] remoteExec ["say3D", 0];
								diag_log "kkkkkkkkkkkkk LEFTLEG kkkkkkkkkkkkk";
							};
							if (_key1 == "rightleg") then {
								[_medic, [_voice+"_rightleg1", 20, 1, true]] remoteExec ["say3D", 0];
								diag_log "kkkkkkkkkkkkk RIGHTLEG kkkkkkkkkkkkk";
							};
							if (_key1 == "body") then {
								[_medic, [_voice+"_torso1", 20, 1, true]] remoteExec ["say3D", 0];
								diag_log "kkkkkkkkkkkkk BODY kkkkkkkkkkkkk";
							};
							if (_key1 == "leftarm") then {
								[_medic, [_voice+"_leftarm1", 20, 1, true]] remoteExec ["say3D", 0];
								diag_log "kkkkkkkkkkkkk LEFTARM kkkkkkkkkkkkk";
							};
							if (_key1 == "rightarm") then {
								[_medic, [_voice+"_rightarm1", 20, 1, true]] remoteExec ["say3D", 0];
								diag_log "kkkkkkkkkkkkk RIGHTARM kkkkkkkkkkkkk";
							};
							if (_key1 == "head") then {
								[_medic, [_voice+"_head1", 20, 1, true]] remoteExec ["say3D", 0];
								diag_log "kkkkkkkkkkkkk HEAD kkkkkkkkkkkkk";
							};
						};

						//encouragment or "and again" voice sample
						_repeatrandom = selectRandom[1,2];
						if (_key1 == _notrepeat && _enc_count < 3 && _repeatrandom == 1) then { 
							[_medic, [_voice+(_encourage select _enc_count), 20, 1, true]] remoteExec ["say3D", 0];
							if (_enc_count == 2) then {_enc_count = 0} else {_enc_count = _enc_count + 1};
						};
						if (_key1 == _notrepeat && _repeatrandom == 2) then { 
							diag_log format ["=====AND AGAIN switch: %1", _againswitch];
							diag_log format ["=====AND AGAIN switch: %1", _againswitch];
							diag_log format ["=====AND AGAIN switch: %1", _againswitch];
							[_medic, [_voice+"_andagain"+(str _againswitch), 20, 1, true]] remoteExec ["say3D", 0];
							if (_againswitch == 1) then { _againswitch = 2; } else { _againswitch = 1; };
						};	
						_notrepeat = _key1;

						if (lifestate _incap != "INCAPACITATED") exitWith {diag_log format ["%1 ==== EXIT BANDAGE LOOP | NO LONGER INCAP [1409]", name _incap];};
						if (lifestate _medic == "INCAPACITATED") exitWith {diag_log format ["%1 ==== EXIT BANDAGE LOOP | MEDIC INCAP [1410]", name _incap];}; //with other players healing simultaneously, this can happen

						//if ([_incap] call ace_medical_status_fnc_isBeingDragged || [_incap] call ace_medical_status_fnc_isBeingCarried) exitWith {diag_log "1627 xxxxxx DRAGGED CARRIED XXXX";};
						if ([_incap] call Lifeline_check_carried_dragged) exitWith {diag_log "1627 xxxxxx DRAGGED CARRIED XXXX";};

						sleep 0.5;
						// sleep 1;
						diag_log "                                                                                         ";							// diag_log format ["kkkkkkkkkkkkkkkkkkkkkkkk |%3|%4| ACE BANDAGE IN PROGRESS %1 DMG %2 KEY %5 VALUE %6", count _value1, damage _incap, name _incap,name _medic,_key1,_value1];
						diag_log format ["kkkkkkkkkkkkkkkkkkkkkkkk |%3|%4| ACE BANDAGE IN PROGRESS %1 DMG %2 KEY %5 VALUE %6", count _bleedingwounds, damage _incap, name _incap,name _medic,_key1];
						diag_log "                                                                                         ";

						//added to increase revive time limit on each loop pass
						_timelimitincap = (_incap getvariable "LifelinePairTimeOut");
						_timelimitmedic = (_medic getvariable "LifelinePairTimeOut");
						_incap setVariable ["LifelinePairTimeOut", _timelimitincap + 12, true]; 
						_medic setVariable ["LifelinePairTimeOut", _timelimitmedic + 12, true]; 

						//===================================bandage 
						[_medic, _incap, _key1, "BasicBandage"] call ace_medical_treatment_fnc_bandage;
						//==========================================

						//============================ CALL ANIMATION ==============================
						_animsvoice = [_incap, _medic,_EnemyCloseBy,_voice,_switch, _againswitch, _encourage,_enc_count] call Lifeline_ACE_Anims_Voice;
						_switch = _animsvoice select 0;
						_againswitch = _animsvoice select 1;
						_enc_count = _animsvoice select 2;
						
						// ==========================================================================

						_cprcount = 1;		
						sleep 1;

						// if (count _value1 <= 0) exitWith {diag_log format ["%1 ==== EXIT WITH count _value1 == 0", name _incap];}; //with other players healing simultaneously, this can happen

					} else {

						if (_key1 == "head") exitWith {
						_key1 = "body";
						};
						if (_key1 == "body") exitWith {
						_key1 = "leftleg";
						};
						if (_key1 == "leftleg") exitWith {
						_key1 = "rightleg";
						};
						if (_key1 == "rightleg") exitWith {
						_key1 = "leftarm";
						};
						if (_key1 == "leftarm") exitWith {
						_key1 = "rightarm";
						};
					
					};	// if can bandage			    

				}; //WHILE is Bleeding


		}; // if (Lifeline_ACE_Bandage_Method == 1) then



		if (Lifeline_ACE_Bandage_Method == 2) then {	

			if (oldACE == false) then {

				private _jsonStr = _incap call ace_medical_fnc_serializeState; 		
				private _jsonhash = [_jsonStr, 2] call CBA_fnc_parseJSON;   diag_log "[0453] ==== CBA_fnc_parseJSON"; // 2nd arg will get native hashMaps
				private _woundsHash = _jsonhash get "ace_medical_openwounds";
				private _fractures = _jsonhash get "ace_medical_fractures";

				_countw = 0;
				{ 	
					private _woundsOnLimb = _y; 
					{ 
						_countw = _countw + 1;
					} forEach _woundsOnLimb; 
				} forEach _woundsHash; 	
				diag_log format ["== WOUND COUNTER %1",  _countw];	
				diag_log format ["== WOUND COUNTER %1",  _countw];	
				diag_log format ["== WOUND COUNTER %1",  _countw];	
				diag_log format ["== WOUND COUNTER %1",  _countw];	

				_countf = 0;
				{
					private _index = _forEachIndex; // Get the current index
					if (_x == 1) then {
					_countf = _countf +1;
					};
				} forEach _fractures;
				diag_log format ["== FRACTURE COUNTER %1",  _countf];	
				diag_log format ["== FRACTURE COUNTER %1",  _countf];	
				diag_log format ["== FRACTURE COUNTER %1",  _countf];	
				diag_log format ["== FRACTURE COUNTER %1",  _countf];	

				// _bandages = (_countw + _countf);

				_countbaby = 0;
				_enc_count = 0;

				// ================= BANDAGE ACTION LOOP ================

				{
					if (lifestate _incap != "INCAPACITATED") exitWith {diag_log format ["%1 ==== EXIT BANDAGE LOOP (KEY) 1280 ====", name _incap];};
					if (lifestate _medic == "INCAPACITATED") exitWith {
						if (Lifeline_Revive_debug) then {
							if (isPlayer _incap && Lifeline_hintsilent) then {[ "MEDIC DOWN" ] remoteExec ["hintsilent",_incap]};
							diag_log format ["%1 ==== EXIT MEDIC INCAP BANDAGE LOOP (KEY) 1281", name _incap];
						};
					}; //with other players healing simultaneously, this can happen

					//if ([_incap] call ace_medical_status_fnc_isBeingDragged || [_incap] call ace_medical_status_fnc_isBeingCarried) exitWith {diag_log "1627 xxxxxx DRAGGED CARRIED XXXX";};
					if ([_incap] call Lifeline_check_carried_dragged) exitWith {diag_log "1627 xxxxxx DRAGGED CARRIED XXXX";};

					 _jsonStr = _incap call ace_medical_fnc_serializeState; 		
					 _jsonhash = [_jsonStr, 2] call CBA_fnc_parseJSON;   diag_log "[0501] ==== CBA_fnc_parseJSON"; // 2nd arg will get native hashMaps
					 _woundsHash = _jsonhash get "ace_medical_openwounds";

					 // delete wounds that have been done by a live player (wounds are not deleted, just a value changed to 0 )
					 {
						 _key2 = _x;    
						 _value2 = _woundsHash get _key2;  
						{
							if (_x select 1 == 0) then {
									_value2 = _value2 - [_x];
									_woundsHash set [_key2, _value2];
							};
							// _woundsHash set [_key2, _value2];									
						} forEach (_value2);
					} forEach (keys _woundsHash);

					 _fractures = _jsonhash get "ace_medical_fractures";
					 _key1 = _x;    // _x represents each key in the hashmap
					 _value1 = _woundsHash get _key1;  // Get the value associated with the key

					diag_log "                                                                                                               ";
					diag_log "                                                                                                               ";
					diag_log format [" xxxxxxxxxxxxxxxxxx |%5|%6| ACE KEY %1 DMG %2 KEY %7 VALUE %8", count _value1, damage _incap, _incap, _medic,name _incap,name _medic,_key1,_value1];
					diag_log format [" xxxxxxxxxxxxxxxxxx |%5|%6| ACE KEY %1 DMG %2 KEY %7 VALUE %8", count _value1, damage _incap, _incap, _medic,name _incap,name _medic,_key1,_value1];
					diag_log format [" xxxxxxxxxxxxxxxxxx |%5|%6| ACE KEY %1 DMG %2 KEY %7 VALUE %8", count _value1, damage _incap, _incap, _medic,name _incap,name _medic,_key1,_value1];
					diag_log format ["1515====| %2 | WOUND HASH %1", _woundsHash, name _incap];
					diag_log "                                                                                                               ";
					diag_log "                                                                                                               ";
					
					_bleedingwounds = [];
					_bruises = [];
					diag_log format ["1910 kkkkkkkkkkkkkkk _wounds %1", _value1];

					{
					diag_log format ["wounds %1", _x];
						if (_x select 0 == 20 || _x select 0 == 21 || _x select 0 == 22 || _x select 0 == 80 || _x select 0 == 81 || _x select 0 == 82 ) then {
							_bruises = _bruises + [_x];
						} else {
							_bleedingwounds = _bleedingwounds + [_x];
						};
					} forEach _value1;


					// diag_log format ["1750           VALUE %1", _value1];	
					diag_log format ["1906 BLEEDING WOUNDS %1", _bleedingwounds];
					// diag_log format ["1750         BRUISES %1", _bruises];
					// diag_log format ["1750        COMBINED %1", _bleedingwounds + _bruises];	

					_notrepeat = "";

					// if (count _value1 > 0) then {  // dont voice empty keys
					if (count _bleedingwounds > 0) then {  // dont voice empty keys
								diag_log format ["| %1 | %2 | 1540 kkkkkkkkkkkkk SAY3D BANDAGE | voice: %3", name _incap, name _medic, _voice];

						if (_key1 == "leftleg") then {
							[_medic, [_voice+"_leftleg1", 20, 1, true]] remoteExec ["say3D", 0];
							diag_log "kkkkkkkkkkkkk LEFTLEG kkkkkkkkkkkkk";
						};
						if (_key1 == "rightleg") then {
							[_medic, [_voice+"_rightleg1", 20, 1, true]] remoteExec ["say3D", 0];
							diag_log "kkkkkkkkkkkkk RIGHTLEG kkkkkkkkkkkkk";
						};
						if (_key1 == "body") then {
							[_medic, [_voice+"_torso1", 20, 1, true]] remoteExec ["say3D", 0];
							diag_log "kkkkkkkkkkkkk BODY kkkkkkkkkkkkk";
						};
						if (_key1 == "leftarm") then {
							[_medic, [_voice+"_leftarm1", 20, 1, true]] remoteExec ["say3D", 0];
							diag_log "kkkkkkkkkkkkk LEFTARM kkkkkkkkkkkkk";
						};
						if (_key1 == "rightarm") then {
							[_medic, [_voice+"_rightarm1", 20, 1, true]] remoteExec ["say3D", 0];
							diag_log "kkkkkkkkkkkkk RIGHTARM kkkkkkkkkkkkk";
						};
						if (_key1 == "head") then {
							[_medic, [_voice+"_head1", 20, 1, true]] remoteExec ["say3D", 0];
							diag_log "kkkkkkkkkkkkk HEAD kkkkkkkkkkkkk";
						};
					};


					// while {count _value1 > 0} do {	
					while {count _bleedingwounds > 0} do {	

						diag_log format ["kkkkkkkkkkkkkkkkkkk COUNT BLEEDING WOUNDS LOOP START count %1", count _bleedingwounds];	

						//encouragment or "and again" voice sample
						_repeatrandom = selectRandom[1,2];
						if (_key1 == _notrepeat && _enc_count < 3 && _repeatrandom == 1) then { 
							[_medic, [_voice+(_encourage select _enc_count), 20, 1, true]] remoteExec ["say3D", 0];
							if (_enc_count == 2) then {_enc_count = 0} else {_enc_count = _enc_count + 1};
						};
						if (_key1 == _notrepeat && _repeatrandom == 2) then { 
							diag_log format ["=====AND AGAIN switch: %1", _againswitch];
							diag_log format ["=====AND AGAIN switch: %1", _againswitch];
							diag_log format ["=====AND AGAIN switch: %1", _againswitch];
							[_medic, [_voice+"_andagain"+(str _againswitch), 20, 1, true]] remoteExec ["say3D", 0];
							if (_againswitch == 1) then { _againswitch = 2; } else { _againswitch = 1; };
						};	
						_notrepeat = _key1;

						// if ([_incap] call ace_medical_status_fnc_isBeingDragged || [_incap] call ace_medical_status_fnc_isBeingCarried) exitWith {diag_log "1672 xxxxxx DRAGGED CARRIED XXXX";};

						if (lifestate _incap != "INCAPACITATED") exitWith {diag_log format ["%1 ==== EXIT BANDAGE LOOP | NO LONGER INCAP [1409]", name _incap];};
						if (lifestate _medic == "INCAPACITATED") exitWith {
							if (Lifeline_Revive_debug) then {
								if (Lifeline_hintsilent) then {[ "MEDIC DOWN" ] remoteExec ["hintsilent",_incap]};
								diag_log format ["%1 ==== EXIT BANDAGE LOOP | MEDIC INCAP [1410]", name _incap];
							};
						}; //with other players healing simultaneously, this can happen

						//if ([_incap] call ace_medical_status_fnc_isBeingDragged || [_incap] call ace_medical_status_fnc_isBeingCarried) exitWith {diag_log "1627 xxxxxx DRAGGED CARRIED XXXX";};
						if ([_incap] call Lifeline_check_carried_dragged) exitWith {diag_log "1627 xxxxxx DRAGGED CARRIED XXXX";};

						//ALL AT FRONT NOW
						 _jsonStr = _incap call ace_medical_fnc_serializeState; 	
						 _jsonhash = [_jsonStr, 2] call CBA_fnc_parseJSON;  diag_log "[0617] ==== CBA_fnc_parseJSON"; 
						 _woundsHash = _jsonhash get "ace_medical_openwounds";				
						// private _key1 = _x;    

						// delete wounds that have been done by a live player (wounds are not deleted, just a value changed to 0. This deletes them instead )
						_countw = 0;
						{
							 _key2 = _x;    
							 _value2 = _woundsHash get _key2;  
							 diag_log format ["== KEY %1", _key2];
							 diag_log format ["== VAL %1", _value2];
							{
							diag_log format ["== loop value %1 ==", _x];
								if (_x select 1 == 0) then {
								diag_log "wowsers";
								diag_log _value2;
										_value2 = _value2 - [_x];
										_woundsHash set [_key2, _value2];
								diag_log _value2;
								} else {
									if (_x select 0 != 20 && _x select 0 != 21 && _x select 0 != 22 && _x select 0 != 80 && _x select 0 != 81 && _x select 0 != 82 ) then {
									_countw = _countw + 1;
									};
								};							
							} forEach (_value2);
						} forEach (keys _woundsHash);

						//SCREEN HINT
						if (isPlayer _incap && Lifeline_HUD_medical) then {
							_colour = "F9CAA7";
							[format ["<t align='right' size='%2' color='#%1'>%3 Bandages</t>",_colour, 0.5,_countw],((safeZoneW - 1) * 0.48),1.3,5,0,0,Lifelinetxt2Layer] remoteExec ["BIS_fnc_dynamicText",_incap];
						};

					     _value1 = _woundsHash get _key1; 

						// seperate bleeding wounds from bruises
						_bleedingwounds = [];
						_bruises = [];

						{
							// diag_log format ["wounds %1", _x];
							if (_x select 0 == 20 || _x select 0 == 21 || _x select 0 == 22 || _x select 0 == 80 || _x select 0 == 81 || _x select 0 == 82 ) then {
								_bruises = _bruises + [_x];
							} else {
								_bleedingwounds = _bleedingwounds + [_x];
							};
						} forEach _value1;

						// diag_log format ["1821           VALUE %1", _value1];	
						diag_log format ["2002 BLEEDING WOUNDS %1", _bleedingwounds];
						// diag_log format ["1821         BRUISES %1", _bruises];
						// diag_log format ["1821        COMBINED %1", _bleedingwounds + _bruises];

						sleep 0.5;

						// _value1 = _value1 - [_value1 select 0];
						_bleedingwounds = _bleedingwounds - [_bleedingwounds select 0];
						diag_log format ["2023  COMBINED AFTER %1", _bleedingwounds + _bruises];
						_woundsHash set [_key1, _bleedingwounds + _bruises];																				
						diag_log format ["2024  %2 ====HASH %1", _woundsHash, name _incap];
						_jsonhash set ["ace_medical_openwounds", _woundsHash];

						 _newJsonStr  = [_jsonhash] call CBA_fnc_encodeJSON;
						[_incap, _newJsonStr, true] call fix_medical_fnc_deserializeState;
						// [_incap, _newJsonStr] remoteExec ["fix_medical_fnc_deserializeState", _incap];

						sleep 1;

					    diag_log "                                                                                         ";
						diag_log format ["kkkkkkkkkkkkkkkkkkkkkkkk |%3|%4| ACE BANDAGE IN PROGRESS %1 DMG %2 KEY %5 VALUE %6 KEYAMT %7", _countw, damage _incap, name _incap,name _medic,toUpper _key1,_value1,count _value1];
						diag_log format ["1515====| %2 | WOUND HASH %1", _woundsHash, name _incap];
					    diag_log "                                                                                         ";

						//added to increase revive time limit on each loop pass
						_timelimitincap = (_incap getvariable "LifelinePairTimeOut");
						_timelimitmedic = (_medic getvariable "LifelinePairTimeOut");
						_incap setVariable ["LifelinePairTimeOut", _timelimitincap + 12, true]; 
						_medic setVariable ["LifelinePairTimeOut", _timelimitmedic + 12, true]; 

						//============================ CALL ANIMATION ==============================
						_animsvoice = [_incap, _medic,_EnemyCloseBy,_voice,_switch, _againswitch, _encourage,_enc_count] call Lifeline_ACE_Anims_Voice;
						_switch = _animsvoice select 0;
						_againswitch = _animsvoice select 1;
						_enc_count = _animsvoice select 2;
						// ==========================================================================

						_cprcount = 1;		
						sleep 1;

						if (count _value1 <= 0) exitWith {diag_log format ["%1 ==== EXIT WITH count _value1 == 0", name _incap];}; //with other players healing simultaneously, this can happen

					};	// while {count _bleedingwounds > 0} do {					    

				} forEach (keys _woundsHash);

			}; //============================ if not OLD ACE


			if (oldACE == true) then {	

					 _jsonStr = _incap call ace_medical_fnc_serializeState; 		
					 _json = [_jsonStr] call CBA_fnc_parseJSON;	 diag_log "[0718] ==== CBA_fnc_parseJSON"; 
					 _wounds = _json getVariable ["ace_medical_openwounds", false];
					 _fractures = _json getVariable ["ace_medical_fractures", false];					
					_bleedingwounds = [];
					_bruises = [];
					diag_log format ["1910 kkkkkkkkkkkkkkk _wounds %1", _wounds];

					{
						diag_log format ["wounds %1", _x];
						if (_x select 0 == 20 || _x select 0 == 21 || _x select 0 == 22 || _x select 0 == 80 || _x select 0 == 81 || _x select 0 == 82 ) then {
							_bruises = _bruises + [_x];
						} else {
							_bleedingwounds = _bleedingwounds + [_x];
						};
					} forEach _wounds;

							{
								diag_log format ["==forEach _reordered_wounds: %1", _bleedingwounds select 0 select 2];
								if (_bleedingwounds select 0 select 2 == 0) then {
									_bleedingwounds = _bleedingwounds - [_bleedingwounds select 0];
								diag_log "1992 xxxxxxxxxxxxxxxxxxxxxxx DELETE _bleedingwounds select 0 select 2 == 0";
								diag_log "1992 xxxxxxxxxxxxxxxxxxxxxxx DELETE _bleedingwounds select 0 select 2 == 0";
								diag_log "1992 xxxxxxxxxxxxxxxxxxxxxxx DELETE _bleedingwounds select 0 select 2 == 0";
								};
							} forEach _bleedingwounds;

					diag_log format ["1921xxxxxxxxxxxxxxxxxxx BLEEDING WOUNDS %1", _bleedingwounds];
					diag_log format ["1921xxxxxxxxxxxxxxxxxxxxxxxxxxx BRUISES %1", _bruises];

					_countf = 0;
					{
						private _index = _forEachIndex; // Get the current index
						if (_x == 1) then {
						_countf = _countf +1;
						};
					} forEach _fractures;
					diag_log format ["== FRACTURE COUNTER %1",  _countf];	
					diag_log format ["== FRACTURE COUNTER %1",  _countf];	
					diag_log format ["== FRACTURE COUNTER %1",  _countf];	
					diag_log format ["== FRACTURE COUNTER %1",  _countf];	

					_EnemyCloseBy = [_incap] call Lifeline_EnemyCloseBy;
					_woundcount = count _bleedingwounds;
					_counter = _woundcount;
					_counter2 = _woundcount;
					_wounds2 = _bleedingwounds;
					_switch = 0;
					_consolidated = [];
					_head = []; _torso = []; _leftarm = []; _rightarm = []; _leftleg = []; _rightleg = []; 

					while {_counter2 > 0} do {
						_bodypart = _wounds2 select 0 select 1;
						if (_bodypart == 0) then {
							_head = _head + [_wounds2 select 0];
						};
						if (_bodypart == 1) then {
							_torso = _torso + [_wounds2 select 0];
						};
						if (_bodypart == 2) then {
							_leftarm = _leftarm + [_wounds2 select 0];
						};
						if (_bodypart == 3) then {
							_rightarm = _rightarm + [_wounds2 select 0];
						};
						if (_bodypart == 4) then {
							_leftleg = _leftleg + [_wounds2 select 0];
						};
						if (_bodypart == 5) then {
							_rightleg = _rightleg + [_wounds2 select 0];
						};
						_counter2 = _counter2 - 1;
						_wounds2 = _wounds2 - [_wounds2 select 0];					
					};

					_reordered_wounds = _head + _torso + _leftarm + _rightarm + _leftleg + _rightleg;

					_json setVariable ["ace_medical_openwounds", _reordered_wounds + _bruises];
					_newJsonStr = [_json] call CBA_fnc_encodeJSON;
					// _json call CBA_fnc_deleteNamespace;
					[_incap, _newJsonStr, true] call fix_medical_fnc_deserializeState;
					// [_incap, _newJsonStr] remoteExec ["fix_medical_fnc_deserializeState", _incap];

					_bodypartcounter = 0;
					_notrepeat = -1;

					diag_log format ["==== head %1 torse %2 leftarm %3 rightarm %4 leftleg %5 rightleg %6", _head, _torso, _leftarm, _rightarm, _leftleg, _rightleg];
					diag_log format ["==== consolidated %1", _consolidated];
					diag_log format ["1979 kkkkkkkkkkkkkkkkkkkkk _reordered_wounds %1", _reordered_wounds];
					diag_log format ["1979 kkkkkkkkkkkkkkkkkkkkk count %1", count _reordered_wounds];
					diag_log "  ";
					diag_log "  ";
					_encourage = ["_greetB5", "_greetB2", "_almostthere1"];
					_enc_count = 0;

					while {count _reordered_wounds > 0} do {
							diag_log " ";
							diag_log " ";
							diag_log " ";
							diag_log " ";
							diag_log "===================== START LOOP ========================";

							_jsonStr = _incap call ace_medical_fnc_serializeState; 		
							_json = [_jsonStr] call CBA_fnc_parseJSON;	 diag_log "[0820] ==== CBA_fnc_parseJSON"; 
							_wounds = _json getVariable ["ace_medical_openwounds", false];
							_bleedingwounds = [];
							_bruises = [];

							// diag_log format ["1910 kkkkkkkkkkkkkkk _wounds %1", _wounds];
								{
								diag_log format ["wounds %1", _x];
									if (_x select 0 == 20 || _x select 0 == 21 || _x select 0 == 22 || _x select 0 == 80 || _x select 0 == 81 || _x select 0 == 82 ) then {
										_bruises = _bruises + [_x];
									} else {
										_bleedingwounds = _bleedingwounds + [_x];
									};
								} forEach _wounds;

							diag_log format ["2026 xxxxxxxxxxxxxxxxxxx BLEEDING WOUNDS %1", _bleedingwounds];
							diag_log format ["2026 xxxxxxxxxxxxxxxxxxxxxxxxxxx BRUISES %1", _bruises];

							_reordered_wounds = _bleedingwounds;

							diag_log format ["1995 kkkkkkkkkkkkkkkkkkkkk _reordered_wounds %1", _reordered_wounds];
							diag_log format ["1995 kkkkkkkkkkkkkkkkkkkkk count %1", count _reordered_wounds];

							{
							diag_log format ["==forEach _reordered_wounds: %1", _reordered_wounds select 0 select 2];
								if (_reordered_wounds select 0 select 2 == 0) then {
									_reordered_wounds = _reordered_wounds - [_reordered_wounds select 0];
								diag_log "1992 xxxxxxxxxxxxxxxxxxxxxxx DELETE _reordered_wounds select 0 select 2 == 0";
								diag_log "1992 xxxxxxxxxxxxxxxxxxxxxxx DELETE _reordered_wounds select 0 select 2 == 0";
								diag_log "1992 xxxxxxxxxxxxxxxxxxxxxxx DELETE _reordered_wounds select 0 select 2 == 0";
								};
							} forEach _reordered_wounds;

							diag_log format ["2006 kkkkkkkkkkkkkkkkkkkkk _reordered_wounds %1", _reordered_wounds];
							diag_log format ["2006 kkkkkkkkkkkkkkkkkkkkk count %1", count _reordered_wounds];
							_json setVariable ["ace_medical_openwounds", _reordered_wounds + _bruises];
							_newJsonStr = [_json] call CBA_fnc_encodeJSON;
							// _json call CBA_fnc_deleteNamespace;
							[_incap, _newJsonStr, true] call fix_medical_fnc_deserializeState;
							// [_incap, _newJsonStr] remoteExec ["fix_medical_fnc_deserializeState", _incap];
							// if (_counter <= 0) exitWith {diag_log "EXIT BANDAGE LOOP";};
							if (count _reordered_wounds <= 0) exitWith {diag_log "EXIT BANDAGE LOOP";};
							if (lifestate _incap != "INCAPACITATED") exitWith {diag_log format ["%1 ==== EXIT BANDAGE LOOP | NO LONGER INCAP [1409]", name _incap];};
							if (lifestate _medic == "INCAPACITATED") exitWith {
								if (Lifeline_Revive_debug) then {
									if (isPlayer _incap && Lifeline_hintsilent) then {[ "MEDIC DOWN" ] remoteExec ["hintsilent",_incap]};
									diag_log format ["%1 ==== EXIT BANDAGE LOOP | MEDIC INCAP [1410]", name _incap];
								};
							};
							//if ([_incap] call ace_medical_status_fnc_isBeingDragged || [_incap] call ace_medical_status_fnc_isBeingCarried) exitWith {diag_log "1627 xxxxxx DRAGGED CARRIED XXXX";};
							if ([_incap] call Lifeline_check_carried_dragged) exitWith {diag_log "1627 xxxxxx DRAGGED CARRIED XXXX";};

							// diag_log format ["2021 kkkkkkkkkkkkkkkkkkkkk _reordered_wounds %1", _reordered_wounds];
							// diag_log format ["2021 kkkkkkkkkkkkkkkkkkkkk count %1", count _reordered_wounds];
							if (isPlayer _incap && Lifeline_HUD_medical) then {
								_colour = "F9CAA7";
								[format ["<t align='right' size='%2' color='#%1'>%3 Bandages</t>",_colour, 0.5,count _reordered_wounds],((safeZoneW - 1) * 0.48),1.3,5,0,0,Lifelinetxt2Layer] remoteExec ["BIS_fnc_dynamicText",_incap];
							};

							_bodypart = _reordered_wounds select 0 select 1;

							// diag_log format ["+++++++++++++++++++++++++++++++++++ BODYPART??? %1", _bodypart];	
							_partname = "";

							if (_bodypart != _notrepeat) then { // to stop voice stating body part twice in a row
								if (_bodypart == 0) then {
									[_medic, [_voice+"_head1", 20, 1, true]] remoteExec ["say3D", 0];
									_partname = "HEAD";
								};
								if (_bodypart == 1) then {
									[_medic, [_voice+"_torso1", 20, 1, true]] remoteExec ["say3D", 0];
									_partname = "TORSO";
								};
								if (_bodypart == 2) then {
									[_medic, [_voice+"_leftarm1", 20, 1, true]] remoteExec ["say3D", 0];
									_partname = "LEFT ARM";
								};
								if (_bodypart == 3) then {
									[_medic, [_voice+"_rightarm1", 20, 1, true]] remoteExec ["say3D", 0];
									_partname = "RIGHT ARM";
								};
								if (_bodypart == 4) then {
									[_medic, [_voice+"_leftleg1", 20, 1, true]] remoteExec ["say3D", 0];
									_partname = "LEFT LEG";
								};
								if (_bodypart == 5) then {
									[_medic, [_voice+"_rightleg1", 20, 1, true]] remoteExec ["say3D", 0];
									_partname = "RIGHT LEG";
								};
							};

							diag_log format ["2013 +++++++++++++++++++++++++++++++++++ BODYPART %1", _partname];

							//encouragment or "and again" voice sample
							_repeatrandom = selectRandom[1,2];
							if (_bodypart == _notrepeat && _enc_count < 3 && _repeatrandom == 1) then { 
								[_medic, [_voice+(_encourage select _enc_count), 20, 1, true]] remoteExec ["say3D", 0];
								if (_enc_count == 2) then {_enc_count = 0} else {_enc_count = _enc_count + 1};
							};
							if (_bodypart == _notrepeat && _repeatrandom == 2) then { 
								diag_log format ["=====AND AGAIN switch: %1", _againswitch];
								diag_log format ["=====AND AGAIN switch: %1", _againswitch];
								diag_log format ["=====AND AGAIN switch: %1", _againswitch];
								[_medic, [_voice+"_andagain"+(str _againswitch), 20, 1, true]] remoteExec ["say3D", 0];
								if (_againswitch == 1) then { _againswitch = 2; } else { _againswitch = 1; };
							};

							_notrepeat = _bodypart;

							diag_log "                                                                                         ";
							diag_log "                                                                                         ";
							diag_log format ["kkkkkkkkkkkkkkkkkkkkkkkk |%3|%4| OLD ACE BANDAGE IN PROGRESS %1 DMG %2 KEY %5 COUNT %6", count _reordered_wounds, damage _incap, name _incap,name _medic, _partname ];
							// diag_log format ["1515====| %2 | WOUND HASH %1", _woundsHash, name _incap];
							diag_log "                                                                                         ";
							diag_log "                                                                                         ";

							//added to increase revive time limit on each loop pass
							_timelimitincap = (_incap getvariable "LifelinePairTimeOut");
							_timelimitmedic = (_medic getvariable "LifelinePairTimeOut");
							_incap setVariable ["LifelinePairTimeOut", _timelimitincap + 12, true]; 
							_medic setVariable ["LifelinePairTimeOut", _timelimitmedic + 12, true]; 

							//actual healing of data moved before animation now to stop errors when live players also healing incap at same time
							// _counter = _counter - 1;
							_reordered_wounds = _reordered_wounds - [_reordered_wounds select 0];
							diag_log format ["2047 kkkkkkkkkkkkkkkkkkkkk _reordered_wounds %1", _reordered_wounds];
							diag_log format ["2047 kkkkkkkkkkkkkkkkkkkkk count %1", count _reordered_wounds];
							_json setVariable ["ace_medical_openwounds", _reordered_wounds + _bruises];
							_newJsonStr = [_json] call CBA_fnc_encodeJSON;
							// _json call CBA_fnc_deleteNamespace;
							[_incap, _newJsonStr, true] call fix_medical_fnc_deserializeState;
							// [_incap, _newJsonStr] remoteExec ["fix_medical_fnc_deserializeState", _incap];
							diag_log format  ["========== SET to DESERIALIZE STATE: %1", _reordered_wounds];

							//============================ CALL ANIMATION ==============================

							_animsvoice = [_incap, _medic,_EnemyCloseBy,_voice,_switch, _againswitch, _encourage,_enc_count] call Lifeline_ACE_Anims_Voice;
							_switch = _animsvoice select 0;
							_againswitch = _animsvoice select 1;
							_enc_count = _animsvoice select 2;
							// ==========================================================================

							_cprcount = 1;	

							// _count = [_incap,_wott] call AceRevive1;
							//_counter = count _count;

							_currentpart = _bodypart;

							//DEBUG
							// _jsonStr = _incap call ace_medical_fnc_serializeState; 		
							// _json = [_jsonStr] call CBA_fnc_parseJSON;	
							// _reordered_wounds = _json getVariable ["ace_medical_openwounds", false];
							
							// diag_log format ["2103 kkkkkkkkkkkkkkkkkkkkk _reordered_wounds %1", _reordered_wounds];
							// diag_log format ["2103 kkkkkkkkkkkkkkkkkkkkk count %1", count _reordered_wounds];
							//ENDDEBUG
					}; // WHILE 
				


			}; // OLD ACE
						
				
		}; // if ACE revive method == 2


				
		diag_log format ["%1 [0988]=====OUT OF WOUNDS LOOP=====", name _incap];
		diag_log format ["%1 [0988]=====OUT OF WOUNDS LOOP=====", name _incap];
		diag_log format ["%1 [0988]=====OUT OF WOUNDS LOOP=====", name _incap];

		//checks to leave revive process
		if (lifestate _incap != "INCAPACITATED") exitWith {diag_log format ["%1 ==== EXIT ROOT | NO LONGER INCAP [1409]", name _incap];};
		if (lifestate _medic == "INCAPACITATED") exitWith {
			if (Lifeline_Revive_debug) then {
				if (isPlayer _incap && Lifeline_hintsilent) then {[ "MEDIC DOWN" ] remoteExec ["hintsilent",_incap]};
				diag_log format ["%1 ==== EXIT ROOT | MEDIC INCAP [0997]", name _incap];
			};
		}; 

		//if ([_incap] call ace_medical_status_fnc_isBeingDragged || [_incap] call ace_medical_status_fnc_isBeingCarried) exitWith {diag_log "1627 xxxxxx DRAGGED CARRIED | EXIT ROOT  XXXX";};
		if ([_incap] call Lifeline_check_carried_dragged) exitWith {diag_log "1627 xxxxxx DRAGGED CARRIED | EXIT ROOT  XXXX";};
		
	
		// IV if needed
		
		// ====================ADD BLOOD IF NEEDED
		
		
		// diag_log format ["+++++++++++++++++++++++++++++++++++ BLOODVOL %1", _bloodvolume];	
				
				
		_json = [];
		_bloodvolume = [];
		
		if (oldACE == false) then {
			 _jsonStr = _incap call ace_medical_fnc_serializeState; 
			 _jsonhash = [_jsonStr, 2] call CBA_fnc_parseJSON;  diag_log "[1018] ==== CBA_fnc_parseJSON"; 
			 _bloodvolume = _jsonhash get "ace_medical_bloodvolume";
		} else {
			 _jsonStr = _incap call ace_medical_fnc_serializeState;
			 _json = [_jsonStr] call CBA_fnc_parseJSON;  diag_log "[1022] ==== CBA_fnc_parseJSON"; 
			 _bloodvolume = _json getVariable ["ace_medical_bloodvolume", false];
			diag_log format ["%2 | %3 [1024]+++++++++++++++++++++++++++++++++++ BLOODVOL %1", _bloodvolume, name _incap, name _medic];	
			// diag_log format ["++++ JSONSTR %1", _jsonStr];	
			// diag_log format ["++++ JSON %1", _json];	
		};
		diag_log format ["%2 | %3 [1028]+++++++++++++++++++++++++++++++++++ BLOODVOL %1", _bloodvolume, name _incap, name _medic];	
		// diag_log format ["%2 ========= BLOOD VOLUMNE BEFORE %1 ==============",_bloodvolume, name _incap];
		// diag_log format ["%2 ========= BLOOD VOLUMNE BEFORE %1 ==============",_bloodvolume, name _incap];
		// diag_log format ["%2 ========= BLOOD VOLUMNE BEFORE %1 ==============",_bloodvolume, name _incap];

		_jsonStr = _incap call ace_medical_fnc_serializeState; 	
		_json = [_jsonStr] call CBA_fnc_parseJSON;  diag_log "[1034] ==== CBA_fnc_parseJSON"; 
		_jsonhash = [_jsonStr, 2] call CBA_fnc_parseJSON;  diag_log "[1035] ==== CBA_fnc_parseJSON"; 
		_fractures = [];

		if (oldACE == false) then {
			_fractures = _jsonhash get "ace_medical_fractures";
		} else {
			_fractures = _json getVariable ["ace_medical_fractures", false];
		};

		//=========FRACTURES

		// quick count of fractures	
			_countf = 0;
		{
			private _index = _forEachIndex; 
			if (_x == 1) then {
			_countf = _countf +1;
			};
		} forEach _fractures;			

		if (_bloodvolume <= 5) then {
			// [_medic, [_voice+"_giveblood1", 50, 1, true]] remoteExec ["say3D", 0];
			[_medic, [_voice+"_giveblood1", 20, 1, true]] remoteExec ["say3D", 0];
			diag_log format ["| %1 | %2 | [1058] kkkkkkkkkkkkk SAY3D BLOOD | voice: %3", name _incap, name _medic, _voice];
			diag_log format ["%1 [1059]==== INJECT BLOOD ====", name _incap];
			diag_log format ["%1 [1059]==== INJECT BLOOD ====", name _incap];
			diag_log format ["%1 [1059]==== INJECT BLOOD ====", name _incap];
			// [_incap, "RightArm", selectRandom["BloodIV","PlasmaIV"]] call ace_medical_treatment_fnc_ivBagLocal;
		/* 	diag_log "====LINE [1063]";
			if (aceversion >= 19) then {
				_currentIV = _incap call ace_medical_fnc_getIVs;
				diag_log "[1065] =====CURRENT IVs====";
				diag_log _currentIV;
			}; */
			[_incap, _medic] call Lifeline_IV_Blood; //update for 3.19 in 2025

			if (_countf == 0) then { // if there are no fractures, then have anim for blood IV (usually blood can inject while fractures being fixed. Saves time)

				//added to increase revive time limit on each loop pass					
				_timelimitincap = (_incap getvariable "LifelinePairTimeOut");
				_timelimitmedic = (_medic getvariable "LifelinePairTimeOut");
				_incap setVariable ["LifelinePairTimeOut", _timelimitincap + 10, true]; 
				_medic setVariable ["LifelinePairTimeOut", _timelimitmedic + 10, true]; 			
					
				if (isPlayer _incap && Lifeline_HUD_medical) then {
				_colour = "F9CAA7";
				[format ["<t align='right' size='%2' color='#%1'>Blood IV</t>",_colour, 0.5],((safeZoneW - 1) * 0.48),1.3,5,0,0,Lifelinetxt2Layer] remoteExec ["BIS_fnc_dynamicText",_incap];
				};

				// Kneeling revive - no near enemy
				if (isNull _EnemyCloseBy) then {
					[_medic,  "AinvPknlMstpSnonWnonDnon_medic1" ] remoteExec ["playMove", _medic];
					diag_log "2293 ==== ANIMATION AinvPknlMstpSnonWnonDnon_medic1";
					 // [_medic, SelectRandom ["AinvPknlMstpSnonWnonDnon_medic1", "AinvPknlMstpSnonWnonDnon_medic2"]] remoteExec ["playMove", _medic];
					 sleep 8;  
				};

				// Lying down revive - near enemy. Alternating between two anims to fix an Arma bug
				if (!isNull _EnemyCloseBy) then {
					if (_switch == 0) then {
							[_medic, "ainvppnemstpslaywrfldnon_medicother"] remoteExec ["playMove", _medic];
							diag_log "2399 ==== ANIMATION ainvppnemstpslaywrfldnon_medicother";
							_switch = 1; 
							sleep 9;
						 } else { [_medic, "AinvPpneMstpSlayWpstDnon_medicOther"] remoteExec ["playMove", _medic];
							diag_log "2403 ==== ANIMATION AinvPpneMstpSlayWpstDnon_medicOther";
							// [_medic, "AinvPpneMstpSlayWnonDnon_medicOther"] remoteExec ["playMove", _medic]; //sometimes looks missing arm 
							_switch = 0;
							sleep 9.5;	
						}; 
				};	
			};
			
			if (_countf > 0) then {sleep 2;}; // add some seconds if fractures exist to give space between voice samples
		};

		_firstrun = true;

		{
			private _index = _forEachIndex; // Get the current index
			if (_x == 1) then {
				if (lifestate _incap != "INCAPACITATED") exitWith {diag_log format ["%1 ==== EXIT FRACTURES | NO LONGER INCAP [1109]", name _incap];};
				if (lifestate _medic == "INCAPACITATED") exitWith {
					if (Lifeline_Revive_debug) then {
						if (isPlayer _incap && Lifeline_hintsilent) then {[ "MEDIC DOWN" ] remoteExec ["hintsilent",_incap]};
						diag_log format ["%1 ==== EXIT FRACTURES | MEDIC INCAP [1113]", name _incap];
					};
				}; //with other players healing simultaneously, this can happen
				
				// if ([_incap] call ace_medical_status_fnc_isBeingDragged || [_incap] call ace_medical_status_fnc_isBeingCarried) exitWith {diag_log "1672 xxxxxxxxxxxxxxxxxxxxx DRAGGED CARRIED xxxxxxxxxxxxxxxxxxxxxx";};
				
				if (_firstrun == true) then {
					// [_medic, [_voice+"_fracture1", 50, 1, true]] remoteExec ["say3D", 0];
					[_medic, [_voice+"_fracture1", 20, 1, true]] remoteExec ["say3D", 0];
					_firstrun = false;
				} else {
					[_medic, [_voice+"_andagain"+(str _againswitch), 20, 1, true]] remoteExec ["say3D", 0];
					if (_againswitch == 1) then { _againswitch = 2; } else { _againswitch = 1; };
				};

				diag_log format ["| %1 | %2 | [1128] kkkkkkkkkkkkk SAY3D FRACTURE | voice: %3", name _incap, name _medic, _voice];
						
				//ALL AT FRONT NOW
				_jsonStr = _incap call ace_medical_fnc_serializeState; 	
				_json = [_jsonStr] call CBA_fnc_parseJSON;  diag_log "[1132] ==== CBA_fnc_parseJSON"; 
				_jsonhash = [_jsonStr, 2] call CBA_fnc_parseJSON;   diag_log "[1133] ==== CBA_fnc_parseJSON"; 

				if (oldACE == false) then {
					_fractures = _jsonhash get "ace_medical_fractures";
				} else {
					_fractures = _json getVariable ["ace_medical_fractures", false];						
				};

				_countf = 0;{private _index = _forEachIndex; if (_x == 1) then {_countf = _countf +1;};} forEach _fractures;
				if (isPlayer _incap && Lifeline_HUD_medical) then {										
					_colour = "F9CAA7";
					[format ["<t align='right' size='%2' color='#%1'>%3 Fractures</t>",_colour, 0.5,_countf],((safeZoneW - 1) * 0.48),1.3,5,0,0,Lifelinetxt2Layer] remoteExec ["BIS_fnc_dynamicText",_incap];
				};

				diag_log format ["====|%5|%6| [1147] ACE FRACTURE IN PROGRESS %1 DMG %2", _index, damage _incap, _incap, _medic, name _incap, name _medic];
				
				if (oldACE == false) then {
					_fractures set [_index, 0]; // Change 1 to 0					
					_jsonhash set ["ace_medical_fractures", _fractures];
					_newJsonStr  = [_jsonhash] call CBA_fnc_encodeJSON;
					[_incap, _newJsonStr, true] call fix_medical_fnc_deserializeState;
					diag_log format ["========[1154] FRACTURES NEWACE %1", _fractures];
					diag_log format ["========[1154] FRACTURES NEWACE %1", _fractures];
					// [_incap, _newJsonStr] remoteExec ["fix_medical_fnc_deserializeState", _incap];
				} else {
					_fractures set [_index, 0];
					diag_log format ["========[1159]FRACTURES OLDACE %1", _fractures];
					diag_log format ["========[1159]FRACTURES OLDACE %1", _fractures];
					// diag_log format ["========FRACTURES OLDACE %1", _fractures];
					// diag_log format ["========FRACTURES OLDACE %1", _fractures];
					_json setVariable ["ace_medical_fractures", _fractures];
					_newJsonStr = [_json] call CBA_fnc_encodeJSON;
					// _json call CBA_fnc_deleteNamespace;
					[_incap, _newJsonStr, true] call fix_medical_fnc_deserializeState;
					// [_incap, _newJsonStr] remoteExec ["fix_medical_fnc_deserializeState", _incap];
				};

				//added to increase revive time limit on each loop pass
				_timelimitincap = (_incap getvariable "LifelinePairTimeOut");
				_timelimitmedic = (_medic getvariable "LifelinePairTimeOut");
				_incap setVariable ["LifelinePairTimeOut", _timelimitincap + 10, true]; 
				_medic setVariable ["LifelinePairTimeOut", _timelimitmedic + 10, true]; 

				//DEBUG	
				// if (isPlayer _incap && Lifeline_HUD_medical) then {										
				// _colour = "F9CAA7";
				// [format ["<t align='right' size='%2' color='#%1'>%3 Fractures</t>",_colour, 0.5,_countf],0.64,1.3,5,0,0,Lifelinetxt2Layer] remoteExec ["BIS_fnc_dynamicText",_incap];
				// [format ["<t align='right' size='%2' color='#%1'>%3 Fractures</t>",_colour, 0.5,_countf],((safeZoneW - 1) * 0.48),1.3,5,0,0,Lifelinetxt2Layer] remoteExec ["BIS_fnc_dynamicText",_incap];
				// };
				// _countf = _countf - 1; //ENDDEBUG

				//============================ CALL ANIMATION ==============================
				_animsvoice = [_incap, _medic,_EnemyCloseBy,_voice,_switch, _againswitch, _encourage,_enc_count] call Lifeline_ACE_Anims_Voice;
				_switch = _animsvoice select 0;
				_againswitch = _animsvoice select 1;
				_enc_count = _animsvoice select 2;				
				// ==========================================================================

			}; // if (_x == 1) then {

		} forEach _fractures;

				
		diag_log format ["%1 =====OUT OF FRACTURES LOOP=====", name _incap];

		if (lifestate _incap != "INCAPACITATED") exitWith {diag_log format ["%1 ==== EXIT ROOT NO LONGER INCAP ==[1920]", name _incap];};

		// ====== blood again if needed - not spawned to allow voice sample time to play
		if (oldACE == false) then {
				 _jsonStr = _incap call ace_medical_fnc_serializeState; 
				 _jsonhash = [_jsonStr, 2] call CBA_fnc_parseJSON;  diag_log "[1203] ==== CBA_fnc_parseJSON"; 
				 _bloodvolume = _jsonhash get "ace_medical_bloodvolume";
				 diag_log format ["%2 | %3 [1205]+++++++++++++++++++++++++++++++++++ BLOODVOL %1", _bloodvolume, name _incap, name _medic];	
		} else {
				 _jsonStr = _incap call ace_medical_fnc_serializeState;
				 _json = [_jsonStr] call CBA_fnc_parseJSON;  diag_log "[1208] ==== CBA_fnc_parseJSON"; 
				 _bloodvolume = _json getVariable ["ace_medical_bloodvolume", false];
				diag_log format ["%2 | %3 [1210]+++++++++++++++++++++++++++++++++++ BLOODVOL %1", _bloodvolume, name _incap, name _medic];	
				// diag_log format ["++++ JSONSTR %1", _jsonStr];	
				// diag_log format ["++++ JSON %1", _json];	
		};

		if (_bloodvolume <= 5) then {
			// [_medic, [_voice+"_moreblood1", 50, 1, true]] remoteExec ["say3D", 0];
			[_medic, [_voice+"_moreblood1", 20, 1, true]] remoteExec ["say3D", 0];
			diag_log format ["| %1 | %2 | 1475 kkkkkkkkkkkkk SAY3D MORE BLOOD | voice: %3", name _incap, name _medic, _voice];
			diag_log format ["%1 [1219]====INJECT BLOOD AGAIN====", name _incap];
			diag_log format ["%1 [1219]====INJECT BLOOD AGAIN====", name _incap];
			if (isPlayer _incap && Lifeline_HUD_medical) then {
				_colour = "F9CAA7";
				[format ["<t align='right' size='%2' color='#%1'>More Blood IV</t>",_colour, 0.5],((safeZoneW - 1) * 0.48),1.3,5,0,0,Lifelinetxt2Layer] remoteExec ["BIS_fnc_dynamicText",_incap];
			};
			/* diag_log "====LINE [1231]";
			// [_incap, "RightArm", selectRandom["BloodIV","PlasmaIV"]] call ace_medical_treatment_fnc_ivBagLocal;
			if (aceversion >= 19) then {
				_currentIV = _incap call ace_medical_fnc_getIVs;
				diag_log "[1235] =====CURRENT IVs====";
				diag_log _currentIV;
			}; */
			[_incap, _medic] call Lifeline_IV_Blood; //update for 3.19 in 2025
			sleep 3; //just added

		}; 

		// last check for blood, in a spawned loop process
		[_incap,_medic] spawn {
			params ["_incap","_medic"];
			_json = [];
			_bloodvolume = [];
			if (oldACE == false) then {
				 _jsonStr = _incap call ace_medical_fnc_serializeState; 
				 _jsonhash = [_jsonStr, 2] call CBA_fnc_parseJSON;  diag_log "[1238] ==== CBA_fnc_parseJSON"; 
				 _bloodvolume = _jsonhash get "ace_medical_bloodvolume";
				 diag_log format ["%2 | %3 [1240]+++++++++++++++++++++++++++++++++++ BLOODVOL %1", _bloodvolume, name _incap, name _medic];	
			} else {
				 _jsonStr = _incap call ace_medical_fnc_serializeState;
				 _json = [_jsonStr] call CBA_fnc_parseJSON;  diag_log "[1243] ==== CBA_fnc_parseJSON"; 
				 _bloodvolume = _json getVariable ["ace_medical_bloodvolume", false];
				diag_log format ["%2 | %3 [1245]+++++++++++++++++++++++++++++++++++ BLOODVOL %1", _bloodvolume, name _incap, name _medic];	
			};
			while {_bloodvolume <= 5} do {
				diag_log format ["[1248]+++++++++++++++++++++++++++++++++++ BLOODVOL IN LOOP %1", _bloodvolume];	
				sleep 5;
				if (oldACE == false) then {
					 _jsonStr = _incap call ace_medical_fnc_serializeState; 
					 _jsonhash = [_jsonStr, 2] call CBA_fnc_parseJSON;  diag_log "[1252] ==== CBA_fnc_parseJSON"; 
					 _bloodvolume = _jsonhash get "ace_medical_bloodvolume";
					 diag_log format ["%2 | %3 [1254]+++++++++++++++++++++++++++++++++++ BLOODVOL %1", _bloodvolume, name _incap, name _medic];	
				} else {
					 _jsonStr = _incap call ace_medical_fnc_serializeState;
					 _json = [_jsonStr] call CBA_fnc_parseJSON;  diag_log "[1257] ==== CBA_fnc_parseJSON"; 
					 _bloodvolume = _json getVariable ["ace_medical_bloodvolume", false];
					diag_log format ["%2 | %3 [1254]+++++++++++++++++++++++++++++++++++ BLOODVOL %1", _bloodvolume, name _incap, name _medic];	
				};
				// [_incap, "RightArm", selectRandom["BloodIV","PlasmaIV"]] call ace_medical_treatment_fnc_ivBagLocal;
				/* diag_log "====LINE [1275]";
				if (aceversion >= 19) then {
					_currentIV = _incap call ace_medical_fnc_getIVs;
					diag_log "[1276] =====CURRENT IVs====";
					diag_log _currentIV;
				}; */
				[_incap, _medic] call Lifeline_IV_Blood; //update for 3.19 in 2025
			}; 
		};

		//========================== check cardiac arrest do CPR again to be sure

		_cprcount = 1;
		_cpr = [_medic, _incap] call ace_medical_treatment_fnc_canCPR;

		while {_cpr == true && _cprcount < 6 && alive _medic && alive _incap && lifestate _incap == "INCAPACITATED"} do {

			// [_medic, [_voice+"_CPR1", 50, 1, true]] remoteExec ["say3D", 0];
			[_medic, [_voice+"_CPR1", 20, 1, true]] remoteExec ["say3D", 0]; //softer
			diag_log format ["| %1 | %2 | 1475 kkkkkkkkkkkkk SAY3D CPR | voice: %3", name _incap, name _medic, _voice];

			if (!isNull _EnemyCloseBy) then {
				[_medic, "AmovPpneMstpSrasWrflDnon_AmovPercMsprSlowWrflDf"] remoteExec ["PlayMove", _medic];
			};	
			sleep 2;

			if (_cprcount == 1) then {
				[_medic, "AinvPknlMstpSnonWnonDr_medic0"] remoteExec ["playMove", _medic]; //from ACE DEVS
			};

			//added to increase revive time limit on each loop pass			
			_timelimitincap = (_incap getvariable "LifelinePairTimeOut");
			_timelimitmedic = (_medic getvariable "LifelinePairTimeOut");
			_incap setVariable ["LifelinePairTimeOut", _timelimitincap + 12, true]; 
			_medic setVariable ["LifelinePairTimeOut", _timelimitmedic + 12, true]; 

			diag_log format ["%1 ========CPR 2 ======= PASS %2", name _incap, _cprcount];
			diag_log format ["%1 ========CPR 2 ======= PASS %2", name _incap, _cprcount];
			diag_log format ["%1 ========CPR 2 ======= PASS %2", name _incap, _cprcount];
			diag_log format ["%1 ========CPR 2 ======= PASS %2", name _incap, _cprcount];

			if (isPlayer _incap && Lifeline_HUD_medical) then {
				_colour = "F9CAA7";
				[format ["<t align='right' size='%2' color='#%1'>CPR</t>",_colour, 0.5],((safeZoneW - 1) * 0.48),1.3,5,0,0,Lifelinetxt2Layer] remoteExec ["BIS_fnc_dynamicText",_incap];
			};

			_cprcount = _cprcount + 1;
			[_medic, _incap, "RightArm", "Epinephrine", objNull, "ACE_epinephrine"] call ace_medical_treatment_fnc_medication;
			sleep 2;
			[_medic, _incap] call ace_medical_treatment_fnc_cprStart;
			 sleep 10;
			// [_medic, _incap] call ace_medical_treatment_fnc_cprSuccess;
			// sleep 2;
			_cpr = [_medic, _incap] call ace_medical_treatment_fnc_canCPR;

		}; // end while

		if (_cprcount > 1 && alive _incap) then {
			[_medic, [_voice+"_pulse1", 20, 1, true]] remoteExec ["say3D", 0]; //softer
			diag_log format ["| %1 | %2 | 1475 kkkkkkkkkkkkk SAY3D PULSE | voice: %3", name _incap, name _medic, _voice];
		};

		// ============== EPI & MORPHINE

		[_medic, _incap, "RightArm", "Morphine", objNull, "ACE_morphine"] call ace_medical_treatment_fnc_medication;

		_counter = 1;

		// EPI to wake up.
		while {_counter < 4 && lifestate _incap == "INCAPACITATED" } do {	

				diag_log format ["%1 ==== EPI LOOP counter: %2", name _incap, _counter];
				
				if (lifestate _incap == "INCAPACITATED") then {
					// if (lifestate _incap == "INCAPACITATED" && !(_incap getVariable ["Lifeline_3timesEPI",false])) then {
					diag_log format ["%1 ========STILL INCAPACITATED - ADD EPI =========", name _incap];

					if (isPlayer _incap && Lifeline_HUD_medical) then {
						_colour = "F9CAA7";
						[format ["<t align='right' size='%2' color='#%1'>Epinephrine</t>",_colour, 0.5],((safeZoneW - 1) * 0.48),1.3,5,0,0,Lifelinetxt2Layer] remoteExec ["BIS_fnc_dynamicText",_incap];
					};

					if (_counter == 1) then {
						// [_medic, [_voice+"_giveEpinephrine1", 50, 1, true]] remoteExec ["say3D", 0];
						[_medic, [_voice+"_giveEpinephrine1", 20, 1, true]] remoteExec ["say3D", 0];
							diag_log format ["| %1 | %2 | 1475 kkkkkkkkkkkkk SAY3D EPI | voice: %3", name _incap, name _medic, _voice];
							
							// morphine too in 4 seconds. Not said eveytime for some randomness
							if (selectRandom[1,2] ==1) then {
								[_incap,_medic,_voice] spawn {
								params ["_incap","_medic","_voice"];
								sleep 6;
								[_medic, [_voice+"_morphine1", 20, 1, true]] remoteExec ["say3D", 0];
								if (isPlayer _incap && Lifeline_HUD_medical) then {
								_colour = "F9CAA7";
								[format ["<t align='right' size='%2' color='#%1'>Morphine</t>",_colour, 0.5],((safeZoneW - 1) * 0.48),1.3,5,0,0,Lifelinetxt2Layer] remoteExec ["BIS_fnc_dynamicText",_incap];
								};
								diag_log format ["| %1 | %2 | 1475 kkkkkkkkkkkkk SAY3D EPI | voice: %3", name _incap, name _medic, _voice];
								};
							};														
					} else {
						// [_medic, [_voice+"_givingmore"+str (_counter - 1), 50, 1, true]] remoteExec ["say3D", 0];
						[_medic, [_voice+"_givingmore"+str (_counter - 1), 20, 1, true]] remoteExec ["say3D", 0];
						diag_log format ["| %1 | %2 | 1475 kkkkkkkkkkkkk SAY3D EPI MORE | voice: %3 | counter: %4", name _incap, name _medic, _voice, _counter];
					};

					//added to increase revive time limit on each loop pass					
					_timelimitincap = (_incap getvariable "LifelinePairTimeOut");
					_timelimitmedic = (_medic getvariable "LifelinePairTimeOut");
					_incap setVariable ["LifelinePairTimeOut", _timelimitincap + 15, true]; 
					_medic setVariable ["LifelinePairTimeOut", _timelimitmedic + 15, true]; 				

					// Kneeling revive - no near enemy
					if (isNull _EnemyCloseBy) then {
						[_medic,  "AinvPknlMstpSnonWrflDnon_medic1" ] remoteExec ["playMove", _medic];
						diag_log "2636 ==== ANIMATION AinvPknlMstpSnonWrflDnon_medic1";
						//DEBUG // [_medic, SelectRandom ["AinvPknlMstpSnonWnonDnon_medic1","AinvPknlMstpSnonWnonDnon_medic2"]] remoteExec ["playMove", _medic];  //ENDDEBUG
						sleep 8;
					};
					// Lying down revive - near enemy. Alternating between two anims to fix an Arma bug
					if (!isNull _EnemyCloseBy) then {
						if (_switch == 0) then {
							[_medic, "ainvppnemstpslaywrfldnon_medicother"] remoteExec ["playMove", _medic];
							diag_log "2644 ==== ANIMATION ainvppnemstpslaywrfldnon_medicother";
							_switch = 1;
							sleep 9;
						} else {
							[_medic, "AinvPpneMstpSlayWpstDnon_medicOther"] remoteExec ["playMove", _medic];
							diag_log "2649 ==== ANIMATION AinvPpneMstpSlayWpstDnon_medicOther";
							//DEBUG // [_medic, "AinvPpneMstpSlayWnonDnon_medicOther"] remoteExec ["playMove", _medic]; //sometimes looks missing arm //ENDDEBUG
							_switch = 0;
							sleep 9.5;
						}; 
					};	
					[_medic, _incap, "RightArm", "Epinephrine", objNull, "ACE_epinephrine"] call ace_medical_treatment_fnc_medication;
				};		

				if (lifestate _incap != "INCAPACITATED") exitWith {diag_log format ["%1 ==== HOW IS THIS POSSIBLE. EXIT EPI no MORE INCAP == [1991]", name _incap];};

				// diag_log format ["%1 ==== EPI LOOP counter: %2", name _incap, _counter];
				sleep 5;

				if (_counter == 3) then {
					diag_log format ["%1 ==== HAD THREE DOSES OF EPINEPHRINE ====", name _incap];
					 // _incap setVariable ["Lifeline_3timesEPI",true,true];

					if (lifestate _incap == "INCAPACITATED") then {

						// this is a hack. need to figure out why not reviving with 3 epis sometimes

						//added to increase revive time limit on each loop pass					
						_timelimitincap = (_incap getvariable "LifelinePairTimeOut");
						_timelimitmedic = (_medic getvariable "LifelinePairTimeOut");
						_incap setVariable ["LifelinePairTimeOut", _timelimitincap + 15, true]; 
						_medic setVariable ["LifelinePairTimeOut", _timelimitmedic + 15, true]; 

						// sleep 5;
						// [_incap, false] call ace_medical_status_fnc_setUnconsciousState;
						sleep 5;
						// [_incap] call ace_medical_treatment_fnc_fullHealLocal;
						[_medic, _incap] call ace_medical_treatment_fnc_fullHeal;
					};
				};
				_counter = _counter + 1;
		};

		// sleep 10;	
		// [_medic, [_voice+"_morphine1", 20, 1, true]] remoteExec ["say3D", 0];
		// diag_log format ["| %1 | %2 | 1475 kkkkkkkkkkkkk SAY3D EPI | voice: %3", name _incap, name _medic, _voice];		

		[_medic, _incap] spawn {
			params ["_medic", "_incap"];
			_medic setdir (_medic getDir _incap)+10;
		};	
};



Lifeline_SelfHeal_ACE = {
params ["_unit"];
	if (alive _unit && lifestate _unit != "INCAPACITATED" && !isPlayer _unit) then {

		// _unit setVariable ["Lifeline_selfheal_progss",true,true];diag_log format ["%1 [1554 ACE]!!!!!!!!! change var Lifeline_selfheal_progss = true !!!!!!!!!!!!!", name _unit]; // in original Lifeline_SelfHeal now
		
		// Get Nearest Enemy to Incap unit
		_EnemyCloseBy = [_unit] call Lifeline_EnemyCloseBy;
		_json = [];
		_bloodvolume = [];
		_jsonStr = [];
		_bloodvolume = "";
		_jsonhash = "";
	
		//DEBUG
		//only for debugging animtion
		// _unit addEventHandler ["AnimStateChanged", {
		// params ["_unit", "_anim"];
		// diag_log format ["%1 !!!!!!!!!!!!!! healself anim %2 anim %3", name _unit, animationstate _unit, _anim];					
		// }];
		//ENDDEBUG

		if (lifeState _unit == "INCAPACITATED" || !alive _unit) exitWith {diag_log format ["%1 [1630]|!!!!!!!!!!!!!! ACE HEAL SELF EXIT !!!!!!!!!!!!", name _unit]; };

		// ================= BANDAGE ACTION LOOP ================

		if (oldACE == false) then {

				 _jsonStr = _unit call ace_medical_fnc_serializeState; 		
				// private _json = [_jsonStr] call CBA_fnc_parseJSON;					
				 _jsonhash = [_jsonStr, 2] call CBA_fnc_parseJSON;   diag_log "[1463] ==== CBA_fnc_parseJSON";  // 2nd arg will get native hashMaps
				 _woundsHash = _jsonhash get "ace_medical_openwounds";
				 _fractures = _jsonhash get "ace_medical_fractures";
				{

					 _key1 = _x;    // _x represents each key in the hashmap
					 _value1 = _woundsHash get _key1;  // Get the value associated with the key

					if (lifeState _unit == "INCAPACITATED" || !alive _unit) exitWith {diag_log format ["%1 [1645]|!!!!!!!!!!!!!! ACE HEAL SELF EXIT !!!!!!!!!!!!", name _unit]; };

					while {count _value1 > 0} do {	

						if (lifeState _unit == "INCAPACITATED" || !alive _unit) exitWith {diag_log format ["%1 [1650]|!!!!!!!!!!!!!! ACE HEAL SELF EXIT !!!!!!!!!!!!", name _unit]; };

						diag_log format ["== COUNT WOUNDS SELFHEAL %1 ==", count _value1];

						if (_unit getVariable ["ReviveInProgress",0] in [1,2]) then {
							diag_log format ["%1 [1660] ========== SELF HEAL ADD 5 SECS (ReviveInProgress in 1 or 2)", name _unit];
							_unit setVariable ["LifelinePairTimeOut", (_unit getvariable "LifelinePairTimeOut") + 5, true];
						}; // add 5 secs to timeout

						if ((isnull _EnemyCloseBy or _unit distance _EnemyCloseBy >100) && count _value1 == 1) then {
							// [_unit,"AinvPknlMstpSlayWrflDnon_medic"] remoteExec ["playMoveNow", _unit];
							// diag_log "== 1";
							diag_log format ["== ANIMATION SELFHEAL %1 ==", name _unit];
							[_unit,"AinvPknlMstpSlayWrflDnon_medic"] remoteExec ["playMoveNow",_unit];
							sleep 5;			
						} else {
							// [_unit,"ainvppnemstpslaywrfldnon_medic"] remoteExec ["playMoveNow",_unit];
							 // diag_log "== 2";
							 diag_log format ["== ANIMATION SELFHEAL %1 ==", name _unit];
							[_unit,"AinvPpneMstpSlayWnonDnon_medicIn"] remoteExec ["playMoveNow",_unit];
							sleep 5;	
						};

						sleep 0.5;

						_value1 = _value1 - [_value1 select 0];
						_woundsHash set [_key1, _value1];									
						diag_log format ["%2 ====HASH %1", _woundsHash, name _unit];
						_jsonhash set ["ace_medical_openwounds", _woundsHash];
						private _newJsonStr  = [_jsonhash] call CBA_fnc_encodeJSON;
						[_unit, _newJsonStr] call fix_medical_fnc_deserializeState;
					};	

				} forEach (keys _woundsHash);

		}; //NEW ACE


		if (oldACE == true) then {

				 _jsonStr = _unit call ace_medical_fnc_serializeState; 		
				 _json = [_jsonStr] call CBA_fnc_parseJSON;	 diag_log "[1516] ==== CBA_fnc_parseJSON"; 
				 _wounds = _json getVariable ["ace_medical_openwounds", false];
				// private _fractures = _json get "ace_medical_fractures";
				_EnemyCloseBy = [_unit] call Lifeline_EnemyCloseBy;
				_woundcount = count _wounds;
				_counter = _woundcount;

				while {_counter > 0} do {

					if (lifeState _unit == "INCAPACITATED" || !alive _unit) exitWith {diag_log format ["%1 [1694]|!!!!!!!!!!!!!! ACE HEAL SELF EXIT !!!!!!!!!!!!", name _unit]; };

					if (_counter <= 0) exitWith {diag_log "EXIT BANDAGE LOOP";};
						_bodyparty = _wounds select 0 select 1;
						// sleep 1;		
						//diag_log format ["==========================COUNT %1", _counter];
						diag_log format  ["kkkkkkkkkkkkkkkkkkkkkkkkkk== _counter %1", _counter];

						if (_unit getVariable ["ReviveInProgress",0] in [1,2]) then {
							diag_log format ["%1 [1710] ========== SELF HEAL ADD 5 SECS (ReviveInProgress in 1 or 2)", name _unit];
							_unit setVariable ["LifelinePairTimeOut", (_unit getvariable "LifelinePairTimeOut") + 5, true];						
						}; // add 5 secs to timeout

						if ((isnull _EnemyCloseBy or _unit distance _EnemyCloseBy >100) && _counter == 1) then {
							// [_unit,"AinvPknlMstpSlayWrflDnon_medic"] remoteExec ["playMoveNow", _unit];
							// diag_log "== 1";
							diag_log format ["== ANIMATION SELFHEAL %1 ==", name _unit];
							[_unit,"AinvPknlMstpSlayWrflDnon_medic"] remoteExec ["playMoveNow",_unit];
							sleep 5;			
						} else {
							// [_unit,"ainvppnemstpslaywrfldnon_medic"] remoteExec ["playMoveNow",_unit];
							 // diag_log "== 2";
							 diag_log format ["== ANIMATION SELFHEAL %1 ==", name _unit];
							[_unit,"AinvPpneMstpSlayWnonDnon_medicIn"] remoteExec ["playMoveNow",_unit];
							sleep 5;	
						};

						_counter = _counter - 1;
						_wounds = _wounds - [_wounds select 0];
						diag_log format  ["kkkkkkkkkkkkkkkkkkkkkkkkkk== _wounds %1", _wounds];
						_json setVariable ["ace_medical_openwounds", _wounds];
						_newJsonStr = [_json] call CBA_fnc_encodeJSON;
						// _json call CBA_fnc_deleteNamespace;
						[_unit, _newJsonStr] call fix_medical_fnc_deserializeState;
						
				}; //while {_counter > 0} do {

				diag_log "=====PAST MINI LOOP";
			
		}; //if (oldACE == true) then {


		// ====================ADD BLOOD IF NEEDED
		if (lifeState _unit == "INCAPACITATED" || !alive _unit) exitWith {diag_log format ["%1 [1731]|!!!!!!!!!!!!!! ACE HEAL SELF EXIT !!!!!!!!!!!!", name _unit]; };

		if (oldACE == false) then {
			 _jsonStr = _unit call ace_medical_fnc_serializeState; 
			 _jsonhash = [_jsonStr, 2] call CBA_fnc_parseJSON;  diag_log "[1572] ==== CBA_fnc_parseJSON"; 
			 _bloodvolume = _jsonhash get "ace_medical_bloodvolume";
		} else {
			 _jsonStr = _unit call ace_medical_fnc_serializeState;
			 _json = [_jsonStr] call CBA_fnc_parseJSON;  diag_log "[1576] ==== CBA_fnc_parseJSON"; 
			 _bloodvolume = _json getVariable ["ace_medical_bloodvolume", false];
		};

		 diag_log format ["%2 | SELFHEAL +++++++++++++++++++++++++++++++++++ BLOODVOL %1", _bloodvolume, name _unit];	
		
		if (_bloodvolume <= 6) then {
			
			// [_unit, _unit, "RightArm", "BloodIV", objNull, "ACE_bloodIV"] call ace_medical_treatment_fnc_ivBag;
			[_unit] call Lifeline_Self_IV_Blood;
			
			// sleep 10;
		};
		// test event handler for blood IV


		// =====================ADD MORPHINE	
		if (lifeState _unit == "INCAPACITATED" || !alive _unit) exitWith {diag_log format ["%1 [1757]|!!!!!!!!!!!!!! ACE HEAL SELF EXIT !!!!!!!!!!!!", name _unit]; };

		_pain = [];

		if (oldACE == false) then {
			 _pain = _jsonhash get "ace_medical_pain";
			 diag_log format ["%1 xxxxxxxxx SELF HEAL PAIN %2", name _unit, _pain];
		} else {
			 _pain = _json getVariable ["ace_medical_pain", false];
			 diag_log format ["%1 xxxxxxxxx SELF HEAL PAIN %2", name _unit, _pain];
		};

		[_unit, "RightArm", "Morphine"] call ace_medical_treatment_fnc_medicationLocal;

		 _fractures = [];
		 _jsonStr = _unit call ace_medical_fnc_serializeState; 	
		  _json = [_jsonStr] call CBA_fnc_parseJSON;	 diag_log "[1608] ==== CBA_fnc_parseJSON"; 
		 _jsonhash = [_jsonStr, 2] call CBA_fnc_parseJSON;   diag_log "[1609] ==== CBA_fnc_parseJSON"; 

		if (oldACE == false) then {	
			_fractures = _jsonhash get "ace_medical_fractures";
		} else {
			_fractures = _json getVariable ["ace_medical_fractures", false];
		};


		 //========== FRACTURE LOOP
		if (lifeState _unit == "INCAPACITATED" || !alive _unit) exitWith {diag_log format ["%1 [1785]|!!!!!!!!!!!!!! ACE HEAL SELF EXIT !!!!!!!!!!!!", name _unit]; };

		{
			if (lifeState _unit == "INCAPACITATED" || !alive _unit) exitWith {diag_log format ["%1 [1788]|!!!!!!!!!!!!!! ACE HEAL SELF EXIT !!!!!!!!!!!!", name _unit]; };
			_index = _forEachIndex; // Get the current index

			if (_x == 1) then {
				_fractures set [_index, 0]; // Change 1 to 0					
					if (oldACE == false) then {
						_fractures = _jsonhash get "ace_medical_fractures";
						_fractures set [_index, 0]; // Change 1 to 0					
						_jsonhash set ["ace_medical_fractures", _fractures];
						_newJsonStr  = [_jsonhash] call CBA_fnc_encodeJSON;
						[_unit, _newJsonStr] call fix_medical_fnc_deserializeState;
					} else {
						_fractures = _json getVariable ["ace_medical_fractures", false];
						_fractures set [_index, 0];
						_json setVariable ["ace_medical_fractures", _fractures];
						_newJsonStr = [_json] call CBA_fnc_encodeJSON;
						// _json call CBA_fnc_deleteNamespace;
						[_unit, _newJsonStr] call fix_medical_fnc_deserializeState;
					};				
			}; //if (_x == 1) then {

		} forEach _fractures;

		if (lifeState _unit == "INCAPACITATED" || !alive _unit) exitWith {diag_log format ["%1 [1811]|!!!!!!!!!!!!!! ACE HEAL SELF EXIT !!!!!!!!!!!!", name _unit]; };

		_goup = group _unit;		

		if (_unit != leader _goup && count units group _unit >1 && _unit getVariable ["ReviveInProgress",0] ==0 ) then {
			_teamcolour = assignedTeam _unit;
			[_unit] joinSilent (leader _goup);
			[_unit] joinsilent group _unit;
			_unit assignTeam _teamcolour;
		}; 

		sleep 3;		
	};
	
	// _unit setVariable ["Lifeline_selfheal_progss",false,true];diag_log format ["%1 [1172 ACE]!!!!!!!!! change var Lifeline_selfheal_progss = false !!!!!!!!!!!!!", name _unit]; // in original Lifeline_SelfHeal now
}; // end function


Lifeline_countdown_timerACE = {
	params ["_unit","_seconds"];
	//DEBUG
	_diag_textbaby = format ["%1 [0194 fnc] >>>>>>>>>>>> FNC Lifeline_countdown_timerACE. sec setting: %2 >>>>>>>>>>>>", name _unit, _seconds];
	[_diag_textbaby] remoteExec ["diag_log", 2];
	//ENDDEBUG
	
	_counter = _seconds;
	_colour = "#FFFAF8";	
	// _font = Lifelinefonts select Lifeline_HUD_dist_font;//added for distance

	while {lifeState _unit == "INCAPACITATED"} do {

		if (_unit getVariable ["Lifeline_canceltimer",false]) exitWith {/*_unit setVariable ["Lifeline_canceltimer",false,true]; diag_log "==== EXIT COUNTDOWN TIMER HINT ====";*/};


		//========================= ADDED distance
		if (Lifeline_HUD_distance) then {
			_AssignedMedic = (_unit getVariable ["Lifeline_AssignedMedic",[]]); 
			if (_AssignedMedic isNotEqualTo []) then {
				_incap = _unit;
				_medic = _AssignedMedic select 0;
				_distcalc = _medic distance2D _incap;
				if (isPlayer _incap && _distcalc > 10) then {
					// [format ["<t align='right' size='%3' color='%4' font='%5'>%1    %2m</t><br>..<br>..",name _medic, _distcalc toFixed 0,0.5,"#FFFAF8",_font],((safeZoneW - 1) * 0.48),1.26,3,0,0,Lifelinetxt1Layer] spawn BIS_fnc_dynamicText; //BIS_fnc_dynamicText METHOD
					   [format ["<t align='right' size='%3' color='%4' font='%5'>%1    %2m</t><br>..<br>..",name _medic, _distcalc toFixed 0,0.5,"#FFFAF8",Lifeline_HUD_dist_font],((safeZoneW - 1) * 0.48),1.26,3,0,0,Lifelinetxt1Layer] spawn BIS_fnc_dynamicText; //BIS_fnc_dynamicText METHOD
					// [format ["<t align='right' size='%3' color='%4' font='%5'>%1    %2m</t><br>..<br>..",name _medic, _distcalc toFixed 0,0.5,"#FFFAF8",_font],((safeZoneW - 1) * 0.48),1.26,5,0,0,LifelineDistLayer] spawn BIS_fnc_dynamicText; //BIS_fnc_dynamicText METHOD
				};
				if (isPlayer _incap && (_distcalc <= 10 && _distcalc >= 5 ) && Lifeline_HUD_distance) then {
					// ["",0.64,1.26,5,0,0,Lifelinetxt1Layer] remoteExec ["BIS_fnc_dynamicText",_incap];
					["",0.64,1.26,5,0,0,Lifelinetxt1Layer] spawn BIS_fnc_dynamicText;
					// ["",0.64,1.26,5,0,0,LifelineDistLayer] remoteExec ["BIS_fnc_dynamicText",_incap];
				};			
			};	
		};
		
		sleep 1;
	}; // end while

	// diag_log format ["%1 == EXIT TIMER LOOP counter %2 ==", name _unit, _counter];
	// _unit setVariable ["Lifeline_canceltimer",false,true];
	_unit setVariable ["Lifeline_countdown_start",false,true];
};

// ======== FUNCTIONS FOR DIFFERENT ACE VERSIONS

if (aceversion >= 19) then {
    Lifeline_check_carried_dragged = {
        params ["_incap"];
        if ([_incap] call ace_common_fnc_isBeingDragged || [_incap] call ace_common_fnc_isBeingCarried) then {
            true
        } else {
            false
        };
    };
	Lifeline_IV_Blood = {
		params ["_incap","_medic"];
		_type = selectRandom["BloodIV","PlasmaIV"];
		[_medic, _incap, "RightArm", _type, _medic, "ACE_"+_type] call ace_medical_treatment_fnc_ivBag;
	};
	Lifeline_Self_IV_Blood = {
		params ["_unit"];
		_type = selectRandom["BloodIV","PlasmaIV"];
		[_unit, "RightArm", _type, _unit, _unit, "ACE_"+_type] call ace_medical_treatment_fnc_ivBagLocal;
	};
	
} else {
    Lifeline_check_carried_dragged = {
        params ["_incap"];
        if ([_incap] call ace_medical_status_fnc_isBeingDragged || [_incap] call ace_medical_status_fnc_isBeingCarried) then {
            true
        } else {
            false
        };
    };
	Lifeline_IV_Blood = {
		params ["_incap","_medic"];
		// [_incap, "RightArm", selectRandom["BloodIV","PlasmaIV"]] call ace_medical_treatment_fnc_ivBagLocal;
		_type = selectRandom["BloodIV","PlasmaIV"];
		[_medic, _incap, "RightArm", _type, objNull, "ACE_"+_type] call ace_medical_treatment_fnc_ivBag;
	};
	Lifeline_Self_IV_Blood = {
		params ["_unit"];
		_type = selectRandom["BloodIV","PlasmaIV"];
		[_unit, "RightArm", _type] call ace_medical_treatment_fnc_ivBagLocal;
	};
};


//====== ACE Blufor Tracking Limit to GPS device ==
Lifeline_ACE_BluForTrackingLimit = {
	diag_log ">>>>>>>>>>>>>>> START BLUFOR LIMITING >>>>>>>>>>>>>>>";
			Include_cTab = false; // temp
			while {true} do {
				// if ((["ace_map_BFT_Enabled", "client"] call CBA_settings_fnc_get) == true && Lifeline_ACE_BluFor == true) then {
				if ((["ace_map_BFT_Enabled", "client"] call CBA_settings_fnc_get) == true && Lifeline_ACE_BluFor != 0) then {
					diag_log "check GPS";
					_hasGPS = false; 
					if (Lifeline_ACE_BluFor == 1) then {
						{ 
							if ((toLower _x) find "gps" > -1 || (toLower _x) find "uavterminal" > -1 || (toLower _x) find "itemandroid" > -1 || (toLower _x) find "microdagr" > -1 ) exitWith { 
								_hasGPS = true; 
							}; 
							if (Include_cTab && (toLower _x) find "ctab" > -1) exitWith {
								_hasGPS = true; 
							}; 
						} forEach (assignedItems player + items player);

						_vehicleGPS = getNumber (configFile >> "CfgVehicles" >> (typeOf vehicle player) >> "enableGPS");
						if (_vehicleGPS == 1) then {
								_hasGPS = true; 
						};
					};
					if (Lifeline_ACE_BluFor == 2) then {
						if (visibleGPS || ace_microdagr_currentShowMode > 0) then {
							_hasGPS = true; 
						};
						if (taofoldingmap == 1) then {
							if (tao_foldmap_wasOpen && tao_foldmap_alternateDrawPaper == false) then {
								_hasGPS = true;
							};
						};					
						if (taofoldingmap == 2) then {
							if (tao_rewrite_main_isOpen && tao_rewrite_main_drawPaper == false) then {
								_hasGPS = true;
							};
						};
					};

					if (_hasGPS == true) then {
						ace_map_BFT_Enabled = true;
					} else {
						ace_map_BFT_Enabled = false;
					};
				};
				sleep 2;
			};
};

if (Lifeline_RevMethod == 3 && !isDedicated && hasInterface) then {
	diag_log ">>>>>>>>>>>>>BO 1828";
	[] spawn Lifeline_ACE_BluForTrackingLimit;
};