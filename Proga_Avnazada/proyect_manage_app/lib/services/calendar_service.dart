import 'package:device_calendar/device_calendar.dart';
import 'package:timezone/timezone.dart' as tz;

class CalendarService {
  final DeviceCalendarPlugin _plugin = DeviceCalendarPlugin();

  Future<List<Calendar>> _getCalendarsWithPermission() async {
    final perm = await _plugin.hasPermissions();
    if (!(perm.data ?? false)) {
      final request = await _plugin.requestPermissions();
      if (!(request.data ?? false)) return [];
    }
    final calendarsResult = await _plugin.retrieveCalendars();
    return calendarsResult.data ?? [];
  }

  Future<bool> addProjectDeadlineToCalendar(
    String title,
    String description,
    DateTime deadline,
  ) async {
    final calendars = await _getCalendarsWithPermission();
    if (calendars.isEmpty) return false;

    final calendar = calendars.first;

    final tzStart = tz.TZDateTime.from(
      deadline.subtract(const Duration(hours: 1)),
      tz.local,
    );
    final tzEnd = tz.TZDateTime.from(
      deadline.add(const Duration(minutes: 30)),
      tz.local,
    );

    final event = Event(
      calendar.id,
      title: '📌 Deadline: $title',
      description: description,
      start: tzStart,
      end: tzEnd,
    );

    final result = await _plugin.createOrUpdateEvent(event);
    return result?.isSuccess ?? false;
  }
}
