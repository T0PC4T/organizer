import 'utils.dart';

const temporalFeasts = [
  (
    latinName: "Sanctissimi Nominis Jesu",
    englishName: "The Holy Name of Jesus",
    daysFromEaster: "",
    daysToEaster: "91",
    feastClass: FeastClass.secondClass,
    color: FeastColor.white,
    readingID: "Most_Holy_Name_of_Jesus"
  ),
  (
    latinName: "Dominica in Septuagesima",
    englishName: "Septuagesima Sunday",
    daysFromEaster: "",
    daysToEaster: "63",
    feastClass: FeastClass.secondClass,
    color: FeastColor.purple,
    readingID: "Septuagesima_Sunday"
  ),
  (
    latinName: "Dominica in Sexagesima",
    englishName: "Sexagesima Sunday",
    daysFromEaster: "",
    daysToEaster: "56",
    feastClass: FeastClass.secondClass,
    color: FeastColor.purple,
    readingID: "Sexagesima_Sunday"
  ),
  (
    latinName: "Dominica in Quinquagesima",
    englishName: "Quinquagesima Sunday",
    daysFromEaster: "",
    daysToEaster: "49",
    feastClass: FeastClass.secondClass,
    color: FeastColor.purple,
    readingID: "Quinquagesima_Sunday"
  ),
  (
    latinName: "Feria IV Cinerum",
    englishName: "Ash Wednesday",
    daysFromEaster: "",
    daysToEaster: "46",
    feastClass: FeastClass.firstClass,
    color: FeastColor.purple,
    readingID: "Ash_Wednesday"
  ),
  (
    latinName: "Dominica I in Quadr",
    englishName: "First Sunday of Lent",
    daysFromEaster: "",
    daysToEaster: "42",
    feastClass: FeastClass.firstClass,
    color: FeastColor.purple,
    readingID: "1st_Sunday_of_Lent"
  ),
  (
    latinName: "Feria Quarta Quattuor Temporum Quadragesimae",
    englishName: "Ember Wednesday of Lent",
    daysFromEaster: "",
    daysToEaster: "39",
    feastClass: FeastClass.secondClass,
    color: FeastColor.purple,
    readingID: ""
  ),
  (
    latinName: "Feria Sexta Quattuor Temporum Quadragesimae",
    englishName: "Ember Friday of Lent",
    daysFromEaster: "",
    daysToEaster: "37",
    feastClass: FeastClass.secondClass,
    color: FeastColor.purple,
    readingID: ""
  ),
  (
    latinName: "Feria VI post Cineres",
    englishName: "Friday after Ash Wednesday",
    daysFromEaster: "",
    daysToEaster: "44",
    feastClass: FeastClass.thirdClass,
    color: FeastColor.purple,
    readingID: ""
  ),
  (
    latinName: "Sabbato Quattuor Temporum Quadragesimae",
    englishName: "Ember Saturday of Lent",
    daysFromEaster: "",
    daysToEaster: "36",
    feastClass: FeastClass.secondClass,
    color: FeastColor.purple,
    readingID: ""
  ),
  (
    latinName: "Sabbato post Cineres",
    englishName: "Saturday after Ash Wednesday",
    daysFromEaster: "",
    daysToEaster: "43",
    feastClass: FeastClass.thirdClass,
    color: FeastColor.purple,
    readingID: ""
  ),
  (
    latinName: "Dominica II in Quadr",
    englishName: "Second Sunday of Lent",
    daysFromEaster: "",
    daysToEaster: "35",
    feastClass: FeastClass.firstClass,
    color: FeastColor.purple,
    readingID: "2nd_Sunday_of_Lent"
  ),
  (
    latinName: "Dominica III in Quadr",
    englishName: "Third Sunday of Lent",
    daysFromEaster: "",
    daysToEaster: "28",
    feastClass: FeastClass.firstClass,
    color: FeastColor.purple,
    readingID: "3rd_Sunday_of_Lent"
  ),
  (
    latinName: "Feria V post Cineres",
    englishName: "Thursday after Ash Wednesday",
    daysFromEaster: "",
    daysToEaster: "45",
    feastClass: FeastClass.thirdClass,
    color: FeastColor.purple,
    readingID: ""
  ),
  (
    latinName: "Dominica IV in Quadr",
    englishName: "Fourth Sunday of Lent",
    daysFromEaster: "",
    daysToEaster: "21",
    feastClass: FeastClass.firstClass,
    color: FeastColor.purple,
    readingID: "4th_Sunday_of_Lent"
  ),
  (
    latinName: "Dominica I Passionis",
    englishName: "Passion Sunday",
    daysFromEaster: "",
    daysToEaster: "14",
    feastClass: FeastClass.firstClass,
    color: FeastColor.purple,
    readingID: "Passion_Sunday"
  ),
  (
    latinName: "Dominica II Passionis seu in Palmis",
    englishName: "Palm Sunday",
    daysFromEaster: "",
    daysToEaster: "7",
    feastClass: FeastClass.firstClass,
    color: FeastColor.purple,
    readingID: "Palm_Sunday"
  ),
  (
    latinName: "Feria Secunda Hebdomadae Sanctae",
    englishName: "Monday of the Holy Week",
    daysFromEaster: "",
    daysToEaster: "6",
    feastClass: FeastClass.firstClass,
    color: FeastColor.purple,
    readingID: ""
  ),
  (
    latinName: "Feria Tertia Hebdomadae Sanctae",
    englishName: "Tuesday of the Holy Week",
    daysFromEaster: "",
    daysToEaster: "5",
    feastClass: FeastClass.firstClass,
    color: FeastColor.purple,
    readingID: ""
  ),
  (
    latinName: "Feria Quarta Hebdomadae Sanctae",
    englishName: "Wednesday of the Holy Week",
    daysFromEaster: "",
    daysToEaster: "4",
    feastClass: FeastClass.firstClass,
    color: FeastColor.purple,
    readingID: ""
  ),
  (
    latinName: "Feria Quinta in Cena Domini",
    englishName: "Holy Thursday",
    daysFromEaster: "",
    daysToEaster: "3",
    feastClass: FeastClass.firstClass,
    color: FeastColor.white,
    readingID: "Holy_Thursday"
  ),
  (
    latinName: "Feria Sexta in Passione et Morte Domini",
    englishName: "Good Friday",
    daysFromEaster: "",
    daysToEaster: "2",
    feastClass: FeastClass.firstClass,
    color: FeastColor.black,
    readingID: "Good_Friday"
  ),
  (
    latinName: "Sabbato Sancto",
    englishName: "Holy Saturday and the Easter Vigil",
    daysFromEaster: "",
    daysToEaster: "1",
    feastClass: FeastClass.firstClass,
    color: FeastColor.purple,
    readingID: "Easter_Vigil"
  ),
  (
    latinName: "Dominica Resurrectionis",
    englishName: "Easter Sunday",
    daysFromEaster: "0",
    daysToEaster: "",
    feastClass: FeastClass.firstClass,
    color: FeastColor.white,
    readingID: "Easter_Sunday"
  ),
  (
    latinName: "Dominica in Albis in Octava Paschae",
    englishName: "Low Sunday",
    daysFromEaster: "7",
    daysToEaster: "",
    feastClass: FeastClass.firstClass,
    color: FeastColor.white,
    readingID: "Low_Sunday"
  ),
  (
    latinName: "Die II infra octavam Paschae",
    englishName: "Easter Monday",
    daysFromEaster: "1",
    daysToEaster: "",
    feastClass: FeastClass.firstClass,
    color: FeastColor.white,
    readingID: ""
  ),
  (
    latinName: "Die III infra octavam Paschae",
    englishName: "Easter Tuesday",
    daysFromEaster: "2",
    daysToEaster: "",
    feastClass: FeastClass.firstClass,
    color: FeastColor.white,
    readingID: ""
  ),
  (
    latinName: "Die IV infra octavam Paschae",
    englishName: "Easter Wednesday",
    daysFromEaster: "3",
    daysToEaster: "",
    feastClass: FeastClass.firstClass,
    color: FeastColor.white,
    readingID: ""
  ),
  (
    latinName: "Die V infra octavam Paschae",
    englishName: "Easter Thursday",
    daysFromEaster: "4",
    daysToEaster: "",
    feastClass: FeastClass.firstClass,
    color: FeastColor.white,
    readingID: ""
  ),
  (
    latinName: "Dominica II Post Pascha",
    englishName: "Second Sunday after Easter",
    daysFromEaster: "14",
    daysToEaster: "",
    feastClass: FeastClass.secondClass,
    color: FeastColor.white,
    readingID: "2nd_Sunday_After_Easter"
  ),
  (
    latinName: "Sabbato in Albis",
    englishName: "Easter Saturday",
    daysFromEaster: "6",
    daysToEaster: "",
    feastClass: FeastClass.firstClass,
    color: FeastColor.white,
    readingID: ""
  ),
  (
    latinName: "Dominica III Post Pascha",
    englishName: "Third Sunday after Easter",
    daysFromEaster: "21",
    daysToEaster: "",
    feastClass: FeastClass.secondClass,
    color: FeastColor.white,
    readingID: "3rd_Sunday_After_Easter"
  ),
  (
    latinName: "Die VI infra octavam Paschae",
    englishName: "Easter Friday",
    daysFromEaster: "5",
    daysToEaster: "",
    feastClass: FeastClass.firstClass,
    color: FeastColor.white,
    readingID: ""
  ),
  (
    latinName: "Dominica IV Post Pascha",
    englishName: "Fourth Sunday after Easter",
    daysFromEaster: "28",
    daysToEaster: "",
    feastClass: FeastClass.secondClass,
    color: FeastColor.white,
    readingID: "4th_Sunday_After_Easter"
  ),
  (
    latinName: "Dominica V Post Pascha",
    englishName: "Fifth Sunday after Easter",
    daysFromEaster: "35",
    daysToEaster: "",
    feastClass: FeastClass.secondClass,
    color: FeastColor.white,
    readingID: "5th_Sunday_After_Easter"
  ),
  (
    latinName: "Feria in Rogationibus",
    englishName: "Rogation Mass",
    daysFromEaster: "36",
    daysToEaster: "",
    feastClass: FeastClass.secondClass,
    color: FeastColor.purple,
    readingID: ""
  ),
  (
    latinName: "Feria in Rogationibus",
    englishName: "Rogation Mass",
    daysFromEaster: "37",
    daysToEaster: "",
    feastClass: FeastClass.secondClass,
    color: FeastColor.purple,
    readingID: ""
  ),
  (
    latinName: "In Vigilia Ascensionis",
    englishName: "The Vigil of Ascention",
    daysFromEaster: "38",
    daysToEaster: "",
    feastClass: FeastClass.secondClass,
    color: FeastColor.purple,
    readingID: ""
  ),
  (
    latinName: "Feria in Rogationibus",
    englishName: "Rogation Mass",
    daysFromEaster: "38",
    daysToEaster: "",
    feastClass: FeastClass.secondClass,
    color: FeastColor.purple,
    readingID: ""
  ),
  (
    latinName: "In Ascensione Domini",
    englishName: "Ascension of the Lord",
    daysFromEaster: "39",
    daysToEaster: "",
    feastClass: FeastClass.firstClass,
    color: FeastColor.white,
    readingID: "Ascension_of_the_Lord"
  ),
  (
    latinName: "Dominica post Ascensionem",
    englishName: "Sunday after the Ascension",
    daysFromEaster: "42",
    daysToEaster: "",
    feastClass: FeastClass.secondClass,
    color: FeastColor.white,
    readingID: "Sunday_After_the_Ascension"
  ),
  (
    latinName: "Sabbato in Vigilia Pentecostes",
    englishName: "Vigil of the Pentecost",
    daysFromEaster: "48",
    daysToEaster: "",
    feastClass: FeastClass.firstClass,
    color: FeastColor.red,
    readingID: ""
  ),
  (
    latinName: "Dominica Pentecostes",
    englishName: "Pentecost Sunday",
    daysFromEaster: "49",
    daysToEaster: "",
    feastClass: FeastClass.firstClass,
    color: FeastColor.red,
    readingID: "Pentecost_Sunday"
  ),
  (
    latinName: "Feria Secunda infra Octavam Pentecostes",
    englishName: "Pentecost Monday",
    daysFromEaster: "50",
    daysToEaster: "",
    feastClass: FeastClass.firstClass,
    color: FeastColor.red,
    readingID: ""
  ),
  (
    latinName: "Feria Tertia infra Octavam Pentecostes",
    englishName: "Pentecost Tuesday",
    daysFromEaster: "51",
    daysToEaster: "",
    feastClass: FeastClass.firstClass,
    color: FeastColor.red,
    readingID: ""
  ),
  (
    latinName: "Feria Quarta Quattuor Temporum Pentecostes",
    englishName: "Ember Wednesday in the Octave of Pentecost",
    daysFromEaster: "52",
    daysToEaster: "",
    feastClass: FeastClass.firstClass,
    color: FeastColor.red,
    readingID: ""
  ),
  (
    latinName: "Feria Quinta infra Octavam Pentecostes",
    englishName: "Pentecost Thursday",
    daysFromEaster: "53",
    daysToEaster: "",
    feastClass: FeastClass.firstClass,
    color: FeastColor.red,
    readingID: ""
  ),
  (
    latinName: "Feria Sexta Quattuor Temporum Pentecostes",
    englishName: "Ember Friday in the Octave of Pentecost",
    daysFromEaster: "54",
    daysToEaster: "",
    feastClass: FeastClass.firstClass,
    color: FeastColor.red,
    readingID: ""
  ),
  (
    latinName: "Sabbato Quattuor Temporum Pentecostes",
    englishName: "Ember Saturday in the Octave of Pentecost",
    daysFromEaster: "55",
    daysToEaster: "",
    feastClass: FeastClass.firstClass,
    color: FeastColor.red,
    readingID: ""
  ),
  (
    latinName: "Dominica Sanctissimae Trinitatis",
    englishName: "Holy Trinity Sunday",
    daysFromEaster: "56",
    daysToEaster: "",
    feastClass: FeastClass.firstClass,
    color: FeastColor.white,
    readingID: "Trinity_Sunday"
  ),
  (
    latinName: "Festum Sanctissimi Corporis Christi",
    englishName: "Corpus Christi",
    daysFromEaster: "60",
    daysToEaster: "",
    feastClass: FeastClass.firstClass,
    color: FeastColor.white,
    readingID: "Corpus_Christi"
  ),
  (
    latinName: "Dominica II Post Pentecosten",
    englishName: "Second Sunday Post Pentecosten",
    daysFromEaster: "63",
    daysToEaster: "",
    feastClass: FeastClass.secondClass,
    color: FeastColor.green,
    readingID: "2nd_Sunday_after_Pentecost"
  ),
  (
    latinName: "(USA)Externa Sollemnitas Corpori Christi",
    englishName: "(USA)External Solemnity of Corpus Christy",
    daysFromEaster: "63",
    daysToEaster: "",
    feastClass: FeastClass.secondClass,
    color: FeastColor.white,
    readingID: "Corpus_Christi"
  ),
  (
    latinName: "Sanctissimi Cordis Domini Nostri Jesu Christi",
    englishName: "Sacred Heart of Jesus",
    daysFromEaster: "68",
    daysToEaster: "",
    feastClass: FeastClass.firstClass,
    color: FeastColor.white,
    readingID: "Sacred_Heart_of_Jesus"
  ),
  (
    latinName: "Dominica III Post Pentecosten",
    englishName: "Third Sunday after the Pentecost",
    daysFromEaster: "70",
    daysToEaster: "",
    feastClass: FeastClass.secondClass,
    color: FeastColor.green,
    readingID: "3rd_Sunday_after_Pentecost"
  ),
  (
    latinName: "(USA)Externa Sollemnitas Sanctissimi Cordis DNJC",
    englishName: "(USA)External Solemnity of The Sacred Heart of Jesus",
    daysFromEaster: "70",
    daysToEaster: "",
    feastClass: FeastClass.secondClass,
    color: FeastColor.green,
    readingID: "Sacred_Heart_of_Jesus"
  ),
  (
    latinName: "Dominica IV Post Pentecosten",
    englishName: "Fourth Sunday after the Pentecost",
    daysFromEaster: "77",
    daysToEaster: "",
    feastClass: FeastClass.secondClass,
    color: FeastColor.green,
    readingID: "4th_Sunday_after_Pentecost"
  ),
  (
    latinName: "Dominica V Post Pentecosten",
    englishName: "Fifth Sunday after the Pentecost",
    daysFromEaster: "84",
    daysToEaster: "",
    feastClass: FeastClass.secondClass,
    color: FeastColor.green,
    readingID: "5th_Sunday_after_Pentecost"
  ),
  (
    latinName: "Dominica VI Post Pentecosten",
    englishName: "Sixth Sunday after the Pentecost",
    daysFromEaster: "91",
    daysToEaster: "",
    feastClass: FeastClass.secondClass,
    color: FeastColor.green,
    readingID: "6th_Sunday_after_Pentecost"
  ),
  (
    latinName: "Dominica VII Post Pentecosten",
    englishName: "Seventh Sunday after the Pentecost",
    daysFromEaster: "98",
    daysToEaster: "",
    feastClass: FeastClass.secondClass,
    color: FeastColor.green,
    readingID: "7th_Sunday_after_Pentecost"
  ),
  (
    latinName: "Dominica VIII Post Pentecosten",
    englishName: "Eight Sunday after the Pentecost",
    daysFromEaster: "105",
    daysToEaster: "",
    feastClass: FeastClass.secondClass,
    color: FeastColor.green,
    readingID: "8th_Sunday_after_Pentecost"
  ),
  (
    latinName: "Dominica IX Post Pentecosten",
    englishName: "Nineth Sunday after the Pentecost",
    daysFromEaster: "112",
    daysToEaster: "",
    feastClass: FeastClass.secondClass,
    color: FeastColor.green,
    readingID: "9th_Sunday_after_Pentecost"
  ),
  (
    latinName: "Dominica X Post Pentecosten",
    englishName: "Tenth Sunday after the Pentecost",
    daysFromEaster: "119",
    daysToEaster: "",
    feastClass: FeastClass.secondClass,
    color: FeastColor.green,
    readingID: "10th_Sunday_after_Pentecost"
  ),
  (
    latinName: "Dominica XI Post Pentecosten",
    englishName: "Eleventh Sunday after the Pentecost",
    daysFromEaster: "126",
    daysToEaster: "",
    feastClass: FeastClass.secondClass,
    color: FeastColor.green,
    readingID: "11th_Sunday_after_Pentecost"
  ),
  (
    latinName: "Dominica XII Post Pentecosten",
    englishName: "Twelfth Sunday after the Pentecost",
    daysFromEaster: "133",
    daysToEaster: "",
    feastClass: FeastClass.secondClass,
    color: FeastColor.green,
    readingID: "12th_Sunday_after_Pentecost"
  ),
  (
    latinName: "Dominica XIII Post Pentecosten",
    englishName: "Thirteenth Sunday after the Pentecost",
    daysFromEaster: "140",
    daysToEaster: "",
    feastClass: FeastClass.secondClass,
    color: FeastColor.green,
    readingID: "13th_Sunday_after_Pentecost"
  ),
  (
    latinName: "Dominica XIV Post Pentecosten",
    englishName: "Fourteenth Sunday after the Pentecost",
    daysFromEaster: "147",
    daysToEaster: "",
    feastClass: FeastClass.secondClass,
    color: FeastColor.green,
    readingID: "14th_Sunday_after_Pentecost"
  ),
  (
    latinName: "Dominica XV Post Pentecosten",
    englishName: "Fifteenth Sunday after the Pentecost",
    daysFromEaster: "154",
    daysToEaster: "",
    feastClass: FeastClass.secondClass,
    color: FeastColor.green,
    readingID: "15th_Sunday_after_Pentecost"
  ),
  (
    latinName: "Dominica XVI Post Pentecosten",
    englishName: "Sixteenth Sunday after the Pentecost",
    daysFromEaster: "161",
    daysToEaster: "",
    feastClass: FeastClass.secondClass,
    color: FeastColor.green,
    readingID: "16th_Sunday_after_Pentecost"
  ),
  (
    latinName: "Dominica XVII Post Pentecosten",
    englishName: "Seventeenth Sunday after the Pentecost",
    daysFromEaster: "168",
    daysToEaster: "",
    feastClass: FeastClass.secondClass,
    color: FeastColor.green,
    readingID: "17th_Sunday_after_Pentecost"
  ),
  (
    latinName: "Dominica XVIII Post Pentecosten",
    englishName: "Eighteenth Sunday after the Pentecost",
    daysFromEaster: "175",
    daysToEaster: "",
    feastClass: FeastClass.secondClass,
    color: FeastColor.green,
    readingID: "18th_Sunday_after_Pentecost"
  ),
  (
    latinName: "Dominica XIX Post Pentecosten",
    englishName: "Nineteenth Sunday after the Pentecost",
    daysFromEaster: "182",
    daysToEaster: "",
    feastClass: FeastClass.secondClass,
    color: FeastColor.green,
    readingID: "19th_Sunday_after_Pentecost"
  ),
  (
    latinName: "Dominica XX Post Pentecosten",
    englishName: "Twentieth Sunday after the Pentecost",
    daysFromEaster: "189",
    daysToEaster: "",
    feastClass: FeastClass.secondClass,
    color: FeastColor.green,
    readingID: "20th_Sunday_after_Pentecost"
  ),
  (
    latinName: "Dominica XXI Post Pentecosten",
    englishName: "Twenty first Sunday after the Pentecost",
    daysFromEaster: "196",
    daysToEaster: "",
    feastClass: FeastClass.secondClass,
    color: FeastColor.green,
    readingID: "21th_Sunday_after_Pentecost"
  ),
  (
    latinName: "Dominica XXII Post Pentecosten",
    englishName: "Twenty second Sunday after the Pentecost",
    daysFromEaster: "203",
    daysToEaster: "",
    feastClass: FeastClass.secondClass,
    color: FeastColor.green,
    readingID: "22th_Sunday_after_Pentecost"
  ),
  (
    latinName: "Dominica XXIII Post Pentecosten",
    englishName: "Twenty third Sunday after the Pentecost",
    daysFromEaster: "210",
    daysToEaster: "",
    feastClass: FeastClass.secondClass,
    color: FeastColor.green,
    readingID: "23th_Sunday_after_Pentecost"
  )
];
