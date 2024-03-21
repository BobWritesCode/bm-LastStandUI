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

const CountDown = (startTime) => {
  const count = setInterval(function () {
    if (startTime == 0) {
      clearInterval(count);
    }
    const s = String(startTime % 60).padStart(2, '0');
    const m = Minutes(startTime)
    document.getElementById("M1").textContent= m[0]
    document.getElementById("M2").textContent= m[1]
    document.getElementById("S1").textContent= s[0]
    document.getElementById("S2").textContent= s[1]
    startTime--;
  }, 1000);
};

const Minutes = (startTime) => {
  const x = Math.floor(startTime / 60);
  if (x > 99) {
    return String(99).padStart(2, '0');
  }
  return String(x).padStart(2, '0');
};

CountDown(137);

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
