 diag_log "                                                                                                "; 
 diag_log "                                                                                                "; 
 diag_log "                                                                                                "; 
diag_log "                                                                                                '"; 
diag_log "                                                                                                '"; 
diag_log "============================================================================================================='"; 
diag_log "============================================================================================================='"; 
diag_log "========================================= Lifeline_Functions.sqf ==============================================='"; 
diag_log "============================================================================================================='"; 
diag_log "============================================================================================================='"; 

//================================================================================
//==== WHEN UNIT INCAPACITATED

Lifeline_Incapped = {
	params ["_unit","_damage","_non_handler"];
	// _non_handler is a boolean. if true it means incapped function was called NOT through the damage handler.
	//DEBUG
	// _unit setCaptive true;diag_log format ["%1 | [0019]!!!!!!!!! change var setCaptive = true !!!!!!!!!!!!!", name _unit];//TEMPCAPTIVEOFF
	// [_unit, true] remoteExec ["setCaptive",_unit];diag_log format ["%1 | [0020]!!!!!!!!! change var setCaptive = true !!!!!!!!!!!!!", name _unit];	
	// diag_log format ["%1 [0022] ~~~ captive %2", name _unit, captive _unit];
	//ENDDEBUG

	if (captive _unit) then {_unit setVariable ["Lifeline_Captive",true,true]} else {_unit setVariable ["Lifeline_Captive",false,true]}; diag_log format ["%1 | [0024]==== UNCONC captive: %2", name _unit, captive _unit];//2025
	
	_unit setCaptive true;diag_log format ["%1 | [0024 FNC \Lifeline_Incapped\ Lifeline_Functions.sqf]!!!!!!!!! change var setCaptive = true !!!!!!!!!!!!!", name _unit];	

	Lifeline_incapacitated pushBackUnique _unit;
	publicVariable "Lifeline_incapacitated";

	//DEBUG
	if (Lifeline_Revive_debug) then {
		// _diagtext = " ";if !(local _unit) then {[_diagtext] remoteExec ["diag_log", 2];} else {diag_log _diagtext};
		_diagtext = format ["%1 TRACE !!!!!!!!!!!!!!!!!!! [0599] Lifeline_Incapped !!!!!!!!!!!!!!!!!!!! _non_handler %2 ", name _unit, _non_handler];if !(local _unit) then {[_diagtext+" REMOTE"] remoteExec ["diag_log", 2];} else {diag_log _diagtext};
		// _diagtext = " ";if !(local _unit) then {[_diagtext] remoteExec ["diag_log", 2];} else {diag_log _diagtext};
	};	
	//ENDDEBUG
	// diag_log format ["%1 [0031] ~~~ captive %2", name _unit, captive _unit];
	_unit spawn {
		params ["_unit"];
		moveOut _unit;
		[_unit, "UnconsciousReviveArms_A"] remoteExec ["PlayMoveNow", _unit];
		[_unit, "Unconscious"] remoteExec ["PlayMove", _unit];
			// diag_log format ["%1 [0037] ~~~ captive %2", name _unit, captive _unit];
	};
	//DEBUG
	// [_unit, "Unconscious"] remoteExec ["PlayMoveNow", _unit];
	// [_unit, "UnconsciousFaceUp"] remoteExec ["PlayMove", _unit];
	//ENDDEBUG

	_randanim = [];

	//bleedout time added here, for latest version
	_BleedOut = (time + Lifeline_BleedOutTime); 
	// [_unit] call Lifeline_autoRecover_check; //roll the dice to see if autorevive should be set to 'true'.

	_unit setVariable ["LifelineBleedOutTime", _BleedOut, true]; diag_log format ["%1 [035 Lifeline_Incapped]!!!!!!!!! change var LifelinePairTimeOut = (time + Lifeline_BleedOutTime) FIRST TIME (%2) !!!!!!!!!!!!!", name _unit,_BleedOut];
	_unit setVariable ["Lifeline_Down",true,true];
	// _unit setUnconscious true;
	[_unit, true] remoteExec ["setUnconscious",0]; //TEMPOFF
	_unit setVariable ["Lifeline_selfheal_progss",false,true]; //clear var if it was in middle of self healing
	
		// diag_log format ["%1 [0056] ~~~ captive %2", name _unit, captive _unit];
	
	// Lifeline_incapacitated pushBackUnique _unit;
	// publicVariable "Lifeline_incapacitated";

	if (count units group _unit ==1) then {
		if (_unit getVariable ["Lifeline_OrigPos",[]] isEqualTo []) then {
			_pos = (getPosATL _unit);
			_dir = (getdir _unit);
			_unit setVariable ["Lifeline_OrigPos", _pos, true];
			_unit setVariable ["Lifeline_OrigDir", _dir, true];
		};
	};	
	
		// diag_log format ["%1 [0069] ~~~ captive %2", name _unit, captive _unit];

		// ONLY FOR either addAction if first time, or setUserActionText if already exist.
		if (Lifeline_BandageLimit == 1) then {	
			_colour = "F69994";	// skin colour
			_text = "REVIVE";		
			if !(_unit getVariable ["Lifeline_RevActionAdded",false]) then { 
				_unit setVariable ["Lifeline_RevActionAdded",true,true];
				[[_unit,_colour,_text],
					{
					params ["_unit","_colour","_text"];
					   _actionId = _unit addAction [format ["<t size='%3' color='#%1'>%2</t>",_colour,_text,1.7],{params ["_target", "_caller", "_actionId", "_arguments"]; [_caller,_actionId] execVM "Lifeline_Revive\scripts\Lifeline_PlayerRevive.sqf" ; },[],8,true,true,"","_target == cursorObject && _this distance cursorObject < 2.2 && lifeState cursorObject == 'INCAPACITATED' && animationstate _this find 'medic' ==-1"];
						_unit setVariable ["Lifeline_ActionMenuWounds",_actionId,true];
				}] remoteExec ["call", 0, true];		
			} else {				
				[[_unit,_colour,_text],
					{
					params ["_unit","_colour","_text"];
					_actionId = _unit getVariable ["Lifeline_ActionMenuWounds",false];
					_colour = "F69994";	// skin colour
					_text = "REVIVE";
					_unit setUserActionText [_actionId, format ["<t size='%3' color='#%1'>%2</t>",_colour,_text,1.7]];
				}] remoteExec ["call", 0, true];
			};	
			
			[_unit] call Lifeline_autoRecover_check; //roll the dice to see if autorevive should be set to 'true'.


			// moved here, start countdown display, or distance medic.
			if ((Lifeline_HUD_distance == true || Lifeline_cntdwn_disply != 0) && isPlayer _unit) then {
				_seconds = Lifeline_cntdwn_disply;
				if (lifeState _unit == "INCAPACITATED" && !(_unit getVariable ["Lifeline_countdown_start",false]) && Lifeline_cntdwn_disply != 0 && Lifeline_RevMethod != 3 && Lifeline_HUD_distance == false) then {
					_unit setVariable ["Lifeline_countdown_start",true,true];
					[[_unit,_seconds], Lifeline_countdown_timer2] remoteExec ["spawn",_unit, true];
				}; 
				if (lifeState _unit == "INCAPACITATED" && !(_unit getVariable ["Lifeline_countdown_start",false])) then {
					_unit setVariable ["Lifeline_countdown_start",true,true];
					[[_unit,_seconds], Lifeline_countdown_timer2] remoteExec ["spawn",_unit, true];
				};
			};	
			
		}; // end if (Lifeline_BandageLimit == 1) then {	

		// diag_log format ["%1 [0115] ~~~ captive %2", name _unit, captive _unit];	
	// 5 second delay to calculate more damage after initial incapacitation, sometimes miliseconds and volley of bullets or fragments
	[_unit, _damage, _non_handler] spawn {
		params ["_unit","_damage", "_non_handler"];	
			// diag_log format ["%1 [0119] ~~~ captive %2", name _unit, captive _unit];
		sleep 5; diag_log format ["%1 nnnnnnnnnnnnnnn INCAP sleep 5 finished nnnnnnnnnnnnnn", name _unit];	
	

//DEBUG
		//5 sec timer constantly checking captive bug.
		/* _secount = 5;
		while {_secount > 0} do {
			if (captive _unit == false) then {
				_unit setCaptive true;diag_log format ["%1 | [0124 Lifeline_Functions.sqf Lifeline_Incapped SPAWN]!!!!!!!!! change var setCaptive = true !!!!!!!!!!!!!", name _unit];
				// [_unit, true] remoteExec ["setCaptive",_unit];diag_log format ["%1 | [0127 Lifeline_Functions.sqf Lifeline_Incapped SPAWN]!!!!!!!!! change var setCaptive = true !!!!!!!!!!!!!", name _unit];
			};
			sleep 1; diag_log format ["%1 [0140 COUNT] ~~~ captive %2 COUNT %3", name _unit, captive _unit,_secount];
		_secount = _secount - 1;
		}; */
//ENDDEBUG

		_randanim = "";
		// diag_log format ["%1 [0128] ~~~ captive %2", name _unit, captive _unit];

		
			
		//=== unconcious anim if Bandage Range is only 1
		if (Lifeline_BandageLimit == 1) then {
			_randanim = selectRandom["Default_A", "Default_B", "Default_C", "Head_A", "Head_B", "Head_C", "Body_A", "Body_B", "Arms_A", "Arms_B", "Arms_C", "Legs_A", "Legs_B"];
			_randanim = "UnconsciousRevive" + _randanim;			
			[_unit, _randanim] remoteExec ["PlayMoveNow", _unit];
			[_unit, "UnconsciousFaceUp"] remoteExec ["PlayMove", _unit];			
		};		
		
			// diag_log format ["%1 [0131] ~~~ captive %2", name _unit, captive _unit];

		//== unconcious anim if Bandage Range is multiple
		if (Lifeline_BandageLimit > 1) then {

			[_unit] call Lifeline_autoRecover_check; //roll the dice to see if autorevive should be set to 'true'.

			//call function to calculate bandages needed according to damage			
			[_unit,_non_handler] call Lifeline_bandage_addAction; 	
			// diag_log format ["%1 [0139] ~~~ captive %2", name _unit, captive _unit];

			_quadstored = _unit getVariable ["quadstored",false];
			
			diag_log format ["%2 |!!!!!!!!!!!!!! QUAD STORED BABY %1 !!!!!!!!!!!!!!!!", _quadstored,name _unit];

			_unitwounds = _unit getVariable "unitwounds";
			_bandges = count(_unitwounds);
			_firstwound = _unitwounds select (_bandges -1) select 0;
			
			diag_log format ["%2 |!!!!!!!!!!!!!! UNITWOUNDS BABY %1 !!!!!!!!!!!!!!!!", _unitwounds,name _unit];
			diag_log format ["%2 |!!!!!!!!!!!!!! FIRST WOUND BABY %1 !!!!!!!!!!!!!!!!", _firstwound,name _unit];

			if (_quadstored <=2) then {
				//anim by most damaged body part
				if ((_firstwound find "Head:") == 0) then {_randanim = selectRandom["UnconsciousReviveHead_A", "UnconsciousReviveHead_B", "UnconsciousReviveHead_C"];};
				if ((_firstwound find "Torso:") == 0) then {_randanim = selectRandom["UnconsciousReviveBody_A", "UnconsciousReviveBody_B"];};
				if ((_firstwound find "Arm:") == 0) then {_randanim = selectRandom["UnconsciousReviveArms_A", "UnconsciousReviveArms_B", "UnconsciousReviveArms_C"];};
				if ((_firstwound find "Leg:") == 0) then {_randanim = selectRandom["UnconsciousReviveLegs_A", "UnconsciousReviveLegs_B"];};								
			} else {
				if ((_firstwound find "CRITICAL") == 0) then {
					_randanim = "UnconsciousReviveDefault_Base";
				} else {
					_randanim = selectRandom["UnconsciousReviveDefault","UnconsciousReviveDefault_A", "UnconsciousReviveDefault_B", "UnconsciousReviveDefault_C"];
				};
			};
		};
		
		diag_log format ["%1 | !!!!!!!!!!!!!!!!!!!!!!!!!! RAND ANIM %2 !!!!!!!!!!!!!!!", name _unit, _randanim];

		[_unit, _randanim] remoteExec ["PlayMoveNow", _unit];							//HERE
		[_unit, "UnconsciousFaceUp"] remoteExec ["PlayMove", _unit];
		
			// diag_log format ["%1 [0172] ~~~ captive %2", name _unit, captive _unit];
	
		// added for protection after incap. 
		//DEBUG
		// [_unit,dmg_trig] remoteExec ["allowDamage",_unit];
		// waitUntil { isDamageAllowed _unit == dmg_trig};
		// diag_log format ["%1 | [0839][Lifeline_Functions.sqf] ALLOWDAMAGE SET: %2", name _unit, isDamageAllowed _unit];
		//ENDDEBUG
		if (Lifeline_RevProtect != 3) then {
			_unit allowDamage dmg_trig;diag_log format ["%1 | [0170][Lifeline_Functions.sqf] ALLOWDAMAGE SET: %2", name _unit, dmg_trig];
			// _unit setCaptive true;diag_log format ["%1 | [0170]!!!!!!!!! change var setCaptive = true !!!!!!!!!!!!!", name _unit];//TEMPCAPTIVEOFF
		};		
			// diag_log format ["%1 [0185] ~~~ captive %2", name _unit, captive _unit];
		
		if (Lifeline_RevProtect != 1) then {
		_unit setVariable ["Lifeline_allowdeath",true,true];
		diag_log "!!!!!!!!!!!!!!!! ALLOW DEATH !!!!!!!!!!!!!!!!!";
		};
	}; //[_unit, _damage, _non_handler] spawn {		

		// diag_log format ["%1 [0193] ~~~ captive %2", name _unit, captive _unit];
	// this is just for vanilla blood effect. when you setDamage it makes all body parts same damage, which seems to trigger vanilla blood effect.
	// when reviving, chunks of damage are taken off each bandage, thus lessening the vanilla blood each time.
};



