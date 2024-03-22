let isDebug = true;

document.onreadystatechange = () => {
  if (document.readyState === 'complete') {
    window.addEventListener('message', function (e) {
      switch (e.data.action) {
        case 'OpenUI':
          console.log(e.data.timer);
          OpenUI(e.data.timer);
          break;
        case 'CloseUI':
          CloseUI();
          break;
        default:
          break;
      }
    });
  }
};

const OpenUI = (reviveTime) => {
  DebugLog('Function:', 'OpenUI()');
  CountDown(reviveTime);
  clearInterval(fadeOutTimer);
  fadeIn();
};

const CloseUI = () => {
  DebugLog('Function:', 'CloseUI()');
  clearInterval(timer);
  clearInterval(fadeInTimer);
  fadeOut();
};

function fadeIn() {
  const element = document.body;
  element.style.opacity = 0.0;
  let initOpacity = 0.1;
  element.style.display = 'block';
  // Update the opacity with 0.1 every 10 milliseconds
  fadeInTimer = setInterval(function () {
    if (initOpacity >= 1) {
      clearInterval(fadeInTimer);
    }
    element.style.opacity = initOpacity;
    element.style.filter = 'alpha(opacity=' + initOpacity * 100 + ')';
    initOpacity += initOpacity * 0.03;
  }, 25);
}

function fadeOut() {
  const element = document.body;
  let initOpacity = element.style.opacity;
  // Update the opacity with 0.1 every 10 milliseconds
  fadeOutTimer = setInterval(function () {
    if (initOpacity <= 0.05) {
      element.style.display = 'none';
      clearInterval(fadeOutTimer);
    }
    element.style.opacity = initOpacity;
    element.style.filter = 'alpha(opacity=' + initOpacity * 100 + ')';
    initOpacity = initOpacity * 0.95;
  }, 25);
}

const CountDown = (reviveTime) => {
  DebugLog('Function:', 'CountDown()');
  SetTime(reviveTime);
  timer = setInterval(function () {
    if (reviveTime == 0) {
      clearInterval(timer);
    }
    SetTime(reviveTime);
    reviveTime--
  }, 1000);
};

const Minutes = (reviveTime) => {
  const x = Math.floor(reviveTime / 60);
  if (x > 99) {
    return String(99).padStart(2, '0');
  }
  return String(x).padStart(2, '0');
};

function SetTime(reviveTime) {
  DebugLog('Revive time left: ', reviveTime);
  const s = String(reviveTime % 60).padStart(2, '0');
  const m = Minutes(reviveTime);
  document.getElementById('M1').textContent = m[0];
  document.getElementById('M2').textContent = m[1];
  document.getElementById('S1').textContent = s[0];
  document.getElementById('S2').textContent = s[1];
}

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
