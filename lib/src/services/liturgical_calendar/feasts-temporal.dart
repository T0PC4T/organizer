import 'utils.dart';

const temporalFeasts = [
  (
    latinName: "Sanctissimi Nominis Jesu",
    englishName: "The Holy Name of Jesus",
    daysFromEaster: "",
    daysToEaster: "91",
    feastClass: FeastClass.secondClass,
    color: Color.white
  ),
  (
    latinName: "Dominica in Septuagesima",
    englishName: "Septuagesima Sunday",
    daysFromEaster: "",
    daysToEaster: "63",
    feastClass: FeastClass.secondClass,
    color: Color.purple
  ),
  (
    latinName: "Dominica in Sexagesima",
    englishName: "Sexagesima Sunday",
    daysFromEaster: "",
    daysToEaster: "56",
    feastClass: FeastClass.secondClass,
    color: Color.purple
  ),
  (
    latinName: "Dominica in Quinquagesima",
    englishName: "Quinquagesima Sunday",
    daysFromEaster: "",
    daysToEaster: "49",
    feastClass: FeastClass.secondClass,
    color: Color.purple
  ),
  (
    latinName: "Feria IV Cinerum",
    englishName: "Ash Wednesday",
    daysFromEaster: "",
    daysToEaster: "46",
    feastClass: FeastClass.firstClass,
    color: Color.purple
  ),
  (
    latinName: "Dominica I in Quadr",
    englishName: "First Sunday of Lent",
    daysFromEaster: "",
    daysToEaster: "42",
    feastClass: FeastClass.firstClass,
    color: Color.purple
  ),
  (
    latinName: "Feria Quarta Quattuor Temporum Quadragesimae",
    englishName: "Ember Wednesday of Lent",
    daysFromEaster: "",
    daysToEaster: "39",
    feastClass: FeastClass.secondClass,
    color: Color.purple
  ),
  (
    latinName: "Feria Sexta Quattuor Temporum Quadragesimae",
    englishName: "Ember Friday of Lent",
    daysFromEaster: "",
    daysToEaster: "37",
    feastClass: FeastClass.secondClass,
    color: Color.purple
  ),
  (
    latinName: "Feria VI post Cineres",
    englishName: "Friday after Ash Wednesday",
    daysFromEaster: "",
    daysToEaster: "44",
    feastClass: FeastClass.thirdClass,
    color: Color.purple
  ),
  (
    latinName: "Sabbato Quattuor Temporum Quadragesimae",
    englishName: "Ember Saturday of Lent",
    daysFromEaster: "",
    daysToEaster: "36",
    feastClass: FeastClass.secondClass,
    color: Color.purple
  ),
  (
    latinName: "Sabbato post Cineres",
    englishName: "Saturday after Ash Wednesday",
    daysFromEaster: "",
    daysToEaster: "43",
    feastClass: FeastClass.thirdClass,
    color: Color.purple
  ),
  (
    latinName: "Dominica II in Quadr",
    englishName: "Second Sunday of Lent",
    daysFromEaster: "",
    daysToEaster: "35",
    feastClass: FeastClass.firstClass,
    color: Color.purple
  ),
  (
    latinName: "Dominica III in Quadr",
    englishName: "Third Sunday of Lent",
    daysFromEaster: "",
    daysToEaster: "28",
    feastClass: FeastClass.firstClass,
    color: Color.purple
  ),
  (
    latinName: "Feria V post Cineres",
    englishName: "Thursday after Ash Wednesday",
    daysFromEaster: "",
    daysToEaster: "45",
    feastClass: FeastClass.thirdClass,
    color: Color.purple
  ),
  (
    latinName: "Dominica IV in Quadr",
    englishName: "Fourth Sunday of Lent",
    daysFromEaster: "",
    daysToEaster: "21",
    feastClass: FeastClass.firstClass,
    color: Color.purple
  ),
  (
    latinName: "Dominica I Passionis",
    englishName: "Passion Sunday",
    daysFromEaster: "",
    daysToEaster: "14",
    feastClass: FeastClass.firstClass,
    color: Color.purple
  ),
  (
    latinName: "Dominica II Passionis seu in Palmis",
    englishName: "Palm Sunday",
    daysFromEaster: "",
    daysToEaster: "7",
    feastClass: FeastClass.firstClass,
    color: Color.purple
  ),
  (
    latinName: "Feria Secunda Hebdomadae Sanctae",
    englishName: "Monday of the Holy Week",
    daysFromEaster: "",
    daysToEaster: "6",
    feastClass: FeastClass.firstClass,
    color: Color.purple
  ),
  (
    latinName: "Feria Tertia Hebdomadae Sanctae",
    englishName: "Tuesday of the Holy Week",
    daysFromEaster: "",
    daysToEaster: "5",
    feastClass: FeastClass.firstClass,
    color: Color.purple
  ),
  (
    latinName: "Feria Quarta Hebdomadae Sanctae",
    englishName: "Wednesday of the Holy Week",
    daysFromEaster: "",
    daysToEaster: "4",
    feastClass: FeastClass.firstClass,
    color: Color.purple
  ),
  (
    latinName: "Feria Quinta in Cena Domini",
    englishName: "Holy Thursday",
    daysFromEaster: "",
    daysToEaster: "3",
    feastClass: FeastClass.firstClass,
    color: Color.white
  ),
  (
    latinName: "Feria Sexta in Passione et Morte Domini",
    englishName: "Good Friday",
    daysFromEaster: "",
    daysToEaster: "2",
    feastClass: FeastClass.firstClass,
    color: Color.black
  ),
  (
    latinName: "Sabbato Sancto",
    englishName: "Holy Saturday and the Easter Vigil",
    daysFromEaster: "",
    daysToEaster: "1",
    feastClass: FeastClass.firstClass,
    color: Color.purple
  ),
  (
    latinName: "Dominica Resurrectionis",
    englishName: "Easter Sunday",
    daysFromEaster: "0",
    daysToEaster: "",
    feastClass: FeastClass.firstClass,
    color: Color.white
  ),
  (
    latinName: "Dominica in Albis in Octava Paschae",
    englishName: "Low Sunday",
    daysFromEaster: "7",
    daysToEaster: "",
    feastClass: FeastClass.firstClass,
    color: Color.white
  ),
  (
    latinName: "Die II infra octavam Paschae",
    englishName: "Easter Monday",
    daysFromEaster: "1",
    daysToEaster: "",
    feastClass: FeastClass.firstClass,
    color: Color.white
  ),
  (
    latinName: "Die III infra octavam Paschae",
    englishName: "Easter Tuesday",
    daysFromEaster: "2",
    daysToEaster: "",
    feastClass: FeastClass.firstClass,
    color: Color.white
  ),
  (
    latinName: "Die IV infra octavam Paschae",
    englishName: "Easter Wednesday",
    daysFromEaster: "3",
    daysToEaster: "",
    feastClass: FeastClass.firstClass,
    color: Color.white
  ),
  (
    latinName: "Die V infra octavam Paschae",
    englishName: "Easter Thursday",
    daysFromEaster: "4",
    daysToEaster: "",
    feastClass: FeastClass.firstClass,
    color: Color.white
  ),
  (
    latinName: "Dominica II Post Pascha",
    englishName: "Second Sunday after Easter",
    daysFromEaster: "14",
    daysToEaster: "",
    feastClass: FeastClass.secondClass,
    color: Color.white
  ),
  (
    latinName: "Sabbato in Albis",
    englishName: "Easter Saturday",
    daysFromEaster: "6",
    daysToEaster: "",
    feastClass: FeastClass.firstClass,
    color: Color.white
  ),
  (
    latinName: "Dominica III Post Pascha",
    englishName: "Third Sunday after Easter",
    daysFromEaster: "21",
    daysToEaster: "",
    feastClass: FeastClass.secondClass,
    color: Color.white
  ),
  (
    latinName: "Die VI infra octavam Paschae",
    englishName: "Easter Friday",
    daysFromEaster: "5",
    daysToEaster: "",
    feastClass: FeastClass.firstClass,
    color: Color.white
  ),
  (
    latinName: "Dominica IV Post Pascha",
    englishName: "Fourth Sunday after Easter",
    daysFromEaster: "28",
    daysToEaster: "",
    feastClass: FeastClass.secondClass,
    color: Color.white
  ),
  (
    latinName: "Dominica V Post Pascha",
    englishName: "Fifth Sunday after Easter",
    daysFromEaster: "35",
    daysToEaster: "",
    feastClass: FeastClass.secondClass,
    color: Color.white
  ),
  (
    latinName: "Feria in Rogationibus",
    englishName: "Rogation Mass",
    daysFromEaster: "36",
    daysToEaster: "",
    feastClass: FeastClass.secondClass,
    color: Color.purple
  ),
  (
    latinName: "Feria in Rogationibus",
    englishName: "Rogation Mass",
    daysFromEaster: "37",
    daysToEaster: "",
    feastClass: FeastClass.secondClass,
    color: Color.purple
  ),
  (
    latinName: "In Vigilia Ascensionis",
    englishName: "The Vigil of Ascention",
    daysFromEaster: "38",
    daysToEaster: "",
    feastClass: FeastClass.secondClass,
    color: Color.purple
  ),
  (
    latinName: "Feria in Rogationibus",
    englishName: "Rogation Mass",
    daysFromEaster: "38",
    daysToEaster: "",
    feastClass: FeastClass.secondClass,
    color: Color.purple
  ),
  (
    latinName: "In Ascensione Domini",
    englishName: "Ascension of the Lord",
    daysFromEaster: "39",
    daysToEaster: "",
    feastClass: FeastClass.firstClass,
    color: Color.white
  ),
  (
    latinName: "Dominica post Ascensionem",
    englishName: "Sunday after the Ascension",
    daysFromEaster: "42",
    daysToEaster: "",
    feastClass: FeastClass.secondClass,
    color: Color.white
  ),
  (
    latinName: "Sabbato in Vigilia Pentecostes",
    englishName: "Vigil of the Pentecost",
    daysFromEaster: "48",
    daysToEaster: "",
    feastClass: FeastClass.firstClass,
    color: Color.red
  ),
  (
    latinName: "Dominica Pentecostes",
    englishName: "Pentecost Sunday",
    daysFromEaster: "49",
    daysToEaster: "",
    feastClass: FeastClass.firstClass,
    color: Color.red
  ),
  (
    latinName: "Feria Secunda infra Octavam Pentecostes",
    englishName: "Pentecost Monday",
    daysFromEaster: "50",
    daysToEaster: "",
    feastClass: FeastClass.firstClass,
    color: Color.red
  ),
  (
    latinName: "Feria Tertia infra Octavam Pentecostes",
    englishName: "Pentecost Tuesday",
    daysFromEaster: "51",
    daysToEaster: "",
    feastClass: FeastClass.firstClass,
    color: Color.red
  ),
  (
    latinName: "Feria Quarta Quattuor Temporum Pentecostes",
    englishName: "Ember Wednesday in the Octave of Pentecost",
    daysFromEaster: "52",
    daysToEaster: "",
    feastClass: FeastClass.firstClass,
    color: Color.red
  ),
  (
    latinName: "Feria Quinta infra Octavam Pentecostes",
    englishName: "Pentecost Thursday",
    daysFromEaster: "53",
    daysToEaster: "",
    feastClass: FeastClass.firstClass,
    color: Color.red
  ),
  (
    latinName: "Feria Sexta Quattuor Temporum Pentecostes",
    englishName: "Ember Friday in the Octave of Pentecost",
    daysFromEaster: "54",
    daysToEaster: "",
    feastClass: FeastClass.firstClass,
    color: Color.red
  ),
  (
    latinName: "Sabbato Quattuor Temporum Pentecostes",
    englishName: "Ember Saturday in the Octave of Pentecost",
    daysFromEaster: "55",
    daysToEaster: "",
    feastClass: FeastClass.firstClass,
    color: Color.red
  ),
  (
    latinName: "Dominica Sanctissimae Trinitatis",
    englishName: "Holy Trinity Sunday",
    daysFromEaster: "56",
    daysToEaster: "",
    feastClass: FeastClass.firstClass,
    color: Color.white
  ),
  (
    latinName: "Festum Sanctissimi Corporis Christi",
    englishName: "Corpus Christi",
    daysFromEaster: "60",
    daysToEaster: "",
    feastClass: FeastClass.firstClass,
    color: Color.white
  ),
  (
    latinName: "Dominica II Post Pentecosten",
    englishName: "Second Sunday Post Pentecosten",
    daysFromEaster: "63",
    daysToEaster: "",
    feastClass: FeastClass.secondClass,
    color: Color.green
  ),
  (
    latinName: "(USA)Externa Sollemnitas Corpori Christi",
    englishName: "(USA)External Solemnity of Corpus Christy",
    daysFromEaster: "63",
    daysToEaster: "",
    feastClass: FeastClass.secondClass,
    color: Color.white
  ),
  (
    latinName: "Sanctissimi Cordis Domini Nostri Jesu Christi",
    englishName: "Sacred Heart of Jesus",
    daysFromEaster: "68",
    daysToEaster: "",
    feastClass: FeastClass.firstClass,
    color: Color.white
  ),
  (
    latinName: "Dominica III Post Pentecosten",
    englishName: "Third Sunday after the Pentecost",
    daysFromEaster: "70",
    daysToEaster: "",
    feastClass: FeastClass.secondClass,
    color: Color.green
  ),
  (
    latinName: "(USA)Externa Sollemnitas Sanctissimi Corde DNJC",
    englishName: "(USA)External Solemnity of The Sacred Heart of Jesus",
    daysFromEaster: "70",
    daysToEaster: "",
    feastClass: FeastClass.secondClass,
    color: Color.green
  ),
  (
    latinName: "Dominica IV Post Pentecosten",
    englishName: "Fourth Sunday after the Pentecost",
    daysFromEaster: "77",
    daysToEaster: "",
    feastClass: FeastClass.secondClass,
    color: Color.green
  ),
  (
    latinName: "Dominica V Post Pentecosten",
    englishName: "Fifth Sunday after the Pentecost",
    daysFromEaster: "84",
    daysToEaster: "",
    feastClass: FeastClass.secondClass,
    color: Color.green
  ),
  (
    latinName: "Dominica VI Post Pentecosten",
    englishName: "Sixth Sunday after the Pentecost",
    daysFromEaster: "91",
    daysToEaster: "",
    feastClass: FeastClass.secondClass,
    color: Color.green
  ),
  (
    latinName: "Dominica VII Post Pentecosten",
    englishName: "Seventh Sunday after the Pentecost",
    daysFromEaster: "98",
    daysToEaster: "",
    feastClass: FeastClass.secondClass,
    color: Color.green
  ),
  (
    latinName: "Dominica VIII Post Pentecosten",
    englishName: "Eight Sunday after the Pentecost",
    daysFromEaster: "105",
    daysToEaster: "",
    feastClass: FeastClass.secondClass,
    color: Color.green
  ),
  (
    latinName: "Dominica IX Post Pentecosten",
    englishName: "Nineth Sunday after the Pentecost",
    daysFromEaster: "112",
    daysToEaster: "",
    feastClass: FeastClass.secondClass,
    color: Color.green
  ),
  (
    latinName: "Dominica X Post Pentecosten",
    englishName: "Tenth Sunday after the Pentecost",
    daysFromEaster: "119",
    daysToEaster: "",
    feastClass: FeastClass.secondClass,
    color: Color.green
  ),
  (
    latinName: "Dominica XI Post Pentecosten",
    englishName: "Eleventh Sunday after the Pentecost",
    daysFromEaster: "126",
    daysToEaster: "",
    feastClass: FeastClass.secondClass,
    color: Color.green
  ),
  (
    latinName: "Dominica XII Post Pentecosten",
    englishName: "Twelfth Sunday after the Pentecost",
    daysFromEaster: "133",
    daysToEaster: "",
    feastClass: FeastClass.secondClass,
    color: Color.green
  ),
  (
    latinName: "Dominica XIII Post Pentecosten",
    englishName: "Thirteenth Sunday after the Pentecost",
    daysFromEaster: "140",
    daysToEaster: "",
    feastClass: FeastClass.secondClass,
    color: Color.green
  ),
  (
    latinName: "Dominica XIV Post Pentecosten",
    englishName: "Fourteenth Sunday after the Pentecost",
    daysFromEaster: "147",
    daysToEaster: "",
    feastClass: FeastClass.secondClass,
    color: Color.green
  ),
  (
    latinName: "Dominica XV Post Pentecosten",
    englishName: "Fifteenth Sunday after the Pentecost",
    daysFromEaster: "154",
    daysToEaster: "",
    feastClass: FeastClass.secondClass,
    color: Color.green
  ),
  (
    latinName: "Dominica XVI Post Pentecosten",
    englishName: "Sixteenth Sunday after the Pentecost",
    daysFromEaster: "161",
    daysToEaster: "",
    feastClass: FeastClass.secondClass,
    color: Color.green
  ),
  (
    latinName: "Dominica XVII Post Pentecosten",
    englishName: "Seventeenth Sunday after the Pentecost",
    daysFromEaster: "168",
    daysToEaster: "",
    feastClass: FeastClass.secondClass,
    color: Color.green
  ),
  (
    latinName: "Dominica XVIII Post Pentecosten",
    englishName: "Eighteenth Sunday after the Pentecost",
    daysFromEaster: "175",
    daysToEaster: "",
    feastClass: FeastClass.secondClass,
    color: Color.green
  ),
  (
    latinName: "Dominica XIX Post Pentecosten",
    englishName: "Nineteenth Sunday after the Pentecost",
    daysFromEaster: "182",
    daysToEaster: "",
    feastClass: FeastClass.secondClass,
    color: Color.green
  ),
  (
    latinName: "Dominica XX Post Pentecosten",
    englishName: "Twentieth Sunday after the Pentecost",
    daysFromEaster: "189",
    daysToEaster: "",
    feastClass: FeastClass.secondClass,
    color: Color.green
  ),
  (
    latinName: "Dominica XXI Post Pentecosten",
    englishName: "Twenty first Sunday after the Pentecost",
    daysFromEaster: "196",
    daysToEaster: "",
    feastClass: FeastClass.secondClass,
    color: Color.green
  ),
  (
    latinName: "Dominica XXII Post Pentecosten",
    englishName: "Twenty second Sunday after the Pentecost",
    daysFromEaster: "203",
    daysToEaster: "",
    feastClass: FeastClass.secondClass,
    color: Color.green
  ),
  (
    latinName: "Dominica XXIII Post Pentecosten",
    englishName: "Twenty third Sunday after the Pentecost",
    daysFromEaster: "210",
    daysToEaster: "",
    feastClass: FeastClass.secondClass,
    color: Color.green
  )
];
