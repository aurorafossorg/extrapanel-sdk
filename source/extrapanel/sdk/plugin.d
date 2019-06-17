module extrapanel.sdk.plugin;

/**
 *	plugin.d - General plugin indo
 */

// Class holding all plugin important info
class PluginInfo {
	// Constructor with all fields
	this(string id, string name, string description, string icon, string strVersion, string url,
		string[] authors, string repoUrl) {
		// Required fields
		this.id = id;
		this.name = name;
		this.description = description;
		this.icon = icon;
		this.strVersion = strVersion;
		this.url = url;

		// Optional fields
		this.authors = authors;
		this.repoUrl = url;
	}

	immutable string id, name, description, icon, strVersion, url, repoUrl;
	string[] authors;
}