Lifeline_actionID = {
	params ["_unit","_colour","_bandageno","_text"];
	_actionId = _unit addAction [format ["<t size='%4' color='#%1'>%3       ..%2</t>",_colour,_bandageno,_text,Lifeline_textsize],{params ["_target", "_caller", "_actionId", "_arguments"]; [_caller,_actionId] execVM "Lifeline_Revive\scripts\Lifeline_PlayerRevive.sqf" ; },[],8,true,true,"","_this distance cursorObject < 2.2 && lifeState cursorObject == 'INCAPACITATED' && animationstate _this find 'medic' ==-1"];
	_unit setVariable ["Lifeline_ActionMenuWounds",_actionId,true];
};



//================================================================================
//==== BANDAGE NUMBER CALCULATION. PER BODY PART

Lifeline_calcbandages = {
	params ["_unit","_dmg_unit"];

	//DEBUG
	if (Lifeline_Revive_debug) then {
		// _diagtext = " ";if !(local _unit) then {[_diagtext] remoteExec ["diag_log", 2];} else {diag_log _diagtext};
		_diagtext = format ["%1 TRACE !!!!!!!!!!!!!!!!!!! [0008] Lifeline_calcbandages !!!!!!!!!!!!!!!!!!!! _dmg_unit %2 captive %3", name _unit, _dmg_unit, captive _unit];if !(local _unit) then {[_diagtext+" REMOTE"] remoteExec ["diag_log", 2];} else {diag_log _diagtext};
		// _diagtext = " ";if !(local _unit) then {[_diagtext] remoteExec ["diag_log", 2];} else {diag_log _diagtext};
	};
	//ENDDEBUG

	// for instant death prevention, sometimes the allover damage is not updated.
	if (_dmg_unit <= Lifeline_IncapThres) then {
		// _dmg_unit = selectRandom [0.998,Lifeline_IncapThres + 0.05];
		// _dmg_unit = Lifeline_IncapThres + 0.05;
		_dmg_unit = 0.998;
		diag_log format ["%1 |============================== Lifeline_calcbandages RECTIFY _dmg_unit <= Lifeline_IncapThres | new DMG: %2 ====================================", name _unit, _dmg_unit];
		diag_log format ["%1 |============================== Lifeline_calcbandages RECTIFY _dmg_unit <= Lifeline_IncapThres | new DMG: %2 ====================================", name _unit, _dmg_unit];
		diag_log format ["%1 |============================== Lifeline_calcbandages RECTIFY _dmg_unit <= Lifeline_IncapThres | new DMG: %2 ====================================", name _unit, _dmg_unit];
		//DEBUG
		if (Lifeline_Revive_debug && Lifeline_debug_soundalert) then {
			[
				[],{
					[] spawn {
						playSound "beep_hi_1";sleep 0.1;
						playSound "beep_hi_1";sleep 0.1;
						playSound "beep_hi_1";sleep 0.1;
					};
				}
			] remoteExec ["call", 2, true];
		};
		//ENDDEBUG
	};

//DEBUG
	/* //TEST TEMPLATE
	_dmg_unit = 0.999;
	_dmg_uncon = 0.331052;
	_unc_range = 0.332052;
	_per_bandage = 0.0787168;
	// _bandage_no = 5;
	_damagesubstr = 0.133391;
	_face = 0.0514868;
	_neck = 0.0877888;
	_head = 0.0877888;
	_pelvis = 0.999;
	_abdomen = 0.999;
	_diaphrm = 0.999;
	_chest = 0.999;
	_body = 0.999;
	_arms = 0.233002;
	_hands = 0.593374;
	_legs = 0.663005; */
//ENDDEBUG
	
	// diag_log format ["Lifeline_IncapThres %1 _dmg_unit %2 _dmg_uncon %3 _unc_range %4 _per_bandage %5 _bandage_no %6 _damagesubstr %7", Lifeline_IncapThres,_dmg_unit,_dmg_uncon,_unc_range,_per_bandage,_bandage_no,_damagesubstr];

	//get damage from body parts for bandage distribution
	_face = _unit getHitPointDamage "hitface";_neck = _unit getHitPointDamage "hitneck";_head = _unit getHitPointDamage "hithead";_pelvis = _unit getHitPointDamage "hitpelvis";_abdomen = _unit getHitPointDamage "hitabdomen";_diaphrm = _unit getHitPointDamage "hitdiaphragm";_chest = _unit getHitPointDamage "hitchest";_body = _unit getHitPointDamage "hitbody";_arms = _unit getHitPointDamage "hitarms";_hands = _unit getHitPointDamage "hithands";_legs = _unit getHitPointDamage "hitlegs";_incap = _unit getHitPointDamage "incapacitated"; 
	diag_log " ";
	diag_log format ["%13 |GETHITPD    ===== FACE %1 NECK %2 HEAD %3 PELVIS %4 ABDOMEN %5 DIAPHRM %6 CHEST %7 BODY %8 ARMS %9 HANDS %10 LEGS %11 INCAP %12",_face,_neck,_head,_pelvis,_abdomen,_diaphrm,_chest,_body,_arms,_hands,_legs,_incap,name _unit];	
	diag_log " ";

	_headGHPD = _face max _neck max _head;
	_torsoGHPD = _pelvis max _abdomen max _diaphrm max _chest max _body;
	_armsGHPD = _hands max _arms;
	_legsGHPD = _legs;
	diag_log format ["%5 |[076] getHitPD      ===== headGHPD %1 torsoGHPD %2 armsGHPD %3 legsGHPD %4", _headGHPD, _torsoGHPD, _armsGHPD, _legsGHPD,name _unit];

	// TEMP CALULATION. instead of max calc like above, add similar body parts (ie add _pelvis + _abdomen). Might not be accurate, but might be useful.
	_headGHPDtemp = _face + _neck + _head;
	_torsoGHPDtemp = _pelvis + _abdomen + _diaphrm + _chest + _body;
	_armsGHPDtemp = _hands + _arms;
	_legsGHPDtemp = _legs;
	diag_log format ["%5 [076]getHitPD ADDED ===== headGHPD %1 torsoGHPD %2 armsGHPD %3 legsGHPD %4", _headGHPDtemp, _torsoGHPDtemp, _armsGHPDtemp, _legsGHPDtemp,name _unit];

	// ========when explosion
	_otherdamage = _unit getVariable ["otherdamage",0];
	// _preventdeath = _unit getVariable ["preventdeath",false];
	_explosion = false;
	//DEBUG
	if (_otherdamage > 0) then {
		diag_log format ["%1 |!!!!!!!!!!!!!!!! CHECK INDIRECT DAMAGE %1 !!!!!!!!!!!!!!!!!!", _otherdamage,name _unit];
		diag_log format ["%1 |!!!!!!!!!!!!!!!! CHECK INDIRECT DAMAGE %1 !!!!!!!!!!!!!!!!!!", _otherdamage,name _unit];
	};
	//ENDDEBUG

	//DEBUG
	// diag_log format ["645 | %1 |======== FIRE FALLING OR EXPLOSION ALTERNATE METHOD | %2 =========", name _unit, _otherdamage];
	// the getHitPointDamage doesnt seem to get damage from explosions or fire. So this will fix that. 
	// if (_torsoGHPD <= Lifeline_IncapThres && _headGHPD <= Lifeline_IncapThres && _armsGHPD <= Lifeline_IncapThres && _legsGHPD <= Lifeline_IncapThres) then {
	// if (_torsoGHPD <= Lifeline_IncapThres && _headGHPD <= Lifeline_IncapThres && (_otherdamage > 1 || _preventdeath == true)) then {
	// if (_torsoGHPD <= Lifeline_IncapThres && _headGHPD <= Lifeline_IncapThres && (_otherdamage > 1 || _preventdeath == true)) then {
	//ENDDEBUG
	if (_torsoGHPD <= Lifeline_IncapThres && _headGHPD <= Lifeline_IncapThres && (_otherdamage > 1 || (_armsGHPD < Lifeline_IncapThres && _legsGHPD < Lifeline_IncapThres))) then {
		_headGHPD = _headGHPD + selectRandom[0,1];
			if (_headGHPD < 1) then {
				_torsoGHPD = 1;
			} else {
				_torsoGHPD = _torsoGHPD + selectRandom[0,1];
			};
		_armsGHPD = _armsGHPD + selectRandom[0,1];
		_legsGHPD = _legsGHPD + selectRandom[0,1];
		_explosion = true;
		diag_log format ["%1 ************** MUST BE EXPLOSION **************. OTHER DAMAGE: %2'", name _unit, _otherdamage];
		diag_log format ["%1 ************** MUST BE EXPLOSION **************. OTHER DAMAGE: %2", name _unit, _otherdamage];
		diag_log format ["%1 ************** MUST BE EXPLOSION **************. OTHER DAMAGE: %2", name _unit, _otherdamage];
		diag_log format ["%1 ************** MUST BE EXPLOSION **************. OTHER DAMAGE: %2", name _unit, _otherdamage];
	};

	if (_headGHPD >= .998) then {_headGHPD = 1};
	if (_torsoGHPD >= .998) then {_torsoGHPD = 1};
	if (_armsGHPD >= .998) then {_armsGHPD = 1};
	if (_legsGHPD >= .998) then {_legsGHPD = 1};

	diag_log format ["%2 | ====TOT %1",(damage _unit), name _unit];
	diag_log format ["%5 |[115] getHitPD    ===== headGHPD %1 torsoGHPD %2 armsGHPD %3 legsGHPD %4", _headGHPD, _torsoGHPD, _armsGHPD, _legsGHPD,name _unit];

	//============================================================================================================

	_bullethits = (_unit getVariable ["Lifeline_bullethits",0]); 
	_armlegswitch = false;

	//if only arms and legs are hit then reduce damage
	// if (_headGHPD < 0.4 && _torsoGHPD < 0.4 && _dmg_unit > 0.9) then {
	if (_headGHPD < 0.998 && _torsoGHPD < 0.998 && _dmg_unit > 0.9) then {
		diag_log format ["%1 | ====LEGS OR ARMS ONLY====", name _unit];
		// _dmg_unit =  _dmg_unit * selectRandom[0.7,0.75,0.8,0.85]; 
		_dmg_unit = _dmg_unit min ( ((0.998 - Lifeline_IncapThres)/2)+Lifeline_IncapThres); // limit damage to no more than half range above Lifeline_IncapThres
		diag_log format ["%1 |======================== _dmg_unit %2 ==================",name _unit, _dmg_unit];
		// _dmg_unit = ( ((0.998 - Lifeline_IncapThres)/3.5)+ Lifeline_IncapThres); // limit damage to no more than half range above Lifeline_IncapThres
		_armlegswitch = true;
		diag_log format ["%1 |======================== _dmg_unit %2 ==================",name _unit, _dmg_unit];
	};
	//============================================================================================================

	_dmg_uncon = (_dmg_unit - Lifeline_IncapThres); // Creates an unconcious damage score between 0.0 and 0.2, which is the damage difference over 0.8. e.g: if damage _unit = 0.83, then _dmg_uncon = 0.03
	_unc_range = 0.998 - Lifeline_IncapThres; // this is the range for unconcois					  
	_per_bandage = _unc_range / Lifeline_BandageLimit;  //   divides 0.2 up into bandage max number. This creates a per bandage division of 0.2
	// _bandagefull = _dmg_uncon / _per_bandage; // full number including decimal. 

	// CALCULATION METHOD ONE. CEILING - ROUND UP. Ends up with more bandages generally
	// _bandage_no = ceil(_dmg_uncon / _per_bandage); //assign number of bandages
	// if (_bandage_no > Lifeline_BandageLimit) then {_bandage_no = Lifeline_BandageLimit};

	// CALCULATION METHOD TWO. ROUND TO NEAREST WHOLE NUMBER
	_bandage_no = round(_dmg_uncon / _per_bandage); 
	if (_bandage_no == 0) then {_bandage_no = 1};
	if (_bandage_no > Lifeline_BandageLimit) then {_bandage_no = Lifeline_BandageLimit};


	_damagesubstr = (_dmg_unit - _unc_range) / _bandage_no; //this calculates the amount of damage to substract each bandage. incap wakes up at 0.2, so only (current damage minus 0.2) divided by num of bandages
	_damagesubstr = _damagesubstr + 0.000001; //added a tiny fraction - sometimes the calculation is a fraction off due to rounding errors. This fixes it.

	//=========================================================================================

	diag_log format ["Lifeline_IncapThres %1 _dmg_unit %2 _dmg_uncon %3 _unc_range %4 _per_bandage %5 _bandage_no %6 _damagesubstr %7", Lifeline_IncapThres,_dmg_unit,_dmg_uncon,_unc_range,_per_bandage,_bandage_no,_damagesubstr];

	//if only arms / legs are hit and bandages calculated are more than bullet hits then reduce bandages to number of bullet hits.
	//DEBUG
	// if (_headGHPD < 0.4 && _torsoGHPD < 0.4 && _bandage_no > _bullethits) then {
	// if (_headGHPD < 1 && _torsoGHPD < 1 && (_bandage_no > _bullethits && _bullethits > 0)) then {
	// if (_headGHPD < 1 && _torsoGHPD < 1 && ((_bandage_no > _bullethits && _bullethits > 0) || (_bandage_no < _bullethits)) ) then {
	// if (_headGHPD < 0.998 && _torsoGHPD < 0.998 && ((_bandage_no > _bullethits && _bullethits > 0)) ) then { // better calculation. e.g. 5 shots sometimes only have 1 bandage, but its still minor damage.
	//ENDDEBUG
	if (_headGHPD < 0.998 && _torsoGHPD < 0.998 && _armlegswitch == false && ((_bandage_no > _bullethits && _bullethits > 0)) ) then { // better calculation. e.g. 5 shots sometimes only have 1 bandage, but its still minor damage.
		if (_bullethits > Lifeline_BandageLimit) then {
			_bandage_no = Lifeline_BandageLimit;
			diag_log format ["%1 | ====MATCH TO BULLETS==== bullets: %3 |_bandage_no = Lifeline_BandageLimit| bandage no %2", name _unit,_bandage_no,_bullethits];
		} else {
			_bandage_no = _bullethits;
			diag_log format ["%1 | ====MATCH TO BULLETS==== bullets: %3 |_bandage_no = _bullethits| bandage no %2", name _unit,_bandage_no,_bullethits];
		};
	};

	//=====calc bandages across parts

	//damage under 0.1 is just noise, make it zero, for cleaner bandage calculation
	if (_headGHPD <= 0.1) then {_headGHPD = 0}; if (_torsoGHPD <= 0.1) then {_torsoGHPD = 0};
	if (_armsGHPD <= 0.1) then {_armsGHPD = 0}; if (_legsGHPD <= 0.1) then {_legsGHPD = 0};

	//spread bandages across parts according to damage
	_totalGHPD = _headGHPD + _torsoGHPD + _armsGHPD + _legsGHPD;
	_bandg_headGHPD = (_headGHPD/_totalGHPD) * _bandage_no;
	_bandg_torsoGHPD = (_torsoGHPD/_totalGHPD) * _bandage_no;
	_bandg_armsGHPD = (_armsGHPD/_totalGHPD) * _bandage_no;
	_bandg_legsGHPD = (_legsGHPD/_totalGHPD) * _bandage_no;

	//Round to nearest whole number, unless between 0.1 - 0.5, then use 'ceil' instead (round upwards). only add to array if  > 0.1. 
	_bandg_total_array = [];

	_randj = selectRandom [1,2];
	if (_randj == 1) then {
		if (_bandg_headGHPD > 0.1) then {_bandg_total_array = _bandg_total_array + [[if (_bandg_headGHPD < 0.5) then {ceil _bandg_headGHPD} else {round _bandg_headGHPD}, "Head:",_headGHPD]];};
		if (_bandg_torsoGHPD > 0.1) then {_bandg_total_array = _bandg_total_array + [[if (_bandg_torsoGHPD < 0.5) then {ceil _bandg_torsoGHPD} else {round _bandg_torsoGHPD}, "Torso:",_torsoGHPD]];};
	} else {
		if (_bandg_torsoGHPD > 0.1) then {_bandg_total_array = _bandg_total_array + [[if (_bandg_torsoGHPD < 0.5) then {ceil _bandg_torsoGHPD} else {round _bandg_torsoGHPD}, "Torso:",_torsoGHPD]];};
		if (_bandg_headGHPD > 0.1) then {_bandg_total_array = _bandg_total_array + [[if (_bandg_headGHPD < 0.5) then {ceil _bandg_headGHPD} else {round _bandg_headGHPD}, "Head:",_headGHPD]];};
	};
	if (_bandg_armsGHPD > 0.1) then {_bandg_total_array = _bandg_total_array + [[if (_bandg_armsGHPD < 0.5) then {ceil _bandg_armsGHPD} else {round _bandg_armsGHPD}, "Arm:",_armsGHPD]];};
	if (_bandg_legsGHPD > 0.1) then {_bandg_total_array = _bandg_total_array + [[if (_bandg_legsGHPD < 0.5) then {ceil _bandg_legsGHPD} else {round _bandg_legsGHPD}, "Leg:",_legsGHPD]];};

	// _dmg_total_array = [[_headGHPD, "head"], [_torsoGHPD, "tors"], [_armsGHPD, "arms"], [_legsGHPD, "legs"]]; 
	_dmg_total_array = [[_headGHPD, "Head:"], [_torsoGHPD, "Torso:"], [_armsGHPD, "Arm:"], [_legsGHPD, "Leg:"]]; 
	_dmg_total_array sort false;
	diag_log format ["%3 | [643]=============== DAMAGE %1 ============= no bandages %2", _dmg_total_array, _bandage_no, name _unit]; 

	 // Loop through the array and accumulate the number of bandages
	_bandg_total = 0;
	{_bandg_total = _bandg_total + (_x select 0); } forEach _bandg_total_array;

	//test diff sorting methods
	_bandg_total_array sort false;
	diag_log format ["%3 | [651]============= BANDAGES %1 ============= TOTAL %2", _bandg_total_array, _bandg_total, name _unit]; 
	// _bandg_total_array = [_bandg_total_array, [], {_x select 2}, "DESCEND"] call BIS_fnc_sortBy;
	// diag_log format ["============= BANDAGES %1 ============= TOTAL %2", _bandg_total_array, _bandg_total]; 

	//sometimes after distributing bandages, there are fractions and they throw off total number. This checks difference
	_diff = _bandg_total - _bandage_no; diag_log format ["%2 |====== DIFF %1", _diff, name _unit];

	//this just checks if there are 3 body parts in a row with same number of bandages, or 2 in a row. This is so distributing bandages can be even.
	_threeeven = false; _twoeven = false;
	if (count _bandg_total_array >=2) then {
		if ((_bandg_total_array select 0 select 0) == (_bandg_total_array select 1 select 0) && (_bandg_total_array select 0 select 0) == (_bandg_total_array select 2 select 0)) then {_threeeven = true;	};
		if ((_bandg_total_array select 0 select 0) == (_bandg_total_array select 1 select 0) && (_bandg_total_array select 0 select 0) != (_bandg_total_array select 2 select 0)) then {_twoeven = true;	};
	};

	//add counter for loop
	_count = _diff;
	if (_diff < 0) then {_count = _diff * -1;};

	// this checks to see a pattern - 3 body parts with equal number of bandages or 2 body parts with equal number. For correcting rounding erros later below by adding or subtracting a bandage.
	_countarr = []; _countarr2 = [];
	if (_threeeven == true) then {_countarr = [2,1,0];_countarr2 = [0,1,2]};
	if (_twoeven == true) then {_countarr = [1,0,1];_countarr2 = [0,1,0]};
	if (_threeeven == false && _twoeven == false) then {_countarr = [0,1,0];_countarr2 = [1,0,1]};

	//========= add or subract a bandage/s to fix rounding calucation throwing off total bandages
	
	//add and subtract version
	if (_diff != 0) then {
		_counter = 0;
		_posneg = 1; //positive or negative - either subtract one or add one
		if (_diff < 0) then {_countarr = _countarr2; _posneg = -1}; 
		while {_counter < _count} do {
			_bandg_total_array set [(_countarr select _counter), [(_bandg_total_array select (_countarr select _counter) select 0) - _posneg, (_bandg_total_array select (_countarr select _counter) select 1), (_bandg_total_array select (_countarr select _counter) select 2)]];
			_counter = _counter + 1;
		};
	};
	//subtract only version
	// if (_diff > 0) then {
		// _counter = 0;
		// while {_counter < _count} do {
			// _bandg_total_array set [(_countarr select _counter), [(_bandg_total_array select (_countarr select _counter) select 0) - 1, (_bandg_total_array select (_countarr select _counter) select 1), (_bandg_total_array select (_countarr select _counter) select 2)]];
			// _counter = _counter + 1;
		// };
	// };

	 // Loop through the array and accumulate the numbers
	if (_diff !=0 ) then {
		_bandg_total = 0;
		{_bandg_total = _bandg_total + (_x select 0);} forEach _bandg_total_array;
		diag_log format ["%3 |============= BANDAGES %1 ============= TOTAL %2", _bandg_total_array, _bandg_total, name _unit]; 
	};
	//============================================================

	_unit setDamage _dmg_unit; //set total damage to _dmg_unit, to fix any issues if it was under [02:22 16/06/2024]
	_unit setVariable ["otherdamage",0,true];
	_unit setVariable ["lastotherdamage",0,true];

	[_bandg_total,_per_bandage,_damagesubstr,_bandg_total_array]
};



