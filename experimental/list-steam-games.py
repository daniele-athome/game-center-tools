#!/usr/bin/env python3
# List all installed games in Steam. This would help writing a script that autoconfigures games on Sunshine as
# applications and keeps them synced.

import vdf

from pathlib import Path
home = Path.home()

d = vdf.load(open(home / '.local' / 'share' / 'Steam' / 'steamapps' / 'libraryfolders.vdf', 'r'))
apps = d['libraryfolders']['0']['apps']
print(apps)

for app_id in apps.keys():
    manifest_file = home / '.local' / 'share' / 'Steam' / 'steamapps' / ('appmanifest_' + app_id + '.acf')
    if manifest_file.exists():
        app_data = vdf.load(open(manifest_file, 'r'))
        print(app_data['AppState'])
