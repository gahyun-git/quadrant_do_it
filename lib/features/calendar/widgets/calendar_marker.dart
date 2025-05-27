import 'package:flutter/material.dart';

/// 캘린더 마커 빌더 (월간/주간 공용)
Widget buildCalendarMarker(BuildContext context, List events, Color Function(String?) getQuadrantColor) {
  if (events.isEmpty) return SizedBox.shrink();
  final isDark = Theme.of(context).brightness == Brightness.dark;
  final displayEvents = events.length > 3 ? events.sublist(0, 3) : events;

  return Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: displayEvents.map((event) {
      Color markerColor;
      String? quadrant;
      if (event is Map<String, dynamic> && event['quadrant'] is String) {
        quadrant = event['quadrant'] as String;
      }
      if (quadrant != null) {
        markerColor = getQuadrantColor(quadrant);
      } else {
        markerColor = isDark
          ? Theme.of(context).colorScheme.secondary
          : Theme.of(context).colorScheme.primary;
      }
      return Container(
        width: 6,
        height: 6,
        margin: const EdgeInsets.symmetric(horizontal: 0.5, vertical: 1.5),
        decoration: BoxDecoration(
          color: markerColor,
          shape: BoxShape.circle,
        ),
      );
    }).toList(),
  );
} 