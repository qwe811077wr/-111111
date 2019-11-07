#include "lua_custom_api_auto.hpp"
#include "game_connection.h"
#include "Commons.h"
#include "LocalNotificationHelp.h"
#include "RemoteNotificationHelp.h"
#include "utils.h"
#include "HttpDownload.h"
#include "HttpDownload.h"
#include "tolua_fix.h"
#include "LuaBasicConversions.h"
#include "SdkHelper.h"


int lua_custom_ProtocolPacket_readUChar(lua_State* tolua_S)
{
    int argc = 0;
    Foxair::ProtocolPacket* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"uq.ProtocolPacket",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (Foxair::ProtocolPacket*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj)
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_custom_ProtocolPacket_readUChar'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 0)
    {
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_custom_ProtocolPacket_readUChar'", nullptr);
            return 0;
        }
        uint16_t ret = cobj->readUChar();
        tolua_pushnumber(tolua_S,(lua_Number)ret);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "uq.ProtocolPacket:readUChar",argc, 0);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_custom_ProtocolPacket_readUChar'.",&tolua_err);
#endif

    return 0;
}
int lua_custom_ProtocolPacket_writeString(lua_State* tolua_S)
{
    int argc = 0;
    Foxair::ProtocolPacket* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"uq.ProtocolPacket",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (Foxair::ProtocolPacket*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj)
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_custom_ProtocolPacket_writeString'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 1)
    {
        std::string arg0;

        ok &= luaval_to_std_string(tolua_S, 2,&arg0, "uq.ProtocolPacket:writeString");
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_custom_ProtocolPacket_writeString'", nullptr);
            return 0;
        }
        cobj->writeString(arg0);
        lua_settop(tolua_S, 1);
        return 1;
    }
    if (argc == 2)
    {
        std::string arg0;
        int arg1;

        ok &= luaval_to_std_string(tolua_S, 2,&arg0, "uq.ProtocolPacket:writeString");

        ok &= luaval_to_int32(tolua_S, 3,(int *)&arg1, "uq.ProtocolPacket:writeString");
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_custom_ProtocolPacket_writeString'", nullptr);
            return 0;
        }
        cobj->writeString(arg0, arg1);
        lua_settop(tolua_S, 1);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "uq.ProtocolPacket:writeString",argc, 1);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_custom_ProtocolPacket_writeString'.",&tolua_err);
#endif

    return 0;
}
int lua_custom_ProtocolPacket_writeShort(lua_State* tolua_S)
{
    int argc = 0;
    Foxair::ProtocolPacket* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"uq.ProtocolPacket",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (Foxair::ProtocolPacket*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj)
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_custom_ProtocolPacket_writeShort'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 1)
    {
        int32_t arg0;

        ok &= luaval_to_int32(tolua_S, 2,&arg0, "uq.ProtocolPacket:writeShort");
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_custom_ProtocolPacket_writeShort'", nullptr);
            return 0;
        }
        cobj->writeShort(arg0);
        lua_settop(tolua_S, 1);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "uq.ProtocolPacket:writeShort",argc, 1);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_custom_ProtocolPacket_writeShort'.",&tolua_err);
#endif

    return 0;
}
int lua_custom_ProtocolPacket_readLongLong(lua_State* tolua_S)
{
    int argc = 0;
    Foxair::ProtocolPacket* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"uq.ProtocolPacket",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (Foxair::ProtocolPacket*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj)
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_custom_ProtocolPacket_readLongLong'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 0)
    {
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_custom_ProtocolPacket_readLongLong'", nullptr);
            return 0;
        }
        long long ret = cobj->readLongLong();
        tolua_pushnumber(tolua_S,(lua_Number)ret);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "uq.ProtocolPacket:readLongLong",argc, 0);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_custom_ProtocolPacket_readLongLong'.",&tolua_err);
#endif

    return 0;
}
int lua_custom_ProtocolPacket_readUShort(lua_State* tolua_S)
{
    int argc = 0;
    Foxair::ProtocolPacket* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"uq.ProtocolPacket",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (Foxair::ProtocolPacket*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj)
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_custom_ProtocolPacket_readUShort'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 0)
    {
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_custom_ProtocolPacket_readUShort'", nullptr);
            return 0;
        }
        unsigned short ret = cobj->readUShort();
        tolua_pushnumber(tolua_S,(lua_Number)ret);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "uq.ProtocolPacket:readUShort",argc, 0);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_custom_ProtocolPacket_readUShort'.",&tolua_err);
#endif

    return 0;
}
int lua_custom_ProtocolPacket_readUInt(lua_State* tolua_S)
{
    int argc = 0;
    Foxair::ProtocolPacket* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"uq.ProtocolPacket",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (Foxair::ProtocolPacket*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj)
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_custom_ProtocolPacket_readUInt'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 0)
    {
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_custom_ProtocolPacket_readUInt'", nullptr);
            return 0;
        }
        unsigned int ret = cobj->readUInt();
        tolua_pushnumber(tolua_S,(lua_Number)ret);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "uq.ProtocolPacket:readUInt",argc, 0);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_custom_ProtocolPacket_readUInt'.",&tolua_err);
#endif

    return 0;
}
int lua_custom_ProtocolPacket_size(lua_State* tolua_S)
{
    int argc = 0;
    Foxair::ProtocolPacket* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"uq.ProtocolPacket",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (Foxair::ProtocolPacket*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj)
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_custom_ProtocolPacket_size'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 0)
    {
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_custom_ProtocolPacket_size'", nullptr);
            return 0;
        }
        unsigned int ret = cobj->size();
        tolua_pushnumber(tolua_S,(lua_Number)ret);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "uq.ProtocolPacket:size",argc, 0);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_custom_ProtocolPacket_size'.",&tolua_err);
#endif

    return 0;
}
int lua_custom_ProtocolPacket_readFloat(lua_State* tolua_S)
{
    int argc = 0;
    Foxair::ProtocolPacket* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"uq.ProtocolPacket",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (Foxair::ProtocolPacket*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj)
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_custom_ProtocolPacket_readFloat'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 0)
    {
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_custom_ProtocolPacket_readFloat'", nullptr);
            return 0;
        }
        double ret = cobj->readFloat();
        tolua_pushnumber(tolua_S,(lua_Number)ret);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "uq.ProtocolPacket:readFloat",argc, 0);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_custom_ProtocolPacket_readFloat'.",&tolua_err);
#endif

    return 0;
}
int lua_custom_ProtocolPacket_writeDouble(lua_State* tolua_S)
{
    int argc = 0;
    Foxair::ProtocolPacket* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"uq.ProtocolPacket",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (Foxair::ProtocolPacket*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj)
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_custom_ProtocolPacket_writeDouble'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 1)
    {
        double arg0;

        ok &= luaval_to_number(tolua_S, 2,&arg0, "uq.ProtocolPacket:writeDouble");
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_custom_ProtocolPacket_writeDouble'", nullptr);
            return 0;
        }
        cobj->writeDouble(arg0);
        lua_settop(tolua_S, 1);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "uq.ProtocolPacket:writeDouble",argc, 1);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_custom_ProtocolPacket_writeDouble'.",&tolua_err);
#endif

    return 0;
}
int lua_custom_ProtocolPacket_readBuffer(lua_State* tolua_S)
{
    int argc = 0;
    Foxair::ProtocolPacket* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"uq.ProtocolPacket",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (Foxair::ProtocolPacket*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj)
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_custom_ProtocolPacket_readBuffer'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 2)
    {
        Foxair::ProtocolPacket* arg0;
        int arg1;

        ok &= luaval_to_object<Foxair::ProtocolPacket>(tolua_S, 2, "uq.ProtocolPacket",&arg0, "uq.ProtocolPacket:readBuffer");

        ok &= luaval_to_int32(tolua_S, 3,(int *)&arg1, "uq.ProtocolPacket:readBuffer");
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_custom_ProtocolPacket_readBuffer'", nullptr);
            return 0;
        }
        cobj->readBuffer(arg0, arg1);
        lua_settop(tolua_S, 1);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "uq.ProtocolPacket:readBuffer",argc, 2);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_custom_ProtocolPacket_readBuffer'.",&tolua_err);
#endif

    return 0;
}
int lua_custom_ProtocolPacket_buffer(lua_State* tolua_S)
{
    int argc = 0;
    Foxair::ProtocolPacket* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"uq.ProtocolPacket",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (Foxair::ProtocolPacket*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj)
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_custom_ProtocolPacket_buffer'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 0)
    {
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_custom_ProtocolPacket_buffer'", nullptr);
            return 0;
        }
        Foxair::Buffer* ret = cobj->buffer();
        #pragma warning NO CONVERSION FROM NATIVE FOR Buffer*;
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "uq.ProtocolPacket:buffer",argc, 0);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_custom_ProtocolPacket_buffer'.",&tolua_err);
#endif

    return 0;
}
int lua_custom_ProtocolPacket_writeFloat(lua_State* tolua_S)
{
    int argc = 0;
    Foxair::ProtocolPacket* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"uq.ProtocolPacket",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (Foxair::ProtocolPacket*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj)
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_custom_ProtocolPacket_writeFloat'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 1)
    {
        double arg0;

        ok &= luaval_to_number(tolua_S, 2,&arg0, "uq.ProtocolPacket:writeFloat");
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_custom_ProtocolPacket_writeFloat'", nullptr);
            return 0;
        }
        cobj->writeFloat(arg0);
        lua_settop(tolua_S, 1);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "uq.ProtocolPacket:writeFloat",argc, 1);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_custom_ProtocolPacket_writeFloat'.",&tolua_err);
#endif

    return 0;
}
int lua_custom_ProtocolPacket_subShort(lua_State* tolua_S)
{
    int argc = 0;
    Foxair::ProtocolPacket* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"uq.ProtocolPacket",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (Foxair::ProtocolPacket*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj)
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_custom_ProtocolPacket_subShort'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 1)
    {
        unsigned int arg0;

        ok &= luaval_to_uint32(tolua_S, 2,&arg0, "uq.ProtocolPacket:subShort");
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_custom_ProtocolPacket_subShort'", nullptr);
            return 0;
        }
        int32_t ret = cobj->subShort(arg0);
        tolua_pushnumber(tolua_S,(lua_Number)ret);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "uq.ProtocolPacket:subShort",argc, 1);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_custom_ProtocolPacket_subShort'.",&tolua_err);
#endif

    return 0;
}
int lua_custom_ProtocolPacket_type(lua_State* tolua_S)
{
    int argc = 0;
    Foxair::ProtocolPacket* cobj = nullptr;
    bool ok  = true;
#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"uq.ProtocolPacket",0,&tolua_err)) goto tolua_lerror;
#endif
    cobj = (Foxair::ProtocolPacket*)tolua_tousertype(tolua_S,1,0);
#if COCOS2D_DEBUG >= 1
    if (!cobj)
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_custom_ProtocolPacket_type'", nullptr);
        return 0;
    }
#endif
    argc = lua_gettop(tolua_S)-1;
    do{
        if (argc == 1) {
            int arg0;
            ok &= luaval_to_int32(tolua_S, 2,(int *)&arg0, "uq.ProtocolPacket:type");

            if (!ok) { break; }
            cobj->type(arg0);
            lua_settop(tolua_S, 1);
            return 1;
        }
    }while(0);
    ok  = true;
    do{
        if (argc == 0) {
            int ret = cobj->type();
            tolua_pushnumber(tolua_S,(lua_Number)ret);
            return 1;
        }
    }while(0);
    ok  = true;
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n",  "uq.ProtocolPacket:type",argc, 0);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_custom_ProtocolPacket_type'.",&tolua_err);
#endif

    return 0;
}
int lua_custom_ProtocolPacket_readShort(lua_State* tolua_S)
{
    int argc = 0;
    Foxair::ProtocolPacket* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"uq.ProtocolPacket",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (Foxair::ProtocolPacket*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj)
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_custom_ProtocolPacket_readShort'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 0)
    {
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_custom_ProtocolPacket_readShort'", nullptr);
            return 0;
        }
        int32_t ret = cobj->readShort();
        tolua_pushnumber(tolua_S,(lua_Number)ret);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "uq.ProtocolPacket:readShort",argc, 0);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_custom_ProtocolPacket_readShort'.",&tolua_err);
#endif

    return 0;
}
int lua_custom_ProtocolPacket_writeChar(lua_State* tolua_S)
{
    int argc = 0;
    Foxair::ProtocolPacket* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"uq.ProtocolPacket",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (Foxair::ProtocolPacket*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj)
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_custom_ProtocolPacket_writeChar'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 1)
    {
        int32_t arg0;

        ok &= luaval_to_int32(tolua_S, 2,&arg0, "uq.ProtocolPacket:writeChar");
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_custom_ProtocolPacket_writeChar'", nullptr);
            return 0;
        }
        cobj->writeChar(arg0);
        lua_settop(tolua_S, 1);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "uq.ProtocolPacket:writeChar",argc, 1);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_custom_ProtocolPacket_writeChar'.",&tolua_err);