//============================================================================================
//==== INJURY NAMES AND COLOUR, ON SEVERITY SCALE 1-4 (called _quads. 4 is highest damage)

Lifeline_bandage_text = {
	params ["_bandage_no", "_unit", "_bandg_total_array", "_cpr", "_non_handler"];

	//DEBUG
	if (Lifeline_Revive_debug) then {
		// _diagtext = " ";if !(local _unit) then {[_diagtext] remoteExec ["diag_log", 2];} else {diag_log _diagtext};
		_diagtext = format ["%1 TRACE !!!!!!!!!!!!!!!!!!! [0324] Lifeline_bandage_text !!!!!!!!!!!!!!!!!!!! _bandage_no %2 _cpr %3 _non_handler %4 captive %5", name _unit, _bandage_no, _cpr, _non_handler, captive _unit];if !(local _unit) then {[_diagtext+" REMOTE"] remoteExec ["diag_log", 2];} else {diag_log _diagtext};
		// _diagtext = " ";if !(local _unit) then {[_diagtext] remoteExec ["diag_log", 2];} else {diag_log _diagtext};
	};
	//ENDDEBUG
	
	diag_log format ["%3 |bandage_text============= BANDAGES %1 ============= TOTAL %2", _bandg_total_array, _bandage_no, name _unit]; 
//DEBUG
	//choices of colour for revive action menu - TO DECIDE FINAL PALLETE LATER
	_pallet01 = ["E34234","E6615B","E8816F","E9927A"];
	_pallet02 = ["F94545","F45F57","EE7868","E9927A"];// red to soft red
	_pallet03 = ["FF3333","FB5E5F","F69994","F9CAA7"]; //red to soft sandy
//ENDDEBUG
	_pallet04 = ["F94545","F97166","F99E86","F9CAA7"];
//DEBUG
	_pallet05 = ["FF3333","FC5553","F97774","F69994"];//orange red  to pink                          //>
	_pallet06 = ["F94545","F8615F","F77D7A","F69994"];                                              //>
	_pallet07 = ["FF3333","FF5B3D","FF8246","FAA550"];// orange red to orange/yellow  //GOOD RED //but not sure about other colours
	_pallet08 = ["F94545","F96549","FA854C","FAA550"];
	_pallet09 = ["FF3333","FF4D22","FF6611","FF8000"];// orange red to REVIVE                         //>
	_pallet10 = ["FF8000","FF9A30","FEB460","FECE90"];// REVIVE to softer
	_pallet11 = ["F94545","FB592E","FD6C17","FF8000"];
	_pallet12 = ["F93B3B","F9673B","F9943B","F9C03B"]; //orange red to yellow
	_pallet13 = ["F94545","F96E42","F9973E","F9C03B"];
	_pallet14 = ["F93B3B","C26730","8A9225","53BE1A"]; //orange red to  green
	_pallet15 = ["F93B3B","D45834","AF752C","8A9225"]; //orange red to  green //naa
	_pallet16 = ["F94545","D45F3A","AF7830","8A9225"];
	_pallet17 = ["F94545","FA7568","FCA68A","FDD6AD"];
	_pallet18 = ["F93B3B","FA6F61","FCA287","FDD6AD"];
	_pallet19 = ["F2003C","F64762","F98F87","FDD6AD"];
	_pallet20 = ["E8816F","EE9982","F3B294","F9CAA7"];//red to skin colour
	_pallet21 = ["F94545","F97166","F99E86","F9CAA7"];     // :)
	_pallet22 = ["FF66FF","FF88FF","FFAAFF","FFCCFF"]; // purples                                      //>

	 // FAVS so far. _pallet05, _pallet06, _pallet09, _pallet22
//ENDDEBUG

	_colour = _pallet04; //just replace variable here

	_unconcious = false;
	_bloodneeded = false;
	_passtrig = false; //triggered when a quadrant, _quad, is passed
	_unitwounds = [];
	_textcolour = "";
	_text = "";
	_part = "";

	//just for calc of anim, a severity of four levels (hence 'quad')
	_quadstored = (4 / Lifeline_BandageLimit) * _bandage_no;
	_quadstored = ceil(_quadstored);
	_unit setVariable ["quadstored",_quadstored,true];

	while {_bandage_no > 0} do {

		_part = _bandg_total_array select 0 select 1;
		_value = _bandg_total_array select 0 select 0;
		_count = count _bandg_total_array;
			
		
		if (_count == 0) exitWith {diag_log "====exit loop, count = 0";};
		// diag_log format ["==== bandage text loop top | part %1 value %2 count %3 _bandage_no %4", _part, _value, _count, _bandage_no];
		// diag_log format ["bandage no %1", _bandage_no];

		_quad = (4 / Lifeline_BandageLimit) * _bandage_no;
		_quad = ceil(_quad); // _quad is a variable to divide serverity of damage into 4 levels for change of colour of the addaction text and also allocation of injury names by severity.		

		if (_quad == 4) then {	
			_bloodneeded = true;
			_unconcious = true;
			_passtrig = true;
			_textcolour = _colour select 0;
			if !(_non_handler) then {
				if (_cpr == true) exitWith { 
					// diag_log format ["801 bandage no %1", _bandage_no];		
					_text = "CRITICAL: Perform CPR";
					_bandage_no = _bandage_no + 1;
					_value = _value + 1;
					_textcolour = "C70039";
					// diag_log format ["804 bandage no %1", _bandage_no];	
				};
				
				if (_part == "Head:") exitWith {
					_text = selectRandom[ "Neck Wound", "Neck Wound", "Neck Wound", "Scalp Wound", "Broken Jaw", "Broken Jaw", "Broken Jaw", "Scalp Wound", "Scalp Wound", "Deep Scalp Cut", "Severe Gash", "Severe Laceration",  "Severe Avulsion", "Severe Laceration", "Severe Avulsion", "Severe Laceration", "Concussion", "Concussion", "Fractured Cranium", "Fractured Cranium", "Fractured Cranium", "Severe Gash", "Severe Gash", "Severe Gash"];
				};
				if (_part == "Torso:") exitWith {
					_text = selectRandom[ "Fractured Shoulder", "Fractured Shoulder", "Fractured Shoulder", "Fractured Collarbone", "Fractured Collarbone", "Fractured Sternum", "Severe Puncture", "Severe Laceration",  "Severe Avulsion", "Severe Laceration", "Severe Avulsion", "Severe Laceration", "Fractured Pelvis", "Severe Gash", "Severe Gash", "Severe Gash"];
				};
				_text = selectRandom[ "Severe Puncture", "Severe Laceration",  "Severe Avulsion", "Severe Laceration", "Severe Avulsion", "Severe Laceration", "Severe Gash", "Severe Gash", "Severe Gash"];
			} else {
			_text = "Unknown Injury";
			};
		};

		if (_quad == 3) then {
			_unconcious = true;
			_passtrig = true;
			_textcolour =  _colour select 1;
			if !(_non_handler) then {
				if (_part == "Head:") exitWith {
					_text = selectRandom[ "Broken Nose", "Broken Nose", "Broken Nose", "Broken Nose", "Neck Gash", "Neck Wound", "Neck Wound", "Scalp Wound", "Scalp Wound", "Cheek Wound", "Cheek Wound", "Smashed Teeth", "Smashed Teeth", "Smashed Teeth", "Severe Laceration",  "Severe Avulsion", "Severe Laceration", "Severe Avulsion", "Severe Laceration", "Concussion", "Concussion", "Fractured Scull", "Deep Gash", "Deep Gash", "Deep Gash"];
				};
				if (_part == "Torso:") exitWith {
					_text = selectRandom[ "Fractured Sternum", "Severe Puncture", "Severe Laceration",  "Severe Avulsion", "Severe Laceration", "Severe Avulsion", "Severe Laceration", "Fractured Pelvis", "Deep Gash", "Deep Gash", "Deep Gash"];
				};
				_text = selectRandom["Penetration Wound", "Avulsion", "Deep Laceration", "Deep Puncture", "Moderate Avulsion", "Deep Avulsion","Avulsion", "Fracture", "Deep Laceration", "Compound Fracture", "Deep Puncture", "Severe Burns And Cuts", "Limb Fracture", "Moderate Avulsion", "Deep Avulsion", "Limb Fracture", "Deep Gash", "Deep Gash", "Deep Gash"];	
			} else {
			_text = "Unknown Injury";
			};
		};

		if (_quad == 2) then {
			_passtrig = true;
			_textcolour = _colour select 2;
			if !(_non_handler) then {
				if (_bandage_no == 2 && _bloodneeded == true) exitWith {
					_text = "Inject Blood IV";
				};
				if (_part == "Head:" || _part == "Torso:") exitWith {
					_text = selectRandom["Gash Wound","Gash Wound","Gash Wound","Lacerations", "Moderate Wound", "Moderate Abrasions", "Lacerations", "Moderate", "Moderate Abrasions", "Moderate Gash", "Moderate Gash", "Moderate Gash" ];
				};
					_text = selectRandom["Lacerations", "Moderate Wound", "Moderate Abrasions", "Penetration Wound","Penetration Wound","Penetration Wound","Lacerations", "Moderate Gash", "Limb Fracture", "Limb Fracture", "Moderate Abrasions", "Moderate Gash", "Moderate Gash", "Moderate Gash" ];
			} else {
			_text = "Unknown Injury";
			};
		};	

		if (_quad == 1) then {
			_textcolour =  _colour select 3;
			if !(_non_handler) then {
				if (_bandage_no == 2 && _bloodneeded == true) exitWith {
					_text = "Inject Blood IV";
				};
				if (_bandage_no == 1 && _unconcious == true ) exitWith {
					_text = selectRandom["Inject Epinephrine","Inject Epinephrine","Inject Epinephrine","Inject Morphine"];
				};
				if (_part == "Head:" || _part == "Torso:") exitWith {
					_text = selectRandom["Abrasions", "Avulsions", "Heavy Bruising And Cuts", "Burns And Abrasions", "Contusion", "Inject Morphine", "Inject Morphine", "Moderate Graze", "Moderate Graze", "Moderate Graze"];
				};
				if (_passtrig == false) then {
					_text = selectRandom[ "Abrasions", "Avulsion", "Moderate Graze", "Moderate Graze", "Moderate Graze"]; 
					_passtrig = true;
				} else {
					_text = selectRandom["Sprained Ligament","Abrasions", "Avulsions", "Heavy Bruising And Cuts", "Sprain", "Treat Burns And Abrasions", "Sprained Ligament", "Contusion", "Fix Dislocated Joint", "Inject Morphine", "Inject Morphine", "Moderate Graze", "Moderate Graze", "Moderate Graze"];
				};
			} else {
			_text = "Unknown Injury";
			};
		};
		// diag_log format ["858 bandage no %1", _bandage_no];	
		if (_text != "Inject Blood IV" && _text != "Inject Morphine" && _text != "Inject Epinephrine" && _text != "Treat Shock" && _text != "CRITICAL: Perform CPR") then {
			_text = _part + " " + _text;
		};

		// diag_log format ["%6 ==== bndge text loop botm | part %1 text %5 value %2 count %3 _bandage_no %4", _part, _value, _count, _bandage_no, _text, name _unit];
		_colourtext = [_text, _textcolour];
		_bandage_no = _bandage_no - 1;
		_unitwounds = [_colourtext] + _unitwounds;
		_value = _value - 1;
		// diag_log format ["866 bandage no %1", _bandage_no];	
		// diag_log format ["== bandage text bottom | part %1 value %2 count %3 _bandage_no %4", _part, _value, _count, _bandage_no];

		if (_value == 0) then {
			_bandg_total_array deleteAt 0;
		};
		if (_cpr == false && _value != 0) then {
			_bandg_total_array set [0, [_value, (_bandg_total_array select 0) select 1, (_bandg_total_array select 0) select 2]];
		};
		_cpr = false;
	}; // while do

	diag_log format ["%2 |==== UNIT WOUND ARRAY %1 no# wounds %3 ====[495]", _unitwounds, name _unit, count _unitwounds];
	_unit setVariable ["unitwounds", _unitwounds, true];
};



