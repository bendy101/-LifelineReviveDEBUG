// Initialize the settings framework
[] call CBA_Settings_fnc_init;

// Add settings using CBA_Settings_fnc_init
["Lifeline_revive_enable", "CHECKBOX", ["ENABLE " + Lifeline_Version, "On or Off.\n\n"], "Lifeline Revive", true, true] call CBA_Settings_fnc_init;
["Lifeline_Scope_CBA", "LIST", ["Scope", "Scope of mod. Which units will Lifeline Revive affect?\nOption 3, 'Playable Slots' is only for Multiplayer\nso it reverts to 'Side' for SinglePlayer\n\n"], ["Lifeline Revive", "_MAIN"], [[1, 2, 3, 4], ["Group", "Side", "Side Playable Slots (only MP)", "Choose in Mission"], 3], true] call CBA_Settings_fnc_init;
["Lifeline_RevProtect", "LIST", ["Shield while reviving", "Protection during revive process. 3 levels.\n1. Invincible during revive for both medic and incap. Even bullets won't affect them.\n2. Semi-Realism mode. The medic and incap is turned pseudo 'captive' to avoid being targeted.\n   Enemy won't target them - however stray bullets and extra damage can still kill.\n3. Protection Off. Most Realism. Both medic and incap, can be both targeted and killed while reviving.\n\n"], ["Lifeline Revive", "_MAIN"], [[1, 2, 3], ["Invincible", "Captive Hack", "Off - Realism"], 1], true] call CBA_Settings_fnc_init;

if (Lifeline_ACEcheck_ == false) then {
    ["Lifeline_BandageLimit", "SLIDER", ["Bandage Range", "Range of bandages any incap needs to revive.\nHigher damage = more bandages within this range\nSet it to 1 for easiest and fastest revive"], ["Lifeline Revive", "_MAIN"], [1, 10, 8, 0], true, {Lifeline_BandageLimit = round Lifeline_BandageLimit}] call CBA_Settings_fnc_init;
    ["Lifeline_InstantDeath", "LIST", ["Instant Death", "0 = Off. Always go into incapacited state.\n1 = Moderate. A bit more casual, instant death still happens with headshots etc.\n2 = Realism. Instant death on realistic level."], ["Lifeline Revive", "_MAIN"], [[0, 1, 2], ["Off", "Moderate", "Realism"], 1], true] call CBA_Settings_fnc_init;
    ["Lifeline_BleedOutTime", "SLIDER", ["Bleedout Time", "Select how long an INCAPACITATED unit can survive in state before dying or autorevive\n\n"], ["Lifeline Revive", "_MAIN"], [0, 600, 300, 0], true, {Lifeline_BleedOutTime = round Lifeline_BleedOutTime}] call CBA_Settings_fnc_init;
    ["Lifeline_autoRecover", "SLIDER", ["Auto Recover", "Percentage chance of regaining consciousness\n\n"], ["Lifeline Revive", "_MAIN"], [0, 1, .3, 0, true], true, {Lifeline_autoRecover = round (Lifeline_autoRecover * 100)}] call CBA_Settings_fnc_init;
    ["Lifeline_CPR_likelihood", "SLIDER", ["Likelihood of Cardiac Arrest w High Damage", "If damage over CPR threshold, how likley?\n\n"], ["Lifeline Revive", "_MAIN"], [0, 1, .9, 0, true], true, {Lifeline_cpr_likelihood = round (Lifeline_cpr_likelihood * 100)}] call CBA_Settings_fnc_init;
    ["Lifeline_CPR_less_bleedouttime", "SLIDER", ["Less Bleedout Time when Cardiac Arrest", "If heart is stopped and need CPR, then bleedout time is compressed to this percentage.\n\n"], ["Lifeline Revive", "_MAIN"], [0, 1, .6, 0, true], true, {Lifeline_CPR_less_bleedouttime = round (Lifeline_CPR_less_bleedouttime * 100)}] call CBA_Settings_fnc_init;
    ["Lifeline_IncapThres", "SLIDER", ["Incap Threshold", "Damage level to trigger incapacitated. Default 0.7\n\n"], "Lifeline Revive Advanced", [0.5, 0.8, 0.7, 1], true, {Lifeline_IncapThres = (round(Lifeline_IncapThres * 10)/10)}] call CBA_Settings_fnc_init;
};

