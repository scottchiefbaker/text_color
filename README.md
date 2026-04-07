## 🔍 What is text\_color?

A tool to simplify coloring text output. Colorizing text can increase
readability and organization.

### 📦 Installation:

Place `text_color.pl` somewhere in your `$PATH`

### ✨ Usage:

```bash
text_color.pl [myfile.txt]
```

**text_color** is useful for login banners. This can be accomplished by putting
the following in your `~/.bashrc`:

```bash
# If it's an interactive terminal show the banner
if [[ $- == *i* ]]; then
  ~/bin/text_color.pl ~/.login_banner.txt
fi
```

### 🔣 Syntax

Similar to HTML tags, **text_color** allows you to wrap strings in blocks for
colorization. Use `{color}` or `{123}` to start a color, and `{}` to end the
color.

Valid textual are colors: red, yellow, blue, green, orange, purple, white, black.
Alternately use the ANSI color number between 0 and 255.

Background colors can be specified with `{on\_red}` or `{yellow\_on\_blue}`.

To insert a literal `{` you can escape it: `\{`. Closing braces `}` do not need to
be escaped.

### 🎨 Colors:

**text_color** expects a 256 color compatible terminal. Most modern terminal emulators
support this automatically.

Example ANSI color codes can be found in `third-party/term-colors/term-colors.pl`