#endif

    return 0;
}
int lua_custom_ProtocolPacket_subChar(lua_State* tolua_S)
{
    int argc = 0;
    Foxair::ProtocolPacket* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"uq.ProtocolPacket",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (Foxair::ProtocolPacket*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj)
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_custom_ProtocolPacket_subChar'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 1)
    {
        unsigned int arg0;

        ok &= luaval_to_uint32(tolua_S, 2,&arg0, "uq.ProtocolPacket:subChar");
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_custom_ProtocolPacket_subChar'", nullptr);
            return 0;
        }
        int32_t ret = cobj->subChar(arg0);
        tolua_pushnumber(tolua_S,(lua_Number)ret);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "uq.ProtocolPacket:subChar",argc, 1);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_custom_ProtocolPacket_subChar'.",&tolua_err);
#endif

    return 0;
}
int lua_custom_ProtocolPacket_readInt(lua_State* tolua_S)
{
    int argc = 0;
    Foxair::ProtocolPacket* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"uq.ProtocolPacket",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (Foxair::ProtocolPacket*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj)
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_custom_ProtocolPacket_readInt'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 0)
    {
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_custom_ProtocolPacket_readInt'", nullptr);
            return 0;
        }
        int ret = cobj->readInt();
        tolua_pushnumber(tolua_S,(lua_Number)ret);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "uq.ProtocolPacket:readInt",argc, 0);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_custom_ProtocolPacket_readInt'.",&tolua_err);
#endif

    return 0;
}
int lua_custom_ProtocolPacket_readReportData(lua_State* tolua_S)
{
    int argc = 0;
    Foxair::ProtocolPacket* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"uq.ProtocolPacket",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (Foxair::ProtocolPacket*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj)
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_custom_ProtocolPacket_readReportData'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 2)
    {
        const char* arg0;
        bool arg1;

        std::string arg0_tmp; ok &= luaval_to_std_string(tolua_S, 2, &arg0_tmp, "uq.ProtocolPacket:readReportData"); arg0 = arg0_tmp.c_str();

        ok &= luaval_to_boolean(tolua_S, 3,&arg1, "uq.ProtocolPacket:readReportData");
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_custom_ProtocolPacket_readReportData'", nullptr);
            return 0;
        }
        bool ret = cobj->readReportData(arg0, arg1);
        tolua_pushboolean(tolua_S,(bool)ret);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "uq.ProtocolPacket:readReportData",argc, 2);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_custom_ProtocolPacket_readReportData'.",&tolua_err);
#endif

    return 0;
}
int lua_custom_ProtocolPacket_readChar(lua_State* tolua_S)
{
    int argc = 0;
    Foxair::ProtocolPacket* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"uq.ProtocolPacket",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (Foxair::ProtocolPacket*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj)
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_custom_ProtocolPacket_readChar'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 0)
    {
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_custom_ProtocolPacket_readChar'", nullptr);
            return 0;
        }
        int32_t ret = cobj->readChar();
        tolua_pushnumber(tolua_S,(lua_Number)ret);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "uq.ProtocolPacket:readChar",argc, 0);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_custom_ProtocolPacket_readChar'.",&tolua_err);
#endif

    return 0;
}
int lua_custom_ProtocolPacket_readDouble(lua_State* tolua_S)
{
    int argc = 0;
    Foxair::ProtocolPacket* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"uq.ProtocolPacket",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (Foxair::ProtocolPacket*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj)
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_custom_ProtocolPacket_readDouble'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 0)
    {
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_custom_ProtocolPacket_readDouble'", nullptr);
            return 0;
        }
        double ret = cobj->readDouble();
        tolua_pushnumber(tolua_S,(lua_Number)ret);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "uq.ProtocolPacket:readDouble",argc, 0);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_custom_ProtocolPacket_readDouble'.",&tolua_err);
#endif

    return 0;
}
int lua_custom_ProtocolPacket_readString(lua_State* tolua_S)
{
    int argc = 0;
    Foxair::ProtocolPacket* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"uq.ProtocolPacket",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (Foxair::ProtocolPacket*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj)
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_custom_ProtocolPacket_readString'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 1)
    {
        unsigned int arg0;

        ok &= luaval_to_uint32(tolua_S, 2,&arg0, "uq.ProtocolPacket:readString");
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_custom_ProtocolPacket_readString'", nullptr);
            return 0;
        }
        std::string ret = cobj->readString(arg0);
        tolua_pushcppstring(tolua_S,ret);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "uq.ProtocolPacket:readString",argc, 1);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_custom_ProtocolPacket_readString'.",&tolua_err);
#endif

    return 0;
}
int lua_custom_ProtocolPacket_concat(lua_State* tolua_S)
{
    int argc = 0;
    Foxair::ProtocolPacket* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"uq.ProtocolPacket",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (Foxair::ProtocolPacket*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj)
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_custom_ProtocolPacket_concat'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 2)
    {
        Foxair::ProtocolPacket* arg0;
        int arg1;

        ok &= luaval_to_object<Foxair::ProtocolPacket>(tolua_S, 2, "uq.ProtocolPacket",&arg0, "uq.ProtocolPacket:concat");

        ok &= luaval_to_int32(tolua_S, 3,(int *)&arg1, "uq.ProtocolPacket:concat");
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_custom_ProtocolPacket_concat'", nullptr);
            return 0;
        }
        cobj->concat(arg0, arg1);
        lua_settop(tolua_S, 1);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "uq.ProtocolPacket:concat",argc, 2);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_custom_ProtocolPacket_concat'.",&tolua_err);
#endif

    return 0;
}
int lua_custom_ProtocolPacket_writeLongLong(lua_State* tolua_S)
{
    int argc = 0;
    Foxair::ProtocolPacket* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"uq.ProtocolPacket",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (Foxair::ProtocolPacket*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj)
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_custom_ProtocolPacket_writeLongLong'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 1)
    {
        long long arg0;

        ok &= luaval_to_long_long(tolua_S, 2,&arg0, "uq.ProtocolPacket:writeLongLong");
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_custom_ProtocolPacket_writeLongLong'", nullptr);
            return 0;
        }
        cobj->writeLongLong(arg0);
        lua_settop(tolua_S, 1);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "uq.ProtocolPacket:writeLongLong",argc, 1);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_custom_ProtocolPacket_writeLongLong'.",&tolua_err);
#endif

    return 0;
}
int lua_custom_ProtocolPacket_readLLongString(lua_State* tolua_S)
{
    int argc = 0;
    Foxair::ProtocolPacket* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"uq.ProtocolPacket",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (Foxair::ProtocolPacket*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj)
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_custom_ProtocolPacket_readLLongString'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 0)
    {
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_custom_ProtocolPacket_readLLongString'", nullptr);
            return 0;
        }
        std::string ret = cobj->readLLongString();
        tolua_pushcppstring(tolua_S,ret);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "uq.ProtocolPacket:readLLongString",argc, 0);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_custom_ProtocolPacket_readLLongString'.",&tolua_err);
#endif

    return 0;
}
int lua_custom_ProtocolPacket_del(lua_State* tolua_S)
{
    int argc = 0;
    Foxair::ProtocolPacket* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"uq.ProtocolPacket",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (Foxair::ProtocolPacket*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj)
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_custom_ProtocolPacket_del'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 0)
    {
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_custom_ProtocolPacket_del'", nullptr);
            return 0;
        }
        cobj->del();
        lua_settop(tolua_S, 1);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "uq.ProtocolPacket:del",argc, 0);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_custom_ProtocolPacket_del'.",&tolua_err);
#endif

    return 0;
}
int lua_custom_ProtocolPacket_writeInt(lua_State* tolua_S)
{
    int argc = 0;
    Foxair::ProtocolPacket* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"uq.ProtocolPacket",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (Foxair::ProtocolPacket*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj)
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_custom_ProtocolPacket_writeInt'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 1)
    {
        int arg0;

        ok &= luaval_to_int32(tolua_S, 2,(int *)&arg0, "uq.ProtocolPacket:writeInt");
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_custom_ProtocolPacket_writeInt'", nullptr);
            return 0;
        }
        cobj->writeInt(arg0);
        lua_settop(tolua_S, 1);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "uq.ProtocolPacket:writeInt",argc, 1);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_custom_ProtocolPacket_writeInt'.",&tolua_err);
#endif

    return 0;
}
int lua_custom_ProtocolPacket_constructor(lua_State* tolua_S)
{
    int argc = 0;
    Foxair::ProtocolPacket* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif



    argc = lua_gettop(tolua_S)-1;
    if (argc == 0)
    {
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_custom_ProtocolPacket_constructor'", nullptr);
            return 0;
        }
        cobj = new Foxair::ProtocolPacket();
        tolua_pushusertype(tolua_S,(void*)cobj,"uq.ProtocolPacket");
        tolua_register_gc(tolua_S,lua_gettop(tolua_S));
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "uq.ProtocolPacket:ProtocolPacket",argc, 0);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_error(tolua_S,"#ferror in function 'lua_custom_ProtocolPacket_constructor'.",&tolua_err);
#endif

    return 0;
}

static int lua_custom_ProtocolPacket_finalize(lua_State* tolua_S)
{
    printf("luabindings: finalizing LUA object (ProtocolPacket)");
    return 0;
}

int lua_register_custom_ProtocolPacket(lua_State* tolua_S)
{
    tolua_usertype(tolua_S,"uq.ProtocolPacket");
    tolua_cclass(tolua_S,"ProtocolPacket","uq.ProtocolPacket","",nullptr);

    tolua_beginmodule(tolua_S,"ProtocolPacket");
        tolua_function(tolua_S,"new",lua_custom_ProtocolPacket_constructor);
        tolua_function(tolua_S,"readUChar",lua_custom_ProtocolPacket_readUChar);
        tolua_function(tolua_S,"writeString",lua_custom_ProtocolPacket_writeString);
        tolua_function(tolua_S,"writeShort",lua_custom_ProtocolPacket_writeShort);
        tolua_function(tolua_S,"readLongLong",lua_custom_ProtocolPacket_readLongLong);
        tolua_function(tolua_S,"readUShort",lua_custom_ProtocolPacket_readUShort);
        tolua_function(tolua_S,"readUInt",lua_custom_ProtocolPacket_readUInt);
        tolua_function(tolua_S,"size",lua_custom_ProtocolPacket_size);
        tolua_function(tolua_S,"readFloat",lua_custom_ProtocolPacket_readFloat);
        tolua_function(tolua_S,"writeDouble",lua_custom_ProtocolPacket_writeDouble);
        tolua_function(tolua_S,"readBuffer",lua_custom_ProtocolPacket_readBuffer);
        tolua_function(tolua_S,"buffer",lua_custom_ProtocolPacket_buffer);
        tolua_function(tolua_S,"writeFloat",lua_custom_ProtocolPacket_writeFloat);
        tolua_function(tolua_S,"subShort",lua_custom_ProtocolPacket_subShort);
        tolua_function(tolua_S,"type",lua_custom_ProtocolPacket_type);
        tolua_function(tolua_S,"readShort",lua_custom_ProtocolPacket_readShort);
        tolua_function(tolua_S,"writeChar",lua_custom_ProtocolPacket_writeChar);
        tolua_function(tolua_S,"subChar",lua_custom_ProtocolPacket_subChar);
        tolua_function(tolua_S,"readInt",lua_custom_ProtocolPacket_readInt);
        tolua_function(tolua_S,"readReportData",lua_custom_ProtocolPacket_readReportData);
        tolua_function(tolua_S,"readChar",lua_custom_ProtocolPacket_readChar);
        tolua_function(tolua_S,"readDouble",lua_custom_ProtocolPacket_readDouble);
        tolua_function(tolua_S,"readString",lua_custom_ProtocolPacket_readString);
        tolua_function(tolua_S,"concat",lua_custom_ProtocolPacket_concat);
        tolua_function(tolua_S,"writeLongLong",lua_custom_ProtocolPacket_writeLongLong);
        tolua_function(tolua_S,"readLLongString",lua_custom_ProtocolPacket_readLLongString);
        tolua_function(tolua_S,"del",lua_custom_ProtocolPacket_del);
        tolua_function(tolua_S,"writeInt",lua_custom_ProtocolPacket_writeInt);
    tolua_endmodule(tolua_S);
    std::string typeName = typeid(Foxair::ProtocolPacket).name();
    g_luaType[typeName] = "uq.ProtocolPacket";
    g_typeCast["ProtocolPacket"] = "uq.ProtocolPacket";
    return 1;
}

int lua_custom_InetHelper_openUrl(lua_State* tolua_S)
{
    int argc = 0;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertable(tolua_S,1,"uq.InetHelper",0,&tolua_err)) goto tolua_lerror;
#endif

    argc = lua_gettop(tolua_S) - 1;

    if (argc == 1)
    {
        std::string arg0;
        ok &= luaval_to_std_string(tolua_S, 2,&arg0, "uq.InetHelper:openUrl");
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_custom_InetHelper_openUrl'", nullptr);
            return 0;
        }
        Foxair::InetHelper::openUrl(arg0);
        lua_settop(tolua_S, 1);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d\n ", "uq.InetHelper:openUrl",argc, 1);
    return 0;
