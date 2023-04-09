#include <amxmodx>
#include <amxmisc>
#include <gunxpmod>
#include <ColorChat>
#include <fakemeta>
#include <engine>
#include <fun>
#include <xs>
#include <hamsandwich>
#include <bbmonets>

#define PLUGIN "BASEBUILDER_Event"
#define VERSION "1.1"
#define AUTHOR "Amator 2k23"

#define MAX_DIST 8192.0
#define MAX 32

new PlayerList[ 33 ][ 33 ];
new PlayerSwitched[ 33 ];
new bool:PlkExp[ 33 ];
new PlayerName[ 33 ][ 32 ];

new bool:sentrys[MAX+1];

new ilosc[33];

new ZmienKilla[2];

new const modelitem[] = "models/basebuilder/Case.mdl";

public plugin_init() 
{
	register_plugin(PLUGIN, VERSION, AUTHOR)
	
	register_clcmd( "say /event", "mymenu" )
	register_clcmd( "Ile chcesz dodac", "AddAdmin" )
	register_logevent("PoczatekRundy", 2, "1=Round_Start"); 
	register_event("HLTV", "NowaRunda", "a", "1=0", "2=0");
	register_message(get_user_msgid("DeathMsg"), "message_DeathMsg")
	
	RegisterHam(Ham_Spawn, "player", "Spawn", 1)
	
	register_think("sentryG","SentryThink");
	
	RegisterHam(Ham_TakeDamage, "func_breakable", "TakeDamage");
	
	register_cvar("zycie_sentry", "1500");
	register_cvar("usun_sentry", "1");
	
	register_forward(FM_Touch, "fwd_touch")
}

public plugin_precache()
{
	precache_model(modelitem);
	precache_model("models/basebuilder/Case.mdl");
	precache_sound("mw/firemw.wav");
	precache_sound("mw/plant.wav");
	precache_sound("mw/sentrygun_starts.wav");
	precache_sound("mw/sentrygun_stops.wav");
	precache_sound("mw/sentrygun_gone.wav");
	//precache_sound("mw/sentrygun_enemy.wav");
}

public client_connect(id)
{
	get_user_name(id, PlayerName[id], charsmax(PlayerName));
}

public PoczatekRundy()
{
	kill_all_entity("skrzynka")
}

