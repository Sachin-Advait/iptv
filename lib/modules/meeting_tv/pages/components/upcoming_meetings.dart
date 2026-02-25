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
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    // Portrait: single-column list (original behaviour)
    // Landscape: 2-column grid — all rooms visible at once
    final int crossAxisCount = isLandscape ? 2 : 1;

    // Show ALL rooms in landscape; cap portrait to avoid scroll
    final int upcomingMax = isLandscape
        ? (upcomingRoom.length - 1)
        : (busyRooms.length == 1 ? 3 : 7);

    final itemCount = upcomingRoom.length < upcomingMax
        ? upcomingRoom.length
        : upcomingMax;

    // Landscape: derive exact card height so all rows fill the column height.
    // Reserved = section header (~44) + top spacing (~10) + header/stat above
    final size = MediaQuery.of(context).size;
    final int rowCount = (itemCount / crossAxisCount).ceil();
    const double reservedLandscape = 190;
    const double cardGap = 8;
    final double cardHeight = isLandscape && rowCount > 0
        ? ((size.height - reservedLandscape - cardGap * (rowCount - 1)) /
                  rowCount)
              .clamp(50.0, 90.0)
        : 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Single busy room card (only when exactly 1 busy room) ─────────────
        if (busyRooms.isNotEmpty && busyRooms.length == 1) ...[
          _SectionHeader(label: 'Busy Rooms', color: AppColors.red),
          const SizedBox(height: 10),
          AnimatedSwitcher(
            duration: fadeDuration,
            switchInCurve: Curves.easeIn,
            switchOutCurve: Curves.easeOut,
            child: GridView.builder(
              shrinkWrap: true,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 1,
                childAspectRatio: isLandscape ? 2.8 : 1.78,
              ),
              physics: const NeverScrollableScrollPhysics(),
              padding: EdgeInsets.zero,
              itemCount: busyRooms.length,
              itemBuilder: (_, i) => CompactRoomCard(room: busyRooms[i]),
            ),
          ),
          const SizedBox(height: 10),
        ],

        // ── Upcoming header ──────────────────────────────────────────────────
        _SectionHeader(label: 'Upcoming', color: AppColors.blue),
        const SizedBox(height: 10),

        // ── Landscape: 2-col grid  |  Portrait: single-col list ──────────────
        AnimatedSwitcher(
          duration: fadeDuration,
          switchInCurve: Curves.easeIn,
          switchOutCurve: Curves.easeOut,
          child: isLandscape
              ? GridView.builder(
                  key: ValueKey('upcoming-ls-$itemCount'),
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: EdgeInsets.zero,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: cardGap,
                    mainAxisExtent: cardHeight,
                  ),
                  itemCount: itemCount,
                  itemBuilder: (_, i) {
                    final room = upcomingRoom[i];
                    if (room == null) return const SizedBox();
                    return UpcomingRoomCard(
                      room: room,
                      isBusy: busyRooms.length > 1,
                      fixedHeight: cardHeight,
                    );
                  },
                )
              : ListView.builder(
                  key: ValueKey('upcoming-pt-$itemCount'),
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: EdgeInsets.zero,
                  itemCount: itemCount,
                  itemBuilder: (_, i) {
                    final room = upcomingRoom[i];
                    if (room == null) return const SizedBox(height: 8);
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 15),
                      child: UpcomingRoomCard(
                        room: room,
                        isBusy: busyRooms.length > 1,
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

// =============================================================================
// Section header
// =============================================================================

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 23,
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