#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_custom_InetHelper_openUrl'.",&tolua_err);
#endif
    return 0;
}
static int lua_custom_InetHelper_finalize(lua_State* tolua_S)
{
    printf("luabindings: finalizing LUA object (InetHelper)");
    return 0;
}

int lua_register_custom_InetHelper(lua_State* tolua_S)
{
    tolua_usertype(tolua_S,"uq.InetHelper");
    tolua_cclass(tolua_S,"InetHelper","uq.InetHelper","cc.CCObject",nullptr);

    tolua_beginmodule(tolua_S,"InetHelper");
        tolua_function(tolua_S,"openUrl", lua_custom_InetHelper_openUrl);
    tolua_endmodule(tolua_S);
    std::string typeName = typeid(Foxair::InetHelper).name();
    g_luaType[typeName] = "uq.InetHelper";
    g_typeCast["InetHelper"] = "uq.InetHelper";
    return 1;
}

int lua_custom_GameConnection_reset(lua_State* tolua_S)
{
    int argc = 0;
    Foxair::GameConnection* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"uq.GameConnection",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (Foxair::GameConnection*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj)
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_custom_GameConnection_reset'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 2)
    {
        std::string arg0;
        unsigned short arg1;

        ok &= luaval_to_std_string(tolua_S, 2,&arg0, "uq.GameConnection:reset");

        ok &= luaval_to_ushort(tolua_S, 3, &arg1, "uq.GameConnection:reset");
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_custom_GameConnection_reset'", nullptr);
            return 0;
        }
        cobj->reset(arg0, arg1);
        lua_settop(tolua_S, 1);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "uq.GameConnection:reset",argc, 2);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_custom_GameConnection_reset'.",&tolua_err);
#endif

    return 0;
}
int lua_custom_GameConnection_readRawPacket(lua_State* tolua_S)
{
    int argc = 0;
    Foxair::GameConnection* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"uq.GameConnection",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (Foxair::GameConnection*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj)
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_custom_GameConnection_readRawPacket'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 0)
    {
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_custom_GameConnection_readRawPacket'", nullptr);
            return 0;
        }
        Foxair::ProtocolPacket* ret = cobj->readRawPacket();
        object_to_luaval<Foxair::ProtocolPacket>(tolua_S, "uq.ProtocolPacket",(Foxair::ProtocolPacket*)ret);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "uq.GameConnection:readRawPacket",argc, 0);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_custom_GameConnection_readRawPacket'.",&tolua_err);
#endif

    return 0;
}
int lua_custom_GameConnection_readRawData(lua_State* tolua_S)
{
    int argc = 0;
    Foxair::GameConnection* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"uq.GameConnection",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (Foxair::GameConnection*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj)
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_custom_GameConnection_readRawData'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 1)
    {
        Foxair::Buffer arg0;

        #pragma warning NO CONVERSION TO NATIVE FOR Buffer
		ok = false;
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_custom_GameConnection_readRawData'", nullptr);
            return 0;
        }
        unsigned int ret = cobj->readRawData(arg0);
        tolua_pushnumber(tolua_S,(lua_Number)ret);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "uq.GameConnection:readRawData",argc, 1);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_custom_GameConnection_readRawData'.",&tolua_err);
#endif

    return 0;
}
int lua_custom_GameConnection_readKey(lua_State* tolua_S)
{
    int argc = 0;
    Foxair::GameConnection* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"uq.GameConnection",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (Foxair::GameConnection*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj)
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_custom_GameConnection_readKey'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 1)
    {
        std::string arg0;

        ok &= luaval_to_std_string(tolua_S, 2,&arg0, "uq.GameConnection:readKey");
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_custom_GameConnection_readKey'", nullptr);
            return 0;
        }
        cobj->readKey(arg0);
        lua_settop(tolua_S, 1);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "uq.GameConnection:readKey",argc, 1);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_custom_GameConnection_readKey'.",&tolua_err);
#endif

    return 0;
}
int lua_custom_GameConnection_sendProxy(lua_State* tolua_S)
{
    int argc = 0;
    Foxair::GameConnection* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"uq.GameConnection",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (Foxair::GameConnection*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj)
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_custom_GameConnection_sendProxy'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 2)
    {
        Foxair::ProtocolPacket* arg0;
        std::string arg1;

        ok &= luaval_to_object<Foxair::ProtocolPacket>(tolua_S, 2, "uq.ProtocolPacket",&arg0, "uq.GameConnection:sendProxy");

        ok &= luaval_to_std_string(tolua_S, 3,&arg1, "uq.GameConnection:sendProxy");
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_custom_GameConnection_sendProxy'", nullptr);
            return 0;
        }
        cobj->sendProxy(arg0, arg1);
        lua_settop(tolua_S, 1);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "uq.GameConnection:sendProxy",argc, 2);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_custom_GameConnection_sendProxy'.",&tolua_err);
#endif

    return 0;
}
int lua_custom_GameConnection_sendRawDataLua(lua_State* tolua_S)
{
    int argc = 0;
    Foxair::GameConnection* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"uq.GameConnection",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (Foxair::GameConnection*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj)
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_custom_GameConnection_sendRawDataLua'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 1)
    {
        Foxair::ProtocolPacket* arg0;

        ok &= luaval_to_object<Foxair::ProtocolPacket>(tolua_S, 2, "uq.ProtocolPacket",&arg0, "uq.GameConnection:sendRawDataLua");
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_custom_GameConnection_sendRawDataLua'", nullptr);
            return 0;
        }
        unsigned int ret = cobj->sendRawDataLua(arg0);
        tolua_pushnumber(tolua_S,(lua_Number)ret);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "uq.GameConnection:sendRawDataLua",argc, 1);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_custom_GameConnection_sendRawDataLua'.",&tolua_err);
#endif

    return 0;
}
int lua_custom_GameConnection_setErrorHandler(lua_State* tolua_S)
{
    int argc = 0;
    Foxair::GameConnection* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"uq.GameConnection",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (Foxair::GameConnection*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj)
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_custom_GameConnection_setErrorHandler'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 1)
    {
        int arg0;

        ok &= luaval_to_int32(tolua_S, 2,(int *)&arg0, "uq.GameConnection:setErrorHandler");
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_custom_GameConnection_setErrorHandler'", nullptr);
            return 0;
        }
        cobj->setErrorHandler(arg0);
        lua_settop(tolua_S, 1);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "uq.GameConnection:setErrorHandler",argc, 1);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_custom_GameConnection_setErrorHandler'.",&tolua_err);
#endif

    return 0;
}
int lua_custom_GameConnection_getServerTime(lua_State* tolua_S)
{
    int argc = 0;
    Foxair::GameConnection* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"uq.GameConnection",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (Foxair::GameConnection*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj)
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_custom_GameConnection_getServerTime'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 0)
    {
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_custom_GameConnection_getServerTime'", nullptr);
            return 0;
        }
        long long ret = cobj->getServerTime();
        tolua_pushnumber(tolua_S,(lua_Number)ret);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "uq.GameConnection:getServerTime",argc, 0);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_custom_GameConnection_getServerTime'.",&tolua_err);
#endif

    return 0;
}
int lua_custom_GameConnection_sendKey(lua_State* tolua_S)
{
    int argc = 0;
    Foxair::GameConnection* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"uq.GameConnection",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (Foxair::GameConnection*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj)
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_custom_GameConnection_sendKey'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 1)
    {
        std::string arg0;

        ok &= luaval_to_std_string(tolua_S, 2,&arg0, "uq.GameConnection:sendKey");
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_custom_GameConnection_sendKey'", nullptr);
            return 0;
        }
        cobj->sendKey(arg0);
        lua_settop(tolua_S, 1);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "uq.GameConnection:sendKey",argc, 1);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_custom_GameConnection_sendKey'.",&tolua_err);
#endif

    return 0;
}
int lua_custom_GameConnection_start(lua_State* tolua_S)
{
    int argc = 0;
    Foxair::GameConnection* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"uq.GameConnection",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (Foxair::GameConnection*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj)
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_custom_GameConnection_start'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 0)
    {
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_custom_GameConnection_start'", nullptr);
            return 0;
        }
        cobj->start();
        lua_settop(tolua_S, 1);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "uq.GameConnection:start",argc, 0);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_custom_GameConnection_start'.",&tolua_err);
#endif

    return 0;
}
int lua_custom_GameConnection_getState(lua_State* tolua_S)
{
    int argc = 0;
    Foxair::GameConnection* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"uq.GameConnection",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (Foxair::GameConnection*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj)
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_custom_GameConnection_getState'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 0)
    {
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_custom_GameConnection_getState'", nullptr);
            return 0;
        }
        int ret = (int)cobj->getState();
        tolua_pushnumber(tolua_S,(lua_Number)ret);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "uq.GameConnection:getState",argc, 0);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_custom_GameConnection_getState'.",&tolua_err);
#endif

    return 0;
}
int lua_custom_GameConnection_getPacket(lua_State* tolua_S)
{
    int argc = 0;
    Foxair::GameConnection* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"uq.GameConnection",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (Foxair::GameConnection*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj)
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_custom_GameConnection_getPacket'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 0)
    {
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_custom_GameConnection_getPacket'", nullptr);
            return 0;
        }
        Foxair::ProtocolPacket* ret = cobj->getPacket();
        object_to_luaval<Foxair::ProtocolPacket>(tolua_S, "uq.ProtocolPacket",(Foxair::ProtocolPacket*)ret);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "uq.GameConnection:getPacket",argc, 0);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_custom_GameConnection_getPacket'.",&tolua_err);
#endif

    return 0;
}
int lua_custom_GameConnection_sendPacket(lua_State* tolua_S)
{
    int argc = 0;
    Foxair::GameConnection* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"uq.GameConnection",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (Foxair::GameConnection*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj)
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_custom_GameConnection_sendPacket'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 1)
    {
        Foxair::ProtocolPacket* arg0;

        ok &= luaval_to_object<Foxair::ProtocolPacket>(tolua_S, 2, "uq.ProtocolPacket",&arg0, "uq.GameConnection:sendPacket");
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_custom_GameConnection_sendPacket'", nullptr);
            return 0;
        }
        cobj->sendPacket(arg0);
        lua_settop(tolua_S, 1);
        return 1;
    }
    if (argc == 2)
    {
        Foxair::ProtocolPacket* arg0;
        bool arg1;

        ok &= luaval_to_object<Foxair::ProtocolPacket>(tolua_S, 2, "uq.ProtocolPacket",&arg0, "uq.GameConnection:sendPacket");

        ok &= luaval_to_boolean(tolua_S, 3,&arg1, "uq.GameConnection:sendPacket");
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_custom_GameConnection_sendPacket'", nullptr);
            return 0;
        }
        cobj->sendPacket(arg0, arg1);
        lua_settop(tolua_S, 1);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "uq.GameConnection:sendPacket",argc, 1);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_custom_GameConnection_sendPacket'.",&tolua_err);
#endif

    return 0;
}
int lua_custom_GameConnection_close(lua_State* tolua_S)
{
    int argc = 0;
    Foxair::GameConnection* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"uq.GameConnection",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (Foxair::GameConnection*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj)
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_custom_GameConnection_close'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 0)
    {
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_custom_GameConnection_close'", nullptr);
            return 0;
        }
        cobj->close();
        lua_settop(tolua_S, 1);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "uq.GameConnection:close",argc, 0);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_custom_GameConnection_close'.",&tolua_err);
#endif

    return 0;
}
int lua_custom_GameConnection_readRawDataLua(lua_State* tolua_S)
{
    int argc = 0;
    Foxair::GameConnection* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"uq.GameConnection",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (Foxair::GameConnection*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj)
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_custom_GameConnection_readRawDataLua'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 1)
    {
        int arg0;

        ok &= luaval_to_int32(tolua_S, 2,(int *)&arg0, "uq.GameConnection:readRawDataLua");
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_custom_GameConnection_readRawDataLua'", nullptr);
            return 0;
        }
        Foxair::ProtocolPacket* ret = cobj->readRawDataLua(arg0);
        object_to_luaval<Foxair::ProtocolPacket>(tolua_S, "uq.ProtocolPacket",(Foxair::ProtocolPacket*)ret);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "uq.GameConnection:readRawDataLua",argc, 1);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_custom_GameConnection_readRawDataLua'.",&tolua_err);
#endif

    return 0;
}
int lua_custom_GameConnection_sendRawData(lua_State* tolua_S)
{
    int argc = 0;
    Foxair::GameConnection* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"uq.GameConnection",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (Foxair::GameConnection*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj)
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_custom_GameConnection_sendRawData'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 1)
    {
        Foxair::Buffer arg0;

        #pragma warning NO CONVERSION TO NATIVE FOR Buffer
		ok = false;
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_custom_GameConnection_sendRawData'", nullptr);
            return 0;
        }
        unsigned int ret = cobj->sendRawData(arg0);
        tolua_pushnumber(tolua_S,(lua_Number)ret);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "uq.GameConnection:sendRawData",argc, 1);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_custom_GameConnection_sendRawData'.",&tolua_err);