public mymenu(id){
	if( !has_flag( id, "a" ) ){
		return PLUGIN_HANDLED;
	}
	new MyMenu=menu_create("\yMenu Wlasciciela: \d","cbMyMenu");
	
	menu_additem(MyMenu,"Dodaj Exp lub Monety")
	menu_additem(MyMenu,"Dodaj wszystkim Expa - 500")
	menu_additem(MyMenu,"Dodaj wszystkim Expa - 1000")
	menu_additem(MyMenu,"Dodaj wszystkim Expa - 1500")
	menu_additem(MyMenu,"Dodaj wszystkim Monety - 500")
	menu_additem(MyMenu,"Dodaj wszystkim Monety - 1000")
	menu_additem(MyMenu,"Dodaj wszystkim Monety - 1500")
	menu_additem(MyMenu,"Dodaj wszystkim Monety - Losowo")
	menu_additem(MyMenu,"Postaw skrzynke eventowa")
	menu_additem(MyMenu,"Postaw dzialko eventowe")
	
	menu_display(id, MyMenu,0);
	return PLUGIN_HANDLED;
}
public cbMyMenu(id, menu, item){
	if( !has_flag( id, "a" ) ){
		return PLUGIN_HANDLED;
	}
	switch(item){
		case 0:{
			AdminMenu( id );
		}
		case 1:{
			dodajWszystkimExpa(id);
		}
		case 2:{
			dodajWszystkimExpa1(id);
		}
		case 3:{
			dodajWszystkimExpa2(id);
		}
		case 4:{
			dodajWszystkimMonet(id);
		}
		case 5:{
			dodajWszystkimMonet1(id);
		}
		case 6:{
			dodajWszystkimMonet2(id);
		}
		case 7:{
			dodajWszystkimMonetRandom(id);
		}
		case 8:{
			create_itm(id);
		}
		case 9:{
		    CreateSentry(id);
		}
	}
	menu_destroy(menu);
	return PLUGIN_HANDLED;

}
public dodajWszystkimExpa(id){
	for(new i=1; i<=32;i++){
		set_user_xp(id, get_user_xp(id)+500)
	}
	ColorChat(0, RED, "^x04[BaseBuilder]^x01 Gracze otrzymali:^x03 500 Expa^x01 za udzial w evencie ");
}
public dodajWszystkimExpa1(id){
	for(new i=1; i<=32;i++){
		set_user_xp(id, get_user_xp(id)+1000)
	}
	ColorChat(0, RED, "^x04[BaseBuilder]^x01 Gracze otrzymali:^x03 1000 Expa^x01 za udzial w evencie");
}
public dodajWszystkimExpa2(id){
	for(new i=1; i<=32;i++){
		set_user_xp(id, get_user_xp(id)+1500)
	}
	ColorChat(0, RED, "^x04[BaseBuilder]^x01 Gracze otrzymali:^x03 1500 Expa^x01 za udzial w evencie");
}
public dodajWszystkimMonet(id){
	for(new i=1; i<=32;i++){
		set_user_ammo_packi(id, get_user_ammo_packi(id)+500)
	}
	ColorChat(0, RED, "^x04[BaseBuilder]^x01 Gracze otrzymali:^x03 500 Monet^x01 za udzial w evencie");
}
public dodajWszystkimMonet1(id){
	for(new i=1; i<=32;i++){
		set_user_ammo_packi(id, get_user_ammo_packi(id)+1000)
	}
	ColorChat(0, RED, "^x04[BaseBuilder]^x01 Gracze otrzymali:^x03 1000 Monet^x01 za udzial w evencie");
}
public dodajWszystkimMonet2(id){
	for(new i=1; i<=32;i++){
		set_user_ammo_packi(id, get_user_ammo_packi(id)+1500)
	}
	ColorChat(0, RED, "^x04[BaseBuilder]^x01 Gracze otrzymali:^x03 1500 Monet^x01 za udzial w evencie");
}
public dodajWszystkimMonetRandom(id){
	new losowa_wartosc = random_num(500, 2000)
	for(new i=1; i<=32;i++){
		set_user_ammo_packi(id, get_user_ammo_packi(id)+losowa_wartosc)
	}
	ColorChat(0, RED, "^x04[BaseBuilder]^x01 Gracze otrzymali:^x03 %d Monet^x01 za udzial w evencie",losowa_wartosc);
}
public AdminMenu( id ){
	if( !has_flag( id, "a" ) ){
		return PLUGIN_CONTINUE
	}
	//new Name[ 33 ]
	new gForm[ 256 ]	
	new menu = menu_create( "Co chcesz dodac?", "AdminMenu_2" )	
	format( gForm, sizeof( gForm ), "Dodaj: %s", PlkExp[ id ] ? "Monety" : "Exp" )
	menu_additem( menu, gForm )
	for( new i = 1, d = 0; i <= get_maxplayers( ); i ++ ){
		if( !is_user_connected( i ) )
			continue			
		//get_user_name( i, Name, sizeof( Name ) )
		format( gForm, sizeof( gForm ), "%s\w [\r%d Monet\w][\r%d Exp\w]\w[\r%d Poziom\w]", PlayerName[i], get_user_ammo_packi( i ), get_user_xp( i ), get_user_level( i ) )
		menu_additem( menu, gForm )
		PlayerList[ id ][ d++ ] = i
	}
	menu_display( id, menu, 0 )
	return PLUGIN_HANDLED
}
public AdminMenu_2( id, menu, item ){
	if( item == MENU_EXIT ){
		menu_destroy( menu )
		return PLUGIN_CONTINUE
	}
	if( item == 0 ){
		PlkExp[ id ] = !PlkExp[ id ]
		AdminMenu( id )
	}else{
		PlayerSwitched[ id ] = PlayerList[ id ][ item-1 ]
		client_cmd( id, "messagemode Ile dodajesz?" )
	}
	return PLUGIN_CONTINUE	
}
public AddAdmin( id ){
	if( !has_flag( id, "a" ) ){
		return PLUGIN_CONTINUE
	}
	new szText[ 12 ];//, Name[ 33 ]
	read_args( szText, sizeof( szText ) )
	remove_quotes( szText )
	new target = PlayerSwitched[ id ]
	if( is_user_connected( target ) ){
		if( PlkExp[ id ] ){
			set_user_ammo_packi( target, get_user_ammo_packi( target )+str_to_num( szText ) )
		}else{
			set_user_xp( target, get_user_xp( target )+str_to_num( szText ) )
		}
		//get_user_name( target, Name, sizeof( Name ) )
		ColorChat( id, RED, "^x04[%s]^x01 Dodano^x03 %d^x01 dla^x04 %s^x01", PlkExp[ id ] ? "Monety" : "Exp", str_to_num( szText ), PlayerName[target] )
	}
	return PLUGIN_CONTINUE
}