["Lifeline_SmokePerc", "SLIDER",   ["Smoke Chance",   "Percentage Chance of using Smoke when Healing\n\n"], ["Lifeline Revive","SMOKE"], [0, 1, .3, 0, true],true,{Lifeline_SmokePerc = round (Lifeline_SmokePerc * 100)}] call CBA_fnc_addSetting;
["Lifeline_EnemySmokePerc", "SLIDER",   ["Smoke Chance, Enemy Nearby",   "Overrides Setting Above if Enemy < 300m\n\n"], ["Lifeline Revive","SMOKE"], [0, 1, .7, 0, true],true,{Lifeline_EnemySmokePerc = round (Lifeline_EnemySmokePerc * 100)}] call CBA_fnc_addSetting;
["Lifeline_SmokeColour", "LIST",     ["Colour of Smoke",     "Colour of Smoke\n\n"], ["Lifeline Revive","SMOKE"], [["white","yellow","red","purple","orange","green","random"], ["white","yellow","red","purple","orange","green","random"], 0],true] call CBA_fnc_addSetting;
["Lifeline_radio", "CHECKBOX", ["Allow radio status messages", "Allow radio status messages. If medic is over 50m away, radio to assure.\n\n"], ["Lifeline Revive","SOUND"], true,true] call CBA_fnc_addSetting;
["Lifeline_MedicComments", "CHECKBOX", ["AI Medic Comments", "Allow AI medic to speak with assurances to incap during revive.\nIgnored for ACE as this is compulsory due to black screen when incap.\n\n"], ["Lifeline Revive","SOUND"], true,true] call CBA_fnc_addSetting;
["Lifeline_Voices", "LIST",     ["Voice Accents",  "Commonwealth (British + Australian) or USA\n\n"], ["Lifeline Revive","SOUND"], [[1,2,3], ["All","British Empire", "USA"], 0],true] call CBA_fnc_addSetting;
["Lifeline_Idle_Medic_Stop", "CHECKBOX", ["6 second limit on idle medics", "Sometime AI in Arma is retarded. This stops them being idle after 6 seconds\n\n"], "Lifeline Revive Advanced", false,true] call CBA_fnc_addSetting;
["Lifeline_AI_skill", "SLIDER",   ["AI Skill",   "AI skill level. The skill level of AI in your squad or side.\n0 means ignore & use mission setting.\n\n"], "Lifeline Revive Advanced", [0, 1, 0, 1],true,{Lifeline_AI_skill = (round(Lifeline_AI_skill * 10)/10)}] call CBA_fnc_addSetting;
["Lifeline_Anim_Method", "LIST",     ["Prone animation method", "Old: Smoother animation but busier with the weapon always pulled out between bandages, and takes longer to revive.
New method: no weapon pulled out between bandages - but due to arma bugs - there is a small animation glitch in the loop (frame jump)\n\n"], ["Lifeline Revive Advanced"], [[0, 1], ["Old Method","New Method"], 1],true] call CBA_fnc_addSetting;


if (Lifeline_ACEcheck_ == false) then {
Lifeline_ACE_Bandage_Method = 1;
Lifeline_RevMethod = 2;
};


if (Lifeline_ACEcheck_ == true) then {
    [] call CBA_Settings_fnc_init;
    ["Lifeline_ACE_Bandage_Method", "LIST", ["ACE Bandage method", "1. Default ACE bandaging.\n2. Less Bandages required.\n\n"], "Lifeline Revive", [[1, 2], ["Default ACE bandaging", "Less Bandages required"], 1]] call CBA_Settings_fnc_init;
    ["Lifeline_ACE_Blackout", "CHECKBOX", ["Disable Unconscious Blackout Screen", "Disable the ACE blackout effect when unconscious\n\n"], "Lifeline Revive", false, true] call CBA_Settings_fnc_init;
    Lifeline_RevMethod = 3;
};
[] call CBA_Settings_fnc_init;
["Lifeline_HUD_distance", "CHECKBOX", ["Show Distance of Medic", "Show distance of medic.\nBottom right near bleedout timer.\n\n"], ["Lifeline Revive", "HUD & MAP"], false, true] call CBA_Settings_fnc_init;
if (Lifeline_ACEcheck_ == false) then {
    ["Lifeline_cntdwn_disply", "SLIDER", ["Bleedout Countdown Display", "When to show countdown display, in seconds left.\ne.g. you could have bleedout set to 300 sec. but the\ncountdown display may only appear at 120 sec.\n0 = off\n\n"], ["Lifeline Revive", "HUD & MAP"], [0, 600, 300, 0], true, {Lifeline_cntdwn_disply = round Lifeline_cntdwn_disply}] call CBA_Settings_fnc_init;
};
["Lifeline_HUD_medical", "CHECKBOX", ["Medical Action Hint", "Show which medical action is happening.\ne.g. CPR, blood IV, morphine, body part bandage and number of bandages\n\n"], ["Lifeline Revive", "HUD & MAP"], true, true] call CBA_Settings_fnc_init;
["Lifeline_HUD_names", "LIST", ["List of Incapacitated & Medics", "0. Off\n1. Names\n2. Names, distance & bandage\n3. Names & distance\n4. Names & bandage\n\n*note there is an extra option available in debugging, the revive pair timer called 'pair timer for HUD list of units'. This is the timeout left before resetting the medic.\n\n"], ["Lifeline Revive", "HUD & MAP"], [[0, 1, 2, 3, 4], ["Off", "Names", "Names, distance & bandage", "Names & distance", "Names & bandage"], 0], true] call CBA_Settings_fnc_init;
["Lifeline_Map_mark", "CHECKBOX", ["Show markers on map", "Incapacitated and dead shown on map\n\n"], ["Lifeline Revive", "HUD & MAP"], false, true] call CBA_Settings_fnc_init;
["Lifeline_Revive_debug", "CHECKBOX", ["Debug On", "Debug On. Settings below only work if this is on"], ["Lifeline Revive Advanced", "DEBUG"], false, true] call CBA_Settings_fnc_init;
["Lifeline_Fatigue", "LIST", ["Fatigue", "Force Fatigue Settings."], ["Lifeline Revive", "~BONUS. Unrelated to revive but useful"], [[0, 1, 2], ["Mission Settings", "Enabled", "Disabled"], 0], true] call CBA_Settings_fnc_init;
["Lifeline_Hotwire", "CHECKBOX", ["Hotwire Locked Vehicles with Toolkit", "Vehicles you cannot access can now be unlocked.\nHotwire them with toolkit.\nIf the vehicle is enclosed, then you need to break in first.\nDoes not apply to armoured units.\n\n"], ["Lifeline Revive", "~BONUS. Unrelated to revive but useful"], true, true] call CBA_Settings_fnc_init;
["Lifeline_ExplSpec", "CHECKBOX", ["Make all your units Explosive Specialists", "It is frustrating when you accidently plant a bomb then cannot undo it.\nThis fixes that.\n\n"], ["Lifeline Revive", "~BONUS. Unrelated to revive but useful"], true, true] call CBA_Settings_fnc_init;
["Lifeline_Idle_Crouch", "CHECKBOX", ["Idle Crouch", "When a unit is standing and idle, it will temporarily go into a 'crouch'.\nThis only applies to 'aware' behaviour mode.\n\n"], ["Lifeline Revive", "~BONUS. Unrelated to revive but useful"], false, true] call CBA_Settings_fnc_init;
["Lifeline_Idle_Crouch_Speed", "SLIDER", ["Idle Crouch 'Idle' Threshold", "For the Idle Crouch, this determines what speed a unit is moving to be considered 'idle'\n0 for dead still, and 1 to 5 for very slow.\n\n"], ["Lifeline Revive", "~BONUS. Unrelated to revive but useful"], [0, 5, 0, 0], true, {Lifeline_Idle_Crouch_Speed = round Lifeline_Idle_Crouch_Speed}] call CBA_Settings_fnc_init;

["Lifeline_HUD_dist_font", "LIST", ["Font for distance hint", "Font for distance hint"], ["Lifeline Revive Advanced", "DEBUG temporary test"], [["EtelkaMonospacePro", "PuristaBold", "PuristaLight", "PuristaMedium", "PuristaSemibold", "RobotoCondensed", "RobotoCondensedBold", "RobotoCondensedLight"], ["EtelkaMonospacePro", "PuristaBold", "PuristaLight", "PuristaMedium", "PuristaSemibold", "RobotoCondensed", "RobotoCondensedBold", "RobotoCondensedLight"], 0], true] call CBA_Settings_fnc_init;
["Lifeline_yellowmarker", "CHECKBOX", ["Yellow marker on incap.", "in debug mode, have yellow marker on incap"], ["Lifeline Revive Advanced", "DEBUG"], false, true] call CBA_Settings_fnc_init;
["Lifeline_remove_3rd_pty_revive", "CHECKBOX", ["Remove Other Revive Systems Before Mission", "Uncheck this if you want the choice of cancelling Lifeline Revive in the mission.\nNot the best method however, its better to disable mod and restart mission (not restart Arma 3).\nDo this by unchecking 'ENABLE Lifeline Revive' and restarting mission.\n\n"], "Lifeline Revive Advanced", true, true] call CBA_Settings_fnc_init;
["Lifeline_hintsilent", "CHECKBOX", ["Debug Hints", "Debug Hints. Using BI 'hinstsilent'"], ["Lifeline Revive Advanced", "DEBUG"], false, true] call CBA_Settings_fnc_init;
["Lifeline_debug_soundalert", "CHECKBOX", ["Error Sound Alerts", "Sound Alerts when there is a bug."], ["Lifeline Revive Advanced", "DEBUG"], false, true] call CBA_Settings_fnc_init;
["Lifeline_HUD_names_pairtime", "CHECKBOX", ["pair timer for HUD list of units", "incl time for pairs in HUD list of incapped units and medics"], ["Lifeline Revive Advanced", "DEBUG"], true, true] call CBA_Settings_fnc_init;

if (Lifeline_remove_3rd_pty_revive == true && Lifeline_revive_enable) then {

	// SOG:PF CDLC revive system
	// Pretend revive system was already initialized.
	// See: vn_fnc_module_advancedrevive
	vn_advanced_revive_started = true;

	// Farooq Revive
	// Overwrite player initialization.
	far_player_init = compileFinal "";
	[{!isNil "far_debugging"}, {
	diag_log format ["%1 uuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuu WAIT AND EXECUTE Farooq Revive uuuuuuuuuuuuuuuuuuuuuuuuuuuuuu", far_debugging];	
		far_isDragging = nil;  // Disable "Drag & Carry animation fix" loop - cannot be killed because spawned while true.
		far_muteRadio = nil;   // Disable initialization hint.
		far_muteACRE = nil;    // Same, but for very old versions.
		far_debugging = false; // Disable adding event handlers to AI in SP.
	}, [], 5] call CBA_fnc_waitUntilAndExecute;

	//Physcho Revive (old)
	player setVariable ["tcb_ais_aisInit",true];
	diag_log format ["!!!!!!!!!!!!!!!!!!!! IN MY FILE tcb_ais_aisInit = %1 player !!!!!!!!!!!!!!!!!!!!!", player getVariable "tcb_ais_aisInit"];
	//Trick Physcho Revive into thinking ACE is loaded, so it exits.
	// PAR_revive = compileFinal "PAR_revive = true";


	[{!isNil "GRLIB_revive"}, {
		GRLIB_revive = 0; 
	diag_log format ["%1 uuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuu WAIT AND EXECUTE GRLIB_revive uuuuuuuuuuuuuuuuuuuuuuuuuuuuuu", GRLIB_revive];	
	}, [], 5] call CBA_fnc_waitUntilAndExecute;
	// [{!isNil "GRLIB_fatigue"}, {
		// GRLIB_fatigue = 1;  
		// diag_log format ["%1 uuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuu WAIT AND EXECUTE GRLIB_fatigue uuuuuuuuuuuuuuuuuuuuuuuuuuuuuu", GRLIB_fatigue];	
	// }, [], 5] call CBA_fnc_waitUntilAndExecute;
	[{!isNil "FHQ_FirstAidSystem"}, {
		FHQ_FirstAidSystem = 0;  
		diag_log format ["%1 uuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuu WAIT AND EXECUTE FHQ_FirstAidSystem uuuuuuuuuuuuuuuuuuuuuuuuuuuuuu", FHQ_FirstAidSystem];	
	}, [], 5] call CBA_fnc_waitUntilAndExecute;
	
	[{!isNil "G_Revive_System"}, {
		G_Revive_System = false;  
		diag_log format ["%1 uuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuu WAIT AND EXECUTE Grimes Simple Revive 1 uuuuuuuuuuuuuuuuuuuuuuuuuuuuuu", G_Revive_System];	
	}, [], 5] call CBA_fnc_waitUntilAndExecute;
	
	



	//Physcho Revive in Liberation
	// GRLIB_revive = 0;
	// GRLIB_fatigue  = 1;
	// FHQ_FirstAidSystem = 0;
	/* PAR_EventHandler = compileFinal nil;
	PAR_fn_nearestMedic = compileFinal nil;
	PAR_fn_medic = compileFinal nil;
	PAR_fn_medicRelease = compileFinal nil;
	PAR_fn_medicRecall = compileFinal nil;
	PAR_fn_checkMedic = compileFinal nil;
	PAR_fn_911 = compileFinal nil;
	PAR_fn_sortie = compileFinal nil;
	PAR_fn_death = compileFinal nil;
	PAR_fn_unconscious = compileFinal nil;
	PAR_fn_eject = compileFinal nil;
	PAR_fn_checkWounded = compileFinal nil;
	PAR_Player_Init = compileFinal nil;
	PAR_EventHandler = compileFinal nil; */

};

//TEMPTEST
{
    if (!isPlayer _x) then {
        _x enableAI "ALL";
		diag_log name _x;
    };
} forEach allUnits;

disabledAI = 0;


if (Lifeline_revive_enable) then {

Lifeline_RevSmokeOn = true; // fix this later.

//for on screen text
Lifelinetxt1Layer = "Lifelinetxt1" call BIS_fnc_rscLayer; 
Lifelinetxt2Layer = "Lifelinetxt2" call BIS_fnc_rscLayer; 
LifelinetxtdebugLayer1 = "Lifelinetxtdebug1" call BIS_fnc_rscLayer; 
LifelinetxtdebugLayer2 = "Lifelinetxtdebug2" call BIS_fnc_rscLayer; 
LifelinetxtdebugLayer3 = "Lifelinetxtdebug3" call BIS_fnc_rscLayer; 

Lifeline_travel_meth = 1; //method of revive travel when changing stance to hit ground. 0 = use playnow anim, 1 =  use unit posture (unitPos)

Debug_to = 2; //for debug sound
// for experimentation
// Lifelinefonts =["EtelkaMonospacePro","EtelkaMonospaceProBold","EtelkaNarrowMediumPro","LCD14","LucidaConsoleB","PuristaBold","PuristaLight","PuristaMedium","PuristaSemibold","RobotoCondensed","RobotoCondensedBold","RobotoCondensedLight","TahomaB"];
Lifelinefonts =["EtelkaMonospacePro","PuristaBold","PuristaLight","PuristaMedium","PuristaSemibold","RobotoCondensed","RobotoCondensedBold","RobotoCondensedLight"];

// some missions delete action menus (mouse scroll wheel menu) on start. So this will load the RO
LifelineREV4_fnc_keyDown = {
    // Code to execute when the key is pressed down.
    // You can put your function logic here.
    // hint "MyKey is pressed!";
	diag_log "   ";
	diag_log " ------------------------- ";
	diag_log format ["Keybind Setting: %1", keybindSetting];
	diag_log " ------------------------- ";
	hint "..initializing";
	execVM "\Lifeline_Revive\init.sqf";
	execVM "\Lifeline_Revive\initserver.sqf";
};

/* LifelineREV4_fnc_keyUp = {
    // Code to execute when the key is released.
    // You can put your function logic here.
   diag_log  "MyKey is released!";
}; 
 */


// temp debug vars	
Debug_Lifeline_downequalstrue = true;	
Debug_unconsciouswithouthandler = true;
Debug_overtheshold = true;	
Debug_Zeusorthirdparty = true;	
Debug_invincible_or_captive = true;
Debug_incapdeathtimelimit_not_zero = true;
Debug_reviveinprogresserror = true;



};