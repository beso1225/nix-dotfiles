ObjC.import('Foundation');

const configuredPath = $.NSProcessInfo.processInfo.environment.objectForKey('CHROME_APP_PATH');
const chromePath = configuredPath ? ObjC.unwrap(configuredPath) : '/Applications/Google Chrome.app';
const chrome = Application(chromePath);
const unitSeparator = String.fromCharCode(31);
const fieldSeparator = String.fromCharCode(9);

if (!chrome.running()) {
  '';
} else {
  const rows = [];
  for (const chromeWindow of chrome.windows()) {
    try {
      const tabs = chromeWindow.tabs();
      const activeTab = chromeWindow.activeTab();
      const urls = tabs.map((tab) => String(tab.url())).join(unitSeparator);
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
  rows.join('\n');
}
