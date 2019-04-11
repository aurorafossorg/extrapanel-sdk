project('extrapanel-sdk', 'd',
	version: '0.0.1',
	license: 'GPLv3')

# Declare the app id
app_id = 'org.aurorafoss.extrapanel'

# Subdirs
sources = []
subdir('src')

src_include_dir = include_directories('src')

xpanel_sdk = executable('extrapanel-sdk', sources, d_args: '-dw',
						include_directories: src_include_dir, install: true)

# Postbuild
# meson.add_install_script('build-aux/meson/postinstall.py')