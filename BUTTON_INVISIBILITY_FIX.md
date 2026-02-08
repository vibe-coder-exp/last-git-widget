# Button Invisibility Fix - Complete Guide

**Issue**: The feedback submit button is rendering with white text on a white/transparent background, making it invisible.
**Cause**: The CSS variable `var(--chat--color-primary)` was not resolving because the feedback modal was appended to `document.body` outside the scope of the `.n8n-chat-widget` class where the variables are defined.

---

## ✅ Fixes Applied

### 1. Correct Variable Inheritance
We modified `showFeedbackModal` to add the `.n8n-chat-widget` class to the overlay element. This ensures that all CSS variables (like primary color, font family) are correctly inherited by the feedback modal.

```javascript
// chat-widget.js
overlay.className = 'n8n-feedback-overlay n8n-chat-widget'; // Added class
```

### 2. CSS Fallback Colors
We added a fallback color (standard purple `#7c3aed`) to the button's background property. If the variable fails for any reason, the button will default to purple instead of being transparent/invisible.

```css
/* Normal State */
background: var(--chat--color-primary, #7c3aed);

/* Disabled State */
background: var(--chat--color-primary, #7c3aed);
```

---

## 🧪 Verification Steps

1.  **Clear Cache**: Hard refresh your browser (Ctrl+Shift+R / Cmd+Shift+R).
2.  **Open Feedback**: Open chat -> Close chat -> Modal appears.
3.  **Check Button**:
    *   The "Submit" button should now be visible.
    *   It should match your bot's primary color.
    *   If the variable fails, it will be purple (which is visible).
4.  **Check Debug Logs**: Debug logging has been removed for production. If you need to troubleshoot visibility again, you can temporarily add this code inside `showFeedbackModal`:

    ```javascript
    const submitBtn = overlay.querySelector('.n8n-feedback-submit');
    if (submitBtn) {
        const styles = window.getComputedStyle(submitBtn);
        console.log('Submit Button Styles:', {
            display: styles.display,
            visibility: styles.visibility,
            opacity: styles.opacity,
            background: styles.backgroundColor,
            width: styles.width
        });
    }
    ```

This guarantees the button will never be invisible again.