public UzyjSkrzynki(id)
{
	if( !is_user_connected(id) || !is_user_alive(id) )
		return PLUGIN_HANDLED;
	
	switch(random_num(1,1))
	{
		case 1:
		{
			new losowa_wartosc[2];
			losowa_wartosc[0] = random_num(38, 1839)// AmmoPacki
			losowa_wartosc[1] = random_num(38, 1839)// XP
			
			set_user_ammo_packi(id, get_user_ammo_packi(id)+losowa_wartosc[0])
			set_user_xp(id, get_user_xp(id)+losowa_wartosc[1])

			ColorChat(0, RED, "^x04[BaseBuilder]^x01 Gracz ^x04%s^x01 znalazl ^x03%iExpa^x01 i ^x03%iMonet^x01", PlayerName[id], losowa_wartosc[0], losowa_wartosc[1]);
		}
	}
	return PLUGIN_HANDLED;
}

public create_itm(id)
{ 
	new Float:origins[3]
	pev(id,pev_origin,origins);
	new entit=create_entity("info_target")
	
	origins[0]+=50.0
	origins[2]-=32.0
	
	set_pev(entit,pev_origin,origins)
	entity_set_model(entit,modelitem)
	set_pev(entit,pev_classname,"skrzynka");
	
	dllfunc(DLLFunc_Spawn, entit); 
	set_pev(entit,pev_solid,SOLID_BBOX); 
	set_pev(entit,pev_movetype,MOVETYPE_FLY);
	
	engfunc(EngFunc_SetSize,entit,{-1.1, -1.1, -1.1},{1.1, 1.1, 1.1});
	set_pev(entit,pev_movetype,MOVETYPE_FLY);
	engfunc(EngFunc_DropToFloor,entit);
	
	set_task(0.1,"force_spin",0,"",0,"b")
}
public fwd_touch(ent,id)
{       
	if(!is_user_alive(id)) return FMRES_IGNORED;
	
	if(!pev_valid(ent)) return FMRES_IGNORED;
	
	static classname[32];
	pev(ent,pev_classname,classname,31); 
	
	if(!equali(classname,"skrzynka")) return FMRES_IGNORED;
	
	if(pev(id,pev_button))
	{
		UzyjSkrzynki(id)
		engfunc(EngFunc_RemoveEntity,ent);
	}
	return FMRES_IGNORED;
}
public force_spin()
{
	static ent, classname[16], Float:angles[3]
	ent = engfunc(EngFunc_FindEntityInSphere,32,Float:{0.0,0.0,0.0},4800.0)
	while(ent)
	{
		if(pev_valid(ent))
		{
			pev(ent,pev_classname,classname,15)
			if(containi(classname,"skrzynka")!=-1)
			{
				pev(ent,pev_angles,angles)
				angles[1] += 45.0 / 10.0
				if(angles[1]>=180.0)
				{
					angles[1] -= 360.0
				}
				set_pev(ent,pev_angles,angles)
			}
		}
		ent = engfunc(EngFunc_FindEntityInSphere,ent,Float:{0.0,0.0,0.0},4800.0)
	}
}
public kill_all_entity(classname[]) {
	new iEnt = find_ent_by_class(-1, classname)
	while(iEnt > 0) {
		remove_entity(iEnt)
		iEnt = find_ent_by_class(iEnt, classname)		
	}
}

public NowaRunda()
{
	new num, players[32];
	get_players(players, num, "gh");
	for(new i = 0; i < num; i++)
	{
		if(task_exists(players[i]+997))
			remove_task(players[i]+997);
	}
	
	if(get_cvar_num("usun_sentry"))
		remove_entity_name("sentryG")
}

public client_disconnect(id)
{
	new ent = -1
	while((ent = find_ent_by_class(ent, "sentryG")))
	{
		if(entity_get_int(ent, EV_INT_iuser2) == id)
			remove_entity(ent);
	}
	return PLUGIN_CONTINUE;
}

public message_DeathMsg()
{
	new killer = get_msg_arg_int(1);
	if(ZmienKilla[1] & (1<<killer))
	{
		set_msg_arg_string(4, "m249");
		return PLUGIN_CONTINUE;
	}
	return PLUGIN_CONTINUE;
}

