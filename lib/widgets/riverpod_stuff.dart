// Provider for events map
import 'package:ais_hackathon_better/firebase/firebase_instance_objects.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// State notifier for events map
class EventsMapNotifier extends StateNotifier<Map<DateTime, Event>> {
  EventsMapNotifier() : super({}) {
    setEvents({});
  }

  void setEvents(Map<DateTime, Event> events) {
    state = events;
  }
}
