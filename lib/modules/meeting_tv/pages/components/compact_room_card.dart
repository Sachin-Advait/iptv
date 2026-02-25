import 'package:flutter/material.dart';
import 'package:oman_tv/configs/theme/app_colors.dart';
import 'package:oman_tv/models/tv_display_response.dart';

class CompactRoomCard extends StatelessWidget {
  final Room room;

  const CompactRoomCard({super.key, required this.room});

  String getRemaining(Meeting meeting) {
    if (meeting.remainingMinutes > 1) {
      return '${meeting.remainingMinutes}';
    }
    return '${meeting.remainingSeconds}';
  }

  @override
  Widget build(BuildContext context) {
    final booked = room.booked ?? false;
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    // Scale everything relative to screen height so cards fill nicely
    final screenH = MediaQuery.of(context).size.height;
    // portrait baseline 1366, landscape baseline 834 (iPad Pro 11")
    final scale = isLandscape ? (screenH / 834).clamp(0.7, 1.4) : 1.0;

    final double nameFontSize = 16 * scale;
    final double infoFontSize = 13 * scale;
    final double capacityFontSize = 16 * scale;
    final double organizerFontSize = 12 * scale;
    final double timeFontSize = 14 * scale;
    final double remainingFontSize = 15 * scale;
    final double iconSize = isLandscape ? 15 * scale : 18.0;
    final double pad = isLandscape ? 10 * scale : 14.0;
    final double innerGap = isLandscape ? 24 * scale : 12.0;
    final double availFontSize = 12 * scale;

    return Container(
      padding: EdgeInsets.all(pad),
      decoration: BoxDecoration(
        color: AppColors.green.withValues(alpha: .1),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: booked
              ? AppColors.red.withValues(alpha: 0.5)
              : AppColors.green.withValues(alpha: 0.45),
          width: 1.8,
        ),
        boxShadow: [
          BoxShadow(
            color: (booked ? AppColors.red : AppColors.green).withValues(
              alpha: 0.06,
            ),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // ── Room name ──────────────────────────────────────────────────────
          Center(
            child: Text(
              room.name!,
              style: TextStyle(
                fontSize: nameFontSize,
                fontWeight: FontWeight.w600,
                color: booked ? AppColors.red : AppColors.green,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
              textAlign: TextAlign.center,
            ),
          ),

          SizedBox(
            height: booked && room.currentMeeting != null
                ? innerGap * 0.6
                : innerGap,
          ),

          // ── Location + capacity row ────────────────────────────────────────
          Row(
            children: [
              const SizedBox(width: 10),
              Icon(Icons.meeting_room, size: iconSize, color: AppColors.white),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  room.location!.split(',').first,
                  style: TextStyle(
                    fontSize: infoFontSize,
                    color: AppColors.white,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const Spacer(),
              Icon(Icons.people, size: iconSize + 2, color: AppColors.white),
              const SizedBox(width: 4),
              Text(
                '${room.currentMeeting?.attendees ?? room.capacity}',
                style: TextStyle(
                  fontSize: capacityFontSize,
                  color: AppColors.white,
                ),
              ),
              const SizedBox(width: 10),
            ],
          ),

          const Spacer(),

          // ── Booked state ───────────────────────────────────────────────────
          if (booked && room.currentMeeting != null) ...[
            Text(
              room.currentMeeting!.organizer,
              style: TextStyle(
                fontSize: organizerFontSize,
                fontWeight: FontWeight.w700,
                color: AppColors.white,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: innerGap * 0.5),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: 6 * scale,
                vertical: 3 * scale,
              ),
              decoration: BoxDecoration(
                color: AppColors.red,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${room.currentMeeting!.startTimeFormatted} - ${room.currentMeeting!.endTimeFormatted}',
                    style: TextStyle(
                      fontSize: timeFontSize,
                      fontWeight: FontWeight.w500,
                      color: AppColors.white,
                    ),
                  ),
                  SizedBox(width: 3 * scale),
                  Icon(Icons.schedule, size: iconSize, color: AppColors.white),
                  SizedBox(width: 3 * scale),
                  Text(
                    getRemaining(room.currentMeeting!),
                    style: TextStyle(
                      fontSize: remainingFontSize,
                      fontWeight: FontWeight.w700,
                      color: AppColors.white,
                    ),
                  ),
                  SizedBox(width: 2 * scale),
                  if (room.currentMeeting!.remainingMinutes > 1)
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Min',
                          style: TextStyle(
                            fontSize: 7 * scale,
                            color: AppColors.white,
                          ),
                        ),
                        Text(
                          'Left',
                          style: TextStyle(
                            fontSize: 7 * scale,
                            color: AppColors.white,
                          ),
                        ),
                      ],
                    )
                  else
                    Text(
                      'sec',
                      style: TextStyle(
                        fontSize: 7 * scale,
                        color: AppColors.white,
                      ),
                    ),
                ],
              ),
            ),
            SizedBox(height: 4 * scale),

            // ── Available state ────────────────────────────────────────────────
          ] else ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.check_circle,
                  color: AppColors.green,
                  size: iconSize,
                ),
                const SizedBox(width: 6),
                Text(
                  'Available',
                  style: TextStyle(
                    fontSize: availFontSize,
                    fontWeight: FontWeight.w700,
                    color: AppColors.green,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