#endif

    return 0;
}
int lua_custom_GameConnection_connect(lua_State* tolua_S)
{
    int argc = 0;
    Foxair::GameConnection* cobj = nullptr;
    bool ok  = true;
#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"uq.GameConnection",0,&tolua_err)) goto tolua_lerror;
#endif
    cobj = (Foxair::GameConnection*)tolua_tousertype(tolua_S,1,0);
#if COCOS2D_DEBUG >= 1
    if (!cobj)
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_custom_GameConnection_connect'", nullptr);
        return 0;
    }
#endif
    argc = lua_gettop(tolua_S)-1;
    do{
        if (argc == 1) {
            int arg0;
            ok &= luaval_to_int32(tolua_S, 2,(int *)&arg0, "uq.GameConnection:connect");

            if (!ok) { break; }
            int ret = cobj->connect(arg0);
            tolua_pushnumber(tolua_S,(lua_Number)ret);
            return 1;
        }
    }while(0);
    ok  = true;
    do{
        if (argc == 0) {
            int ret = cobj->connect();
            tolua_pushnumber(tolua_S,(lua_Number)ret);
            return 1;
        }
    }while(0);
    ok  = true;
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n",  "uq.GameConnection:connect",argc, 0);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_custom_GameConnection_connect'.",&tolua_err);
#endif

    return 0;
}
int lua_custom_GameConnection_sharedGameConnection(lua_State* tolua_S)
{
    int argc = 0;
    bool ok  = true;
#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertable(tolua_S,1,"uq.GameConnection",0,&tolua_err)) goto tolua_lerror;
#endif

    argc = lua_gettop(tolua_S)-1;

    do
    {
        if (argc == 2)
        {
            std::string arg0;
            ok &= luaval_to_std_string(tolua_S, 2,&arg0, "uq.GameConnection:sharedGameConnection");
            if (!ok) { break; }
            unsigned short arg1;
            ok &= luaval_to_ushort(tolua_S, 3, &arg1, "uq.GameConnection:sharedGameConnection");
            if (!ok) { break; }
            Foxair::GameConnection* ret = Foxair::GameConnection::sharedGameConnection(arg0, arg1);
            object_to_luaval<Foxair::GameConnection>(tolua_S, "uq.GameConnection",(Foxair::GameConnection*)ret);
            return 1;
        }
    } while (0);
    ok  = true;
    do
    {
        if (argc == 0)
        {
            Foxair::GameConnection* ret = Foxair::GameConnection::sharedGameConnection();
            object_to_luaval<Foxair::GameConnection>(tolua_S, "uq.GameConnection",(Foxair::GameConnection*)ret);
            return 1;
        }
    } while (0);
    ok  = true;
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d", "uq.GameConnection:sharedGameConnection",argc, 0);
    return 0;
#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_custom_GameConnection_sharedGameConnection'.",&tolua_err);
#endif
    return 0;
}
int lua_custom_GameConnection_constructor(lua_State* tolua_S)
{
    int argc = 0;
    Foxair::GameConnection* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif



    argc = lua_gettop(tolua_S)-1;
    if (argc == 2)
    {
        std::string arg0;
        unsigned short arg1;

        ok &= luaval_to_std_string(tolua_S, 2,&arg0, "uq.GameConnection:GameConnection");

        ok &= luaval_to_ushort(tolua_S, 3, &arg1, "uq.GameConnection:GameConnection");
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_custom_GameConnection_constructor'", nullptr);
            return 0;
        }
        cobj = new Foxair::GameConnection(arg0, arg1);
        tolua_pushusertype(tolua_S,(void*)cobj,"uq.GameConnection");
        tolua_register_gc(tolua_S,lua_gettop(tolua_S));
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "uq.GameConnection:GameConnection",argc, 2);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_error(tolua_S,"#ferror in function 'lua_custom_GameConnection_constructor'.",&tolua_err);
#endif

    return 0;
}

static int lua_custom_GameConnection_finalize(lua_State* tolua_S)
{
    printf("luabindings: finalizing LUA object (GameConnection)");
    return 0;
}

int lua_register_custom_GameConnection(lua_State* tolua_S)
{
    tolua_usertype(tolua_S,"uq.GameConnection");
    tolua_cclass(tolua_S,"GameConnection","uq.GameConnection","cc.CCObject",nullptr);

    tolua_beginmodule(tolua_S,"GameConnection");
        tolua_function(tolua_S,"new",lua_custom_GameConnection_constructor);
        tolua_function(tolua_S,"reset",lua_custom_GameConnection_reset);
        tolua_function(tolua_S,"readRawPacket",lua_custom_GameConnection_readRawPacket);
        tolua_function(tolua_S,"readRawData",lua_custom_GameConnection_readRawData);
        tolua_function(tolua_S,"readKey",lua_custom_GameConnection_readKey);
        tolua_function(tolua_S,"sendProxy",lua_custom_GameConnection_sendProxy);
        tolua_function(tolua_S,"sendRawDataLua",lua_custom_GameConnection_sendRawDataLua);
        tolua_function(tolua_S,"setErrorHandler",lua_custom_GameConnection_setErrorHandler);
        tolua_function(tolua_S,"getServerTime",lua_custom_GameConnection_getServerTime);
        tolua_function(tolua_S,"sendKey",lua_custom_GameConnection_sendKey);
        tolua_function(tolua_S,"start",lua_custom_GameConnection_start);
        tolua_function(tolua_S,"getState",lua_custom_GameConnection_getState);
        tolua_function(tolua_S,"getPacket",lua_custom_GameConnection_getPacket);
        tolua_function(tolua_S,"sendPacket",lua_custom_GameConnection_sendPacket);
        tolua_function(tolua_S,"close",lua_custom_GameConnection_close);
        tolua_function(tolua_S,"readRawDataLua",lua_custom_GameConnection_readRawDataLua);
        tolua_function(tolua_S,"sendRawData",lua_custom_GameConnection_sendRawData);
        tolua_function(tolua_S,"connect",lua_custom_GameConnection_connect);
        tolua_function(tolua_S,"sharedGameConnection", lua_custom_GameConnection_sharedGameConnection);
    tolua_endmodule(tolua_S);
    std::string typeName = typeid(Foxair::GameConnection).name();
    g_luaType[typeName] = "uq.GameConnection";
    g_typeCast["GameConnection"] = "uq.GameConnection";
    return 1;
}

int lua_custom_Commons_unzip(lua_State* tolua_S)
{
    int argc = 0;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertable(tolua_S,1,"Commons",0,&tolua_err)) goto tolua_lerror;
#endif

    argc = lua_gettop(tolua_S) - 1;

    if (argc == 2)
    {
        std::string arg0;
        std::string arg1;
        ok &= luaval_to_std_string(tolua_S, 2,&arg0, "Commons:unzip");
        ok &= luaval_to_std_string(tolua_S, 3,&arg1, "Commons:unzip");
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_custom_Commons_unzip'", nullptr);
            return 0;
        }
        bool ret = Commons::unzip(arg0, arg1);
        tolua_pushboolean(tolua_S,(bool)ret);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d\n ", "Commons:unzip",argc, 2);
    return 0;
#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_custom_Commons_unzip'.",&tolua_err);
#endif
    return 0;
}
int lua_custom_Commons_sha1(lua_State* tolua_S)
{
    int argc = 0;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertable(tolua_S,1,"Commons",0,&tolua_err)) goto tolua_lerror;
#endif

    argc = lua_gettop(tolua_S) - 1;

    if (argc == 1)
    {
        std::string arg0;
        ok &= luaval_to_std_string(tolua_S, 2,&arg0, "Commons:sha1");
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_custom_Commons_sha1'", nullptr);
            return 0;
        }
        std::string ret = Commons::sha1(arg0);
        tolua_pushcppstring(tolua_S,ret);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d\n ", "Commons:sha1",argc, 1);
    return 0;
#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_custom_Commons_sha1'.",&tolua_err);
#endif
    return 0;
}
int lua_custom_Commons_trimChar(lua_State* tolua_S)
{
    int argc = 0;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertable(tolua_S,1,"Commons",0,&tolua_err)) goto tolua_lerror;
#endif

    argc = lua_gettop(tolua_S) - 1;

    if (argc == 2)
    {
        std::string arg0;
        int32_t arg1;
        ok &= luaval_to_std_string(tolua_S, 2,&arg0, "Commons:trimChar");
        ok &= luaval_to_int32(tolua_S, 3,&arg1, "Commons:trimChar");
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_custom_Commons_trimChar'", nullptr);
            return 0;
        }
        std::string& ret = Commons::trimChar(arg0, arg1);
        tolua_pushcppstring(tolua_S,ret);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d\n ", "Commons:trimChar",argc, 2);
    return 0;
#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_custom_Commons_trimChar'.",&tolua_err);
#endif
    return 0;
}
int lua_custom_Commons_base64_decode(lua_State* tolua_S)
{
    int argc = 0;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertable(tolua_S,1,"Commons",0,&tolua_err)) goto tolua_lerror;
#endif

    argc = lua_gettop(tolua_S) - 1;

    if (argc == 1)
    {
        std::string arg0;
        ok &= luaval_to_std_string(tolua_S, 2,&arg0, "Commons:base64_decode");
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_custom_Commons_base64_decode'", nullptr);
            return 0;
        }
        std::string ret = Commons::base64_decode(arg0);
        tolua_pushcppstring(tolua_S,ret);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d\n ", "Commons:base64_decode",argc, 1);
    return 0;
#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_custom_Commons_base64_decode'.",&tolua_err);
#endif
    return 0;
}
int lua_custom_Commons_hmacSha1(lua_State* tolua_S)
{
    int argc = 0;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertable(tolua_S,1,"Commons",0,&tolua_err)) goto tolua_lerror;
#endif

    argc = lua_gettop(tolua_S) - 1;

    if (argc == 2)
    {
        std::string arg0;
        std::string arg1;
        ok &= luaval_to_std_string(tolua_S, 2,&arg0, "Commons:hmacSha1");
        ok &= luaval_to_std_string(tolua_S, 3,&arg1, "Commons:hmacSha1");
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_custom_Commons_hmacSha1'", nullptr);
            return 0;
        }
        std::string ret = Commons::hmacSha1(arg0, arg1);
        tolua_pushcppstring(tolua_S,ret);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d\n ", "Commons:hmacSha1",argc, 2);
    return 0;
#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_custom_Commons_hmacSha1'.",&tolua_err);
#endif
    return 0;
}
int lua_custom_Commons_base64_encode(lua_State* tolua_S)
{
    int argc = 0;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertable(tolua_S,1,"Commons",0,&tolua_err)) goto tolua_lerror;
#endif

    argc = lua_gettop(tolua_S) - 1;

    if (argc == 1)
    {
        std::string arg0;
        ok &= luaval_to_std_string(tolua_S, 2,&arg0, "Commons:base64_encode");
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_custom_Commons_base64_encode'", nullptr);
            return 0;
        }
        std::string ret = Commons::base64_encode(arg0);
        tolua_pushcppstring(tolua_S,ret);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d\n ", "Commons:base64_encode",argc, 1);
    return 0;
#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_custom_Commons_base64_encode'.",&tolua_err);
#endif
    return 0;
}
int lua_custom_Commons_md5(lua_State* tolua_S)
{
    int argc = 0;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertable(tolua_S,1,"Commons",0,&tolua_err)) goto tolua_lerror;
#endif

    argc = lua_gettop(tolua_S) - 1;

    if (argc == 1)
    {
        std::string arg0;
        ok &= luaval_to_std_string(tolua_S, 2,&arg0, "Commons:md5");
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_custom_Commons_md5'", nullptr);
            return 0;
        }
        std::string ret = Commons::md5(arg0);
        tolua_pushcppstring(tolua_S,ret);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d\n ", "Commons:md5",argc, 1);
    return 0;
#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_custom_Commons_md5'.",&tolua_err);
#endif
    return 0;
}
int lua_custom_Commons_constructor(lua_State* tolua_S)
{
    int argc = 0;
    Commons* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif



    argc = lua_gettop(tolua_S)-1;
    if (argc == 0)
    {
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_custom_Commons_constructor'", nullptr);
            return 0;
        }
        cobj = new Commons();
        cobj->autorelease();
        int ID =  (int)cobj->_ID ;
        int* luaID =  &cobj->_luaID ;
        toluafix_pushusertype_ccobject(tolua_S, ID, luaID, (void*)cobj,"Commons");
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "Commons:Commons",argc, 0);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_error(tolua_S,"#ferror in function 'lua_custom_Commons_constructor'.",&tolua_err);
#endif

    return 0;
}

static int lua_custom_Commons_finalize(lua_State* tolua_S)
{
    printf("luabindings: finalizing LUA object (Commons)");
    return 0;
}

int lua_register_custom_Commons(lua_State* tolua_S)
{
    tolua_usertype(tolua_S,"Commons");
    tolua_cclass(tolua_S,"Commons","Commons","",nullptr);

    tolua_beginmodule(tolua_S,"Commons");
        tolua_function(tolua_S,"new",lua_custom_Commons_constructor);
        tolua_function(tolua_S,"unzip", lua_custom_Commons_unzip);
        tolua_function(tolua_S,"sha1", lua_custom_Commons_sha1);
        tolua_function(tolua_S,"trimChar", lua_custom_Commons_trimChar);
        tolua_function(tolua_S,"base64_decode", lua_custom_Commons_base64_decode);
        tolua_function(tolua_S,"hmacSha1", lua_custom_Commons_hmacSha1);
        tolua_function(tolua_S,"base64_encode", lua_custom_Commons_base64_encode);
        tolua_function(tolua_S,"md5", lua_custom_Commons_md5);
    tolua_endmodule(tolua_S);
    std::string typeName = typeid(Commons).name();
    g_luaType[typeName] = "Commons";
    g_typeCast["Commons"] = "Commons";
    return 1;
}

