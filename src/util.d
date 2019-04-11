module util;

import std.file;
import std.string;

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