ObjC.import('Foundation');

const configuredPath = $.NSProcessInfo.processInfo.environment.objectForKey('CHROME_APP_PATH');
const chromePath = configuredPath ? ObjC.unwrap(configuredPath) : '/Applications/Google Chrome.app';
const chrome = Application(chromePath);
const unitSeparator = String.fromCharCode(31);
const fieldSeparator = String.fromCharCode(9);
const environment = $.NSProcessInfo.processInfo.environment;
const helperPath = ObjC.unwrap(environment.objectForKey('CHROME_PIN_HELPER'));
eval(ObjC.unwrap($.NSString.stringWithContentsOfFileEncodingError(helperPath, $.NSUTF8StringEncoding, null)));
const dataDir = ObjC.unwrap(environment.objectForKey('CHROME_DATA_DIR'));
const profileDir = ObjC.unwrap(environment.objectForKey('CHROME_DEFAULT_PROFILE_DIR'));
let defaultSession = null;
try {
  const directory = dataDir + '/' + profileDir + '/Sessions';
  const names = ObjC.deepUnwrap($.NSFileManager.defaultManager.contentsOfDirectoryAtPathError(directory, null))
    .filter(name => /^Session_\d+$/.test(name)).sort();
  if (names.length) {
    const data = $.NSData.dataWithContentsOfFile(directory + '/' + names[names.length - 1]);
    defaultSession = parsePinnedSession(decodeSessionBase64(ObjC.unwrap(data.base64EncodedStringWithOptions(0))));
  }
} catch (_) {
  // Missing, unsupported, or incomplete session data must never imply unpinned.
}

if (!chrome.running()) {
  '';
} else {
  const rows = [];
  const snapshots = [];
  for (const chromeWindow of chrome.windows()) {
    try {
      const tabs = chromeWindow.tabs();
      const activeTab = chromeWindow.activeTab();
      const urls = tabs.map((tab) => String(tab.url())).join(unitSeparator);
      snapshots.push({id: String(chromeWindow.id()),
        tabs: tabs.map(tab => ({id: String(tab.id()), url: String(tab.url())}))});
      rows.push([
        String(chromeWindow.id()),
        String(chromeWindow.name()),
        String(activeTab.url()),
        String(tabs.length),
        urls,
      ].join(fieldSeparator));
    } catch (_) {
      // A window can disappear while Chrome is restoring a session. It will
      // be observed on the next retry instead of being guessed here.
    }
  }
  const roles = classifyMailWindows(snapshots, defaultSession);
  rows.map(row => row + fieldSeparator + (roles[row.split(fieldSeparator)[0]] || 'unknown')).join('\n');
}