Lifeline_bandage_addAction = {
	params ["_unit","_non_handler"];
	
	//DEBUG
	if (Lifeline_Revive_debug) then {
		// _diagtext = " ";if !(local _unit) then {[_diagtext] remoteExec ["diag_log", 2];} else {diag_log _diagtext};
		_diagtext = format ["%1 TRACE !!!!!!!!!!!!!!!!!!! [0499] Lifeline_bandage_addAction !!!!!!!!!!!!!!!!!!!! _non_handler %2 captive %3", name _unit, _non_handler, captive _unit];if !(local _unit) then {[_diagtext+" REMOTE"] remoteExec ["diag_log", 2];} else {diag_log _diagtext};
		// _diagtext = " ";if !(local _unit) then {[_diagtext] remoteExec ["diag_log", 2];} else {diag_log _diagtext};
	};
	//ENDDEBUG

	_dmgyo = damage _unit;
	diag_log format ["%1 | 858 ==== Lifeline_bandage_addAction dmg %2", name _unit, _dmgyo];
	_calcbandages = [_unit,_dmgyo] call Lifeline_calcbandages;
	_bandageno = _calcbandages select 0;											
	_damagesubstr = _calcbandages select 2;
	_bandg_total_array = _calcbandages select 3;
	_bandage_no = _bandageno; // this is just temp due to laziness 

	diag_log "                                                                                      ";
	diag_log format ["kkkkkkkkkkkkkkkkkkkk|%1| CALC BANDAGE %2 | DMG UNIT %3 | SUBTR %4 | SUBTR.DEDUCT %6 count %5 kkkkkkkkkkkkkkkkkkkkkkkkkkk", name _unit, _bandageno, damage _unit, _damagesubstr,  _unit getVariable ["DHcount",0], damage _unit / _bandage_no];
	diag_log format ["kkkkkkkkkkkkkkkkkkkk|%1| CALC BANDAGE %2 | DMG UNIT %3 | SUBTR %4 | SUBTR.DEDUCT %6 count %5 kkkkkkkkkkkkkkkkkkkkkkkkkkk", name _unit, _bandageno, damage _unit, _damagesubstr,  _unit getVariable ["DHcount",0], damage _unit / _bandage_no];
	diag_log "                                                                                      ";
	_unit setVariable ["damagesubstr", _damagesubstr, true];

	
	_colour = "";
	_text = "";
	_cpr = false; 
	_randomNumber = 0;

	
	if (Lifeline_CPR_likelihood == 100) then {
		_randomNumber = 100 //save CPU maybe? probably not lol.
		} else {
		_randomNumber = floor (random 101);
		diag_log format ["CPR ROLL DICE random number %1. %2 ", _randomNumber, if (_randomNumber <= Lifeline_CPR_likelihood) then {"SUCCESS"} else {"FAIL"}];
	};		
	
	//DEBUG
	// if (damage _unit > _cprlevel && selectRandom[1,2] == 1) then {												
	// if ((Lifeline_InstantDeath == 0 && damage _unit >= 0.998 && selectRandom[1,2,3,4] == 1) || (Lifeline_InstantDeath == 1 && damage _unit > 0.97 && selectRandom[1,2,3,4] == 1) || (Lifeline_InstantDeath == 2 && damage _unit > 0.97 )) then {	
	//ENDDEBUG
	if (Lifeline_CPR_likelihood > 0) then {
		if ((Lifeline_InstantDeath == 0 && damage _unit >= 0.998 && _randomNumber <= Lifeline_CPR_likelihood) || (Lifeline_InstantDeath == 1 && damage _unit > 0.97 && _randomNumber <= Lifeline_CPR_likelihood) || (Lifeline_InstantDeath == 2 && damage _unit > 0.97 )) then {											
		// if (damage _unit >= 0.998) then {		// for testing									
			_cpr = true;
			//turn of autorevive
			_unit setVariable ["Lifeline_autoRecover",false,true];	diag_log format ["%1 [0662]!!!!!!!!! change var Lifeline_autoRecover = false !!!!!!!!!!!!!", name _unit];
			if (Lifeline_CPR_less_bleedouttime != 100) then {
				_bleedouttime = _unit getVariable ["LifelineBleedOutTime", 0];
				// _bleedouttime = _bleedouttime - (Lifeline_BleedOutTime / 3);
				// _bleedouttime = _bleedouttime - (Lifeline_BleedOutTime * (Lifeline_CPR_less_bleedouttime / 100));
				_bleedouttime = time + (Lifeline_BleedOutTime * (Lifeline_CPR_less_bleedouttime / 100));
				_unit setVariable ["LifelineBleedOutTime", _bleedouttime, true];diag_log format ["%1 [684]!!!!!!!!! change var LifelinePairTimeOut = adjusted for CPR (%2) !!!!!!!!!!!!!", name _unit,_bleedouttime];
			};
		};
	};
	if !(_cpr) then {
		_unit setVariable ["LifelineBleedOutTime", time + Lifeline_BleedOutTime, true]; //add again to start fresh.
		diag_log format ["%1 [690]!!!!!!!!! change var LifelinePairTimeOut = %2 !!!!!!!!!!!!! //add again to start fresh. NOT CPR", name _unit, time + Lifeline_BleedOutTime];
	};
	
	//add marker 
	// if (Lifeline_Map_mark) then {[_unit,_cpr] call Lifeline_Incap_Marker;};

	// moved here, start display
	if ((Lifeline_HUD_distance == true || Lifeline_cntdwn_disply != 0) && isPlayer _unit) then {
		_seconds = Lifeline_cntdwn_disply;
		if (lifeState _unit == "INCAPACITATED" && !(_unit getVariable ["Lifeline_countdown_start",false]) 
			&& Lifeline_cntdwn_disply != 0 && Lifeline_RevMethod != 3 && Lifeline_HUD_distance == false) then {
			_unit setVariable ["Lifeline_countdown_start",true,true];
			[[_unit,_seconds], Lifeline_countdown_timer2] remoteExec ["spawn",_unit, true];
		}; 
		if (lifeState _unit == "INCAPACITATED" && !(_unit getVariable ["Lifeline_countdown_start",false])) then {
			_unit setVariable ["Lifeline_countdown_start",true,true];
			[[_unit,_seconds], Lifeline_countdown_timer2] remoteExec ["spawn",_unit, true];
		};
	};
		

	[_bandageno,_unit,_bandg_total_array,_cpr,_non_handler] call Lifeline_bandage_text;

	[_unit] call Lifeline_text_addAction;

	diag_log format ["%1 |=================================JJ CALC BANDAGES %2 =================================", name _unit, _bandage_no];

	diag_log format ["%1 |===================================JJ BULLET HITS %2 =================================", name _unit, (_unit getVariable ["Lifeline_bullethits",0])];
	// diag_log " ";
	// diag_log " ";
	// diag_log " ";
	// diag_log " ";
};



