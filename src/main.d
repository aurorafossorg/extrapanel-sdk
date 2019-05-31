module main;

import std.stdio;

import bootstrapper;
import packager;
import tester;

/**
 *	main.d - Entrypoint for the SDK
 */

string output;

int main(string[] args) {
	for(int i = 1; i < args.length; i++) {
		// Prints help
		if(args[i] == "-h" || args[i] == "--help") {
			printHelp();
			return 0;

		// Bootstrapper
		} else if(args[i] == "-b" || args[i] == "--bootstrap") {
			string outputPath = (i+1) < args.length ? args[i+1] : ".";
			i++;
			return _bootstrap(outputPath);

		// Packager
		} else if(args[i] == "-p" || args[i] == "--package") {
			string inputPath = (i+1) < args.length ? args[i+1] : ".";
			i++;
			string outputPath = (i+1) < args.length ? args[i+1] : ".";
			i++;
			return _package(inputPath, outputPath);

		// Tester
		} else if(args[i] == "-t" || args[i] == "--test") {
			string inputPath = (i+1) < args.length ? args[i+1] : ".";
			i++;
			string outputPath = (i+1) < args.length ? args[i+1] : ".";
			i++;
			return _test(inputPath);

		// Unknown option
		} else {
			writeln("Unknow argument: ", args[i]);
			writeln("Use -h or --help to get argument list");
			return -1;
		}
	}

	// No options present besides the own executable path
	writeln("No arguments were given.");
	writeln("Use -h or --help to get argument list");
	return -1;
}

void printHelp() {
	string text =  "Usage: extrapanel-sdk [options] [input] [output=.]\n" ~
					"\n" ~
					" Available options:\n" ~
					"  -b, --bootstrap		Bootstraps a sample project to [input]\n" ~
					"  -p, --package			Packages the plugin on [input] to [output]\n" ~
					"  -t, --test			Tests a plugin on [input]\n";
					
	writeln(text);
}