import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:oman_tv/configs/theme/app_colors.dart';
import 'package:oman_tv/models/tv_display_response.dart';

class UpcomingRoomCard extends StatelessWidget {
  final Room room;
  final bool isBusy;

  const UpcomingRoomCard({super.key, required this.room, required this.isBusy});

  @override
  Widget build(BuildContext context) {
    final booked = room.booked! && room.currentMeeting != null;
    final start = booked ? room.currentMeeting!.startTime : null;
    final end = booked ? room.currentMeeting!.endTime : null;
    final localStart = start?.toLocal();
    final localEnd = end?.toLocal();

    // Format date (e.g., "2 Dec 25")
    final dateStr = localStart != null
        ? '${localStart.day} ${DateFormat('MMM').format(localStart)} ${localStart.year.toString().substring(2)}'
        : '';

    // Format time range (e.g., "11:00 - 12:30")
    String formatTime(DateTime dateTime) {
      return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    }

    return Container(
      height: isBusy
          ? MediaQuery.of(context).size.height * .082
          : MediaQuery.of(context).size.height * .06,
      margin: EdgeInsets.only(bottom: isBusy ? 10 : 5),
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
          // Main content
          Padding(
            padding: booked
                ? const EdgeInsets.fromLTRB(10, 5, 5, 5)
                : const EdgeInsets.fromLTRB(10, 10, 5, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Room name and date
                Row(
                  children: [
                    Text(
                      room.name!,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Spacer(),
                    if (booked && dateStr.isNotEmpty) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.blue.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          dateStr,
                          style: const TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 5),
                // Status row
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
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Column(
                              children: [
                                Text(
                                  formatTime(localStart!),
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.white,
                                  ),
                                ),
                                Text(
                                  formatTime(localEnd!),
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.white,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        room.currentMeeting!.organizer,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(width: 12),
                    ],
                  ),
                ] else ...[
                  Text(
                    'Available',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF4CAF50),
                    ),
                  ),
                ],
              ],
            ),
          ),
          // Right side curved section with floor and capacity
          Positioned(
            right: 0,
            top: 0,
            child: ClipPath(
              clipBehavior: Clip.antiAlias,
              clipper: CurvedCardClipper(),
              child: Container(
                height: 450,
                width: 120,
                decoration: BoxDecoration(
                  color: booked ? AppColors.blue : AppColors.green,
                ),
              ),
            ),
          ),
          Positioned(
            right: 0,
            bottom: 0,
            child: Padding(
              padding: const EdgeInsets.only(right: 5),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Floor info
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.business, size: 16, color: AppColors.white),
                      const SizedBox(width: 4),
                      Text(
                        'Floor ${room.location?.split('st').first.split('nd').first ?? 1}',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: AppColors.white,
                        ),
                      ),
                    ],
                  ),
                  // Capacity info
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.people, size: 16, color: AppColors.white),
                      const SizedBox(width: 4),
                      Text(
                        '${room.capacity ?? 0}',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: AppColors.white,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
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

    // --- Start top-left (flipped vertically) ---
    path.moveTo(20, h);

    // Top-left inward curve (formerly bottom)
    path.quadraticBezierTo(0, h, 0, h - 10);

    // Left vertical
    path.lineTo(0, h * 0.4);

    // Big TOP curve (flipped from bottom)
    path.quadraticBezierTo(
      w * 0.1, // control X stays same
      10,
      w,
      h * 0.08,
    );

    // Top-right rounded
    path.lineTo(100, h - 20);
    path.quadraticBezierTo(0, h, 0, h);

    path.close();
    return path;
  }

  @override
  bool shouldReclip(oldClipper) => false;
}