Lifeline_text_addAction = {
	params["_unit"];
	
	//DEBUG
	if (Lifeline_Revive_debug) then {
		// _diagtext = " ";if !(local _unit) then {[_diagtext] remoteExec ["diag_log", 2];} else {diag_log _diagtext};
		_diagtext = format ["%1 TRACE !!!!!!!!!!!!!!!!!!! [0553] Lifeline_text_addAction !!!!!!!!!!!!!!!!!!!! captive %2", name _unit, captive _unit];if !(local _unit) then {[_diagtext+" REMOTE"] remoteExec ["diag_log", 2];} else {diag_log _diagtext};
		// _diagtext = " ";if !(local _unit) then {[_diagtext] remoteExec ["diag_log", 2];} else {diag_log _diagtext};
	};
	//ENDDEBUG

	_unitwounds =  _unit getVariable ["unitwounds",[["Inject Morphine","F9CAA7"]]];
	_bandageno = count _unitwounds;
	_unit setVariable ["num_bandages",_bandageno,true];
	_text = _unit getVariable "unitwounds" select (_bandageno -1) select 0;
	_colour = _unit getVariable "unitwounds" select (_bandageno -1) select 1;
	
	diag_log format ["%2 |==== UNIT WOUND ARRAY %1 no wounds %3 ====[361] local: %4", _unitwounds, name _unit, _bandageno, name player];

	if (_text != "CRITICAL: Perform CPR") then {
	_text = format ["%1       ..%2", _text, _bandageno];
	};

	// diag_log format ["500====BANDAGE VAR CHECK _var: %1 setVariable: %2", _bandageno, _unit getVariable ["num_bandages",false]];
																					
	diag_log format ["%1 !!!!!!!!!! Lifeline_RevActionAdded %2", name _unit, (_unit getVariable ['Lifeline_RevActionAdded',false])];

		// === OLD METHOD IF. Using "" to replace action menu when not used.
	if !(_unit getVariable ["Lifeline_RevActionAdded",false]) then { 
			_unit setVariable ["Lifeline_RevActionAdded",true,true];	
			[[_unit,_colour,_bandageno,_text],
				{params ["_unit","_colour","_bandageno","_text"];
				   _actionId = _unit addAction [format ["<t size='%3' color='#%1'>%2</t>",_colour,_text,Lifeline_textsize],{params ["_target", "_caller", "_actionId", "_arguments"]; [_caller,_actionId] execVM "Lifeline_Revive\scripts\Lifeline_PlayerRevive.sqf" ; },[],8,true,true,"","_target == cursorObject && _this distance cursorObject < 2.2 && lifeState cursorObject == 'INCAPACITATED' && animationstate _this find 'medic' ==-1"];
					_unit setVariable ["Lifeline_ActionMenuWounds",_actionId,true];
				}] remoteExec ["call", 0, true];
			//DEBUG
			if (Lifeline_Revive_debug) then {			
				// _diagtext = " ";if !(local _unit) then {[_diagtext] remoteExec ["diag_log", 2];} else {diag_log _diagtext};
				_diagtext = format ["%1 TRACE !!!!!!!!!!!!!!!!!!! [0590] Lifeline_RevActionAdded [addAction] !!!!!!!!!!!!!!!!!!!! captive %2", name _unit,captive _unit];if !(local _unit) then {[_diagtext] remoteExec ["diag_log", 2];} else {diag_log _diagtext};
				// _diagtext = " ";if !(local _unit) then {[_diagtext] remoteExec ["diag_log", 2];} else {diag_log _diagtext};
			}; //ENDDEBUG
		} else {
			_actionId = _unit getVariable ["Lifeline_ActionMenuWounds",false];
			[[_unit,_actionId,_colour,_bandageno, _text],
				{params ["_unit", "_actionId", "_colour","_bandageno","_text"];
				_unit setUserActionText [_actionId, format ["<t size='%3' color='#%1'>%2</t>",_colour,_text, Lifeline_textsize]];
				}] remoteExec ["call", 0, true];
			//DEBUG
			if (Lifeline_Revive_debug) then {
				// _diagtext = " ";if !(local _unit) then {[_diagtext] remoteExec ["diag_log", 2];} else {diag_log _diagtext};
				_diagtext = format ["%1 TRACE !!!!!!!!!!!!!!!!!!! [0600] Lifeline_RevActionAdded [setUserActionText] !!!!!!!!!!!!!!!!!!!! captive %2", name _unit, captive _unit];if !(local _unit) then {[_diagtext+" REMOTE"] remoteExec ["diag_log", 2];} else {diag_log _diagtext};
				// _diagtext = " ";if !(local _unit) then {[_diagtext] remoteExec ["diag_log", 2];} else {diag_log _diagtext};
			}; //ENDDEBUG
		};		
};



// this is a powercurve over incap threshold. Can change the curve to affect number of bandages. 
// _powerValue = 1 mean no effect (straight line).  1.1 - 1.9 is recomended range for _powerValue
powerCurve = {
	params ["_damage","_powerValue","_threshold"];
	_processedDamage = 0;
	_normalizedDamage = 0;
	// Define the threshold above which the curve will apply 
	// _threshold = 0.8; 
	// _powerValue = 1.5; // You can adjust this value to control the curve //EDIT now a param
	if (_damage > _threshold) then { 
		_normalizedDamage = (_damage - _threshold) / (1 - _threshold); 
		_processedDamage = _threshold + (1 - _threshold) * _normalizedDamage ^ _powerValue; 
		// diag_log format ["==POWERCURVE damage %1 | %2", _damage, _processedDamage];
	} else { 
		_processedDamage = _damage; 
		// diag_log format ["==ELSE POWERCURVE damage %1 | %2", _damage, _processedDamage];
	}; 
	_processedDamage
};



