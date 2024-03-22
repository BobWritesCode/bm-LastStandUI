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
