// Read-only subset of Chromium's SNSS v3 session commands. Never combine an
// older session with live IDs: IDs are used only within the current session.
function decodeSessionBase64(text) {
  var alphabet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';
  var result = [], bits = 0, value = 0;
  for (var i = 0; i < text.length; i++) {
    var digit = alphabet.indexOf(text[i]);
    if (digit < 0) continue;
    value = (value << 6) | digit;
    bits += 6;
    if (bits >= 8) { bits -= 8; result.push((value >> bits) & 255); }
  }
  return result;
}

function parsePinnedSession(bytes) {
  function int32(offset) {
    return bytes[offset] | (bytes[offset + 1] << 8) |
      (bytes[offset + 2] << 16) | (bytes[offset + 3] << 24);
  }
  if (bytes.length < 8 || int32(0) !== 0x53534e53 || int32(4) !== 3) return null;
  var tabs = {}, offset = 8;
  while (offset < bytes.length) {
    if (offset + 2 > bytes.length) return null;
    var size = bytes[offset] | (bytes[offset + 1] << 8);
    if (!size || offset + 2 + size > bytes.length) return null;
    var command = bytes[offset + 2], payload = offset + 3;
    if (command === 0 && size === 9) {
      var windowId = int32(payload), tabId = int32(payload + 4);
      var previous = tabs[tabId];
      tabs[tabId] = { windowId: String(windowId), pinned: previous ? previous.pinned : false };
    } else if (command === 12 && size === 9) {
      var pinnedId = int32(payload);
      if (!tabs[pinnedId]) return null;
      tabs[pinnedId].pinned = bytes[payload + 4] !== 0;
    } else if (command === 16 && size >= 5) {
      delete tabs[int32(payload)];
    } else if (command === 17 && size >= 5) {
      var closedId = String(int32(payload));
      Object.keys(tabs).forEach(function(id) {
        if (tabs[id].windowId === closedId) delete tabs[id];
      });
    }
    offset += 2 + size;
  }
  return tabs;
}

function classifyMailWindows(windows, defaultSession) {
  var result = {};
  if (!defaultSession) return result;
  var defaults = windows.filter(function(w) {
    return w.tabs.length && w.tabs.every(function(t) {
      var saved = defaultSession[t.id];
      return saved && saved.windowId === String(w.id);
    });
  });
  if (defaults.length !== 2) return result;
  var matches = defaults.filter(function(w) {
    var accounts = {};
    w.tabs.forEach(function(t) {
      var match = /^https:\/\/mail\.google\.com\/mail\/u\/([01])(?:\/|$)/.exec(t.url);
      if (defaultSession[t.id].pinned && match) accounts[match[1]] = true;
    });
    return accounts['0'] && accounts['1'];
  });
  if (matches.length !== 1) return result;
  defaults.forEach(function(w) { result[w.id] = w.id === matches[0].id ? '1' : '2'; });
  return result;
}

if (typeof module !== 'undefined') module.exports = { decodeSessionBase64: decodeSessionBase64,
  parsePinnedSession: parsePinnedSession, classifyMailWindows: classifyMailWindows };
