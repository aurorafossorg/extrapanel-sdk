module extrapanel.sdk.bootstrapper;

import util = extrapanel.sdk.util;

import std.file;
import std.path;
import std.stdio;
import std.json;

/**
 *	bootstrapper.d - Bootstraps base projects to aid in plugin development
 */

public static int _bootstrap(string path) {
	if(!exists(path)) {
		util.mkdir(path);
	}

	try {
		// Create folders
		makeFolder(path, "assets");
		makeFolder(path, "mobile");
		makeFolder(path, "pc");

		// Create files
		makeMetaFile(path);
		makeFile(buildPath(path, "pc"), "default.cfg");  	// Config file
		makeScriptFile(buildPath(path, "pc"));
	} catch(FileException e) {
		writeln("Error! > ", e.msg);
		return -1;
	}

	writeln("Project bootstrapped successfully to ", path);
	return 0;
}

public void makeFolder(string path, string name) {
	util.mkdir(buildPath(path, name));
}

public void makeFile(string path, string name) {
	File file = File(buildPath(path, name), "w");
	file.close();
}

public void makeMetaFile(string path) {
	File file = File(buildPath(path, "meta.json"), "w");
	string boilerplate = 	"{\n" ~
							"	\"id\": \"undefined\",\n" ~
							"	\"name\": \"undefined\",\n" ~
							"	\"description\": \"undefined\",\n" ~
							"	\"icon\": \"assets/icon.png\",\n" ~
							"	\"authors\": [\"undefined\"],\n" ~
							"	\"version\": \"undefined\",\n" ~
							"	\"url\": \"undefined\"\n" ~
							"}\n";

	file.write(boilerplate);
	file.close();
}

public void makeScriptFile(string path) {
	File file = File(buildPath(path, "main.lua"), "w");
	string boilerplate = 	"--setup() - Sets the plugin up for running. Receives it's configuration and returns whether is good to go or an error ocurred\n" ~
							"function setup(config)\n" ~
							"	-- TODO - Implement functionality\n" ~
							"end\n" ~
							"\n" ~
							"--query() - Queries information from the host; only returns info if state changed after last call\n" ~
							"function query()\n" ~
							"	-- TODO - Implement functionality\n" ~
							"end\n" ~
							"\n" ~
							"--change() - Changes behaviour on host according to the instructions of controller\n" ~
							"function change(action)\n" ~
							"	-- TODO - Implement functionality\n" ~
							"end\n";

	file.write(boilerplate);
	file.close();
}