public Spawn(id)
{
	if(!is_user_alive(id) || !is_user_connected(id))
		return PLUGIN_CONTINUE;
	
	ilosc[id] = 1;
	
	return PLUGIN_CONTINUE;
}

public CreateSentry(id) 
{
	if(!(entity_get_int(id, EV_INT_flags) & FL_ONGROUND)) 
		return;
	
	new entlist[3];
	if(find_sphere_class(id, "func_bomb_target", 650.0, entlist, 2))
	{
		client_print(id, print_chat, "Jestes zbyt blisko BS'A");
		return;
	}
	if(find_sphere_class(id, "func_buyzone", 650.0, entlist, 2))
	{
		client_print(id, print_chat, "Jestes zbyt blisko Respa");
		return;
	}
	new num, players[32], Float:Origin[3];
	get_players(players, num, "gh");
	/*for(new a = 0; a < num; a++)
	{
		new i = players[a];
		if(get_user_team(id) != get_user_team(i))
			client_cmd(i, "spk sound/mw/sentrygun_enemy.wav");
		else
			client_cmd(i, "spk sound/mw/sentrygun_friend.wav");
	}*/
	print_info(id, "Sentry Gun");
	
	entity_get_vector(id, EV_VEC_origin, Origin);
	Origin[2] += 45.0;
	
	new health[12], ent = create_entity("func_breakable");
	get_cvar_string("zycie_sentry",health, charsmax(health));
	
	DispatchKeyValue(ent, "health", health);
	DispatchKeyValue(ent, "material", "6");
	
	entity_set_string(ent, EV_SZ_classname, "sentryG");
	entity_set_model(ent, "models/basebuilder/EVENT.mdl");
	
	entity_set_float(ent, EV_FL_takedamage, DAMAGE_YES);
	
	entity_set_size(ent, Float:{-16.0, -16.0, 0.0}, Float:{16.0, 16.0, 48.0});
	
	entity_set_origin(ent, Origin);
	entity_set_int(ent, EV_INT_solid, SOLID_SLIDEBOX);
	entity_set_int(ent, EV_INT_movetype, MOVETYPE_TOSS);
	entity_set_int(ent, EV_INT_iuser2, id);
	entity_set_vector(ent, EV_VEC_angles, Float:{0.0, 0.0, 0.0});
	entity_set_byte(ent, EV_BYTE_controller2, 127);
	
	entity_set_float(ent, EV_FL_nextthink, get_gametime()+1.0);
	
	sentrys[id] = false;
	emit_sound(ent, CHAN_ITEM, "mw/plant.wav", 1.0, ATTN_NORM, 0, PITCH_NORM);
}

public SentryThink(ent)
{
	if(!is_valid_ent(ent)) 
		return PLUGIN_CONTINUE;
	
	new Float:SentryOrigin[3], Float:closestOrigin[3];
	entity_get_vector(ent, EV_VEC_origin, SentryOrigin);
	
	new id = entity_get_int(ent, EV_INT_iuser2);
	new target = entity_get_edict(ent, EV_ENT_euser1);
	new firemods = entity_get_int(ent, EV_INT_iuser1);
	
	if(firemods)
	{ 
		if(/*ExecuteHam(Ham_FVisible, target, ent)*/fm_is_ent_visible(target, ent) && is_user_alive(target)) 
		{
			if(UTIL_In_FOV(target,ent))
			{
				goto fireoff;
			}
			
			new Float:TargetOrigin[3];
			entity_get_vector(target, EV_VEC_origin, TargetOrigin);
			
			emit_sound(ent, CHAN_AUTO, "mw/firemw.wav", 1.0, ATTN_NORM, 0, PITCH_NORM);
			sentry_turntotarget(ent, SentryOrigin, TargetOrigin);
			
			new Float:hitRatio = random_float(0.0, 1.0) - 0.2;
			if(hitRatio <= 0.0)
			{
				UTIL_Kill(id, target, random_float(5.0, 35.0), DMG_BULLET, 1);
				
				message_begin(MSG_BROADCAST, SVC_TEMPENTITY);
				write_byte(TE_TRACER);
				write_coord(floatround(SentryOrigin[0]));
				write_coord(floatround(SentryOrigin[1]));
				write_coord(floatround(SentryOrigin[2]));
				write_coord(floatround(TargetOrigin[0]));
				write_coord(floatround(TargetOrigin[1]));
				write_coord(floatround(TargetOrigin[2]));
				message_end();
			}
			entity_set_float(ent, EV_FL_nextthink, get_gametime()+0.1);
			return PLUGIN_CONTINUE;
		}
		else
		{
			fireoff:
			firemods = 0;
			entity_set_int(ent, EV_INT_iuser1, 0);
			entity_set_edict(ent, EV_ENT_euser1, 0);
			emit_sound(ent, CHAN_AUTO, "mw/sentrygun_stops.wav", 1.0, ATTN_NORM, 0, PITCH_NORM);
			
			entity_set_float(ent, EV_FL_nextthink, get_gametime()+1.0);
			return PLUGIN_CONTINUE;
		}
	}
	
	new closestTarget = getClosestPlayer(ent)
	if(closestTarget)
	{
		emit_sound(ent, CHAN_AUTO, "mw/sentrygun_starts.wav", 1.0, ATTN_NORM, 0, PITCH_NORM);
		entity_get_vector(closestTarget, EV_VEC_origin, closestOrigin);
		sentry_turntotarget(ent, SentryOrigin, closestOrigin);
		
		entity_set_int(ent, EV_INT_iuser1, 1);
		entity_set_edict(ent, EV_ENT_euser1, closestTarget);
		
		entity_set_float(ent, EV_FL_nextthink, get_gametime()+1.0);
		return PLUGIN_CONTINUE;
	}
	
	if(!firemods)
	{
		new controler1 = entity_get_byte(ent, EV_BYTE_controller1)+1;
		if(controler1 > 255)
			controler1 = 0;
		entity_set_byte(ent, EV_BYTE_controller1, controler1);
		
		new controler2 = entity_get_byte(ent, EV_BYTE_controller2);
		if(controler2 > 127 || controler2 < 127)
			entity_set_byte(ent, EV_BYTE_controller2, 127);
		
		entity_set_float(ent, EV_FL_nextthink, get_gametime()+0.05);
	}
	return PLUGIN_CONTINUE
}

