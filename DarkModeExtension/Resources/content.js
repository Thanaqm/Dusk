// Forces a dark theme on the page by inverting it, then re-inverting media
// (images, video, etc.) so they keep their original colors.

const STYLE_ID = "force-dark-mode-style";

const DEFAULTS = { enabled: true, disabledSites: [], brightness: 100 };

const host = location.hostname;

let settings = { ...DEFAULTS };

// True when the page already ships its own dark theme, in which case
// inverting it would turn it light again.
let pageIsNativelyDark = false;

function buildCSS(brightness) {
    return `
        html {
            filter: invert(1) hue-rotate(180deg) brightness(${brightness / 100}) !important;
        }
        /* Zero-specificity fallback so pages without a background still invert to black. */
        :where(html) {
            background-color: #fff;
        }
        /* Re-invert media so photos and videos look normal. */
        img, picture, video, canvas, iframe, embed, object, svg image {
            filter: invert(1) hue-rotate(180deg) !important;
        }
        /* Avoid double-inverting images nested inside <picture>. */
        picture img {
            filter: none !important;
        }
    `;
}

function shouldApply() {
    return settings.enabled
        && !settings.disabledSites.includes(host)
        && !pageIsNativelyDark;
}

function applyStyle() {
    let style = document.getElementById(STYLE_ID);

    if (!shouldApply()) {
        style?.remove();
        return;
    }

    if (!style) {
        style = document.createElement("style");
        style.id = STYLE_ID;
    }
    style.textContent = buildCSS(settings.brightness);

    // At document_start <head> may not exist yet, so attach to <html>.
    const parent = document.head || document.documentElement;
    if (style.parentNode !== parent) {
        parent.appendChild(style);
    }
}

// Parses "rgb(r, g, b)" / "rgba(r, g, b, a)" into [r, g, b, a].
function parseColor(value) {
    const match = value.match(/rgba?\(([^)]+)\)/);
    if (!match) return null;
    const parts = match[1].split(/[\s,\/]+/).filter(Boolean).map(Number);
    return [parts[0], parts[1], parts[2], parts.length > 3 ? parts[3] : 1];
}

// Detects whether the page's own background is already dark. Computed
// styles are unaffected by our CSS filter, so this reads the site's colors.
function detectNativeDark() {
    for (const element of [document.body, document.documentElement]) {
        if (!element) continue;
        const color = parseColor(getComputedStyle(element).backgroundColor);
        if (!color || color[3] === 0) continue;

        const [r, g, b] = color;
        const luminance = (0.2126 * r + 0.7152 * g + 0.0722 * b) / 255;
        return luminance < 0.4;
    }
    return false;
}

function recheckNativeDark() {
    // Temporarily remove our style so the :where(html) fallback doesn't
    // mask a page whose dark background is set on <html> via a low-priority rule.
    const style = document.getElementById(STYLE_ID);
    style?.remove();
    pageIsNativelyDark = detectNativeDark();
    applyStyle();
}

// Apply immediately with defaults to avoid a white flash, then refine.
applyStyle();

browser.storage.local.get(DEFAULTS).then((stored) => {
    settings = { ...DEFAULTS, ...stored };
    applyStyle();
});

if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", recheckNativeDark, { once: true });
} else {
    recheckNativeDark();
}

// Re-add our <style> if the page (e.g. a single-page app) removes it.
new MutationObserver(() => {
    if (shouldApply() && !document.getElementById(STYLE_ID)) {
        applyStyle();
    }
}).observe(document.documentElement, { childList: true, subtree: true });

// React live to changes made in the popup.
browser.storage.onChanged.addListener((changes, area) => {
    if (area !== "local") return;
    for (const [key, { newValue }] of Object.entries(changes)) {
        settings[key] = newValue ?? DEFAULTS[key];
    }
    applyStyle();
});

// Lets the popup ask which site is open and whether it's already dark.
browser.runtime.onMessage.addListener((request) => {
    if (request?.type === "getPageInfo" && window === window.top) {
        return Promise.resolve({ host, pageIsNativelyDark });
    }
});
