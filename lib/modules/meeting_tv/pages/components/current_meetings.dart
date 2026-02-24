import 'package:flutter/material.dart';
import 'package:oman_tv/configs/theme/app_colors.dart';
import 'package:oman_tv/models/tv_display_response.dart';
import 'package:oman_tv/modules/meeting_tv/pages/components/compact_room_card.dart';

class CurrentMeetings extends StatelessWidget {
  final bool showBusyRooms;
  final List<Room> bookedRooms;
  final List<Room> freeRooms;
  final Duration fadeDuration;

  const CurrentMeetings({
    super.key,
    required this.showBusyRooms,
    required this.bookedRooms,
    required this.freeRooms,
    required this.fadeDuration,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final containerWidth = screenWidth * .56;

    // Determine cross axis count based on container width
    final crossAxisCount = containerWidth > 800 ? 4 : 2;

    // Separate the last room if there are 7 or more free rooms
    final gridFreeRooms = freeRooms.length >= 7
        ? freeRooms.sublist(0, 6)
        : freeRooms;
    final lastFreeRoom = freeRooms.length >= 7 ? freeRooms[6] : null;

    return SizedBox(
      width: containerWidth,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (showBusyRooms && bookedRooms.length > 1) ...[
            Container(
              width: double.infinity,
              alignment: Alignment.center,
              padding: EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.red,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Busy Rooms',
                style: TextStyle(
                  fontSize: 23,
                  color: AppColors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 15),
            AnimatedSwitcher(
              duration: fadeDuration,
              switchInCurve: Curves.easeIn,
              switchOutCurve: Curves.easeOut,
              child: GridView.builder(
                key: ValueKey('busy-$crossAxisCount-${bookedRooms.length}'),
                shrinkWrap: true,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                  childAspectRatio: 1.1,
                ),
                physics: const NeverScrollableScrollPhysics(),
                padding: EdgeInsets.zero,
                itemCount: bookedRooms.length,
                itemBuilder: (context, index) {
                  final room = bookedRooms[index];
                  return CompactRoomCard(room: room);
                },
              ),
            ),
            const SizedBox(height: 15),
          ],
          if (gridFreeRooms.isNotEmpty) ...[
            Container(
              width: double.infinity,
              alignment: Alignment.center,
              padding: EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.green,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Available Rooms',
                style: TextStyle(
                  fontSize: 23,
                  color: AppColors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 15),
            AnimatedSwitcher(
              duration: fadeDuration,
              child: GridView.builder(
                key: ValueKey('free-$crossAxisCount-${gridFreeRooms.length}'),
                shrinkWrap: true,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: bookedRooms.length == 1 ? 24 : 10,
                  childAspectRatio: bookedRooms.length == 1 ? 1.3 : 1.4,
                ),
                physics: const NeverScrollableScrollPhysics(),
                padding: EdgeInsets.zero,
                itemCount: bookedRooms.length > 1
                    ? (gridFreeRooms.length > 4 ? 4 : gridFreeRooms.length)
                    : gridFreeRooms.length,
                itemBuilder: (context, index) {
                  final room = gridFreeRooms[index];
                  return CompactRoomCard(room: room);
                },
              ),
            ),
            const SizedBox(height: 20),
          ],
          // Display the 7th room in upcoming-style format
          if (lastFreeRoom != null) ...[
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.green, width: 1),
                color: AppColors.green.withValues(alpha: .1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          lastFreeRoom.name ?? '',
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.green,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(
                              Icons.check_circle,
                              color: AppColors.green,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Available',
                              style: TextStyle(
                                fontSize: 16,
                                color: AppColors.green,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.green.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.meeting_room,
                              color: Colors.white,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              lastFreeRoom.location ?? '',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.people, color: Colors.white, size: 16),
                            const SizedBox(width: 4),
                            Text(
                              '${lastFreeRoom.capacity ?? 0}',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ],
      ),
    );
  }
}