public sentry_turntotarget(ent, Float:sentryOrigin[3], Float:closestOrigin[3]) 
{
	new newTrip, Float:newAngle = floatatan(((closestOrigin[1]-sentryOrigin[1])/(closestOrigin[0]-sentryOrigin[0])), radian) * 57.2957795;
	
	if(closestOrigin[0] < sentryOrigin[0])
		newAngle += 180.0;
	if(newAngle < 0.0)
		newAngle += 360.0;
	
	sentryOrigin[2] += 35.0
	if(closestOrigin[2] > sentryOrigin[2])
		newTrip = 0;
	if(closestOrigin[2] < sentryOrigin[2])
		newTrip = 255;
	if(closestOrigin[2] == sentryOrigin[2])
		newTrip = 127;
	
	entity_set_byte(ent, EV_BYTE_controller1,floatround(newAngle*0.70833));
	entity_set_byte(ent, EV_BYTE_controller2, newTrip);
	entity_set_byte(ent, EV_BYTE_controller3, entity_get_byte(ent, EV_BYTE_controller3)+20>255? 0: entity_get_byte(ent, EV_BYTE_controller3)+20);
}

public TakeDamage(ent, idinflictor, attacker, Float:damage, damagebits)
{
	if(!is_user_alive(attacker))
		return HAM_IGNORED;
	
	new classname[32];
	entity_get_string(ent, EV_SZ_classname, classname, 31);
	
	if(equal(classname, "sentryG")) 
	{
		new id = entity_get_int(ent, EV_INT_iuser2);
		if(get_user_team(attacker) == get_user_team(id))
			return HAM_SUPERCEDE;
		
		set_hudmessage(255, 0, 0, -1.0, 0.35, 0, 0.1, 1.0, 0.1, 0.2, -1)
		show_hudmessage(attacker, "Pozosta³o Zycia: %0.f", entity_get_float(ent, EV_FL_health));
		
		if(damage >= entity_get_float(ent, EV_FL_health))
		{
			new Float:Origin[3];
			entity_get_vector(ent, EV_VEC_origin, Origin);	
			new entlist[33];
			new numfound = find_sphere_class(ent, "player", 190.0, entlist, 32);
						
			for(new i=0; i < numfound; i++)
			{		
				new pid = entlist[i];
				
				if(!is_user_alive(pid) || get_user_team(id) == get_user_team(pid))
					continue;
				UTIL_Kill(id, pid, 70.0, (1<<24));			
				
			}
			client_cmd(id, "spk sound/mw/sentrygun_gone.wav");
			
			set_task(1.0, "del_sentry", ent);
			ColorChat(attacker, GREEN, "%s^1 zniszczyl dzialko.", PlayerName[attacker]);
			
			new losowa_wartosc[2];
			losowa_wartosc[0] = random_num(38, 1839)// AmmoPacki
			losowa_wartosc[1] = random_num(38, 1839)// XP
			
			set_user_ammo_packi(attacker, get_user_ammo_packi(attacker)+losowa_wartosc[0])
			set_user_xp(attacker, get_user_xp(attacker)+losowa_wartosc[1])
			
			ColorChat(0, RED, "^x04[BaseBuilder]^x01 Gracz ^x04%s^x01 dostal ^x03%iExpa^x01 i ^x03%iMonet^x01", PlayerName[attacker], losowa_wartosc[0], losowa_wartosc[1]);

		}
	}
	return HAM_IGNORED;
}

