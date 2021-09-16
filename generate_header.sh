#!/bin/sh
# Takes lua folder, outputs a header file that includes all the necessary macros for writing a lite plugin.
# Takes a minimal approach, and strips out problematic functions. Should be good enough for most purposes.

echo "// This file was automatically generated by generate_header.sh. Do not modify directly."
echo "#include <stddef.h>"
echo "typedef struct lua_State lua_State; typedef double lua_Number; typedef int (*lua_CFunction)(lua_State*); typedef ptrdiff_t lua_Integer;"
echo "typedef unsigned long lua_Unsigned; typedef struct luaL_Buffer luaL_Buffer; typedef struct luaL_Reg luaL_Reg; typedef struct lua_Debug lua_Debug;"
echo "typedef void (*lua_Hook) (lua_State *L, lua_Debug *ar);"
echo "typedef void * (*lua_Alloc) (void *ud, void *ptr, size_t osize, size_t nsize);"
echo "typedef int (*lua_Writer) (lua_State *L, const void* p, size_t sz, void* ud);"
grep -h "^LUA\(LIB\)*_API" $1/*.h | sed "s/LUA\(LIB\)*_API //" | sed "s/(lua/(*lua/" | grep -v ",\s*$" | sed "s/^/static /"
grep -h "#define luaL*_" $1/*.h | grep -v "\\\s*$" | grep -v "\(assert\|lock\)" | grep -v "\(asm\|int32\)" | grep -v "#define lua_number2integer(i,n)\s*lua_number2int(i, n)"
echo "#define IMPORT_SYMBOL(name, ret, ...) name = (ret (*)(__VA_ARGS__))symbol(#name)"
echo "static void lite_init_plugin(void* (*symbol(const char*))) {"
grep -h "^LUA\(LIB\)*_API" $1/*.h | sed "s/LUA\(LIB\)*_API //" | sed "s/(lua/(*lua/" | grep -v ",\s*$" | sed "s/^\([^)]*\)(\*\(lua\w*\))\s*(/\tIMPORT_SYMBOL(\2, \1,/"
echo "}"
