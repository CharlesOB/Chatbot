String.prototype.repeat = function(num) {
  return new Array(parseInt(num) + 1).join(this);
}

String.prototype.contains = function(str) {
  return this.indexOf(str) != -1;
}

Number.prototype.toStringWithDigits = function(numDigits) {
  var str = this.toString();
  while (str.length < numDigits) {
    str = "0" + str;
  }
  return str;
}

function addLoadEvent(func) {
  var oldonload = window.onload;
  if (typeof window.onload != 'function') {
    window.onload = func;
  } else {
    window.onload = function() {
      if (oldonload) {
        oldonload();
      }
      func();
    }
  }
}

function loadScript(url, callback) {
  // Adding the script tag to the head
  var head = document.getElementsByTagName('head')[0];
  var script = document.createElement('script');
  script.type = 'text/javascript';
  script.src = url;

  // Then bind the event to the callback function.
  // There are several events for cross browser compatibility.
  script.onreadystatechange = callback;
  script.onload = callback;

  // Fire the loading
  head.appendChild(script);
}

function setCookie(cname, cvalue, exdays) {
  var d = new Date();
  d.setTime(d.getTime() + (exdays*24*60*60*1000));
  var expires = "expires="+d.toGMTString();
  document.cookie = cname + "=" + cvalue + "; " + expires;
}

function getCookie(cname) {
  var name = cname + "=";
  var ca = document.cookie.split(';');
  for(var i=0; i<ca.length; i++) {
    var c = ca[i];
    while (c.charAt(0)==' ') c = c.substring(1);
    if (c.indexOf(name) != -1) return c.substring(name.length,c.length);
  }
  return "";
}

progress = getCookie('progress');

function getProgressFor(category) {
  progress = getCookie('progress');
  if(progress.search(category) > -1) {
    var categories = progress.split(',');
    var categoryString = '';
    for(var i = 0; i < categories.length; i++) {
      if(categories[i].search(category) > -1) {
        var resultsString = categories[i].replace(category + '-', '');
        var resultsArray = resultsString.split('-');
        return [parseInt(resultsArray[0]), parseInt(resultsArray[1])]
      }
    }
  } else {
    return [0, 0]
  }
}

function updateProgressFor(category, resultsArray) {
  progress = getCookie('progress');
  if(progress.search(category) > -1) {
    var categories = progress.split(',');
    var categoryString = '';
    for(var i = 0; i < categories.length; i++) {
      if(categories[i].search(category) > -1) {
        categories[i] = category + '-' + resultsArray[0].toString() + '-' + resultsArray[1].toString();
        break;
      }
    }
    progress = categories.join(',');
  } else {
    if(progress.length > 0) {
      progress += ',' + category + '-' + resultsArray[0].toString() + '-' + resultsArray[1].toString();
    } else {
      progress = category + '-' + resultsArray[0].toString() + '-' + resultsArray[1].toString();
    }
  }
  setCookie('progress', progress, 52);
}

function getProgressCategories() {
  progress = getCookie('progress');
  if(progress.length > 0) {
    var categories = progress.split(',');
    var categoryNames = []
    for(var i = 0; i < categories.length; i++) {
      categoryNames.push(categories[i].split('-')[0]);
    }
    return categoryNames;
  } else {
    return [];
  }
}

function updateCorrect(category) {
  results = getProgressFor(category);
  updateProgressFor(category, [results[0] + 1, results[1]]);
}

function updateIncorrect(category) {
  results = getProgressFor(category);
  updateProgressFor(category, [results[0], results[1] + 1]);
}

function removeCorrect(category) {
  results = getProgressFor(category);
  updateProgressFor(category, [results[0] - 1, results[1]]);
}

function removeIncorrect(category) {
  results = getProgressFor(category);
  updateProgressFor(category, [results[0], results[1] - 1]);
}

function clearProgress() {
  setCookie('progress', getCookie('progress'), -1);
}