public del_sentry(ent)
{	
	remove_entity(ent);
}

stock UTIL_Kill(atakujacy, obrywajacy, Float:damage, damagebits, ile=0)
{
	ZmienKilla[ile] |= (1<<atakujacy);
	ExecuteHam(Ham_TakeDamage, obrywajacy, atakujacy, atakujacy, damage, damagebits);
	ZmienKilla[ile] &= ~(1<<atakujacy);
}

stock print_info(id, const nagroda[], const nazwa[] = "y")
{
	new nick[64];
	get_user_name(id, nick, 63);
}

stock bool:fm_is_ent_visible(index, entity, ignoremonsters = 0) 
{
	new Float:start[3], Float:dest[3];
	pev(index, pev_origin, start);
	pev(index, pev_view_ofs, dest);
	xs_vec_add(start, dest, start);
	
	pev(entity, pev_origin, dest);
	engfunc(EngFunc_TraceLine, start, dest, ignoremonsters, index, 0);
	
	new Float:fraction;
	get_tr2(0, TR_flFraction, fraction);
	if (fraction == 1.0 || get_tr2(0, TR_pHit) == entity)
		return true;
	
	return false;
}

stock bool:UTIL_In_FOV(id,ent)
{
	if((get_pdata_int(id, 510) & (1<<16)) && (Find_Angle(id, ent) > 0.0))
		return true;
	return false;
}

stock getClosestPlayer(ent)
{
	new iClosestPlayer = 0, Float:flClosestDist = MAX_DIST, Float:flDistanse, Float:fOrigin[2][3];
	new num, players[32];
	get_players(players, num, "gh")
	for(new a = 0; a < num; a++)
	{
		new i = players[a];
		if(!is_user_connected(i) || !is_user_alive(i) || /*!ExecuteHam(Ham_FVisible, i, ent)*/!fm_is_ent_visible(i, ent) || get_user_team(i) == get_user_team(entity_get_int(ent, EV_INT_iuser2)))
			continue;
		
		if(UTIL_In_FOV(i, ent))
			continue;
		
		entity_get_vector(i, EV_VEC_origin, fOrigin[0]);
		entity_get_vector(ent, EV_VEC_origin, fOrigin[1]);
		
		flDistanse = get_distance_f(fOrigin[0], fOrigin[1]);
		
		if(flDistanse <= flClosestDist)
		{
			iClosestPlayer = i;
			flClosestDist = flDistanse;
		}
	}
	return iClosestPlayer;
}

stock Float:Find_Angle(id, target)
{
	new Float:Origin[3], Float:TargetOrigin[3];
	pev(id,pev_origin, Origin);
	pev(target,pev_origin,TargetOrigin);
	
	new Float:Angles[3], Float:vec2LOS[3];
	pev(id,pev_angles, Angles);
	
	xs_vec_sub(TargetOrigin, Origin, vec2LOS);
	vec2LOS[2] = 0.0;
	
	new Float:veclength = vector_length(vec2LOS);
	if (veclength <= 0.0)
		vec2LOS[0] = vec2LOS[1] = 0.0;
	else
	{
		new Float:flLen = 1.0 / veclength;
		vec2LOS[0] = vec2LOS[0]*flLen;
		vec2LOS[1] = vec2LOS[1]*flLen;
	}
	engfunc(EngFunc_MakeVectors, Angles);
	
	new Float:v_forward[3];
	get_global_vector(GL_v_forward, v_forward);
	
	new Float:flDot = vec2LOS[0]*v_forward[0]+vec2LOS[1]*v_forward[1];
	if(flDot > 0.5)
		return flDot;
	
	return 0.0;
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1045\\ f0\\ fs16 \n\\ par }
*/
