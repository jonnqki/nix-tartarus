// lyrics-translate.js
// Spicetify extension: append an English translation under each lyric line.
// Uses the free (unofficial) Google translate endpoint. No API key.
// Detected-English songs are left untouched.

(function LyricsTranslate() {
  // Wait until Spicetify core (and the menu API) is ready.
  if (!window.Spicetify || !Spicetify.Menu || !Spicetify.showNotification) {
    setTimeout(LyricsTranslate, 300);
    return;
  }

  const TARGET_LANG = "en";
  const LS_ENABLED = "lyrics-translate:enabled";

  // Lyric-line selectors, most-specific first. Spotify obfuscates class names,
  // so the stable data-testid is primary; the rest are fallbacks / lyrics-plus.
  const LINE_SELECTORS = [
    '[data-testid="fullscreen-lyric"]',
    ".lyrics-lyricsContent-lyric",
    ".LyricsLine",
  ];
  const LINE_SELECTOR = LINE_SELECTORS.join(",");

  // Text -> { translated, detected } (or a Promise while in flight).
  const cache = new Map();
  let enabled = localStorage.getItem(LS_ENABLED) !== "false";

  // --- translation ---------------------------------------------------------

  async function translate(text) {
    if (cache.has(text)) return cache.get(text);

    const p = (async () => {
      const url =
        "https://translate.googleapis.com/translate_a/single" +
        "?client=gtx&sl=auto&tl=" +
        TARGET_LANG +
        "&dt=t&q=" +
        encodeURIComponent(text);
      const res = await fetch(url);
      if (!res.ok) throw new Error("translate HTTP " + res.status);
      const data = await res.json();
      const translated = (data[0] || []).map((seg) => seg[0]).join("");
      const detected = data[2]; // ISO code of the source language
      return { translated, detected };
    })();

    cache.set(text, p);
    try {
      const result = await p;
      cache.set(text, result); // replace promise with resolved value
      return result;
    } catch (e) {
      cache.delete(text); // allow a retry later
      throw e;
    }
  }

  // --- DOM injection -------------------------------------------------------

  function originalText(line) {
    // Read only the real lyric text, never our own appended translation.
    const existing = line.querySelector(":scope > .lyrics-translate");
    if (!existing) return line.textContent.trim();
    const clone = line.cloneNode(true);
    clone.querySelectorAll(".lyrics-translate").forEach((n) => n.remove());
    return clone.textContent.trim();
  }

  async function processLine(line) {
    const text = originalText(line);

    // Skip empties and instrumental markers (♪ etc.).
    if (!text || /^[\s♪♫•·.\-–—]+$/.test(text)) return;

    // Already handled this exact text? Leave it.
    if (line.dataset.ltText === text) return;
    line.dataset.ltText = text;

    // Remove any stale translation from a previous text.
    const stale = line.querySelector(":scope > .lyrics-translate");
    if (stale) stale.remove();

    let result;
    try {
      result = await translate(text);
    } catch (e) {
      delete line.dataset.ltText; // let the observer retry
      return;
    }

    // Bail if disabled or the line was recycled to different text meanwhile.
    if (!enabled || line.dataset.ltText !== text) return;

    // Don't clutter English (or already-matching) lyrics.
    if (
      !result.translated ||
      result.detected === TARGET_LANG ||
      result.translated.trim().toLowerCase() === text.toLowerCase()
    ) {
      return;
    }

    const el = document.createElement("div");
    el.className = "lyrics-translate";
    el.textContent = result.translated;
    line.appendChild(el);
  }

  function scan(root) {
    if (!enabled) return;
    const scope = root && root.querySelectorAll ? root : document;
    scope.querySelectorAll(LINE_SELECTOR).forEach(processLine);
    // If root itself is a line (added directly), handle it too.
    if (root && root.matches && root.matches(LINE_SELECTOR)) processLine(root);
  }

  function clearAll() {
    document.querySelectorAll(".lyrics-translate").forEach((n) => n.remove());
    document
      .querySelectorAll("[data-lt-text]")
      .forEach((n) => delete n.dataset.ltText);
  }

  // --- styling -------------------------------------------------------------

  const style = document.createElement("style");
  style.textContent = `
    .lyrics-translate {
      font-size: 0.72em;
      font-style: italic;
      opacity: 0.62;
      margin-top: 0.15em;
      font-weight: 500;
      line-height: 1.2;
      pointer-events: none;
    }
  `;
  document.head.appendChild(style);

  // --- observe lyric changes ----------------------------------------------

  let pending = false;
  const observer = new MutationObserver((mutations) => {
    if (!enabled || pending) return;
    // Coalesce bursts of DOM churn into one scan per frame.
    pending = true;
    requestAnimationFrame(() => {
      pending = false;
      for (const m of mutations) {
        m.addedNodes.forEach((node) => {
          if (node.nodeType === 1) scan(node);
        });
      }
      scan(document); // catch text swaps on existing nodes
    });
  });
  observer.observe(document.body, { childList: true, subtree: true });

  // --- toggle menu item ----------------------------------------------------

  const menuItem = new Spicetify.Menu.Item(
    "Translate lyrics → English",
    enabled,
    (self) => {
      enabled = !enabled;
      self.setState(enabled);
      localStorage.setItem(LS_ENABLED, enabled ? "true" : "false");
      if (enabled) {
        scan(document);
        Spicetify.showNotification("Lyrics translation on");
      } else {
        clearAll();
        Spicetify.showNotification("Lyrics translation off");
      }
    }
  );
  menuItem.register();

  // Initial pass for lyrics already on screen.
  scan(document);
})();