Lifeline_Medic_Anim_and_Revive = {
		params ["_incap","_medic","_EnemyCloseBy","_voice","_B"];

		_bleedoutbaby = "LifelineBleedOutTime";
		_pairtimebaby = "LifelinePairTimeOut";			
		_exit = false;		

		if (lifestate _incap == "INCAPACITATED") then {

					if (Lifeline_RevMethod == 1 || Lifeline_BandageLimit == 1) then {
						_incap setVariable ["damagesubstr", damage _incap, true]; // ADDED to be compatible with new bandage anim method. even though its only 1 revive action
						_incap setVariable ["num_bandages",1,true];				// ADDED to be compatible with new bandage anim method. even though its only 1 revive action
					};														

					_bandages = _incap getVariable ["num_bandages",0];

					//usually takes 5 seconds for wound and injury data for incap to be calculated. This prevents medic trying to bandage before then.
					if (_bandages == 0 && Lifeline_RevMethod == 2 && Lifeline_BandageLimit > 1) then {
						_count = 7;
						while {_count > 0} do {
						diag_log format ["%1 | %2 uuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuu NO BANDAGE WAIT %3 uuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuu", name _incap, name _medic, _count];	
						_incap setVariable [_pairtimebaby, (_incap getvariable _pairtimebaby) + 1, true]; // add 5 seconds to incap revivetimer
						_medic setVariable [_pairtimebaby, (_medic getvariable _pairtimebaby) + 1, true]; // add 5 seconds to medic revivetimer
						_incap setVariable [_bleedoutbaby, (_incap getvariable _bleedoutbaby) + 1, true];  
						_bandages = _incap getVariable ["num_bandages",0];
						if (_bandages != 0 ) exitWith {diag_log "uuuuuuuuuuuuuuuu exit timer loop, bandage number now valid uuuuuuuuuuuuuuuu";};
						_count =  _count - 1;
						sleep 1;
						};
						if (_bandages == 0 ) then {_exit = true;};
					};
					if (_exit == true) exitWith {
						// if (Lifeline_debug_soundalert) then {["siren1"] remoteExec ["playSound",2]};
						hintsilent format ["NO BANDAGE DATA: %1\nEXIT BEFORE BANDAGE ANIM", name _incap];
						diag_log format ["%1 | %2 uuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuu NO BANDAGE DATA: EXIT uuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuu", name _incap, name _medic];	
					};

					// _damagesubtract = _incap getVariable "damagesubstr"; // IS THIS FUCKING RIGHT? THE DAMAGE TO SUBRACT SHOULD JUST BE TOTAL DAMAGE DIVIDED BY TOTAL BANDAGES
					_damagesubtract = damage _incap / _bandages;
					
					diag_log format ["%3 | 1371====BANDAGE VAR CHECK _var: %1 setVariable: %2", _bandages, _incap getVariable ["num_bandages",false], name _incap];

					_switch = 0;
					diag_log format ["kkkkkkkkkkkkk|%6|%7|  START- BANDAGE %1 | DMG %2 | SUBTR %3 kkkkkkkkkkkkkkkkkkkkkkkkkkk", _bandages, damage _incap, _damagesubtract, _incap, _medic, name _incap, name _medic];
					
					_unitwounds =  _incap getVariable ["unitwounds",[]];
					diag_log format ["%2 | TEXT | UNIT WOUND ARRAY %1 count _unitwounds %3 _bandages %4 ====[851]", _unitwounds, name _incap, count _unitwounds, _bandages];
					// [format ["%2 | TEXT | UNIT WOUND ARRAY %1 count _unitwounds %3 _bandages %4 ====[851]", _unitwounds, name _incap, count _unitwounds, _bandages]] remoteExec ["diag_log", 2];


					//=====================================================================================================

					_switch = 0;
					_againswitch = 1; // this is so the voice sample "and again" alternates samples and not sound robotic

					// _encourage = ["_greetB5", "_greetB2", "_almostthere1"];	//different voices of encouragement
					_encourage = ["_greetB5", "_greetB2", "_almostthere1","_staybuddy1"];	//different voices of encouragement
					_enc_count = 0;											//round-robin counter for above	
					_cprcheck = false;
					_notrepeat = "";
					_colour = "";
					_part_yo = "";
					// _firstpass = true;
					_crouchreviveanim = selectRandom [0,1]; // this is to randomize between two different crouch revive animations.


					// ================= BANDAGE ACTION LOOP ===============================================================
					diag_log format ["%1 | %2 | uuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuu", name _incap, name _medic];
					diag_log format ["%1 | %2 | uuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuu BANDAGE ACTION LOOP uuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuu", name _incap, name _medic];
					diag_log format ["%1 | %2 | uuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuu", name _incap, name _medic];
					_firstimetrigg = false; // TEMP FOR NEW ANIMATION
					// _tempswitch = false;

					// _textright = "BLEEDOUT CLEAR";
					// [_textright,1.3,5,Lifelinetxt2Layer] remoteExec ["Lifeline_display_textright",_incap];

					// while {_bandages > 0 && (lifestate _incap == "INCAPACITATED" && lifestate _medic != "INCAPACITATED" && alive _medic)} do { 
					while {_bandages > 0 && (lifestate _incap == "INCAPACITATED" && lifestate _medic != "INCAPACITATED" && alive _medic && alive _incap)} do { 

						_bandages = _incap getVariable "num_bandages"; //copy of this in loop so updates from other medics reviving at same time works
						//loop for medical actions
						// while {damage _incap > 0.2 && (lifestate _incap == "INCAPACITATED" && lifestate _medic != "INCAPACITATED" && alive _medic)} do { //loop for medical actions

						if (_bandages <= 0) exitWith {diag_log "1385 EXIT BANDAGE LOOP=====(_bandages == 0)";};//backup to exit in case of bandage calulation error (mutiple players reviving same incap, it might happen)

						if (lifestate _medic == "INCAPACITATED" || !(alive _medic)) exitWith {diag_log format ["==== 2030 EXIT MEDIC INCAP %1", lifestate _incap];};
						if (lifestate _incap != "INCAPACITATED" || !(alive _incap)) exitWith {diag_log format ["==== 2031 EXIT INCAP DEAD OR REVIVED %1", lifestate _incap];};
									
						diag_log format ["====|%3|%4| BANDAGE IN PROGRESS %1 DMG %2", _bandages, damage _incap, name _incap,name _medic];
						diag_log format ["====|%2|%3| BANDAGE WOUNDS: %1", _unitwounds, name _incap,name _medic];

						//============== ADD MORE TIMER. added to increase revive time limit on each loop pass ==============================================================================
						_timelimitincap = (_incap getvariable _pairtimebaby);
						_timelimitmedic = (_medic getvariable _pairtimebaby);
						_incap setVariable [_pairtimebaby, _timelimitincap + 10, true]; 
						_medic setVariable [_pairtimebaby, _timelimitmedic + 10, true]; 
						_bleedoutincap = (_incap getvariable _bleedoutbaby);
						_incap setVariable [_bleedoutbaby, _bleedoutincap + 30, true];
						//======================================================================================================================================================================		


						if (_bandages > 0 && Lifeline_RevMethod == 2 && Lifeline_BandageLimit > 1) then {

							_text = _incap getVariable "unitwounds" select (_bandages -1) select 0;
							diag_log format ["====|%3|%4| TEXT | %1 no %2", _text,_bandages, name _incap,name _medic];
							_colour = _incap getVariable "unitwounds" select (_bandages -1) select 1;
							_actionId = _incap getVariable ["Lifeline_ActionMenuWounds",0];
							
							//new method
							if (_text != "CRITICAL: Perform CPR") then {
								_text = format ["%1       ..%2", _text, _bandages];
							};

							[[_incap,_actionId,_colour,_bandages, _text],
								{params ["_incap", "_actionId", "_colour","_bandages","_text"];
								_incap setUserActionText [_actionId, format ["<t size='%3' color='#%1'>%2</t>",_colour,_text, Lifeline_textsize]];}] remoteExec ["call", 0, true];

							//hint feedback for incap player
							if (isPlayer _incap && Lifeline_HUD_medical) then {
								// [format ["<t align='right' size='%3' color='#%1'>%2</t>",_colour,_text, 0.7],((safeZoneW - 1) * 0.48),1.3,5,0,0,Lifelinetxt2Layer] remoteExec ["BIS_fnc_dynamicText",_incap];
								_textright = format ["<t align='right' size='%3' color='#%1'>%2</t>",_colour,_text, 0.7];
								[_textright,1.3,5,Lifelinetxt2Layer] remoteExec ["Lifeline_display_textright",_incap];																
							};
							
							diag_log format ["%5|%6|==  | %3 |%4|       NEXT BANDAGE  %1 DMG %2", _bandages, damage _incap, _text, _part_yo,name _incap,name _medic];

							if (lifestate _medic != "INCAPACITATED" && lifestate _incap == "INCAPACITATED" && (alive _incap) && (alive _medic) && (Lifeline_MedicComments)) then {
							
							diag_log format ["%5|%6|==  |       TEMP TEST SAY3D  bandages:%1 | DMG:%2 | %3 | part_yo:%4 | _notrepeat:%7", _bandages, damage _incap, _text, _part_yo,name _incap,name _medic,_notrepeat];

								if (_text == "CRITICAL: Perform CPR") then {
									_part_yo = "CPR";
									if (_part_yo != _notrepeat) then {
										diag_log format ["| %1 | %2 | [1074] kkkkkkkkkkkkk SAY3D CPR | voice: %3", name _incap, name _medic, _voice];
										[_medic, [_voice+"_CPR1", 20, 1, true]] remoteExec ["say3D", 0];
									};
								};
								if ((_text find "Head:") == 0) then {
									// diag_log format ["== HEAD == for say3d | %1", _text];
									_part_yo = "head";
									if (_part_yo != _notrepeat) then {
										[_medic, [_voice+"_head1", 20, 1, true]] remoteExec ["say3D", 0];
										diag_log format ["| %1 | %2 | [1088] kkkkkkkkkkkkk SAY3D HEAD | voice: %3", name _incap, name _medic, _voice];
									};
								};		
								if ((_text find "Torso:") == 0) then {
								// diag_log format ["== TORSO == for say3d | %1", _text];
									_part_yo = "torso";
									if (_part_yo != _notrepeat) then {
										[_medic, [_voice+"_torso1", 20, 1, true]] remoteExec ["say3D", 0];
										diag_log format ["| %1 | %2 | [1096] kkkkkkkkkkkkk SAY3D TORSO | voice: %3", name _incap, name _medic, _voice];
									};
								};	
								if ((_text find "Arm:") == 0) then {
									_part_yo = selectRandom["_leftarm1","_rightarm1"];
									if (_part_yo != _notrepeat && (_text find "Fracture") == -1) then {
										[_medic, [_voice+_part_yo, 20, 1, true]] remoteExec ["say3D", 0];
										diag_log format ["| %1 | %2 | [1103] kkkkkkkkkkkkk SAY3D ARM "+_part_yo+" | voice: %3", name _incap, name _medic, _voice];
									};									
								};
								if ((_text find "Leg:") == 0) then {
									_part_yo = selectRandom["_leftleg1","_rightleg1"];
									if (_part_yo != _notrepeat && (_text find "Fracture") == -1) then {
										[_medic, [_voice+_part_yo, 20, 1, true]] remoteExec ["say3D", 0];
										diag_log format ["| %1 | %2 | [1110] kkkkkkkkkkkkk SAY3D LEG "+_part_yo+" | voice: %3", name _incap, name _medic, _voice];
									};		
								};
								if ((_text find "Fracture") != -1 && _part_yo != "torso" && _part_yo != "head") then { // only arms and legs
								// if ((_text find "Fracture") != -1 && _part_yo != "head") then { //this version includes fracture shoulders which are part of torso
									// diag_log format ["== FIND FRACTURE == for say3d | %1", _text];
									_part_yo = "fracture";
									if (_part_yo != _notrepeat) then {
										[_medic, [_voice+"_fracture1", 20, 1, true]] remoteExec ["say3D", 0];
										diag_log format ["| %1 | %2 | [1118] kkkkkkkkkkkkk SAY3D FRACTURE | voice: %3", name _incap, name _medic, _voice];
									};
								};
								if ((_text find "Inject Blood IV") == 0) then {
									_part_yo = "blood";
									if (_part_yo != _notrepeat) then {
										[_medic, [_voice+"_giveblood1", 20, 1, true]] remoteExec ["say3D", 0];
										diag_log format ["| %1 | %2 | [1125] kkkkkkkkkkkkk SAY3D BLOOD | voice: %3", name _incap, name _medic, _voice];
									};
								};
								if ((_text find "Inject Epinephrine") == 0) then {
									_part_yo = "Epinephrine";
									if (_part_yo != _notrepeat) then {
										[_medic, [_voice+"_giveEpinephrine1", 20, 1, true]] remoteExec ["say3D", 0];
										diag_log format ["| %1 | %2 | [1132] kkkkkkkkkkkkk SAY3D EPINEPHRINE | voice: %3", name _incap, name _medic, _voice];
									};	
								};
								if ((_text find "Inject Morphine") == 0) then {
									_part_yo = "Morphine";
									if (_part_yo != _notrepeat) then {
										[_medic, [_voice+"_morphine1", 20, 1, true]] remoteExec ["say3D", 0];
										diag_log format ["| %1 | %2 | [1139] kkkkkkkkkkkkk SAY3D MORPHINE | voice: %3", name _incap, name _medic, _voice];
									};	
								};
								// diag_log format ["%2 ==== SAY3D PARTYO %1 ====", _part_yo, name _incap];
							}; // end if not incapped

						}; // end if RevMethod == 2


						//encouragment or "and again" voice sample when body part is repeated for Lifeline_RevMethod 2. Repeated audio samples are not cool. 
																			
						// if (Lifeline_RevMethod == 2) then {
						if (Lifeline_RevMethod == 2 && (Lifeline_MedicComments) && Lifeline_BandageLimit > 1) then {
							_repeatrandom = selectRandom[1,2];	
							diag_log format ["==== START ANIM RANDO %1 count %2 VOICE %3", _repeatrandom, _enc_count, _voice];
							if (_part_yo == _notrepeat && _enc_count < 4 && _repeatrandom == 1) then { 
								[_medic, [_voice+(_encourage select _enc_count), 20, 1, true]] remoteExec ["say3D", 0];
								diag_log format ["| %1 | %2 | [1157] kkkkkkkkkkkkk SAY3D %4 | voice: %3", name _incap, name _medic, _voice, (_encourage select _enc_count)];
								if (_enc_count == 3) then {_enc_count = 0} else {_enc_count = _enc_count + 1};
							};
							if (_part_yo == _notrepeat && _repeatrandom == 2) then { 
								diag_log format ["=====AND AGAIN switch: %1", _againswitch];
								[_medic, [_voice+"_andagain"+(str _againswitch), 20, 1, true]] remoteExec ["say3D", 0];
								diag_log format ["| %1 | %2 | [1163] kkkkkkkkkkkkk SAY3D: AND AGAIN | voice: %3", name _incap, name _medic, _voice];
								if (_againswitch == 1) then { _againswitch = 2; } else { _againswitch = 1; };
							};	
							_notrepeat = _part_yo;
						};

						_sleeptime = 0;
						//DEBUG
						// if (lifestate _medic == "INCAPACITATED" || !(alive _medic)) exitWith {diag_log format ["==== 2030 EXIT MEDIC INCAP %1", lifestate _incap];};
						// if (lifestate _incap != "INCAPACITATED" || !(alive _incap)) exitWith {diag_log format ["==== 2031 EXIT INCAP DEAD OR REVIVED %1", lifestate _incap];};
						//ENDDEBUG
						diag_log " ";
						diag_log format ["%1 | %2 |========================== REVIVE ANIMATION ===========================", name _incap, name _medic];
						diag_log format ["%1 | %2 |========================== REVIVE ANIMATION ===========================", name _incap, name _medic];
						diag_log format ["%1 | %2 |========================== REVIVE ANIMATION ===========================", name _incap, name _medic];
						diag_log " ";

						//turning off the random choice between two animations. Hard setting it here:
						_crouchreviveanim = 0;

						// if (lifestate _medic != "INCAPACITATED" || (alive _medic) || lifestate _incap == "INCAPACITATED" || (alive _incap)) then { 
					/* 	if (lifestate _medic != "INCAPACITATED" && alive _medic) then {
							// _medic setdir (_medic getDir _incap); //TEMPOFF yeha
							// diag_log format ["%1 | [1105 Lifeline_Functions.sqf] nnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnn FORCE DIRECTION ===============================", name _medic];playsound "forcedirection";
							
							_checkdegrees = [_incap,_medic,25] call Lifeline_checkdegrees;
							if (_checkdegrees == false) then {
								[_medic,_incap] call Lifeline_align_dir;
								if (Lifeline_debug_soundalert && Lifeline_Revive_debug) then {playsound "adjust_direction"};
								if (Lifeline_hintsilent && Lifeline_Revive_debug) then {hint format ["%1 ADJUST DIRECTION ", name _medic]};
								diag_log format ["%1 | [1112 Lifeline_Functions.sqf] nnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnn ADJUST DIRECTION ===============================", name _medic];
							};			
							_medic disableAI "ANIM";
							_checkdegrees = [_incap,_medic,15] call Lifeline_checkdegrees;
							 // if (_checkdegrees == false) then {
								// sleep 3;diag_log format ["%1 | [1116 Lifeline_Functions.sqf SLEEP 3 BEFORE FORCE DIRECTION", name _medic];
								// _medic setDir (_medic getDir _incap);diag_log format ["%1 | [1116 Lifeline_Functions.sqf] nnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnn FORCE DIRECTION ===============================", name _medic];playsound "forcedirection";
							// };							
						}; */

						if (_part_yo != "CPR") then {
								// Kneeling revive - no near enemy
								// if (isNull _EnemyCloseBy) then {
								if (lifestate _incap == "INCAPACITATED" && isNull _EnemyCloseBy && lifestate _medic != "INCAPACITATED" && alive _medic) then {
									// _medic setdir (_medic getDir _incap)+5;/* diag_log "1924 !!!!!!!! SET DIR !!!!!!!!!" ; */ //SETDIRTEMP
									if (_crouchreviveanim == 0) then {
										 // [_medic, "AinvPknlMstpSnonWnonDnon_medic4"] remoteExec ["playMoveNow", _medic];
										 [_medic, "AinvPknlMstpSnonWnonDnon_medic4"] remoteExec ["playMoveNow", _medic, true];
										 _sleeptime = 4;
									};
									//DEBUG
									 //NEW ANIMATION LOOP
									/* if (_crouchreviveanim == 1) then {
										 if (_firstimetrigg == false) then {
										 _medic setAnimSpeedCoef 1;
										[_medic,"AinvPknlMstpSnonWnonDnon_medic0"] remoteExec ["playMove", _medic,true];
										[_medic,"AinvPknlMstpSnonWnonDnon_medic_2"] remoteExec ["playMove", _medic, true];
										_firstimetrigg = true;
										};
										if (_bandages == 1) then {
										_medic setAnimSpeedCoef 1;
										[_medic,"AinvPknlMstpSnonWnonDnon_medic0"] remoteExec ["playMoveNow", _medic, true];
										};
									 _sleeptime = 3.75;
									}; */
									//ENDDEBUG
								};

								// Prone revive - near enemy. Alternating between two anims to fix an Arma bug
								if (lifestate _incap == "INCAPACITATED" && !isNull _EnemyCloseBy && lifestate _medic != "INCAPACITATED" && alive _medic) then {
									// _medic setdir (_medic getDir _incap)+5;/* diag_log "1936 !!!!!!!! SET DIR !!!!!!!!!"; *///SETDIRTEMP
									// [_medic, (_medic getDir _incap)+5] remoteExec ["setdir", _medic];

									if (Lifeline_Anim_Method == 0) then {
											// _switch = 0; // TEMP - force switch for testing.
											if (_switch == 0) then {
												[_medic, "AinvPpneMstpSlayWrflDnon_medicOther"] remoteExec ["playMove", _medic, true]; //CURRENT
												 diag_log format ["%1 | %2 | PRONE ANIME 1 xxxxxxxxxxxxxxxxxxx ainvppnemstpslaywrfldnon_medicother xxxxxxxxxxxxxxxxxxxxx", name _incap, name _medic];
												// [_medic, "ainvppnemstpslaywrfldnon_medicother"] remoteExec ["SwitchMove", _medic];
												_switch = 1;
												// sleep 9;
												_sleeptime = 4.5;
											} else {
												[_medic, "AinvPpneMstpSlayWrflDnon_medicOther"] remoteExec ["SwitchMove", 0, true]; //CURRENT
												 diag_log format ["%1 | %2 | PRONE ANIM 2 xxxxxxxxxxxxxxxxxxx ainvppnemstpslaywrfldnon_medicother xxxxxxxxxxxxxxxxxxxxx", name _incap, name _medic];
												_sleeptime = 4.75;
												// sleep 9.5;
											}; 
											[_medic, _incap] spawn {
												params ["_medic", "_incap"];
												// _medic setdir (_medic getDir _incap)+10;/* diag_log "1958 !!!!!!!! SET DIR !!!!!!!!!"; *///SETDIRTEMP
											};
										};														
										//NEW ANIMATION LOOP, less weapon being pulled out between bandages, faster, but a frame jump in the loop.
										if (Lifeline_Anim_Method == 1) then {
											if (_firstimetrigg == false ) then {
												_randomanimloop = selectrandom[1,2,3,4];
												
												// _randomanimloop = 1;
												
												//remote exec the function with the bandage animation loop
												// [_incap,_medic,_randomanimloop,_cprcheck] remoteExec ["Lifeline_Anim_Bandage_new",0,true];
												[_incap,_medic,_randomanimloop,_cprcheck] remoteExec ["Lifeline_Anim_Bandage_new",[_incap,_medic],true];
												// [_incap,_medic,_randomanimloop] spawn Lifeline_Anim_Bandage_new;
												_firstimetrigg = true;
											};
											_sleeptime = 3.75;
										};														
								};	//if (!isNull _EnemyCloseBy) then
						}; // if != CPR


						if (_part_yo == "CPR") then {
							if (lifestate _incap == "INCAPACITATED" && lifestate _medic != "INCAPACITATED" && alive _medic) then {
								// _medic setdir (_medic getDir _incap)+5; diag_log "1964 !!!!!!!! SET DIR !!!!!!!!!";//SETDIRTEMP
								// [_medic, (_medic getDir _incap)+5] remoteExec ["setdir", _medic];
								// [_medic, "AinvPknlMstpSnonWnonDr_medic0"] remoteExec ["playMoveNow", _medic];
								[_medic, "AinvPknlMstpSnonWnonDr_medic0"] remoteExec ["playMoveNow", _medic, true];
								_cprcheck = true;
								 diag_log format ["%1 | %2 |xxxxxxxxxxxxxxxxxxx CPR AinvPknlMstpSnonWnonDr_medic0 xxxxxxxxxxxxxxxxxxxxx", name _incap, name _medic];
								_sleeptime = 4;
							};
						};

						// does this direction code go before or after animations?
						[_medic, _incap] spawn {
							params ["_medic", "_incap"];
							// _medic setdir (_medic getDir _incap)+10; diag_log "1929 !!!!!!!! SET DIR !!!!!!!!!";//SETDIRTEMP
						}; 

						// }; // end if (lifestate _medic != "INCAPACITATED" etc

						sleep _sleeptime;

						// random verbal encouragement halfway through playMove, for both Lifeline_RevMethod 1 & 2. There is a sample repeat blocker for Lifeline_RevMethod 1.
						if (Lifeline_MedicComments) then {	
							_rando = selectRandom[1,2,3,4];
							if (Lifeline_RevMethod == 1 || Lifeline_BandageLimit == 1) then {
								_rando = selectRandom[1,2];
								_enc_count = selectRandom[0,1,2,3];
								diag_log format ["0862 !!!! == _enc count %1 _B %2",_enc_count,_B]; 
								//this will stop a repeated sample from the greeting (some shared samples in arrival greeting)
								while {(_enc_count == 0 && _B == "5") || (_enc_count == 1 && _B == "2")} do {
									diag_log format ["==== STOP REPEATED SAMPLE _enc_count %1 _B %2 ====", _enc_count, _B];
									_enc_count = selectRandom[0,1,2,3];
								};
								diag_log format ["0868 !!!! == _enc count %1 _B",_enc_count,_B]; 
							};

							diag_log format ["==== MID ANIM RANDO %1 count %2 VOICE %3", _rando, _enc_count, _voice];
							if (_rando == 1) then { 
								[_medic, [_voice+(_encourage select _enc_count), 20, 1, true]] remoteExec ["say3D", 0];
								diag_log format ["| %1 | %2 | 1959 kkkkkkkkkkkkk SAY3D MID ANIM | voice: %3", name _incap, name _medic, str (_voice+(_encourage select _enc_count))];
								if (_enc_count == 3) then {_enc_count = 0} else {_enc_count = _enc_count + 1};
								diag_log "====1926 half anim encouragment voice====";
							};
						};

						sleep _sleeptime;

						if (_part_yo == "CPR") then {	
							sleep 4;
							if (Lifeline_MedicComments) then {	
								diag_log format ["| %1 | %2 | [1330] kkkkkkkkkkkkk SAY3D PULSE | voice: %3", name _incap, name _medic, _voice];
								[_medic, [_voice+"_pulse1", 20, 1, true]] remoteExec ["say3D", 0];
							};							
							// take incap out of CPR animation (dead still)
							[_incap] spawn {
								params ["_incap"];
								sleep 5;
								[_incap, "UnconsciousReviveDefault_C"] remoteExec ["PlayMoveNow", _incap];	   
								[_incap, "UnconsciousFaceUp"] remoteExec ["PlayMove", _incap];	
								//local anim 
								// _incap playMoveNow "UnconsciousReviveDefault_C";
								// _incap playMove "UnconsciousFaceUp";
							};
						};

						// THIS IS HACKED ON MORPHINE AT END 
						if (_part_yo == "Epinephrine" && _bandages == 1) then {
							[_incap,_medic,_voice,_colour] spawn {
							params ["_incap","_medic","_voice","_colour"];
							sleep 2;
								if (isPlayer _incap && Lifeline_HUD_medical) then {
									_text = "Inject Morphine       ..extra";
									// [format ["<t align='right' size='%3' color='#%1'>%2</t>",_colour,_text, 0.7],((safeZoneW - 1) * 0.48),1.3,5,0,0,Lifelinetxt2Layer] remoteExec ["BIS_fnc_dynamicText",_incap];
									_textright = format ["<t align='right' size='%3' color='#%1'>%2</t>",_colour,_text, 0.7];
									[_textright,1.3,5,Lifelinetxt2Layer] remoteExec ["Lifeline_display_textright",_incap];									
								};
								if (Lifeline_MedicComments) then {
									[_medic, [_voice+"_morphine1", 20, 1, true]] remoteExec ["say3D", 0];
									diag_log format ["| %1 | %2 | [1153] kkkkkkkkkkkkk SAY3D MORPHINE ADDED SPAWN | voice: %3", name _incap, name _medic, _voice];
								};
							};	
							sleep 2;
						};


						// }; // end if (lifestate _medic != "INCAPACITATED" etc


						_newdamage = damage _incap - _damagesubtract;
						if (_newdamage < 0.2) then {
							diag_log format ["%1 kkkkkkkkkkkkkkkkkkkk DAMAGE UNDER: %2", name _incap, _newdamage];
							// _incap setDamage 0.2;
							_newdamage = 0.2;						
						};

						_incap setDamage _newdamage;
						_bandages = _bandages - 1;
						_incap setVariable ["num_bandages",_bandages,true];	

						// NEW TEST for deleting from array
						diag_log format ["%2 | %3 kkkkkkkk BOO MINUS: %1 ", _unitwounds, name _incap, name _medic];
						// _unitwounds = _unitwounds - [(_unitwounds select (_bandages))]; // WRONGGG
						_unitwounds deleteAt _bandages;
						diag_log format ["%2 | %3 kkkkkkkk BOO MINUS: %1 ", _unitwounds, name _incap, name _medic];
						_incap setVariable ["unitwounds",_unitwounds,true];

						//DEBUG
						// if (Lifeline_RevMethod == 2 && (Lifeline_MedicComments) && Lifeline_BandageLimit > 1) then {_notrepeat = _part_yo}; // maybe this move to here?
									
						//moved to front now
						
						/* 	if (_bandages > 0 && !(isPlayer _incap)) then {
							// _bandage_text = [_bandages,false] call Lifeline_bandage_text;
							// _colour = (_bandage_text select 1);
							// _text = (_bandage_text select 0);
							
							_text = _incap getVariable "unitwounds" select (_bandages -1) select 0;
							_colour = _incap getVariable "unitwounds" select (_bandages -1) select 1;
							// _incap setUserActionText [0, format ["<t size='%4' color='#%1'>%3      ..%2</t>",_colour,_bandages,_text, Lifeline_textsize]];
							
							[_incap, [0, format ["<t size='%4' color='#%1'>%3      ..%2</t>",_colour,_bandages,_text, Lifeline_textsize]]] remoteexec ["setUserActionText", _incap];														
							
							diag_log format ["==  |%3|%4|%5|%6|       NEXT BANDAGE  %1 DMG %2", _bandages, damage _incap, _incap, _medic,name _incap,name _medic];
						}; */
									
						// if (_bandages <= 0 && _newdamage > 0.2) exitWith {diag_log "1447 EXIT BANDAGE LOOP=====(_bandages == 0)";};//backup to exit in case of bandage calulation error (mutiple players reviving same incap, it might happen)				
						//ENDDEBUG

					}; // end while ================================================ END BANDAGE LOOP ========================================
					
					
					//DEBUG
					/* [_medic, _incap] spawn {
						params ["_medic", "_incap"];
						_medic setdir (_medic getDir _incap)+10; diag_log "2042 !!!!!!!! SET DIR !!!!!!!!!";
					};	 */
					//ENDDEBUG

		}; // if lifestate == incapacitated
						

		//================================================ REMOVE DAMAGE AND WAKE UP OR ABORT ============================

		_tempswitch = true;

		//DEBUG
		// if (lifestate _medic != "INCAPACITATED" && alive _medic && alive _incap) then {
		// if (lifestate _medic != "INCAPACITATED" && alive _medic && alive _incap && lifestate _incap == "INCAPACITATED") then {
		//ENDDEBUG
		if (lifestate _medic != "INCAPACITATED" && alive _medic && alive _incap && lifestate _incap == "INCAPACITATED" && _exit == false) then {

			// Remove damage and wake up //
			diag_log format ["%1 | %2 | !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! REMOVE DAMAGE AND WAKE UP !!!!!!!!!!!!!!!!!!!", name _incap, name _medic];
			diag_log format ["%1 | %2 | !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! REMOVE DAMAGE AND WAKE UP !!!!!!!!!!!!!!!!!!!", name _incap, name _medic];
			diag_log format ["%1 | %2 | !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! REMOVE DAMAGE AND WAKE UP !!!!!!!!!!!!!!!!!!!", name _incap, name _medic];

			
			if ((animationState _incap find "unconscious" == 0 && animationState _incap != "unconsciousrevivedefault" && animationState _incap != "unconsciousoutprone") || animationState _incap == "unconsciousrevivedefault") then {
				[_incap, "unconsciousrevivedefault"] remoteExec ["SwitchMove", 0];
			};

			if (Lifeline_RevMethod == 2 && Lifeline_BandageLimit > 1) then {
				_actionId = _incap getVariable "Lifeline_ActionMenuWounds";
				if (!isNil "_actionId") then {
						[[_incap,_actionId],{params ["_unit","_actionId"];_unit setUserActionText [_actionId, ""];}] remoteExec ["call", 0, true];
						//DEBUG
						if (Lifeline_Revive_debug) then {
							_diagtext = format ["%1 TRACE !!!!!!!!!!!!!!!!!!! [1431] CLEAR setUserActionText !!!!!!!!!!!!!!!!!!!! captive %2", name _incap, captive _incap];if !(local _incap) then {[_diagtext+" REMOTE"] remoteExec ["diag_log", 2];} else {diag_log _diagtext};
						};
						//ENDDEBUG
				};
			};
			// _medic setVariable ["Lifeline_reset_trig",false,true]; // THIS AGAIN, SOMETIMES NOT SET AT START
			_incap setVariable ["Lifeline_Down",false,true];// for Revive Method 2
			_incap setVariable ["Lifeline_autoRecover",false,true];diag_log format ["%1 [1264]!!!!!!!!! change var Lifeline_autoRecover = false !!!!!!!!!!!!!", name _incap];
			_incap setVariable ["Lifeline_allowdeath",false,true];
			_incap setVariable ["Lifeline_bullethits",0,true];

			// _medic setVariable ["ReviveInProgress",0,true];
			// Reset health state and zero damage
			[_incap, false] remoteExec ["setUnconscious",_incap];
			// _incap setUnconscious false;
			_incap setdamage 0;		
			_incap setVariable ["unitwounds",[],true]; //added
			//COUNTDOWN TIMERS
			_incap setVariable ["Lifeline_countdown_start",false,true];
			_incap setVariable ["Lifeline_canceltimer",false,true];
			// _unit setVariable ["preventdeath",false,true]; // I dont think this is used. need to check

			_Lifeline_Down = (_incap getVariable ["Lifeline_Down",false]);
			diag_log format ["%1 | %2 | BEFORE [1306] !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! CHECK Lifeline_Down: %3 !!!!!!!!!!!!!!!!!!!", name _incap, name _medic, _Lifeline_Down];

			//DEBUG
			//reset damage and captive states (double check)
					// [_incap,true] remoteExec ["allowDamage",_incap]; diag_log format ["%1 | [1302][Lifeline_Functions.sqf] ALLOWDAMAGE SET: %2", name _incap, "true"];
					// [_incap,false] remoteExec ["setCaptive",_incap];diag_log format ["%1 | [1305]!!!!!!!!! change var setCaptive = false !!!!!!!!!!!!!", name _incap];
					// _incap allowDamage true;diag_log format ["%1 | [1302][Lifeline_Functions.sqf] ALLOWDAMAGE SET: %2", name _incap, isDamageAllowed _incap];
					// _incap setCaptive false;diag_log format ["%1 | [1305]!!!!!!!!! change var setCaptive = false !!!!!!!!!!!!!", name _incap];					
					// [_incap, true] remoteExec ["allowDamage",_incap];diag_log format ["%1 | [1302][Lifeline_Functions.sqf] ALLOWDAMAGE SET: %2", name _incap, "true"];
					// [_incap, false] remoteExec ["setCaptive",_incap];diag_log format ["%1 | [1305]!!!!!!!!! change var setCaptive = false !!!!!!!!!!!!!", name _incap];	
			//ENDDEBUG
				_captive = _incap getVariable ["Lifeline_Captive", false];
				if !(local _incap) then {
					[_incap, true] remoteExec ["allowDamage",_incap];diag_log format ["%1 | [1336][Lifeline_Functions.sqf] ALLOWDAMAGE SET: %2", name _incap, "true"];
					// [_incap, false] remoteExec ["setCaptive",_incap];diag_log format ["%1 | [1336]!!!!!!!!! change var setCaptive = false !!!!!!!!!!!!!", name _incap];	
					[_incap, _captive] remoteExec ["setCaptive",_incap];diag_log format ["%1 | [1336]!!!!!!!!! change var setCaptive = %2 !!!!!!!!!!!!!", name _incap, _captive];	
				} else {
					_incap allowDamage true;diag_log format ["%1 | [1340][Lifeline_Functions.sqf] ALLOWDAMAGE SET: %2", name _incap, isDamageAllowed _incap];
					// _incap setCaptive false;diag_log format ["%1 | [1340]!!!!!!!!! change var setCaptive = false !!!!!!!!!!!!!", name _incap];		
					_incap setCaptive _captive;diag_log format ["%1 | [1340]!!!!!!!!! change var setCaptive = %2 !!!!!!!!!!!!!", name _incap, _captive];		
				};


					
		};
		diag_log format ["%1 | %2 | [1307]====== FNC Lifeline_Medic_Anim_and_Revive. _exit = %3", name _incap, name _medic, _exit];
		 
		// waitUntil {lifestate _incap != "INCAPACITATED"}; // if incap is remote player, sometimes there is a delay. Wait until data catches up. // DO NOT USE. 
_exit
};



