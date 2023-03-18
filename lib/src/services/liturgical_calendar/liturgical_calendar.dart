import 'package:organizer/src/services/liturgical_calendar/feasts-sanctoral.dart';
import 'package:organizer/src/services/liturgical_calendar/feasts-temporal.dart';

import 'calendar.dart';
import 'utils.dart';

Calendar getLiturgicalCalendar([int? year]) {
  year ??= DateTime.now().year;

  Calendar calendar = Calendar(year);

  List<Map<String, String>> tempore = temporalFeasts;
  for (var feast in tempore) {
    calendar.addFeast(getFeastDate(year, feast, PropriumType.Tempore),
        getFeastData(feast, PropriumType.Tempore));
  }

  List<Map<String, String>> sanctorum = sanctoralFeasts;
  for (var feast in sanctorum) {
    calendar.addFeast(getFeastDate(year, feast, PropriumType.Sanctorum),
        getFeastData(feast, PropriumType.Sanctorum));
  }

  calendar.addMissingStuff();
  // calendar.saveCalendar();
  return calendar;
}
