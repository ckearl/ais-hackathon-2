// Provider for events map
import 'package:ais_hackathon_better/firebase/firebase_instance_objects.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// State notifier for events map
class EventsMapNotifier extends StateNotifier<Map<DateTime, List<Event>>> {
  EventsMapNotifier() : super({}) {
    setEvents({});
  }

  void setEvents(Map<DateTime, List<Event>> events) {
    state = events;
  }
}

class EventItemsMapNotifier extends StateNotifier<Map<DateTime, EventItem>> {
  EventItemsMapNotifier() : super({}) {
    setEventItems({});
  }

  void setEventItems(Map<DateTime, EventItem> eventItems) {
    state = eventItems;
  }
}

class UserAdminNotifier extends StateNotifier<bool> {
  UserAdminNotifier() : super(false);

  void setBool(String str) {
    state = (str == 'false') ? false : true;
  }
}

class UserLastNameNotifier extends StateNotifier<String> {
  UserLastNameNotifier() : super("");

  void setString(String str) => state = str;
}

class UserFirstNameNotifier extends StateNotifier<String> {
  UserFirstNameNotifier() : super("");

  void setString(String str) => state = str;
}

class UserEmailNotifier extends StateNotifier<String> {
  UserEmailNotifier() : super("");

  void setString(String str) => state = str;
}

class UserUsernameNotifier extends StateNotifier<String> {
  UserUsernameNotifier() : super("");

  void setString(String str) => state = str;
}
