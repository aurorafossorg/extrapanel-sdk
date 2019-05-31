module tester;

import riverd.lua.statfun;
import riverd.lua.types;

import util: findRootPath, stackDump;
import std.path;
import std.stdio;
import std.file;
import std.string;
import std.conv;

public static int _test(string inputPath) {
	string rootPath = inputPath;
		if(!(exists(inputPath) && findRootPath(inputPath, rootPath))) {
			writeln("ERROR > Make sure \"", inputPath, "\" contains the file \"meta.json\"");
			return -1;
		}
		writeln("Found meta.json at \"" ~ buildPath(rootPath, "meta.json") ~ "\"");

	string pcLuaScript = buildPath(rootPath, "main.lua");
	if(!exists(pcLuaScript)) {
		writeln("ERROR > No \"main.lua\" script found in \"", inputPath, "\"!");
		return -1;
	}

	// Script found, so let's initiate LuaVM
	// Inits the Lua state for each plugin
	lua_State* lua = luaL_newstate();
	luaL_openlibs(lua);
	writeln("Lua state created");

	// Loads Lua script and calls setup()
	if(luaL_dofile(lua, pcLuaScript.toStringz)) {
		writeln("Failed to load Lua script! Error: ", lua_tostring(lua, -1).fromStringz);
		lua_close(lua);
		return -1;
	}
	writeln("Script loaded successfully");

	// Parses config for Lua
	writeln("Type in the configuration for plugin: ");
	string config = chomp(readln());
	// Push parsedConfig and calls setup
	lua_getglobal(lua, ("setup").toStringz);
	lua_pushstring(lua, config.toStringz);

	if(lua_pcall(lua, 1, 0, 0)) {
		writeln("setup() call failed for plugin! Error: ", lua_tostring(lua, -1).fromStringz);
		lua_close(lua);
	}
	writeln("setup() executed successfully");

	while(true) {
		printCommands();
		string option = chomp(readln());
		switch(option) {
			case "q":
				_query(lua);
				break;
			case "u":
				_update(lua);
				break;
			case "s":
				stackDump(lua);
				break;
			case "x":
				_cleanup(lua);
				return 1;
			default:
				break;
		}
	}
}

public void _query(lua_State* lua) {
		// Pushes the query() method on the stack
		lua_getglobal(lua, ("query").toStringz);

		// Calls query()
		if(lua_pcall(lua, 0, 1, 0)) {
			writeln("query() call failed! Error: ", lua_tostring(lua, -1).fromStringz);
		}

		// Return query() result and empties stack (to prevent memleaks/stackoverflow)
		string result = to!string(lua_tostring(lua, -1).fromStringz);
		lua_settop(lua, 0);

		writeln("Result from query: ", result);
}

public void _update(lua_State* lua) {
	// Pushes the update() method on the stack 
	writeln("Type in the update string to send: ");
	string update = chomp(readln());

	lua_getglobal(lua, ("change").toStringz);
	lua_pushstring(lua, update.toStringz);

	// Calls update()
	if(lua_pcall(lua, 1, 0, 0)) {
			writeln("update() call failed! Error: ", lua_tostring(lua, -1).fromStringz);
	}
}

public void _cleanup(lua_State* lua) {

}

public void printCommands() {
	writeln("Commands available:\n");
	writeln("\tq - Perform a query");
	writeln("\tu - Issue an update");
	writeln("\ts - Do a stack dump");
	writeln("\tx - Exit\n");
	write(": ");
}