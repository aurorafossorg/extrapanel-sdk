module extrapanel.sdk.util;

import riverd.lua.statfun;
import riverd.lua.types;

import std.file;
import std.stdio;
import std.string;
import std.path;

public static bool findRootPath(string inputPath, ref string rootPath) {
	// Detect if inputPath is the actual file
	if(isFile(inputPath) && inputPath == "meta.json") {
		rootPath = getcwd();
		return true;
	}

	if(isDir(inputPath)) {
		foreach(string name; dirEntries(inputPath, "meta.json", SpanMode.breadth)) {
			rootPath = name.chomp("meta.json");
			return true;
		}
	}

	return false;
}

public static void mkdir(string path) {
	if(!exists(path)) {
		std.file.mkdir(path);
	}
}

public static string createTempPath() {
	string root = buildPath(tempDir, "xpanel");
	if(!exists(root))
		mkdir(root);
	if(!exists(buildPath(root, "sdk")))
		mkdir(buildPath(root, "sdk"));

	return root;
}

public static void stackDump (lua_State *L) {
	int i;
	int top = lua_gettop(L);
	for (i = 1; i <= top; i++) {  /* repeat for each level */
		int t = lua_type(L, i);
		switch (t) {
	
		case LUA_TSTRING:  /* strings */
			writeln("String: ", lua_tostring(L, i).fromStringz);
			break;
	
		case LUA_TBOOLEAN:  /* booleans */
			writeln("Boolean: ", lua_toboolean(L, i) ? "true" : "false");
			break;
	
		case LUA_TNUMBER:  /* numbers */
			writeln("Number: ", lua_tonumber(L, i));
			break;
	
		default:  /* other values */
			writeln("Other type: ", lua_typename(L, t).fromStringz, "\t", lua_touserdata(L, i));
			break;
	
		}
	}
}