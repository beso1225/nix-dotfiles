const assert = require('node:assert/strict');
const {decodeSessionBase64, parsePinnedSession, classifyMailWindows} = require('../../chezmoi/dot_config/aerospace/scripts/chrome-pinned-tabs.js');
function command(id, a, b) {
  const record = Buffer.alloc(11);
  record.writeUInt16LE(9); record[2] = id;
  record.writeInt32LE(a, 3); record.writeInt32LE(b, 7);
  return record;
}
const bytes = Buffer.concat([Buffer.from('534e535303000000', 'hex'),
  command(0, 10, 11), command(12, 11, 1), command(0, 10, 12), command(12, 12, 1),
  command(0, 20, 21)]);
const state = parsePinnedSession(bytes);
assert.deepEqual(decodeSessionBase64(bytes.toString('base64')), [...bytes]);
assert.equal(state[11].pinned, true);
assert.equal(parsePinnedSession(bytes.subarray(0, bytes.length - 1)), null);
assert.equal(parsePinnedSession(Buffer.from('534e535304000000', 'hex')), null);
const mail = n => `https://mail.google.com/mail/u/${n}/#inbox`;
const windows = [{id: '10', tabs: [{id: '11', url: mail(0)}, {id: '12', url: mail(1)}]},
  {id: '20', tabs: [{id: '21', url: 'https://example.com'}]}];
assert.deepEqual(classifyMailWindows(windows, state), {'10': '1', '20': '2'});
assert.deepEqual(classifyMailWindows([...windows].reverse(), state), {'10': '1', '20': '2'});
assert.deepEqual(classifyMailWindows(windows, null), {});
state[12].pinned = false;
assert.deepEqual(classifyMailWindows(windows, state), {});
state[12].pinned = true;
windows[0].tabs[1].url = mail(0);
assert.deepEqual(classifyMailWindows(windows, state), {});
windows[0].tabs[1].url = mail(1);
assert.deepEqual(classifyMailWindows([...windows, {id: '30', tabs: [{id: '31', url: mail(0)}]}],
  {...state, 31: {windowId: '30', pinned: true}}), {});
delete state[12];
assert.deepEqual(classifyMailWindows(windows, state), {});
const bothPinned = {...state, 12: {windowId: '10', pinned: true},
  21: {windowId: '20', pinned: true}, 22: {windowId: '20', pinned: true}};
const both = [windows[0], {id: '20', tabs: [{id: '21', url: mail(0)}, {id: '22', url: mail(1)}]}];
assert.deepEqual(classifyMailWindows(both, bothPinned), {});
assert.equal(parsePinnedSession(Buffer.concat([bytes, command(12, 11, 0)]))[11].pinned, false);
assert.equal(parsePinnedSession(Buffer.concat([bytes, command(16, 11, 0)]))[11], undefined);
console.log('Chrome pinned-mail matching: ok');