//new animation for bandage loop without pulling out weapon after each animation
Lifeline_Anim_Bandage_new = {
	params ["_incap","_medic","_randomanimloop","_cprcheck"];
	
	//AinvPpneMstpSlayWnonDnon_medicOther  for use later. For no weapon characters.

	if (_randomanimloop == 1) then {		
		if (_cprcheck == true) then {  // to smooth animation if CPR animation was prevously
			_medic playmovenow "amovppnemstpsraswrfldnon"; sleep 4;
		};
		
		_medic playmoveNow "AinvPpneMstpSlayWpstDnon_medicOther";
			sleep 10;
		
		_medic playmovenow "AmovPpneMstpSrasWrflDnon_AmovPpneMstpSrasWpstDnon";
		sleep 2;
		while {_incap getVariable "num_bandages" > 0 && lifestate _incap == "INCAPACITATED" && lifestate _medic != "INCAPACITATED" &&  alive _incap} do {
			_medic switchmove "AinvPpneMstpSlayWpstDnon_medicOther";
			sleep 7;
			_medic playmoveNow "AinvPpneMstpSlayWpstDnon_medicOtherOut";
			sleep 0.2;
		};
	};														

	if (_randomanimloop == 2) then {	
		if (_cprcheck == true) then {  // to smooth animation if CPR animation was prevously
			_medic playmovenow "amovppnemstpsraswrfldnon"; sleep 4;
		};		
		_medic playmovenow "AinvPpneMstpSlayWpstDnon_medicOther";
		sleep 7;
		while {_incap getVariable "num_bandages" > 0 && lifestate _incap == "INCAPACITATED" && lifestate _medic != "INCAPACITATED" &&  alive _incap} do {
			_medic switchmove "AinvPpneMstpSlayWpstDnon_medicOther";
			sleep 7;
			_medic playmoveNow "AinvPpneMstpSlayWpstDnon_medicOtherOut";
			sleep 0.2;
		};
	};

	if (_randomanimloop == 3) then {
		if (_cprcheck == true) then {  // to smooth animation if CPR animation was prevously
			_medic playmovenow "amovppnemstpsraswrfldnon"; sleep 4;
		};
		// _medic setAnimSpeedCoef 1.9;
		 _medic playmove "AmovPpneMstpSrasWrflDnon_AmovPpneMstpSrasWpstDnon"; 
		// _medic setAnimSpeedCoef 1;
		sleep 2;
		while {_incap getVariable "num_bandages" > 0 && lifestate _incap == "INCAPACITATED" && lifestate _medic != "INCAPACITATED" &&  alive _incap} do {
			_medic switchmove "AinvPpneMstpSlayWpstDnon_medicOther";
			sleep 4;
		};
	};

	if (_randomanimloop == 4) then {
		_medic playmovenow "amovppnemstpsraswrfldnon"; 
		while {_incap getVariable "num_bandages" > 0 && lifestate _incap == "INCAPACITATED" && lifestate _medic != "INCAPACITATED" &&  alive _incap} do {
			_medic switchmove "ainvppnemstpslaywrfldnon_medicother"; 
			sleep 7.607; 
		};
	_medic playmovenow "amovppnemstpsraswrfldnon_amovpercmstpsraswrfldnon"; 
	};														
};





