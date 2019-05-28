module packager;

import util : mkdir, findRootPath;
import plugin;

import std.stdio;
import std.file;
import std.json;
import std.path;
import std.algorithm;
import std.array;
import std.string;
import std.process;

public static int _package(string inputPath, string outputPath) {
	try {
		string rootPath = inputPath;
		if(!(exists(inputPath) && findRootPath(inputPath, rootPath))) {
			writeln("ERROR > Make sure \"", inputPath, "\" contains the file \"meta.json\"");
			return -1;
		}
		writeln("[1/6] Found meta.json at \"" ~ buildPath(rootPath, "meta.json") ~ "\"");
		
		JSONValue j = parseJSON(readText(buildPath(rootPath, "meta.json")));
		PluginInfo pluginInfo = new PluginInfo(
			j["id"].str,			// ID
			j["name"].str,			// Name
			j["description"].str,	// Description
			j["icon"].str,			// Icon
			j["version"].str,		// Version
			j["url"].str,			// URL
			string[].init,			// Authors
			"repoUrl" in j ? j["repoUrl"].str : "unspecified");	// Repository URL
		writeln("[2/6] Parsed JSON properties.");

		string workDir = buildPath(outputPath, pluginInfo.id);
		mkdir(workDir);
		writeln("[3/6] Made output \"", workDir, "\" directory on \"", outputPath, "\"");

		// Modify UI's id's
		string configMenuPath = buildPath(rootPath, "pc", "configMenu.ui");
		if(!exists(configMenuPath)) {
			writeln("[4/6] Plugin has no config menu, continuing...");
		} else {
			File configMenuFileSource = File(configMenuPath, "r");
			File configMenuFileTarget = File(buildPath(workDir, "configMenu.ui"), "w");
			while(!configMenuFileSource.eof) {
				string line = configMenuFileSource.readln();
				if(line.find("id=\"configWindow\"").length > 0) {
					//writeln("found: \"", line, "\"");
					line = line.replace("id=\"configWindow\"", "id=\"" ~ pluginInfo.id ~ "_configWindow\"");
				}
				configMenuFileTarget.write(line);
			}

			configMenuFileSource.close();
			configMenuFileTarget.close();
			writeln("[4/6] Configuration UI parsed successfully.");
		}

		// Compile the Lua scripts
		foreach(string name; dirEntries(buildPath(rootPath, "pc"), "*.lua", SpanMode.depth)) {
			string filename = baseName(name);
			int result = wait(spawnProcess(["luac", "-o", buildPath(workDir, filename), name]));
			if (result != 0) {
				writeln("ERROR: Error compiling \"", name, "\" Lua script!");
				return -1;
			}
		}
		writeln("[5/6] Lua scripts compiled");

		// Copy main files to tmp folder
		copy(buildPath(rootPath, "meta.json"), buildPath(workDir, "meta.json"));
		copy(buildPath(rootPath, "pc", "default.cfg"), buildPath(workDir, "default.cfg"));
		copy(buildPath(workDir, "default.cfg"), buildPath(workDir, "config.cfg"));
		mkdir(buildPath(workDir, "assets"));
		copy(buildPath(rootPath, "assets", "icon.png"), buildPath(workDir, "assets", "icon.png"));
		writeln("[6/6] Copied files successfully");

		writeln("Plugin packaged with success");

		return 0;
	} catch(Exception e) {
		writeln("ERROR > ", e.msg);
		return -1;
	}
}