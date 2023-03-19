import 'package:organizer/src/services/liturgical_calendar/feasts-sanctoral.dart';
import 'package:organizer/src/services/liturgical_calendar/feasts-temporal.dart';

import 'calendar.dart';
import 'utils.dart';

Calendar getLiturgicalCalendar([int? year]) {
  year ??= DateTime.now().year;

  Calendar calendar = Calendar(year);

  for (var feast in temporalFeasts) {
    calendar.addFeast(
        getDatePropriumDeTempore(year, feast), getFeastData(feast));
  }

  for (var feast in sanctoralFeasts) {
    calendar.addFeast(parseTime(year, feast['date']!), getFeastData(feast));
  }

  calendar.addMissingStuff();
  // calendar.saveCalendar();
  return calendar;
}
