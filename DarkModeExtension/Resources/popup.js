const DEFAULTS = { enabled: true, disabledSites: [], brightness: 100 };

const enabledInput = document.getElementById("enabled");
const siteRow = document.getElementById("site-row");
const siteName = document.getElementById("site-name");
const siteInput = document.getElementById("site-enabled");
const nativeDarkNote = document.getElementById("native-dark-note");
const brightnessInput = document.getElementById("brightness");
const brightnessValue = document.getElementById("brightness-value");

let settings = { ...DEFAULTS };
let host = null;

function render() {
    enabledInput.checked = settings.enabled;

    siteRow.hidden = !host;
    siteName.textContent = host ?? "";
    siteInput.checked = !settings.disabledSites.includes(host);
    siteInput.disabled = !settings.enabled;

    brightnessInput.value = settings.brightness;
    brightnessValue.textContent = `${settings.brightness}%`;
}

// Asks the content script in the active tab which site it's on.
async function loadPageInfo() {
    try {
        const [tab] = await browser.tabs.query({ active: true, currentWindow: true });
        const info = await browser.tabs.sendMessage(tab.id, { type: "getPageInfo" });
        host = info?.host || null;
        nativeDarkNote.hidden = !info?.pageIsNativelyDark;
    } catch {
        // No content script on this page (e.g. a start page or no site access yet).
        host = null;
    }
}

enabledInput.addEventListener("change", () => {
    settings.enabled = enabledInput.checked;
    browser.storage.local.set({ enabled: settings.enabled });
    render();
});

siteInput.addEventListener("change", () => {
    const others = settings.disabledSites.filter((site) => site !== host);
    settings.disabledSites = siteInput.checked ? others : [...others, host];
    browser.storage.local.set({ disabledSites: settings.disabledSites });
});

brightnessInput.addEventListener("input", () => {
    settings.brightness = Number(brightnessInput.value);
    browser.storage.local.set({ brightness: settings.brightness });
    render();
});

const [stored] = await Promise.all([browser.storage.local.get(DEFAULTS), loadPageInfo()]);
settings = { ...DEFAULTS, ...stored };
render();
