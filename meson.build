project('extrapanel-sdk', 'd',
	version: '0.0.1',
	license: 'GPLv3')

# Declare the app id
app_id = 'org.aurorafoss.extrapanel'

# Dependencies
riverd_core_dep = dependency('riverd-core', method: 'dub')
riverd_lua_dep = dependency('riverd-lua', method: 'dub')

# Subdirs
sources = []
subdir('src')

src_include_dir = include_directories('src')

xpanel_sdk = executable('extrapanel-sdk', sources, dependencies: [riverd_core_dep, riverd_lua_dep],
						d_args: ['-dw', '-g'], include_directories: src_include_dir, install: true)

# Postbuild
# meson.add_install_script('build-aux/meson/postinstall.py')