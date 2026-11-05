"""Build "VS Night Violet": Rider's Visual Studio Night UI theme with every neutral grey tinted violet.

Usage:  python -I build-violet-theme.py <path-to-rider-install> <output-dir>
Writes  <output-dir>/vs-night-violet.jar  (a theme-only plugin; drop it in Rider's plugins folder
or use Settings → Plugins → ⚙ → Install Plugin from Disk).
"""
import colorsys, json, re, sys, zipfile
from pathlib import Path

HUE = 250 / 360          # same hue as the editor background 1c1a26
rider, out = Path(sys.argv[1]), Path(sys.argv[2])
jar = rider / "plugins/rider-theme-pack/lib/rider-theme-pack.jar"
with zipfile.ZipFile(jar) as z:
    text = z.read("VisualStudioNight.theme.json").decode("utf-8")

def tint(m):
    h, alpha = m.group(1), m.group(2) or ""
    r, g, b = (int(h[i:i + 2], 16) / 255 for i in (0, 2, 4))
    if max(r, g, b) - min(r, g, b) > 8 / 255 or max(r, g, b) in (0, 1):
        return m.group(0)                         # coloured, pure black or pure white: leave alone
    _, l, _ = colorsys.rgb_to_hls(r, g, b)
    sat = 0.20 if l < 0.35 else 0.20 - (l - 0.35) * 0.25   # darks get the strongest tint
    l *= 0.93 if l < 0.35 else 1.0                          # and get a little darker
    nr, ng, nb = colorsys.hls_to_rgb(HUE, l, max(sat, 0.05))
    return '"#%02X%02X%02X%s"' % (round(nr * 255), round(ng * 255), round(nb * 255), alpha)

text = re.sub(r'"#([0-9a-fA-F]{6})([0-9a-fA-F]{2})?"', tint, text)
theme = json.loads(text)
theme.pop("commentary", None)
theme.update(name="VS Night Violet", author="Andrew", editorScheme="VS Dark Monokai")

plugin_xml = """<idea-plugin>
  <id>local.andrew.vs-night-violet</id>
  <name>VS Night Violet Theme</name>
  <version>1.0.0</version>
  <vendor>Andrew</vendor>
  <description>Visual Studio Night with violet-tinted greys. Built by Colonizer/app/rider/build-violet-theme.py.</description>
  <idea-version since-build="262"/>
  <depends>com.intellij.modules.platform</depends>
  <extensions defaultExtensionNs="com.intellij">
    <themeProvider id="VSNightViolet" path="/VSNightViolet.theme.json" targetUi="new"/>
  </extensions>
</idea-plugin>
"""
out.mkdir(parents=True, exist_ok=True)
with zipfile.ZipFile(out / "vs-night-violet.jar", "w", zipfile.ZIP_DEFLATED) as z:
    z.writestr("META-INF/plugin.xml", plugin_xml)
    z.writestr("VSNightViolet.theme.json", json.dumps(theme, indent=2))
print("palette:", {k: v for k, v in theme["colors"].items() if k.startswith("Gray")})
