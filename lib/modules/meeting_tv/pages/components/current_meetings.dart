import 'package:flutter/material.dart';
import 'package:oman_tv/configs/theme/app_colors.dart';
import 'package:oman_tv/models/tv_display_response.dart';
import 'package:oman_tv/modules/meeting_tv/pages/components/compact_room_card.dart';

class CurrentMeetings extends StatelessWidget {
  final bool showBusyRooms;
  final List<Room> bookedRooms;
  final List<Room> freeRooms;
  final Duration fadeDuration;

  /// In landscape mode, when there is exactly 1 busy room we inject it here
  /// (above Available Rooms) instead of in the right column (UpcomingMeetings).
  /// Pass `true` to render the busy room inside this widget.
  final bool injectBusyInLeft;

  const CurrentMeetings({
    super.key,
    required this.showBusyRooms,
    required this.bookedRooms,
    required this.freeRooms,
    required this.fadeDuration,
    this.injectBusyInLeft = false,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    final containerWidth = isLandscape ? size.width * 0.55 : size.width * 0.56;

    final bool hasSingleBusy = bookedRooms.length == 1;

    // Landscape + 1 busy room → 3 columns (busy card sits above in left col)
    // Everything else          → 2 columns
    final int crossAxisCount = (isLandscape && hasSingleBusy) ? 3 : 2;

    const int gridMax = 6;
    double lsHeight = 0;
    final gridFreeRooms = freeRooms.length > gridMax
        ? freeRooms.sublist(0, gridMax)
        : freeRooms;
    final extraFreeRooms = freeRooms.length > gridMax
        ? freeRooms.sublist(gridMax)
        : <Room>[];

    final int freeGridCount = bookedRooms.length > 1
        ? (gridFreeRooms.length > 4 ? 4 : gridFreeRooms.length)
        : gridFreeRooms.length;

    // ── Card height ──────────────────────────────────────────────────────────
    final double reservedVertical = isLandscape ? 220 : 260;
    final double gridSpacing = 12;
    final int rowCount = (freeGridCount / crossAxisCount).ceil();
    final double totalSpacing = gridSpacing * (rowCount - 1) + reservedVertical;
    final double cardHeight = ((size.height - totalSpacing) / rowCount).clamp(
      isLandscape ? 120.0 : 150.0,
      // 1 busy room in landscape → 3-col needs slightly taller cards (156)
      // normal landscape (no busy / multi-busy) → 2-col cap stays at 146
      isLandscape ? (hasSingleBusy ? 156.0 : 146.0) : 380.0,
    );

    final double portraitFreeAspect = hasSingleBusy ? 1.3 : 1.4;
    final double freeSpacing = hasSingleBusy ? 12 : 10;

    lsHeight = hasSingleBusy ? 150 : 130;

    // Whether to show busy section inside this widget
    // Portrait: always show if showBusyRooms && > 1 busy room (original)
    // Landscape: show if injectBusyInLeft is true (1 busy room case)
    final bool showBusyHere = isLandscape
        ? injectBusyInLeft && bookedRooms.isNotEmpty
        : showBusyRooms && bookedRooms.length > 1;

    return SizedBox(
      width: containerWidth,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // ── Busy rooms (portrait >1, or landscape injected) ────────────────
          if (showBusyHere) ...[
            _SectionHeader(label: 'Busy Rooms', color: AppColors.red),
            const SizedBox(height: 12),
            AnimatedSwitcher(
              duration: fadeDuration,
              switchInCurve: Curves.easeIn,
              switchOutCurve: Curves.easeOut,
              child: _BusyRoomsGrid(
                key: ValueKey('busy-${bookedRooms.length}'),
                rooms: bookedRooms,
                isLandscape: isLandscape,
                lsHeight: lsHeight,
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
// Busy rooms grid — odd/single cards span full width
// =============================================================================

/// Renders busy room cards in pairs (2 columns). When the count is odd the
/// last card stretches to full width. A single busy room always fills the row.
class _BusyRoomsGrid extends StatelessWidget {
  const _BusyRoomsGrid({
    super.key,
    required this.rooms,
    required this.isLandscape,
    required this.lsHeight,
  });

  final List<Room> rooms;
  final bool isLandscape;
  final double lsHeight;

  @override
  Widget build(BuildContext context) {
    const double spacing = 12;
    // Fixed card height in landscape; aspect-ratio-driven in portrait.
    const double ptAspect = 1.1;

    final List<Widget> rows = [];

    for (int i = 0; i < rooms.length; i += 2) {
      final bool isLastOdd = i + 1 >= rooms.length; // no pair partner

      if (isLastOdd) {
        // ── Full-width single card ──────────────────────────────────────────
        rows.add(
          SizedBox(
            height: isLandscape
                ? lsHeight
                : MediaQuery.of(context).size.width * 0.56 / ptAspect,
            child: CompactRoomCard(room: rooms[i]),
          ),
        );
      } else {
        // ── Side-by-side pair ───────────────────────────────────────────────
        final double pairHeight = isLandscape
            ? lsHeight
            : (MediaQuery.of(context).size.width * 0.56 - spacing) /
                  2 /
                  ptAspect;

        rows.add(
          SizedBox(
            height: pairHeight,
            child: Row(
              children: [
                Expanded(child: CompactRoomCard(room: rooms[i])),
                const SizedBox(width: spacing),
                Expanded(child: CompactRoomCard(room: rooms[i + 1])),
              ],
            ),
          ),
        );
      }

      if (i + 2 < rooms.length) rows.add(const SizedBox(height: spacing));
    }

    return Column(mainAxisSize: MainAxisSize.min, children: rows);
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
