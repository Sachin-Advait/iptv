import 'package:flutter/material.dart';
import 'package:oman_tv/configs/theme/app_colors.dart';
import 'package:oman_tv/models/tv_display_response.dart';
import 'package:oman_tv/modules/meeting_tv/pages/components/compact_room_card.dart';
import 'package:oman_tv/modules/meeting_tv/pages/components/upcoming_room_card.dart';

class UpcomingMeetings extends StatelessWidget {
  final List<Room?> upcomingRoom;
  final Duration fadeDuration;
  final List<Room> busyRooms;

  const UpcomingMeetings({
    super.key,
    required this.upcomingRoom,
    required this.fadeDuration,
    this.busyRooms = const [],
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return SizedBox(
      width: screenWidth,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (busyRooms.isNotEmpty && busyRooms.length == 1) ...[
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
                // key: ValueKey('busy-$crossAxisCount-${bookedRooms.length}'),
                shrinkWrap: true,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 1,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                  childAspectRatio: 1.78,
                ),
                physics: const NeverScrollableScrollPhysics(),
                padding: EdgeInsets.zero,
                itemCount: busyRooms.length,
                itemBuilder: (context, index) {
                  final room = busyRooms[index];
                  return CompactRoomCard(room: room);
                },
              ),
            ),
            const SizedBox(height: 15),
          ],

          // Upcoming Section
          Container(
            width: double.infinity,
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.blue,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              'Upcoming',
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
            child: ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: EdgeInsets.zero,
              itemCount: busyRooms.length == 1 && busyRooms.isNotEmpty ? 3 : 6,
              itemBuilder: (context, index) {
                final room = upcomingRoom[index];
                if (room == null) return const SizedBox(height: 12);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: UpcomingRoomCard(
                    room: room,
                    isBusy: busyRooms.length > 1,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