int lua_custom_LocalNotificationHelp_registerUserNotification(lua_State* tolua_S)
{
    int argc = 0;
    LocalNotificationHelp* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"LocalNotificationHelp",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (LocalNotificationHelp*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj)
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_custom_LocalNotificationHelp_registerUserNotification'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 0)
    {
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_custom_LocalNotificationHelp_registerUserNotification'", nullptr);
            return 0;
        }
        cobj->registerUserNotification();
        lua_settop(tolua_S, 1);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "LocalNotificationHelp:registerUserNotification",argc, 0);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_custom_LocalNotificationHelp_registerUserNotification'.",&tolua_err);
#endif

    return 0;
}
int lua_custom_LocalNotificationHelp_setLocalNotificationConfig(lua_State* tolua_S)
{
    int argc = 0;
    LocalNotificationHelp* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"LocalNotificationHelp",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (LocalNotificationHelp*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj)
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_custom_LocalNotificationHelp_setLocalNotificationConfig'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 1)
    {
        int arg0;

        ok &= luaval_to_int32(tolua_S, 2,(int *)&arg0, "LocalNotificationHelp:setLocalNotificationConfig");
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_custom_LocalNotificationHelp_setLocalNotificationConfig'", nullptr);
            return 0;
        }
        cobj->setLocalNotificationConfig(arg0);
        lua_settop(tolua_S, 1);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "LocalNotificationHelp:setLocalNotificationConfig",argc, 1);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_custom_LocalNotificationHelp_setLocalNotificationConfig'.",&tolua_err);
#endif

    return 0;
}
int lua_custom_LocalNotificationHelp_removeNotification(lua_State* tolua_S)
{
    int argc = 0;
    LocalNotificationHelp* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"LocalNotificationHelp",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (LocalNotificationHelp*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj)
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_custom_LocalNotificationHelp_removeNotification'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 0)
    {
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_custom_LocalNotificationHelp_removeNotification'", nullptr);
            return 0;
        }
        cobj->removeNotification();
        lua_settop(tolua_S, 1);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "LocalNotificationHelp:removeNotification",argc, 0);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_custom_LocalNotificationHelp_removeNotification'.",&tolua_err);
#endif

    return 0;
}
int lua_custom_LocalNotificationHelp_createLocalNotificationConfig(lua_State* tolua_S)
{
    int argc = 0;
    LocalNotificationHelp* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"LocalNotificationHelp",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (LocalNotificationHelp*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj)
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_custom_LocalNotificationHelp_createLocalNotificationConfig'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 0)
    {
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_custom_LocalNotificationHelp_createLocalNotificationConfig'", nullptr);
            return 0;
        }
        cobj->createLocalNotificationConfig();
        lua_settop(tolua_S, 1);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "LocalNotificationHelp:createLocalNotificationConfig",argc, 0);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_custom_LocalNotificationHelp_createLocalNotificationConfig'.",&tolua_err);
#endif

    return 0;
}
int lua_custom_LocalNotificationHelp_getLocalNotificationConfig(lua_State* tolua_S)
{
    int argc = 0;
    LocalNotificationHelp* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"LocalNotificationHelp",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (LocalNotificationHelp*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj)
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_custom_LocalNotificationHelp_getLocalNotificationConfig'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 0)
    {
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_custom_LocalNotificationHelp_getLocalNotificationConfig'", nullptr);
            return 0;
        }
        int ret = cobj->getLocalNotificationConfig();
        tolua_pushnumber(tolua_S,(lua_Number)ret);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "LocalNotificationHelp:getLocalNotificationConfig",argc, 0);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_custom_LocalNotificationHelp_getLocalNotificationConfig'.",&tolua_err);
#endif

    return 0;
}
int lua_custom_LocalNotificationHelp_addLocalNotification(lua_State* tolua_S)
{
    int argc = 0;
    LocalNotificationHelp* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"LocalNotificationHelp",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (LocalNotificationHelp*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj)
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_custom_LocalNotificationHelp_addLocalNotification'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 0)
    {
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_custom_LocalNotificationHelp_addLocalNotification'", nullptr);
            return 0;
        }
        cobj->addLocalNotification();
        lua_settop(tolua_S, 1);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "LocalNotificationHelp:addLocalNotification",argc, 0);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_custom_LocalNotificationHelp_addLocalNotification'.",&tolua_err);
#endif

    return 0;
}
int lua_custom_LocalNotificationHelp_getInstance(lua_State* tolua_S)
{
    int argc = 0;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertable(tolua_S,1,"LocalNotificationHelp",0,&tolua_err)) goto tolua_lerror;
#endif

    argc = lua_gettop(tolua_S) - 1;

    if (argc == 0)
    {
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_custom_LocalNotificationHelp_getInstance'", nullptr);
            return 0;
        }
        LocalNotificationHelp* ret = LocalNotificationHelp::getInstance();
        object_to_luaval<LocalNotificationHelp>(tolua_S, "LocalNotificationHelp",(LocalNotificationHelp*)ret);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d\n ", "LocalNotificationHelp:getInstance",argc, 0);
    return 0;
#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_custom_LocalNotificationHelp_getInstance'.",&tolua_err);
#endif
    return 0;
}
int lua_custom_LocalNotificationHelp_constructor(lua_State* tolua_S)
{
    int argc = 0;
    LocalNotificationHelp* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif



    argc = lua_gettop(tolua_S)-1;
    if (argc == 0)
    {
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_custom_LocalNotificationHelp_constructor'", nullptr);
            return 0;
        }
        cobj = new LocalNotificationHelp();
        cobj->autorelease();
        int ID =  (int)cobj->_ID ;
        int* luaID =  &cobj->_luaID ;
        toluafix_pushusertype_ccobject(tolua_S, ID, luaID, (void*)cobj,"LocalNotificationHelp");
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "LocalNotificationHelp:LocalNotificationHelp",argc, 0);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_error(tolua_S,"#ferror in function 'lua_custom_LocalNotificationHelp_constructor'.",&tolua_err);
#endif

    return 0;
}

static int lua_custom_LocalNotificationHelp_finalize(lua_State* tolua_S)
{
    printf("luabindings: finalizing LUA object (LocalNotificationHelp)");
    return 0;
}

int lua_register_custom_LocalNotificationHelp(lua_State* tolua_S)
{
    tolua_usertype(tolua_S,"LocalNotificationHelp");
    tolua_cclass(tolua_S,"LocalNotificationHelp","LocalNotificationHelp","",nullptr);

    tolua_beginmodule(tolua_S,"LocalNotificationHelp");
        tolua_function(tolua_S,"new",lua_custom_LocalNotificationHelp_constructor);
        tolua_function(tolua_S,"registerUserNotification",lua_custom_LocalNotificationHelp_registerUserNotification);
        tolua_function(tolua_S,"setLocalNotificationConfig",lua_custom_LocalNotificationHelp_setLocalNotificationConfig);
        tolua_function(tolua_S,"removeNotification",lua_custom_LocalNotificationHelp_removeNotification);
        tolua_function(tolua_S,"createLocalNotificationConfig",lua_custom_LocalNotificationHelp_createLocalNotificationConfig);
        tolua_function(tolua_S,"getLocalNotificationConfig",lua_custom_LocalNotificationHelp_getLocalNotificationConfig);
        tolua_function(tolua_S,"addLocalNotification",lua_custom_LocalNotificationHelp_addLocalNotification);
        tolua_function(tolua_S,"getInstance", lua_custom_LocalNotificationHelp_getInstance);
    tolua_endmodule(tolua_S);
    std::string typeName = typeid(LocalNotificationHelp).name();
    g_luaType[typeName] = "LocalNotificationHelp";
    g_typeCast["LocalNotificationHelp"] = "LocalNotificationHelp";
    return 1;
}

int lua_custom_RemoteNotificationHelp_getClientid(lua_State* tolua_S)
{
    int argc = 0;
    RemoteNotificationHelp* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"RemoteNotificationHelp",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (RemoteNotificationHelp*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj)
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_custom_RemoteNotificationHelp_getClientid'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 0)
    {
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_custom_RemoteNotificationHelp_getClientid'", nullptr);
            return 0;
        }
        std::string ret = cobj->getClientid();
        tolua_pushcppstring(tolua_S,ret);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "RemoteNotificationHelp:getClientid",argc, 0);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_custom_RemoteNotificationHelp_getClientid'.",&tolua_err);
#endif

    return 0;
}
int lua_custom_RemoteNotificationHelp_setDeviceToken(lua_State* tolua_S)
{
    int argc = 0;
    RemoteNotificationHelp* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"RemoteNotificationHelp",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (RemoteNotificationHelp*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj)
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_custom_RemoteNotificationHelp_setDeviceToken'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 1)
    {
        std::string arg0;

        ok &= luaval_to_std_string(tolua_S, 2,&arg0, "RemoteNotificationHelp:setDeviceToken");
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_custom_RemoteNotificationHelp_setDeviceToken'", nullptr);
            return 0;
        }
        cobj->setDeviceToken(arg0);
        lua_settop(tolua_S, 1);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "RemoteNotificationHelp:setDeviceToken",argc, 1);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_custom_RemoteNotificationHelp_setDeviceToken'.",&tolua_err);
#endif

    return 0;
}
int lua_custom_RemoteNotificationHelp_getDeviceToken(lua_State* tolua_S)
{
    int argc = 0;
    RemoteNotificationHelp* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"RemoteNotificationHelp",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (RemoteNotificationHelp*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj)
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_custom_RemoteNotificationHelp_getDeviceToken'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 0)
    {
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_custom_RemoteNotificationHelp_getDeviceToken'", nullptr);
            return 0;
        }
        std::string ret = cobj->getDeviceToken();
        tolua_pushcppstring(tolua_S,ret);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "RemoteNotificationHelp:getDeviceToken",argc, 0);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_custom_RemoteNotificationHelp_getDeviceToken'.",&tolua_err);
#endif

    return 0;
}
int lua_custom_RemoteNotificationHelp_getInstance(lua_State* tolua_S)
{
    int argc = 0;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertable(tolua_S,1,"RemoteNotificationHelp",0,&tolua_err)) goto tolua_lerror;
#endif

    argc = lua_gettop(tolua_S) - 1;

    if (argc == 0)
    {
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_custom_RemoteNotificationHelp_getInstance'", nullptr);
            return 0;
        }
        RemoteNotificationHelp* ret = RemoteNotificationHelp::getInstance();
        object_to_luaval<RemoteNotificationHelp>(tolua_S, "RemoteNotificationHelp",(RemoteNotificationHelp*)ret);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d\n ", "RemoteNotificationHelp:getInstance",argc, 0);
    return 0;
#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_custom_RemoteNotificationHelp_getInstance'.",&tolua_err);
#endif
    return 0;
}
int lua_custom_RemoteNotificationHelp_constructor(lua_State* tolua_S)
{
    int argc = 0;
    RemoteNotificationHelp* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif



    argc = lua_gettop(tolua_S)-1;
    if (argc == 0)
    {
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_custom_RemoteNotificationHelp_constructor'", nullptr);
            return 0;
        }
        cobj = new RemoteNotificationHelp();
        cobj->autorelease();
        int ID =  (int)cobj->_ID ;
        int* luaID =  &cobj->_luaID ;
        toluafix_pushusertype_ccobject(tolua_S, ID, luaID, (void*)cobj,"RemoteNotificationHelp");
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "RemoteNotificationHelp:RemoteNotificationHelp",argc, 0);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_error(tolua_S,"#ferror in function 'lua_custom_RemoteNotificationHelp_constructor'.",&tolua_err);
#endif

    return 0;
}

static int lua_custom_RemoteNotificationHelp_finalize(lua_State* tolua_S)
{
    printf("luabindings: finalizing LUA object (RemoteNotificationHelp)");
    return 0;
}

int lua_register_custom_RemoteNotificationHelp(lua_State* tolua_S)
{
    tolua_usertype(tolua_S,"RemoteNotificationHelp");
    tolua_cclass(tolua_S,"RemoteNotificationHelp","RemoteNotificationHelp","",nullptr);

    tolua_beginmodule(tolua_S,"RemoteNotificationHelp");
        tolua_function(tolua_S,"new",lua_custom_RemoteNotificationHelp_constructor);
        tolua_function(tolua_S,"getClientid",lua_custom_RemoteNotificationHelp_getClientid);
        tolua_function(tolua_S,"setDeviceToken",lua_custom_RemoteNotificationHelp_setDeviceToken);
        tolua_function(tolua_S,"getDeviceToken",lua_custom_RemoteNotificationHelp_getDeviceToken);
        tolua_function(tolua_S,"getInstance", lua_custom_RemoteNotificationHelp_getInstance);
    tolua_endmodule(tolua_S);
    std::string typeName = typeid(RemoteNotificationHelp).name();
    g_luaType[typeName] = "RemoteNotificationHelp";
    g_typeCast["RemoteNotificationHelp"] = "RemoteNotificationHelp";
    return 1;
}