Lifeline_autoRecover_check = {
	params ["_unit"];				
	_percentchance = Lifeline_autoRecover;
	
	//do this later
	// if (Lifeline_RevMethod ==2) then {
	// _quadstored = _unit getVariable ["quadstored",false];
	// };
	
	_randm = [1,100] call BIS_fnc_randomInt; 
	if (_percentchance == 100 OR _randm <= _percentchance) then {
		diag_log format ["%1 ================ AUTORECOVER CHECK = TRUE ==================", name _unit];
		_unit setVariable ["Lifeline_autoRecover",true,true];diag_log format ["%1 [1305]!!!!!!!!! change var Lifeline_autoRecover = true !!!!!!!!!!!!!", name _unit];
		true
	} else {
		diag_log format ["%1 ================ AUTORECOVER CHECK = FALSE ==================", name _unit];
		_unit setVariable ["Lifeline_autoRecover",false,true];diag_log format ["%1 [1308]!!!!!!!!! change var Lifeline_autoRecover = false !!!!!!!!!!!!!", name _unit];
		false
	};
};



Lifeline_countdown_timer2 = {
	params ["_unit","_seconds"];
	//DEBUG
	_diag_textbaby = format ["%1 [0194 fnc] >>>>>>>>>>>> FNC Lifeline_countdown_timer. sec setting: %2 >>>>>>>>>>>>", name _unit, _seconds];
	[_diag_textbaby] remoteExec ["diag_log", 2];
	//ENDDEBUG

	_bleedout = (_unit getVariable "LifelineBleedOutTime");
	_realseconds = round(_bleedout - time); // to adjust exactly	
	_counter = _realseconds;
	_colour = "#FFFAF8";	
	// _font = Lifelinefonts select Lifeline_HUD_dist_font;//added for distance

	while {_counter >= 0 && lifeState _unit == "INCAPACITATED"} do {

		if (_unit getVariable ["Lifeline_canceltimer",false]) exitWith {/*_unit setVariable ["Lifeline_canceltimer",false,true]; diag_log "==== EXIT COUNTDOWN TIMER HINT ====";*/};

		if (time > (_bleedout - (Lifeline_cntdwn_disply+3)) && Lifeline_RevMethod == 2) then {
			//DEBUG
			// diag_log format ["!!!!!!!!!!!!!!!!!!! GETTING CLOSE          %2 | %1  _CDtrig: %3 _cancel: %4", name _unit, _counter, (_unit getVariable ["Lifeline_countdown_start",false]),(_unit getVariable ["Lifeline_canceltimer",false])];
			// _counter = round(_bleedout - time);
			//ENDDEBUG

			// if (_counter <= 60 && isPlayer _unit) then {_colour = "#A10A0A"};
			if (_counter <= 60 && isPlayer _unit) then {_colour = "#EF5736"};
			if (_counter <= 10 && isPlayer _unit) then {_colour = "#FF0000";playSound "beep_hi_1";};
			if (isPlayer _unit && _counter <= _seconds) then { 
					[format ["<t align='right' size='%3' color='%1'>..%2</t><br>..<br>..",_colour,_counter,0.7],((safeZoneW - 1) * 0.48),1.3,5,0,0,Lifelinetxt2Layer] spawn BIS_fnc_dynamicText;
					// [format ["<t align='right' size='%3' color='%1'>..%2</t><br>..<br>..",_colour,_counter,0.7],((safeZoneW - 1) * 0.48),1.3,1,0,0,LifelineBleedoutLayer] spawn BIS_fnc_dynamicText;
			};			
		};	

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
		//last 3 are just counter instead of calc time
		if (_counter < 4) then {
			_counter = _counter - 1;
		} else { 
			// _counter = round(_bleedout - time);
			_counter = round((_unit getVariable "LifelineBleedOutTime") - time);
		};
		sleep 1;
	}; // end while

	// diag_log format ["%1 == EXIT TIMER LOOP counter %2 ==", name _unit, _counter];
	// _unit setVariable ["Lifeline_canceltimer",false,true];
	_unit setVariable ["Lifeline_countdown_start",false,true];
};




Lifeline_reset_variables = {
	params ["_unit"];
	_unit setVariable ["Lifeline_Down",false,true];// for Revive Method 2
	_unit setVariable ["Lifeline_autoRecover",false,true];diag_log format ["%1 [1318]!!!!!!!!! change var Lifeline_autoRecover = false !!!!!!!!!!!!!", name _unit];
	_unit setVariable ["Lifeline_allowdeath",false,true];
	_unit setVariable ["Lifeline_bullethits",0,true];
	_unit setVariable ["Lifeline_countdown_start",false,true];
	_unit setVariable ["Lifeline_canceltimer",false,true]; 
	_unit setVariable ["ReviveInProgress",0,true];
	if (Lifeline_RevMethod == 2 && Lifeline_BandageLimit > 1) then {
		_actionId = _x getVariable "Lifeline_ActionMenuWounds"; 
		if (!isNil "_actionId") then {
				[[_x,_actionId],{params ["_unit","_actionId"];_unit setUserActionText [_actionId, ""];}] remoteExec ["call", 0, true];
		};
	};
};



Lifeline_timer = {
	params ["_seconds"];
	sleep _seconds;
	true
};



// work in progress. Finish later.
/*
Lifeline_radio_how_copy = {
	params ["_voice","_medic"];
	sleep 2;
	//[_incap, [_voice+"_hangtight1", 50, 1, true]] remoteExec ["say3D", _incap];
	_RPArand = selectRandom RadioPartA;
	_RPBrand = selectRandom RadioPartB;
	_medic groupRadio (_voice+_RPArand); 
	_medic groupRadio (_voice+_RPBrand); 
	diag_log format ["| %1 | %2 | [1645] kkkkkkkkkkkkk SAY3D HANGTIGHT | voice: %3", name _medic, name _medic, _voice];
};
*/






