var wordsOfTheDay = ["Morgan Freeman", "Dinner", "Old War Stories", "Leonardo DiCaprio", "Family", "None", "Childhood", "The Pharmacy", "Antigravity",
	"None", "Frozen", "Karma", "Noodles", "Pokemon Go!", "John Cena", "The Jungle"];
var allImportantWords = [["freeman"],
    ["dinner", "supper", "eat", "eating", "food", "foods", "eats", "ate", "cook", "cooking", "cooks", "hungry", "hunger"],
    ["war", "stories", "story", "country", "countries", "nation", "nations", "conflict", "crisis", "gun", "guns", "refugee", "tank", "aah"],
    ["dicaprio", "movie", "actor", "star"],
    ["grandma", "grandpa", "grandmother", "grandfather", "grandparents", "grandmama", "grandad", "mom", "dad", "mother", "father", "family", "brother", "sister", "sibling", "siblings", "brothers", "sisters", "aunt", "uncle"],
    [],
    ["childhood", "child", "little", "kid", "kids", "children", "happy", "friend", "friends", "mom", "dad", "home", "house", "school"],
    ["pharmacy", "pharmacist", "pharmaceutical", "drug", "drugs", "chemistry", "chemicals", "prescription"],
    ["antigravity", "gravity", "chamber", "space", "rocket", "dropping", "elevator", "physics"],
    [],
    ["frozen", "elsa", "anna", "kristoff", "hans", "olaf", "pabbie", "bulda", "disney", "movie", "ice", "snow", "love", "magic", "snowman"],
    ["karma", "luck", "good", "bad"],
    ["noodles", "sauce", "linguini", "spaghetti", "penne", "lasagna", "macaroni", "boil", "shell"],
    ["pokemon", "pikachu", "pika", "charizard", "squirtle", "ekans", "bulbasaur", "charmander", "psyduck", "em"],
    ["cena"],
    ["jungle", "tree", "trees", "monkey", "monkeys", "rain", "machete", "flowers", "foliage", "chimpanzee", "fig", "figs", "leaf", "leaves"]];

var firstDay = new Date(2016, 2, 12);

var todayMillis = Date.now(); // a number of milliseconds. NOT a Date object.

/* Number of milliseconds between first day and now divided by
   num of milliseconds in a day (86400000) tells us what day
   we're on.
*/
var index = Math.floor((todayMillis - firstDay.valueOf()) / 86400000.0) % wordsOfTheDay.length; 

var wordOfTheDay = wordsOfTheDay[index] || "There isn't one because no one suggested any. Go to Facebook and suggest one right now!";
var importantWords = allImportantWords[index] || [];

var cookieResetTime = 365 // days

function addAllWordOfTheDayReferences(topic, times, endFunction) {
  var xmlhttp = new XMLHttpRequest();
  xmlhttp.onreadystatechange = function() {
    if (xmlhttp.readyState == 4 && xmlhttp.status == 200) {
      endFunction(xmlhttp.responseText);
    }
  }
  xmlhttp.open("GET", "/word_of_the_day.cgi?times=" + times.toString() + "&&word=" + escape(topic), true);
  xmlhttp.send();
}

function getReferencesFor(word) {
  var references = parseInt(getCookie(word));
  if (isNaN(references)) {
    setCookie(word, "0", cookieResetTime);
    references = 0;
  }
  return references;
}

var todayReferences = getReferencesFor(wordOfTheDay);

function addReferencesFor(word, numReferences) {
  var references = parseInt(getCookie(word));
  if (isNaN(references)) {
    setCookie(word, numReferences.toString(), cookieResetTime);
    references = numReferences;
  } else {
    references += numReferences;
    setCookie(word, references.toString(), cookieResetTime);
  }
  
  function changeElement(times) {
    if (times > 0) {
      document.getElementById("percent").innerHTML = (100 * todayReferences / times).toFixed(1);
      document.getElementById("allReferences").innerHTML = times.toString();
    }
  }
  
  addAllWordOfTheDayReferences(word, numReferences, changeElement);
  
  todayReferences = references;
  return references;
}

function wordOfTheDayReferencesIn(string) {
  var times = 0;
  var fixedString = string.toLowerCase();
  fixedString = fixedString.replace(/(,|\.|\?|!|"|'|:|;|`|~|@|#|\$|%|\^|&|\*|\(|\)|\[|\]|\{|\}|<|>|\\|\/|\|)/g, "");
  var words = fixedString.split(" ");
  for (var i = 0; i < words.length; i++) {
    if (importantWords.indexOf(words[i]) != -1) {
      times++;
    }
  }
  return times;
}
