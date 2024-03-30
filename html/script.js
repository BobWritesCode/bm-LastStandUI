let isDebug = false;
let fadeInTimer;
let fadeOutTimer;
let isUIOpen = true;

window.addEventListener('DOMContentLoaded', function () {
  fetch('https://bm-AmbientHealthUI/nuiReady', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({}),
  })
    .then((r) => {
      // pass
    })
    .catch((e) => {
      // pass
    });
});

document.onreadystatechange = () => {
  if (document.readyState === 'complete') {
    window.addEventListener('message', function (e) {
      switch (e.data.action) {
        case 'UpdateHp':
          DebugLog('UpdateHp', e.data.hp);
          HitPoint(e.data.hp, e.data.maxHp);
          break;
        case 'Debug':
          isDebug = e.data.debug;
          break;
        case 'Died':
          Reset();
          break;
        case 'Revived':
          HitPoint(e.data.hp, e.data.maxHp);
          break;
        case 'UpdateMessage':
          const el = document.getElementById(e.data.el);
          el.innerText = e.data.displayMsg;
          break;
        case 'HideEl':
          const el4 = document.getElementById(e.data.el);
          el4.style.visibility = e.data.show ? 'visible' : 'hidden';
          break;
        case 'Display':
          const el5 = document.getElementById(e.data.el);
          el5.style.display = e.data.show;
          break;
        default:
          break;
      }
    });
  }
};

const HitPoint = (_hp, _maxHp) => {
  const hp = Number(_hp);
  const maxHp = Number(_maxHp);
  DebugLog('Function:', 'HitPoint()');
  DebugLog('hp:', hp);
  DebugLog('maxHp:', maxHp);
  DebugLog('Percent:', hp / maxHp);
  const Percent = hp / maxHp;
  const bodyOpacity = window.getComputedStyle(document.body).getPropertyValue('opacity');
  DebugLog('Current opacity:', bodyOpacity);
  if (Percent < 1 - bodyOpacity) {
    fadeIn(Math.min(1.0, 1 - Percent));
  } else {
    fadeOut(Math.max(0.0, 1 - Percent));
  }
};

function fadeIn(_fadeTo) {
  let fadeTo = Number(_fadeTo);
  DebugLog('fadeIn(fadeTo):', fadeTo);
  clearInterval(fadeOutTimer);
  clearInterval(fadeInTimer);
  let initOpacity = Number(window.getComputedStyle(document.body).getPropertyValue('opacity'));
  initOpacity = initOpacity.toFixed(4);
  fadeInTimer = setInterval(function () {
    if (initOpacity >= fadeTo) {
      DebugLog('Fade in finished at:', initOpacity);
      clearInterval(fadeInTimer);
    }
    initOpacity = Number(initOpacity) + 0.05;
    document.body.style.opacity = initOpacity;
  }, 25);
}

function fadeOut(_fadeTo) {
  DebugLog(_fadeTo);
  let fadeTo = Number(_fadeTo);
  DebugLog('fadeOut(fadeTo):', fadeTo);
  clearInterval(fadeOutTimer);
  clearInterval(fadeInTimer);
  let initOpacity = Number(window.getComputedStyle(document.body).getPropertyValue('opacity'));
  initOpacity = initOpacity.toFixed(4);
  fadeOutTimer = setInterval(function () {
    if (initOpacity <= Math.max(0.1, fadeTo)) {
      document.body.style.opacity = 0.0;
      DebugLog('Fade out finished at:', initOpacity);
      clearInterval(fadeOutTimer);
      fadeOutTimer = null;
    }
    initOpacity = (initOpacity * 0.97).toFixed(4);
    document.body.style.opacity = initOpacity;
  }, 25);
}

function Reset() {
  const elTimeContainer = document.getElementById('time-container');
  elTimeContainer.style.display = 'flex';
  const elCD = document.getElementById('CD');
  elCD.style.display = 'none';
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
