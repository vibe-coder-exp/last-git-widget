# 🤖 Bot Response Guide: How to Send Images & Links

This guide explains exactly what your bot (N8N) needs to send to the chat widget to display images, links, or text correctly.

## 1. Sending Images 🖼️

You have two ways to send images.

### A. The "Smart" Way (Markdown) - **RECOMMENDED**
Use this for **all** images, especially if the URL is long or from Google/APIs.

**Syntax:** `![Alt Text](URL)`

**Example:**
```text
Here is your design:
![Logo Preview](https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcR35U-NEuSH5lo1NoZPyouSDtkL7X7dCnYE2Q&s)
```

**Result:** The widget forces this to display as an image.

### B. The "Simple" Way (Auto-Detect)
Only works if the URL ends in `.jpg`, `.png`, `.gif`, or `.webp`.

**Example:**
```text
Check this out: https://example.com/image.png
```

---

## 2. Sending Clickable Links 🔗

To send a blue, clickable text link (not a raw URL).

**Syntax:** `[Link Text](URL)`

**Example:**
```text
Please visit our website: [Click Here](https://www.google.com)
```

**Result:** Displays "Click Here" in blue. Clicking it opens Google.

---

## 3. Sending Raw Links 🌐

If you just copy-paste a URL, it will still be clickable, but shows the full address.

**Example:**
```text
Go to https://google.com
```

**Result:** Displays "https://google.com" as a clickable text link.

---

## 🧪 Cheat Sheet for N8N

| To Send... | Use this Format |
| :--- | :--- |
| **Image** | `![Image Name](https://url...)` |
| **Link with Text** | `[Click Here](https://url...)` |
| **Plain URL** | `https://url...` |
| **Bold Text** | `This is **bold**` |
| **Italic Text** | `This is *italic*` |

---

### ⚠️ Troubleshooting

*   **Image fails to load?** If the URL is broken (404), the widget will automatically hide the broken image icon and show a fallback link saying "Image".
*   **Link not blue?** Make sure you use `[Square Brackets](Parentheses)`.
