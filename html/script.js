let isDebug = true;

document.onreadystatechange = () => {
  if (document.readyState === 'complete') {
    window.addEventListener('message', function (e) {
      switch (e.data.action) {
        case 'open':
          break;
        case 'damage':
          UpdateDamage(e.data.health);
          break;
        default:
          break;
      }
    });
  }
};

const UpdateDamage = (health) => {
  DebugLog('UpdateDamage()', health);
};

function DebugLog(str = null, _str2 = null) {
  if (!isDebug) {
    return;
  }
  if (str && _str2) {
    let str2 = String(_str2);
    console.log('^4[Debug] ^2' + str + ' ^3' + str2 + '^7');
  }
  if (str && !_str2) {
    console.log('^4[Debug] ^2' + str + '^7');
  }
}
