import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:oman_tv/configs/theme/app_colors.dart';
import 'package:oman_tv/models/tv_display_response.dart';

class UpcomingRoomCard extends StatelessWidget {
  final Room room;
  final bool isBusy;

  /// When provided (landscape grid), the card fills this exact height and
  /// scales its content accordingly. When null (portrait list), the card
  /// sizes itself from MediaQuery as before.
  final double? fixedHeight;

  const UpcomingRoomCard({
    super.key,
    required this.room,
    required this.isBusy,
    this.fixedHeight,
  });

  @override
  Widget build(BuildContext context) {
    final booked = room.booked! && room.currentMeeting != null;
    final start = booked ? room.currentMeeting!.startTime : null;
    final end = booked ? room.currentMeeting!.endTime : null;
    final localStart = start?.toLocal();
    final localEnd = end?.toLocal();

    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    final dateStr = localStart != null
        ? '${localStart.day} ${DateFormat('MMM').format(localStart)} ${localStart.year.toString().substring(2)}'
        : '';

    String formatTime(DateTime dt) =>
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';

    // ── Height ──────────────────────────────────────────────────────────────
    final double cardHeight;
    if (fixedHeight != null && fixedHeight! > 0) {
      cardHeight = fixedHeight!;
    } else if (isLandscape) {
      cardHeight = isBusy
          ? MediaQuery.of(context).size.height * 0.10
          : MediaQuery.of(context).size.height * 0.075;
    } else {
      cardHeight = isBusy
          ? MediaQuery.of(context).size.height * 0.082
          : MediaQuery.of(context).size.height * 0.06;
    }

    // Scale font/icon sizes to the card height so content never overflows
    final double scale = (cardHeight / 20).clamp(0.7, 1.4);
    final double nameFz = 12 * scale;
    final double subFz = 10 * scale;
    final double iconSz = 13 * scale;
    final double timeFz = 10 * scale;
    final double badgeFz = 8 * scale;

    return Container(
      height: cardHeight,
      decoration: BoxDecoration(
        color: booked
            ? AppColors.blue.withValues(alpha: .1)
            : AppColors.green.withValues(alpha: .1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: booked ? AppColors.blue : AppColors.green,
          width: 1,
        ),
      ),
      child: Stack(
        children: [
          // ── Main content ─────────────────────────────────────────────────
          Padding(
            padding: EdgeInsets.fromLTRB(
              10,
              booked ? 4 : 8,
              108,
              booked ? 4 : 8,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Room name + date badge
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        room.name!,
                        style: TextStyle(
                          fontSize: nameFz,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: 0.4,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (booked && dateStr.isNotEmpty) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 5,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.blue.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          dateStr,
                          style: TextStyle(
                            fontSize: badgeFz,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                SizedBox(height: 3 * scale),
                // Status / time
                if (booked) ...[
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 3,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.blue,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              formatTime(localStart!),
                              style: TextStyle(
                                fontSize: timeFz,
                                fontWeight: FontWeight.w700,
                                color: AppColors.white,
                              ),
                            ),
                            Text(
                              formatTime(localEnd!),
                              style: TextStyle(
                                fontSize: timeFz,
                                fontWeight: FontWeight.w700,
                                color: AppColors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          room.currentMeeting!.organizer,
                          style: TextStyle(
                            fontSize: subFz,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ] else ...[
                  Text(
                    'Available',
                    style: TextStyle(
                      fontSize: subFz,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF4CAF50),
                    ),
                  ),
                ],
              ],
            ),
          ),

          // ── Right curved section ─────────────────────────────────────────
          Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            child: ClipPath(
              clipBehavior: Clip.antiAlias,
              clipper: CurvedCardClipper(),
              child: Container(
                width: 100,
                color: booked ? AppColors.blue : AppColors.green,
              ),
            ),
          ),
          Positioned(
            right: 5,
            top: 0,
            bottom: 0,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.business, size: iconSz, color: AppColors.white),
                    const SizedBox(width: 3),
                    Text(
                      'Floor ${room.location?.split('st').first.split('nd').first ?? 1}',
                      style: TextStyle(
                        fontSize: subFz - 1,
                        fontWeight: FontWeight.w600,
                        color: AppColors.white,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 2 * scale),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.people, size: iconSz, color: AppColors.white),
                    const SizedBox(width: 3),
                    Text(
                      '${room.capacity ?? 0}',
                      style: TextStyle(
                        fontSize: subFz - 1,
                        fontWeight: FontWeight.w500,
                        color: AppColors.white,
                      ),
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

class CurvedCardClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final w = size.width;
    final h = size.height;
    final path = Path();
    path.moveTo(20, h);
    path.quadraticBezierTo(0, h, 0, h - 10);
    path.lineTo(0, h * 0.4);
    path.quadraticBezierTo(w * 0.1, 10, w, h * 0.08);
    path.lineTo(100, h - 20);
    path.quadraticBezierTo(0, h, 0, h);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(oldClipper) => false;
}
