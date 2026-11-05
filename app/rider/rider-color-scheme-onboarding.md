# Rider color scheme: VS Dark Monokai

`VS Dark Monokai.icls` is a full copy of Rider's bundled **Visual Studio Dark** editor scheme with
dark violet backgrounds, ocean-blue text, and Monokai string and number colors. Keywords, types, methods,
locals and comments keep VS Dark's colors, so it doesn't turn pink. Only these keys changed:

| Key | VS Dark | Custom |
|---|---|---|
| `TEXT` background, `GUTTER_BACKGROUND`, `CONSOLE_BACKGROUND_KEY` | `1e1e1e` | `1c1a26` |
| `CARET_ROW_COLOR` | `0f0f0f` | `2a2738` |
| `SELECTION_BACKGROUND` | `245b82` | `3b3654` |
| `LINE_NUMBERS_COLOR` / `LINE_NUMBER_ON_CARET_ROW_COLOR` | `8a8a8a` / `e0e0e0` | `7d7894` / `cde0f0` |
| `INDENT_GUIDE` / `SELECTED_INDENT_GUIDE` | `464646` / `505050` | `2d2a3b` / `4a4563` |
| Foreground of `TEXT`, `DEFAULT_IDENTIFIER`, `DEFAULT_INSTANCE_FIELD`, `DEFAULT_DOC_MARKUP`, `ReSharper.NAMESPACE_IDENTIFIER` | `dcdcdc` | `cde0f0` |
| Foreground of `DEFAULT_STRING`, `DEFAULT_DOC_COMMENT_TAG_VALUE`, `ReSharper.ASP_NET_ATTRIBUTE_VALUE`, `ReSharper.IL_STRING_LITERAL` | `d69d85` | `e6db74` |
| Foreground of `DEFAULT_NUMBER` | `b5cea8` | `ae81ff` |

Pairs with the **Visual Studio Night** UI theme.

## Apply

1. Copy the `.icls` into `%APPDATA%\JetBrains\Rider<version>\colors\`.
2. Restart Rider. It only reads that folder at startup.
3. **Settings → Editor → Color Scheme →** pick **VS Dark Monokai**.

If Rider is already running and you'd rather not restart, use **⚙ → Import Scheme** with this file
instead of step 1. Don't do both, or you'll end up with two copies.

## Regenerate after a Rider upgrade

The base scheme lives at `plugins/rider-theme-pack/lib/rider-theme-pack.jar` →
`colorSchemes/VisualStudioDark.xml` in the Rider install folder. To pick up JetBrains' changes,
extract that file, rename the scheme to `VS Dark Monokai`, and apply the table above again.

## UI theme: VS Night Violet

The editor scheme only colors the editor. The surrounding UI (project tree, tool windows, toolbars)
comes from the UI theme, so `build-violet-theme.py` builds a matching one. It takes Rider's
**Visual Studio Night** theme, tints every neutral grey violet (hue 250°, the same as the editor
background), and packages it as a small theme plugin. The theme sets **VS Dark Monokai** as its
editor scheme.

```sh
python -I build-violet-theme.py "$LOCALAPPDATA/Programs/Rider" .
cp vs-night-violet.jar "$APPDATA/JetBrains/Rider2026.2/plugins/"
```

Restart Rider, then pick **Settings → Appearance → Theme → VS Night Violet**. Run the script again
after Rider upgrades so the theme picks up JetBrains' changes.