int lua_custom_Utils_createGrayImage(lua_State* tolua_S)
{
    int argc = 0;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertable(tolua_S,1,"uq.Utils",0,&tolua_err)) goto tolua_lerror;
#endif

    argc = lua_gettop(tolua_S) - 1;

    if (argc == 1)
    {
        cocos2d::Image* arg0;
        ok &= luaval_to_object<cocos2d::Image>(tolua_S, 2, "cc.Image",&arg0, "uq.Utils:createGrayImage");
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_custom_Utils_createGrayImage'", nullptr);
            return 0;
        }
        Foxair::Utils::createGrayImage(arg0);
        lua_settop(tolua_S, 1);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d\n ", "uq.Utils:createGrayImage",argc, 1);
    return 0;
#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_custom_Utils_createGrayImage'.",&tolua_err);
#endif
    return 0;
}
int lua_custom_Utils_getPixelColor(lua_State* tolua_S)
{
    int argc = 0;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertable(tolua_S,1,"uq.Utils",0,&tolua_err)) goto tolua_lerror;
#endif

    argc = lua_gettop(tolua_S) - 1;

    if (argc == 3)
    {
        cocos2d::Image* arg0;
        unsigned int arg1;
        unsigned int arg2;
        ok &= luaval_to_object<cocos2d::Image>(tolua_S, 2, "cc.Image",&arg0, "uq.Utils:getPixelColor");
        ok &= luaval_to_uint32(tolua_S, 3,&arg1, "uq.Utils:getPixelColor");
        ok &= luaval_to_uint32(tolua_S, 4,&arg2, "uq.Utils:getPixelColor");
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_custom_Utils_getPixelColor'", nullptr);
            return 0;
        }
        unsigned int ret = Foxair::Utils::getPixelColor(arg0, arg1, arg2);
        tolua_pushnumber(tolua_S,(lua_Number)ret);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d\n ", "uq.Utils:getPixelColor",argc, 3);
    return 0;
#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_custom_Utils_getPixelColor'.",&tolua_err);
#endif
    return 0;
}
int lua_custom_Utils_getMilliSecond(lua_State* tolua_S)
{
    int argc = 0;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertable(tolua_S,1,"uq.Utils",0,&tolua_err)) goto tolua_lerror;
#endif

    argc = lua_gettop(tolua_S) - 1;

    if (argc == 0)
    {
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_custom_Utils_getMilliSecond'", nullptr);
            return 0;
        }
        long ret = Foxair::Utils::getMilliSecond();
        tolua_pushnumber(tolua_S,(lua_Number)ret);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d\n ", "uq.Utils:getMilliSecond",argc, 0);
    return 0;
#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_custom_Utils_getMilliSecond'.",&tolua_err);
#endif
    return 0;
}
int lua_custom_Utils_getNodePixelColor(lua_State* tolua_S)
{
    int argc = 0;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertable(tolua_S,1,"uq.Utils",0,&tolua_err)) goto tolua_lerror;
#endif

    argc = lua_gettop(tolua_S) - 1;

    if (argc == 3)
    {
        cocos2d::Node* arg0;
        unsigned int arg1;
        unsigned int arg2;
        ok &= luaval_to_object<cocos2d::Node>(tolua_S, 2, "cc.Node",&arg0, "uq.Utils:getNodePixelColor");
        ok &= luaval_to_uint32(tolua_S, 3,&arg1, "uq.Utils:getNodePixelColor");
        ok &= luaval_to_uint32(tolua_S, 4,&arg2, "uq.Utils:getNodePixelColor");
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_custom_Utils_getNodePixelColor'", nullptr);
            return 0;
        }
        unsigned int ret = Foxair::Utils::getNodePixelColor(arg0, arg1, arg2);
        tolua_pushnumber(tolua_S,(lua_Number)ret);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d\n ", "uq.Utils:getNodePixelColor",argc, 3);
    return 0;
#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_custom_Utils_getNodePixelColor'.",&tolua_err);
#endif
    return 0;
}
int lua_custom_Utils_getFileData(lua_State* tolua_S)
{
    int argc = 0;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertable(tolua_S,1,"uq.Utils",0,&tolua_err)) goto tolua_lerror;
#endif

    argc = lua_gettop(tolua_S) - 1;

    if (argc == 1)
    {
        std::string arg0;
        ok &= luaval_to_std_string(tolua_S, 2,&arg0, "uq.Utils:getFileData");
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_custom_Utils_getFileData'", nullptr);
            return 0;
        }
        Foxair::ProtocolPacket* ret = Foxair::Utils::getFileData(arg0);
        object_to_luaval<Foxair::ProtocolPacket>(tolua_S, "uq.ProtocolPacket",(Foxair::ProtocolPacket*)ret);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d\n ", "uq.Utils:getFileData",argc, 1);
    return 0;
#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_custom_Utils_getFileData'.",&tolua_err);
#endif
    return 0;
}
int lua_custom_Utils_md5(lua_State* tolua_S)
{
    int argc = 0;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertable(tolua_S,1,"uq.Utils",0,&tolua_err)) goto tolua_lerror;
#endif

    argc = lua_gettop(tolua_S) - 1;

    if (argc == 1)
    {
        std::string arg0;
        ok &= luaval_to_std_string(tolua_S, 2,&arg0, "uq.Utils:md5");
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_custom_Utils_md5'", nullptr);
            return 0;
        }
        std::string ret = Foxair::Utils::md5(arg0);
        tolua_pushcppstring(tolua_S,ret);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d\n ", "uq.Utils:md5",argc, 1);
    return 0;
#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_custom_Utils_md5'.",&tolua_err);
#endif
    return 0;
}
static int lua_custom_Utils_finalize(lua_State* tolua_S)
{
    printf("luabindings: finalizing LUA object (Utils)");
    return 0;
}

int lua_register_custom_Utils(lua_State* tolua_S)
{
    tolua_usertype(tolua_S,"uq.Utils");
    tolua_cclass(tolua_S,"Utils","uq.Utils","",nullptr);

    tolua_beginmodule(tolua_S,"Utils");
        tolua_function(tolua_S,"getMilliSecond", lua_custom_Utils_getMilliSecond);
        tolua_function(tolua_S,"getNodePixelColor", lua_custom_Utils_getNodePixelColor);
        tolua_function(tolua_S,"createGrayImage", lua_custom_Utils_createGrayImage);
        tolua_function(tolua_S,"getPixelColor", lua_custom_Utils_getPixelColor);
        tolua_function(tolua_S,"getFileData", lua_custom_Utils_getFileData);
        tolua_function(tolua_S,"md5", lua_custom_Utils_md5);
    tolua_endmodule(tolua_S);
    std::string typeName = typeid(Foxair::Utils).name();
    g_luaType[typeName] = "uq.Utils";
    g_typeCast["Utils"] = "uq.Utils";
    return 1;
}

int lua_custom_EventHttpDownload_getLoaded(lua_State* tolua_S)
{
    int argc = 0;
    Foxair::EventHttpDownload* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"uq.EventHttpDownload",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (Foxair::EventHttpDownload*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj)
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_custom_EventHttpDownload_getLoaded'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 0)
    {
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_custom_EventHttpDownload_getLoaded'", nullptr);
            return 0;
        }
        double ret = cobj->getLoaded();
        tolua_pushnumber(tolua_S,(lua_Number)ret);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "uq.EventHttpDownload:getLoaded",argc, 0);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_custom_EventHttpDownload_getLoaded'.",&tolua_err);
#endif

    return 0;
}
int lua_custom_EventHttpDownload_getDownloader(lua_State* tolua_S)
{
    int argc = 0;
    Foxair::EventHttpDownload* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"uq.EventHttpDownload",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (Foxair::EventHttpDownload*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj)
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_custom_EventHttpDownload_getDownloader'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 0)
    {
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_custom_EventHttpDownload_getDownloader'", nullptr);
            return 0;
        }
        Foxair::HttpDownload* ret = cobj->getDownloader();
        object_to_luaval<Foxair::HttpDownload>(tolua_S, "uq.HttpDownload",(Foxair::HttpDownload*)ret);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "uq.EventHttpDownload:getDownloader",argc, 0);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_custom_EventHttpDownload_getDownloader'.",&tolua_err);
#endif

    return 0;
}
int lua_custom_EventHttpDownload_getAssetId(lua_State* tolua_S)
{
    int argc = 0;
    Foxair::EventHttpDownload* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"uq.EventHttpDownload",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (Foxair::EventHttpDownload*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj)
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_custom_EventHttpDownload_getAssetId'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 0)
    {
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_custom_EventHttpDownload_getAssetId'", nullptr);
            return 0;
        }
        std::string ret = cobj->getAssetId();
        tolua_pushcppstring(tolua_S,ret);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "uq.EventHttpDownload:getAssetId",argc, 0);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_custom_EventHttpDownload_getAssetId'.",&tolua_err);
#endif

    return 0;
}
int lua_custom_EventHttpDownload_getCURLECode(lua_State* tolua_S)
{
    int argc = 0;
    Foxair::EventHttpDownload* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"uq.EventHttpDownload",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (Foxair::EventHttpDownload*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj)
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_custom_EventHttpDownload_getCURLECode'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 0)
    {
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_custom_EventHttpDownload_getCURLECode'", nullptr);
            return 0;
        }
        int ret = cobj->getCURLECode();
        tolua_pushnumber(tolua_S,(lua_Number)ret);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "uq.EventHttpDownload:getCURLECode",argc, 0);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_custom_EventHttpDownload_getCURLECode'.",&tolua_err);
#endif

    return 0;
}
int lua_custom_EventHttpDownload_getTotal(lua_State* tolua_S)
{
    int argc = 0;
    Foxair::EventHttpDownload* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"uq.EventHttpDownload",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (Foxair::EventHttpDownload*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj)
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_custom_EventHttpDownload_getTotal'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 0)
    {
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_custom_EventHttpDownload_getTotal'", nullptr);
            return 0;
        }
        double ret = cobj->getTotal();
        tolua_pushnumber(tolua_S,(lua_Number)ret);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "uq.EventHttpDownload:getTotal",argc, 0);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_custom_EventHttpDownload_getTotal'.",&tolua_err);
#endif

    return 0;
}
int lua_custom_EventHttpDownload_getMessage(lua_State* tolua_S)
{
    int argc = 0;
    Foxair::EventHttpDownload* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"uq.EventHttpDownload",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (Foxair::EventHttpDownload*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj)
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_custom_EventHttpDownload_getMessage'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 0)
    {
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_custom_EventHttpDownload_getMessage'", nullptr);
            return 0;
        }
        std::string ret = cobj->getMessage();
        tolua_pushcppstring(tolua_S,ret);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "uq.EventHttpDownload:getMessage",argc, 0);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_custom_EventHttpDownload_getMessage'.",&tolua_err);
#endif

    return 0;
}
int lua_custom_EventHttpDownload_getCURLMCode(lua_State* tolua_S)
{
    int argc = 0;
    Foxair::EventHttpDownload* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"uq.EventHttpDownload",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (Foxair::EventHttpDownload*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj)
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_custom_EventHttpDownload_getCURLMCode'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 0)
    {
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_custom_EventHttpDownload_getCURLMCode'", nullptr);
            return 0;
        }
        int ret = cobj->getCURLMCode();
        tolua_pushnumber(tolua_S,(lua_Number)ret);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "uq.EventHttpDownload:getCURLMCode",argc, 0);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_custom_EventHttpDownload_getCURLMCode'.",&tolua_err);
#endif

    return 0;
}
int lua_custom_EventHttpDownload_getEventCode(lua_State* tolua_S)
{
    int argc = 0;
    Foxair::EventHttpDownload* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"uq.EventHttpDownload",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (Foxair::EventHttpDownload*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj)
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_custom_EventHttpDownload_getEventCode'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 0)
    {
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_custom_EventHttpDownload_getEventCode'", nullptr);
            return 0;
        }
        int ret = (int)cobj->getEventCode();
        tolua_pushnumber(tolua_S,(lua_Number)ret);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "uq.EventHttpDownload:getEventCode",argc, 0);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_custom_EventHttpDownload_getEventCode'.",&tolua_err);
