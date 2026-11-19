# zjump.yazi

Type a query and jump to it with [zoxide](https://github.com/ajeetdsouza/zoxide), the same way `z`/`cd` works in your shell.

- Empty input goes to `~`
- `-` goes back
- A single argument that is an existing directory (absolute, `~/...`, or relative to the current directory) is entered directly
- Anything else is passed to `zoxide query --exclude <cwd> -- <words>`

## Installation

```sh
ya pkg add cwelsys/zjump
```

## Usage

Add this to your `keymap.toml`:

```toml
[[mgr.prepend_keymap]]
on   = [ "g", "z" ]
run  = "plugin zjump"
desc = "Jump (zoxide)"
```
