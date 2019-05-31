module packager;

import std.stdio;
import std.file;
import std.json;
import std.path;
import std.algorithm;
import std.array;
import std.string;
import std.process;

import util : mkdir, findRootPath, createTempPath;
import plugin;

public static int _package(string inputPath, string outputPath) {
	try {
		string rootPath = inputPath;
		if(!(exists(inputPath) && findRootPath(inputPath, rootPath))) {
			writeln("ERROR > Make sure \"", inputPath, "\" contains the file \"meta.json\"");
			return -1;
		}
		writeln("[1/7] Found meta.json at \"" ~ buildPath(rootPath, "meta.json") ~ "\"");
		
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
		writeln("[2/7] Parsed JSON properties.");

		string tmpDir = buildPath(createTempPath(), "sdk", pluginInfo.id);
		if(exists(tmpDir))
			rmdirRecurse(tmpDir);
		mkdir(tmpDir);
		writeln("[3/7] Created temporary directory at \"", tmpDir, "\"");

		// Modify UI's id's
		string configMenuPath = buildPath(rootPath, "pc", "configMenu.ui");
		if(!exists(configMenuPath)) {
			writeln("[4/7] Plugin has no config menu, continuing...");
		} else {
			File configMenuFileSource = File(configMenuPath, "r");
			File configMenuFileTarget = File(buildPath(tmpDir, "configMenu.ui"), "w");
			while(!configMenuFileSource.eof) {
				string line = configMenuFileSource.readln();
				if(line.find("id=\"configWindow\"").length > 0) {
					line = line.replace("id=\"configWindow\"", "id=\"" ~ pluginInfo.id ~ "_configWindow\"");
				}
				configMenuFileTarget.write(line);
			}

			configMenuFileSource.close();
			configMenuFileTarget.close();
			writeln("[4/7] Configuration UI parsed successfully.");
		}

		// Compile the Lua scripts
		foreach(string name; dirEntries(buildPath(rootPath, "pc"), "*.lua", SpanMode.depth)) {
			string filename = baseName(name);
			int result = wait(spawnProcess(["luac", "-o", buildPath(tmpDir, filename), name]));
			if (result != 0) {
				writeln("ERROR: Error compiling \"", name, "\" Lua script!");
				return -1;
			}
		}
		writeln("[5/7] Lua scripts compiled");

		// Copy main files to tmp folder
		copy(buildPath(rootPath, "meta.json"), buildPath(tmpDir, "meta.json"));
		copy(buildPath(rootPath, "pc", "default.cfg"), buildPath(tmpDir, "default.cfg"));
		copy(buildPath(tmpDir, "default.cfg"), buildPath(tmpDir, "config.cfg"));
		mkdir(buildPath(tmpDir, "assets"));
		copy(buildPath(rootPath, "assets", "icon.png"), buildPath(tmpDir, "assets", "icon.png"));
		writeln("[6/7] Copied files successfully");

		string compressedName = pluginInfo.id ~ ".tar.gz";
		string workDir = buildPath(outputPath, pluginInfo.id);
		mkdir(outputPath);
		mkdir(workDir);
		int result = wait(spawnProcess(["tar", "czf", buildPath(workDir, compressedName),
		"-C", buildPath(createTempPath(), "sdk"), pluginInfo.id]));
		if(result != 0) {
			writeln("ERROR: Error compressing archive!");
		}

		copy(buildPath(rootPath, "meta.json"), buildPath(workDir, "meta.json"));
		copy(buildPath(rootPath, "assets", "icon.png"), buildPath(workDir, "icon.png"));
		writeln("[7/7] Plugin compressed and stored on \"", workDir, "\" successfully");

		writeln("Plugin packaged with success");

		return 0;
	} catch(Exception e) {
		writeln("ERROR > ", e.msg);
		return -1;
	}
}