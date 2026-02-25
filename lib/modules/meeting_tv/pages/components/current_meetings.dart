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
    final size = MediaQuery.of(context).size;
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    final containerWidth = isLandscape ? size.width * 0.55 : size.width * 0.56;

    // Landscape → 3 columns, Portrait → 2 columns
    final int crossAxisCount = isLandscape ? 2 : 2;

    // First 6 rooms in grid, 7th+ as compact rows
    const int gridMax = 6;
    final gridFreeRooms = freeRooms.length > gridMax
        ? freeRooms.sublist(0, gridMax)
        : freeRooms;
    final extraFreeRooms = freeRooms.length > gridMax
        ? freeRooms.sublist(gridMax)
        : <Room>[];

    final int freeGridCount = bookedRooms.length > 1
        ? (gridFreeRooms.length > 4 ? 4 : gridFreeRooms.length)
        : gridFreeRooms.length;

    // ── Card height derived from available screen height ───────────────────
    // Available height = screen height minus:
    //   header (~110) + stat row (~60) + section header (~44) + spacings
    // In landscape we have 2 rows of 3 cards; in portrait 3 rows of 2 cards.
    final double reservedVertical = isLandscape ? 220 : 260;
    final double gridSpacing = 12;
    final int rowCount = (freeGridCount / crossAxisCount).ceil();
    final double totalSpacing = gridSpacing * (rowCount - 1) + reservedVertical;
    final double cardHeight = ((size.height - totalSpacing) / rowCount).clamp(
      isLandscape ? 120.0 : 150.0,
      isLandscape ? 155.0 : 380.0,
    );

    // Portrait keeps aspect ratio approach (proven to work)
    final double portraitFreeAspect = bookedRooms.length == 1 ? 1.3 : 1.4;
    final double freeSpacing = bookedRooms.length == 1 ? 16 : 10;

    return SizedBox(
      width: containerWidth,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // ── Busy rooms ────────────────────────────────────────────────────
          if (showBusyRooms && bookedRooms.length > 1) ...[
            _SectionHeader(label: 'Busy Rooms', color: AppColors.red),
            const SizedBox(height: 12),
            AnimatedSwitcher(
              duration: fadeDuration,
              switchInCurve: Curves.easeIn,
              switchOutCurve: Curves.easeOut,
              child: GridView.builder(
                key: ValueKey('busy-${bookedRooms.length}'),
                shrinkWrap: true,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: isLandscape ? 1.15 : 1.1,
                ),
                physics: const NeverScrollableScrollPhysics(),
                padding: EdgeInsets.zero,
                itemCount: bookedRooms.length,
                itemBuilder: (_, i) => CompactRoomCard(room: bookedRooms[i]),
              ),
            ),
            const SizedBox(height: 12),
          ],

          // ── Available rooms grid ───────────────────────────────────────────
          if (gridFreeRooms.isNotEmpty) ...[
            _SectionHeader(label: 'Available Rooms', color: AppColors.green),
            const SizedBox(height: 12),
            AnimatedSwitcher(
              duration: fadeDuration,
              child: isLandscape
                  // Landscape: fixed card height so 2 rows fill the screen
                  ? GridView.builder(
                      key: ValueKey('free-ls-$freeGridCount'),
                      shrinkWrap: true,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        mainAxisExtent: cardHeight,
                      ),
                      physics: const NeverScrollableScrollPhysics(),
                      padding: EdgeInsets.zero,
                      itemCount: freeGridCount,
                      itemBuilder: (_, i) =>
                          CompactRoomCard(room: gridFreeRooms[i]),
                    )
                  // Portrait: aspect ratio as before
                  : GridView.builder(
                      key: ValueKey('free-pt-$freeGridCount'),
                      shrinkWrap: true,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        crossAxisSpacing: 14,
                        mainAxisSpacing: freeSpacing,
                        childAspectRatio: portraitFreeAspect,
                      ),
                      physics: const NeverScrollableScrollPhysics(),
                      padding: EdgeInsets.zero,
                      itemCount: freeGridCount,
                      itemBuilder: (_, i) =>
                          CompactRoomCard(room: gridFreeRooms[i]),
                    ),
            ),
            const SizedBox(height: 12),
          ],

          // ── Extra rooms (7th+) as compact rows ────────────────────────────
          for (final room in extraFreeRooms) ...[
            _CompactFreeRow(room: room),
            const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }
}

// =============================================================================
// Helpers
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
          color: AppColors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

/// Compact single-row card for overflow rooms (7th+)
class _CompactFreeRow extends StatelessWidget {
  const _CompactFreeRow({required this.room});

  final Room room;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.green, width: 1),
        color: AppColors.green.withValues(alpha: .1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          // Name + available badge
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  room.name ?? '',
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.green,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Icons.check_circle,
                      color: AppColors.green,
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      'Available',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.green,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Floor + capacity chip
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.green.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.meeting_room,
                      color: Colors.white,
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      room.location ?? '',
                      style: const TextStyle(fontSize: 12, color: Colors.white),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.people, color: Colors.white, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      '${room.capacity ?? 0}',
                      style: const TextStyle(fontSize: 12, color: Colors.white),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