#endif

    return 0;
}
int lua_custom_EventHttpDownload_constructor(lua_State* tolua_S)
{
    int argc = 0;
    Foxair::EventHttpDownload* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif



    argc = lua_gettop(tolua_S)-1;
    if (argc == 3)
    {
        std::string arg0;
        Foxair::HttpDownload* arg1;
        Foxair::EventHttpDownload::EventCode arg2;

        ok &= luaval_to_std_string(tolua_S, 2,&arg0, "uq.EventHttpDownload:EventHttpDownload");

        ok &= luaval_to_object<Foxair::HttpDownload>(tolua_S, 3, "uq.HttpDownload",&arg1, "uq.EventHttpDownload:EventHttpDownload");

        ok &= luaval_to_int32(tolua_S, 4,(int *)&arg2, "uq.EventHttpDownload:EventHttpDownload");
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_custom_EventHttpDownload_constructor'", nullptr);
            return 0;
        }
        cobj = new Foxair::EventHttpDownload(arg0, arg1, arg2);
        cobj->autorelease();
        int ID =  (int)cobj->_ID ;
        int* luaID =  &cobj->_luaID ;
        toluafix_pushusertype_ccobject(tolua_S, ID, luaID, (void*)cobj,"uq.EventHttpDownload");
        return 1;
    }
    if (argc == 4)
    {
        std::string arg0;
        Foxair::HttpDownload* arg1;
        Foxair::EventHttpDownload::EventCode arg2;
        double arg3;

        ok &= luaval_to_std_string(tolua_S, 2,&arg0, "uq.EventHttpDownload:EventHttpDownload");

        ok &= luaval_to_object<Foxair::HttpDownload>(tolua_S, 3, "uq.HttpDownload",&arg1, "uq.EventHttpDownload:EventHttpDownload");

        ok &= luaval_to_int32(tolua_S, 4,(int *)&arg2, "uq.EventHttpDownload:EventHttpDownload");

        ok &= luaval_to_number(tolua_S, 5,&arg3, "uq.EventHttpDownload:EventHttpDownload");
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_custom_EventHttpDownload_constructor'", nullptr);
            return 0;
        }
        cobj = new Foxair::EventHttpDownload(arg0, arg1, arg2, arg3);
        cobj->autorelease();
        int ID =  (int)cobj->_ID ;
        int* luaID =  &cobj->_luaID ;
        toluafix_pushusertype_ccobject(tolua_S, ID, luaID, (void*)cobj,"uq.EventHttpDownload");
        return 1;
    }
    if (argc == 5)
    {
        std::string arg0;
        Foxair::HttpDownload* arg1;
        Foxair::EventHttpDownload::EventCode arg2;
        double arg3;
        double arg4;

        ok &= luaval_to_std_string(tolua_S, 2,&arg0, "uq.EventHttpDownload:EventHttpDownload");

        ok &= luaval_to_object<Foxair::HttpDownload>(tolua_S, 3, "uq.HttpDownload",&arg1, "uq.EventHttpDownload:EventHttpDownload");

        ok &= luaval_to_int32(tolua_S, 4,(int *)&arg2, "uq.EventHttpDownload:EventHttpDownload");

        ok &= luaval_to_number(tolua_S, 5,&arg3, "uq.EventHttpDownload:EventHttpDownload");

        ok &= luaval_to_number(tolua_S, 6,&arg4, "uq.EventHttpDownload:EventHttpDownload");
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_custom_EventHttpDownload_constructor'", nullptr);
            return 0;
        }
        cobj = new Foxair::EventHttpDownload(arg0, arg1, arg2, arg3, arg4);
        cobj->autorelease();
        int ID =  (int)cobj->_ID ;
        int* luaID =  &cobj->_luaID ;
        toluafix_pushusertype_ccobject(tolua_S, ID, luaID, (void*)cobj,"uq.EventHttpDownload");
        return 1;
    }
    if (argc == 6)
    {
        std::string arg0;
        Foxair::HttpDownload* arg1;
        Foxair::EventHttpDownload::EventCode arg2;
        double arg3;
        double arg4;
        std::string arg5;

        ok &= luaval_to_std_string(tolua_S, 2,&arg0, "uq.EventHttpDownload:EventHttpDownload");

        ok &= luaval_to_object<Foxair::HttpDownload>(tolua_S, 3, "uq.HttpDownload",&arg1, "uq.EventHttpDownload:EventHttpDownload");

        ok &= luaval_to_int32(tolua_S, 4,(int *)&arg2, "uq.EventHttpDownload:EventHttpDownload");

        ok &= luaval_to_number(tolua_S, 5,&arg3, "uq.EventHttpDownload:EventHttpDownload");

        ok &= luaval_to_number(tolua_S, 6,&arg4, "uq.EventHttpDownload:EventHttpDownload");

        ok &= luaval_to_std_string(tolua_S, 7,&arg5, "uq.EventHttpDownload:EventHttpDownload");
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_custom_EventHttpDownload_constructor'", nullptr);
            return 0;
        }
        cobj = new Foxair::EventHttpDownload(arg0, arg1, arg2, arg3, arg4, arg5);
        cobj->autorelease();
        int ID =  (int)cobj->_ID ;
        int* luaID =  &cobj->_luaID ;
        toluafix_pushusertype_ccobject(tolua_S, ID, luaID, (void*)cobj,"uq.EventHttpDownload");
        return 1;
    }
    if (argc == 7)
    {
        std::string arg0;
        Foxair::HttpDownload* arg1;
        Foxair::EventHttpDownload::EventCode arg2;
        double arg3;
        double arg4;
        std::string arg5;
        std::string arg6;

        ok &= luaval_to_std_string(tolua_S, 2,&arg0, "uq.EventHttpDownload:EventHttpDownload");

        ok &= luaval_to_object<Foxair::HttpDownload>(tolua_S, 3, "uq.HttpDownload",&arg1, "uq.EventHttpDownload:EventHttpDownload");

        ok &= luaval_to_int32(tolua_S, 4,(int *)&arg2, "uq.EventHttpDownload:EventHttpDownload");

        ok &= luaval_to_number(tolua_S, 5,&arg3, "uq.EventHttpDownload:EventHttpDownload");

        ok &= luaval_to_number(tolua_S, 6,&arg4, "uq.EventHttpDownload:EventHttpDownload");

        ok &= luaval_to_std_string(tolua_S, 7,&arg5, "uq.EventHttpDownload:EventHttpDownload");

        ok &= luaval_to_std_string(tolua_S, 8,&arg6, "uq.EventHttpDownload:EventHttpDownload");
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_custom_EventHttpDownload_constructor'", nullptr);
            return 0;
        }
        cobj = new Foxair::EventHttpDownload(arg0, arg1, arg2, arg3, arg4, arg5, arg6);
        cobj->autorelease();
        int ID =  (int)cobj->_ID ;
        int* luaID =  &cobj->_luaID ;
        toluafix_pushusertype_ccobject(tolua_S, ID, luaID, (void*)cobj,"uq.EventHttpDownload");
        return 1;
    }
    if (argc == 8)
    {
        std::string arg0;
        Foxair::HttpDownload* arg1;
        Foxair::EventHttpDownload::EventCode arg2;
        double arg3;
        double arg4;
        std::string arg5;
        std::string arg6;
        int arg7;

        ok &= luaval_to_std_string(tolua_S, 2,&arg0, "uq.EventHttpDownload:EventHttpDownload");

        ok &= luaval_to_object<Foxair::HttpDownload>(tolua_S, 3, "uq.HttpDownload",&arg1, "uq.EventHttpDownload:EventHttpDownload");

        ok &= luaval_to_int32(tolua_S, 4,(int *)&arg2, "uq.EventHttpDownload:EventHttpDownload");

        ok &= luaval_to_number(tolua_S, 5,&arg3, "uq.EventHttpDownload:EventHttpDownload");

        ok &= luaval_to_number(tolua_S, 6,&arg4, "uq.EventHttpDownload:EventHttpDownload");

        ok &= luaval_to_std_string(tolua_S, 7,&arg5, "uq.EventHttpDownload:EventHttpDownload");

        ok &= luaval_to_std_string(tolua_S, 8,&arg6, "uq.EventHttpDownload:EventHttpDownload");

        ok &= luaval_to_int32(tolua_S, 9,(int *)&arg7, "uq.EventHttpDownload:EventHttpDownload");
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_custom_EventHttpDownload_constructor'", nullptr);
            return 0;
        }
        cobj = new Foxair::EventHttpDownload(arg0, arg1, arg2, arg3, arg4, arg5, arg6, arg7);
        cobj->autorelease();
        int ID =  (int)cobj->_ID ;
        int* luaID =  &cobj->_luaID ;
        toluafix_pushusertype_ccobject(tolua_S, ID, luaID, (void*)cobj,"uq.EventHttpDownload");
        return 1;
    }
    if (argc == 9)
    {
        std::string arg0;
        Foxair::HttpDownload* arg1;
        Foxair::EventHttpDownload::EventCode arg2;
        double arg3;
        double arg4;
        std::string arg5;
        std::string arg6;
        int arg7;
        int arg8;

        ok &= luaval_to_std_string(tolua_S, 2,&arg0, "uq.EventHttpDownload:EventHttpDownload");

        ok &= luaval_to_object<Foxair::HttpDownload>(tolua_S, 3, "uq.HttpDownload",&arg1, "uq.EventHttpDownload:EventHttpDownload");

        ok &= luaval_to_int32(tolua_S, 4,(int *)&arg2, "uq.EventHttpDownload:EventHttpDownload");

        ok &= luaval_to_number(tolua_S, 5,&arg3, "uq.EventHttpDownload:EventHttpDownload");

        ok &= luaval_to_number(tolua_S, 6,&arg4, "uq.EventHttpDownload:EventHttpDownload");

        ok &= luaval_to_std_string(tolua_S, 7,&arg5, "uq.EventHttpDownload:EventHttpDownload");

        ok &= luaval_to_std_string(tolua_S, 8,&arg6, "uq.EventHttpDownload:EventHttpDownload");

        ok &= luaval_to_int32(tolua_S, 9,(int *)&arg7, "uq.EventHttpDownload:EventHttpDownload");

        ok &= luaval_to_int32(tolua_S, 10,(int *)&arg8, "uq.EventHttpDownload:EventHttpDownload");
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_custom_EventHttpDownload_constructor'", nullptr);
            return 0;
        }
        cobj = new Foxair::EventHttpDownload(arg0, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8);
        cobj->autorelease();
        int ID =  (int)cobj->_ID ;
        int* luaID =  &cobj->_luaID ;
        toluafix_pushusertype_ccobject(tolua_S, ID, luaID, (void*)cobj,"uq.EventHttpDownload");
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "uq.EventHttpDownload:EventHttpDownload",argc, 3);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_error(tolua_S,"#ferror in function 'lua_custom_EventHttpDownload_constructor'.",&tolua_err);
#endif

    return 0;
}

static int lua_custom_EventHttpDownload_finalize(lua_State* tolua_S)
{
    printf("luabindings: finalizing LUA object (EventHttpDownload)");
    return 0;
}

int lua_register_custom_EventHttpDownload(lua_State* tolua_S)
{
    tolua_usertype(tolua_S,"uq.EventHttpDownload");
    tolua_cclass(tolua_S,"EventHttpDownload","uq.EventHttpDownload","cc.EventCustom",nullptr);

    tolua_beginmodule(tolua_S,"EventHttpDownload");
        tolua_function(tolua_S,"new",lua_custom_EventHttpDownload_constructor);
        tolua_function(tolua_S,"getLoaded",lua_custom_EventHttpDownload_getLoaded);
        tolua_function(tolua_S,"getDownloader",lua_custom_EventHttpDownload_getDownloader);
        tolua_function(tolua_S,"getAssetId",lua_custom_EventHttpDownload_getAssetId);
        tolua_function(tolua_S,"getCURLECode",lua_custom_EventHttpDownload_getCURLECode);
        tolua_function(tolua_S,"getTotal",lua_custom_EventHttpDownload_getTotal);
        tolua_function(tolua_S,"getMessage",lua_custom_EventHttpDownload_getMessage);
        tolua_function(tolua_S,"getCURLMCode",lua_custom_EventHttpDownload_getCURLMCode);
        tolua_function(tolua_S,"getEventCode",lua_custom_EventHttpDownload_getEventCode);
    tolua_endmodule(tolua_S);
    std::string typeName = typeid(Foxair::EventHttpDownload).name();
    g_luaType[typeName] = "uq.EventHttpDownload";
    g_typeCast["EventHttpDownload"] = "uq.EventHttpDownload";
    return 1;
}

int lua_custom_HttpDownload_eventName(lua_State* tolua_S)
{
    int argc = 0;
    Foxair::HttpDownload* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"uq.HttpDownload",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (Foxair::HttpDownload*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj)
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_custom_HttpDownload_eventName'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 0)
    {
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_custom_HttpDownload_eventName'", nullptr);
            return 0;
        }
        std::string ret = cobj->eventName();
        tolua_pushcppstring(tolua_S,ret);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "uq.HttpDownload:eventName",argc, 0);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_custom_HttpDownload_eventName'.",&tolua_err);
#endif

    return 0;
}
int lua_custom_HttpDownload_downloadFile(lua_State* tolua_S)
{
    int argc = 0;
    Foxair::HttpDownload* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"uq.HttpDownload",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (Foxair::HttpDownload*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj)
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_custom_HttpDownload_downloadFile'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 3)
    {
        std::string arg0;
        std::string arg1;
        std::string arg2;

        ok &= luaval_to_std_string(tolua_S, 2,&arg0, "uq.HttpDownload:downloadFile");

        ok &= luaval_to_std_string(tolua_S, 3,&arg1, "uq.HttpDownload:downloadFile");

        ok &= luaval_to_std_string(tolua_S, 4,&arg2, "uq.HttpDownload:downloadFile");
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_custom_HttpDownload_downloadFile'", nullptr);
            return 0;
        }
        cobj->downloadFile(arg0, arg1, arg2);
        lua_settop(tolua_S, 1);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "uq.HttpDownload:downloadFile",argc, 3);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_custom_HttpDownload_downloadFile'.",&tolua_err);
