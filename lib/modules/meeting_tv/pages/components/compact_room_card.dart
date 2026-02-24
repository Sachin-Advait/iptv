import 'package:flutter/material.dart';
import 'package:oman_tv/configs/theme/app_colors.dart';
import 'package:oman_tv/models/tv_display_response.dart';

class CompactRoomCard extends StatelessWidget {
  final Room room;

  const CompactRoomCard({super.key, required this.room});

  String getRemaining(Meeting meeting) {
    if (meeting.remainingMinutes > 1) {
      return '${meeting.remainingMinutes} min';
    }

    // Less than one minute → show seconds
    return '${meeting.remainingSeconds} sec';
  }

  @override
  Widget build(BuildContext context) {
    final booked = room.booked ?? false;
    return Container(
      padding: const EdgeInsets.all(14),
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
          Center(
            child: Text(
              room.name!,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: booked ? AppColors.red : AppColors.green,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
              textAlign: TextAlign.center,
            ),
          ),

          booked && room.currentMeeting != null
              ? const SizedBox(height: 12)
              : const SizedBox(height: 22),
          Row(
            children: [
              const Icon(Icons.meeting_room, size: 18, color: AppColors.white),
              const SizedBox(width: 6),
              Text(
                room.location!.split(',').first,
                style: const TextStyle(fontSize: 15, color: AppColors.white),
              ),
              Spacer(),
              const Icon(Icons.people, size: 20, color: AppColors.white),
              const SizedBox(width: 6),
              Text(
                '${room.currentMeeting?.attendees ?? room.capacity}',
                style: const TextStyle(fontSize: 18, color: AppColors.white),
              ),
            ],
          ),

          const Spacer(),
          if (booked && room.currentMeeting != null) ...[
            Text(
              room.currentMeeting!.organizer,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.white,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
                      fontSize: 17,
                      fontWeight: FontWeight.w500,
                      color: AppColors.white,
                    ),
                  ),
                  const SizedBox(width: 3),
                  const Icon(Icons.schedule, size: 18, color: AppColors.white),
                  const SizedBox(width: 3),
                  Text(
                    getRemaining(room.currentMeeting!),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.white,
                    ),
                  ),
                  SizedBox(width: 3),
                  if (room.currentMeeting!.remainingMinutes > 1)
                    Column(
                      children: [
                        RichText(
                          text: TextSpan(
                            text: 'Min',
                            style: TextStyle(
                              fontSize: 8,
                              color: AppColors.white,
                            ),
                          ),
                        ),
                        RichText(
                          text: TextSpan(
                            text: 'Left',
                            style: TextStyle(
                              fontSize: 8,
                              color: AppColors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
            SizedBox(height: 5),
          ] else ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
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
                    fontSize: 13,
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
