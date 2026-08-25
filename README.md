# Portal Prompt

Portal Prompt is a tiny [Omarchy](https://omarchy.org/) Quattro bar widget for the annoying state where Wi-Fi is connected but the internet is blocked behind a hotel, airport, cafe, or conference login page.

![Portal Prompt showing a captive-portal warning in the Omarchy bar](preview.png)

It stays hidden during normal connectivity. When NetworkManager reports `portal` or `limited`, a warning icon appears:

- Left-click opens a plain-HTTP page so the network can redirect the browser to its sign-in page.
- Right-click asks NetworkManager to check connectivity again.
- The status is also refreshed locally every 30 seconds.

Portal Prompt does not bypass a captive portal or handle its credentials. It only detects the state and helps open the portal in your browser.

## Install

From GitHub after the repository is published:

```bash
omarchy plugin add https://github.com/blackscaletech/portal-prompt.git --enable
```

For local development, clone or copy this repository to:

```text
~/.config/omarchy/plugins/io.github.blackscaletech.portal-prompt
```

Then validate, discover, and enable it:

```bash
omarchy plugin validate ~/.config/omarchy/plugins/io.github.blackscaletech.portal-prompt
omarchy-shell shell rescanPlugins
omarchy plugin enable io.github.blackscaletech.portal-prompt
```

The widget defaults to the right side of the bar. Its `loginUrl` setting defaults to `http://example.com/`; a plain-HTTP URL is intentional because captive portals cannot transparently redirect a valid HTTPS connection. Non-HTTP values are ignored and fall back to the default.

## Remove

```bash
omarchy plugin remove io.github.blackscaletech.portal-prompt
```

## Requirements

- Omarchy Quattro
- NetworkManager's `nmcli`
- `xdg-open` from `xdg-utils`

These are standard Omarchy components. There are no downloaded or bundled dependencies.

## Security and privacy

The complete runtime is [`BarWidget.qml`](BarWidget.qml). It:

- runs only `nmcli` to read or recheck NetworkManager connectivity;
- passes the configured login URL directly to `xdg-open` as one argument, without a shell;
- accepts only a URL beginning with `http://`, falling back to `http://example.com/` otherwise;
- stays within the current user session and never reads credentials, writes files, stores history, or sends telemetry.

Like every Omarchy shell plugin, it runs with the user's permissions, so review the source before enabling it.

## License

[MIT](LICENSE)