#endif

    return 0;
}
int lua_custom_HttpDownload_create(lua_State* tolua_S)
{
    int argc = 0;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertable(tolua_S,1,"uq.HttpDownload",0,&tolua_err)) goto tolua_lerror;
#endif

    argc = lua_gettop(tolua_S) - 1;

    if (argc == 0)
    {
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_custom_HttpDownload_create'", nullptr);
            return 0;
        }
        Foxair::HttpDownload* ret = Foxair::HttpDownload::create();
        object_to_luaval<Foxair::HttpDownload>(tolua_S, "uq.HttpDownload",(Foxair::HttpDownload*)ret);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d\n ", "uq.HttpDownload:create",argc, 0);
    return 0;
#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_custom_HttpDownload_create'.",&tolua_err);
#endif
    return 0;
}
int lua_custom_HttpDownload_constructor(lua_State* tolua_S)
{
    int argc = 0;
    Foxair::HttpDownload* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif



    argc = lua_gettop(tolua_S)-1;
    if (argc == 0)
    {
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_custom_HttpDownload_constructor'", nullptr);
            return 0;
        }
        cobj = new Foxair::HttpDownload();
        cobj->autorelease();
        int ID =  (int)cobj->_ID ;
        int* luaID =  &cobj->_luaID ;
        toluafix_pushusertype_ccobject(tolua_S, ID, luaID, (void*)cobj,"uq.HttpDownload");
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "uq.HttpDownload:HttpDownload",argc, 0);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_error(tolua_S,"#ferror in function 'lua_custom_HttpDownload_constructor'.",&tolua_err);
#endif

    return 0;
}

static int lua_custom_HttpDownload_finalize(lua_State* tolua_S)
{
    printf("luabindings: finalizing LUA object (HttpDownload)");
    return 0;
}

int lua_register_custom_HttpDownload(lua_State* tolua_S)
{
    tolua_usertype(tolua_S,"uq.HttpDownload");
    tolua_cclass(tolua_S,"HttpDownload","uq.HttpDownload","",nullptr);

    tolua_beginmodule(tolua_S,"HttpDownload");
        tolua_function(tolua_S,"new",lua_custom_HttpDownload_constructor);
        tolua_function(tolua_S,"eventName",lua_custom_HttpDownload_eventName);
        tolua_function(tolua_S,"downloadFile",lua_custom_HttpDownload_downloadFile);
        tolua_function(tolua_S,"create", lua_custom_HttpDownload_create);
    tolua_endmodule(tolua_S);
    std::string typeName = typeid(Foxair::HttpDownload).name();
    g_luaType[typeName] = "uq.HttpDownload";
    g_typeCast["HttpDownload"] = "uq.HttpDownload";
    return 1;
}
int lua_custom_SdkHelper_runSDKCmd(lua_State* tolua_S)
{
    int argc = 0;
    SdkHelper* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"SdkHelper",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (SdkHelper*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj)
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_custom_SdkHelper_runSDKCmd'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 2)
    {
        const char* arg0;
        int arg1;

        std::string arg0_tmp; ok &= luaval_to_std_string(tolua_S, 2, &arg0_tmp, "SdkHelper:runSDKCmd"); arg0 = arg0_tmp.c_str();

        ok &= luaval_to_int32(tolua_S, 3,(int *)&arg1, "SdkHelper:runSDKCmd");
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_custom_SdkHelper_runSDKCmd'", nullptr);
            return 0;
        }
        cobj->runSDKCmd(arg0, arg1);
        lua_settop(tolua_S, 1);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "SdkHelper:runSDKCmd",argc, 2);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_custom_SdkHelper_runSDKCmd'.",&tolua_err);
#endif

    return 0;
}
int lua_custom_SdkHelper_runJavaCmd(lua_State* tolua_S)
{
    int argc = 0;
    SdkHelper* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"SdkHelper",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (SdkHelper*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj)
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_custom_SdkHelper_runJavaCmd'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 1)
    {
        const char* arg0;

        std::string arg0_tmp; ok &= luaval_to_std_string(tolua_S, 2, &arg0_tmp, "SdkHelper:runJavaCmd"); arg0 = arg0_tmp.c_str();
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_custom_SdkHelper_runJavaCmd'", nullptr);
            return 0;
        }
        cobj->runJavaCmd(arg0);
        lua_settop(tolua_S, 1);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "SdkHelper:runJavaCmd",argc, 1);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_custom_SdkHelper_runJavaCmd'.",&tolua_err);
#endif

    return 0;
}
int lua_custom_SdkHelper_isUserCentre(lua_State* tolua_S)
{
    int argc = 0;
    SdkHelper* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"SdkHelper",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (SdkHelper*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj)
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_custom_SdkHelper_isUserCentre'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 0)
    {
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_custom_SdkHelper_isUserCentre'", nullptr);
            return 0;
        }
        bool ret = cobj->isUserCentre();
        tolua_pushboolean(tolua_S,(bool)ret);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "SdkHelper:isUserCentre",argc, 0);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_custom_SdkHelper_isUserCentre'.",&tolua_err);
#endif

    return 0;
}
int lua_custom_SdkHelper_registerScriptHandler(lua_State* tolua_S)
{
    int argc = 0;
    SdkHelper* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"SdkHelper",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (SdkHelper*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj)
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_custom_SdkHelper_registerScriptHandler'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 2)
    {
        int arg0;
        int arg1;

        ok &= luaval_to_int32(tolua_S, 2,(int *)&arg0, "SdkHelper:registerScriptHandler");

        ok &= luaval_to_int32(tolua_S, 3,(int *)&arg1, "SdkHelper:registerScriptHandler");
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_custom_SdkHelper_registerScriptHandler'", nullptr);
            return 0;
        }
        cobj->registerScriptHandler(arg0, arg1);
        lua_settop(tolua_S, 1);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "SdkHelper:registerScriptHandler",argc, 2);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_custom_SdkHelper_registerScriptHandler'.",&tolua_err);
#endif

    return 0;
}
int lua_custom_SdkHelper_runAction(lua_State* tolua_S)
{
    int argc = 0;
    SdkHelper* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"SdkHelper",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (SdkHelper*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj)
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_custom_SdkHelper_runAction'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 1)
    {
        const char* arg0;

        std::string arg0_tmp; ok &= luaval_to_std_string(tolua_S, 2, &arg0_tmp, "SdkHelper:runAction"); arg0 = arg0_tmp.c_str();
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_custom_SdkHelper_runAction'", nullptr);
            return 0;
        }
        cobj->runAction(arg0);
        lua_settop(tolua_S, 1);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "SdkHelper:runAction",argc, 1);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_custom_SdkHelper_runAction'.",&tolua_err);
#endif

    return 0;
}
int lua_custom_SdkHelper_exit(lua_State* tolua_S)
{
    int argc = 0;
    SdkHelper* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"SdkHelper",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (SdkHelper*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj)
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_custom_SdkHelper_exit'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 0)
    {
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_custom_SdkHelper_exit'", nullptr);
            return 0;
        }
        cobj->exit();
        lua_settop(tolua_S, 1);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "SdkHelper:exit",argc, 0);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_custom_SdkHelper_exit'.",&tolua_err);
#endif

    return 0;
}
int lua_custom_SdkHelper_unregisterScriptHandler(lua_State* tolua_S)
{
    int argc = 0;
    SdkHelper* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"SdkHelper",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (SdkHelper*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj)
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_custom_SdkHelper_unregisterScriptHandler'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 1)
    {
        int arg0;

        ok &= luaval_to_int32(tolua_S, 2,(int *)&arg0, "SdkHelper:unregisterScriptHandler");
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_custom_SdkHelper_unregisterScriptHandler'", nullptr);
            return 0;
        }
        cobj->unregisterScriptHandler(arg0);
        lua_settop(tolua_S, 1);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "SdkHelper:unregisterScriptHandler",argc, 1);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_custom_SdkHelper_unregisterScriptHandler'.",&tolua_err);
#endif

    return 0;
}
int lua_custom_SdkHelper_getScriptHandler(lua_State* tolua_S)
{
    int argc = 0;
    SdkHelper* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"SdkHelper",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (SdkHelper*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj)
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_custom_SdkHelper_getScriptHandler'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 1)
    {
        int arg0;

        ok &= luaval_to_int32(tolua_S, 2,(int *)&arg0, "SdkHelper:getScriptHandler");
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_custom_SdkHelper_getScriptHandler'", nullptr);
            return 0;
        }
        int ret = cobj->getScriptHandler(arg0);
        tolua_pushnumber(tolua_S,(lua_Number)ret);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "SdkHelper:getScriptHandler",argc, 1);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_custom_SdkHelper_getScriptHandler'.",&tolua_err);
#endif

    return 0;
}
int lua_custom_SdkHelper_getInstance(lua_State* tolua_S)
{
    int argc = 0;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertable(tolua_S,1,"SdkHelper",0,&tolua_err)) goto tolua_lerror;
#endif

    argc = lua_gettop(tolua_S) - 1;

    if (argc == 0)
    {
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_custom_SdkHelper_getInstance'", nullptr);
            return 0;
        }
        SdkHelper* ret = SdkHelper::getInstance();
        object_to_luaval<SdkHelper>(tolua_S, "SdkHelper",(SdkHelper*)ret);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d\n ", "SdkHelper:getInstance",argc, 0);
    return 0;
#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_custom_SdkHelper_getInstance'.",&tolua_err);
#endif
    return 0;
}
int lua_custom_SdkHelper_constructor(lua_State* tolua_S)
{
    int argc = 0;
    SdkHelper* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif



    argc = lua_gettop(tolua_S)-1;
    if (argc == 0)
    {
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_custom_SdkHelper_constructor'", nullptr);
            return 0;
        }
        cobj = new SdkHelper();
        cobj->autorelease();
        int ID =  (int)cobj->_ID ;
        int* luaID =  &cobj->_luaID ;
        toluafix_pushusertype_ccobject(tolua_S, ID, luaID, (void*)cobj,"SdkHelper");
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "SdkHelper:SdkHelper",argc, 0);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_error(tolua_S,"#ferror in function 'lua_custom_SdkHelper_constructor'.",&tolua_err);
#endif

    return 0;
}

static int lua_custom_SdkHelper_finalize(lua_State* tolua_S)
{
    printf("luabindings: finalizing LUA object (SdkHelper)");
    return 0;
}

int lua_register_custom_SdkHelper(lua_State* tolua_S)
{
    tolua_usertype(tolua_S,"SdkHelper");
    tolua_cclass(tolua_S,"SdkHelper","SdkHelper","",nullptr);

    tolua_beginmodule(tolua_S,"SdkHelper");
        tolua_function(tolua_S,"new",lua_custom_SdkHelper_constructor);
        tolua_function(tolua_S,"runSDKCmd",lua_custom_SdkHelper_runSDKCmd);
        tolua_function(tolua_S,"runJavaCmd",lua_custom_SdkHelper_runJavaCmd);
        tolua_function(tolua_S,"isUserCentre",lua_custom_SdkHelper_isUserCentre);
        tolua_function(tolua_S,"registerScriptHandler",lua_custom_SdkHelper_registerScriptHandler);
        tolua_function(tolua_S,"runAction",lua_custom_SdkHelper_runAction);
        tolua_function(tolua_S,"exit",lua_custom_SdkHelper_exit);
        tolua_function(tolua_S,"unregisterScriptHandler",lua_custom_SdkHelper_unregisterScriptHandler);
        tolua_function(tolua_S,"getScriptHandler",lua_custom_SdkHelper_getScriptHandler);
        tolua_function(tolua_S,"getInstance", lua_custom_SdkHelper_getInstance);
    tolua_endmodule(tolua_S);
    std::string typeName = typeid(SdkHelper).name();
    g_luaType[typeName] = "SdkHelper";
    g_typeCast["SdkHelper"] = "SdkHelper";
    return 1;
}
TOLUA_API int register_all_custom(lua_State* tolua_S)
{
	tolua_open(tolua_S);

	tolua_module(tolua_S,"uq",0);
	tolua_beginmodule(tolua_S,"uq");

	lua_register_custom_RemoteNotificationHelp(tolua_S);
	lua_register_custom_HttpDownload(tolua_S);
	lua_register_custom_LocalNotificationHelp(tolua_S);
	lua_register_custom_EventHttpDownload(tolua_S);
	lua_register_custom_Utils(tolua_S);
	lua_register_custom_Commons(tolua_S);
	lua_register_custom_InetHelper(tolua_S);
	lua_register_custom_ProtocolPacket(tolua_S);
	lua_register_custom_GameConnection(tolua_S);
    lua_register_custom_SdkHelper(tolua_S);

	tolua_endmodule(tolua_S);
	return 1;
}

