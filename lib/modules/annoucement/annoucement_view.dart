import 'package:flutter/material.dart';
import 'package:oman_tv/common/utils/app_screen_util.dart';
import 'package:oman_tv/configs/theme/app_colors.dart';
import 'package:oman_tv/configs/theme/app_theme.dart';

class AnnouncementView extends StatelessWidget {
  const AnnouncementView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: 20.widthMultiplier,
          vertical: 10.widthMultiplier,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Meeting Rooms Section
            Expanded(child: _buildMeetingRoomsSection(context)),
            20.horizontalSpace,
            // Now Serving Section
            Expanded(child: _buildNowServingSection(context)),
            20.horizontalSpace,
            // Announcements Section
            Expanded(child: _buildAnnouncementsSection(context)),
          ],
        ),
      ),
    );
  }

  Widget _buildMeetingRoomsSection(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(24.widthMultiplier),
      decoration: BoxDecoration(
        color: AppColors.lightBeige.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(20.radiusMultipier),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Meeting Rooms',
            style: context.bold.copyWith(
              fontSize: 24.textMultiplier,
              color: const Color(0xFF6B5D4F),
            ),
          ),
          15.verticalSpace,
          _buildMeetingRoomCard(
            context,
            roomName: 'Conference A',
            status: 'FREE',
            statusColor: const Color(0xFF4CAF50),
            isFree: true,
          ),
          10.verticalSpace,
          _buildMeetingRoomCard(
            context,
            roomName: 'Conference B',
            status: 'OCCUPIED',
            statusColor: const Color(0xFFFFA726),
            isFree: false,
            time: '10:00 - 11:30',
            meeting: 'HR Monthly Review',
          ),
          10.verticalSpace,
          _buildMeetingRoomCard(
            context,
            roomName: 'Conference C',
            status: 'FREE',
            statusColor: const Color(0xFF4CAF50),
            isFree: true,
          ),
        ],
      ),
    );
  }

  Widget _buildMeetingRoomCard(
    BuildContext context, {
    required String roomName,
    required String status,
    required Color statusColor,
    required bool isFree,
    String? time,
    String? meeting,
  }) {
    return Container(
      padding: EdgeInsets.all(16.widthMultiplier),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16.radiusMultipier),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                roomName,
                style: context.semiBold.copyWith(
                  fontSize: 16.textMultiplier,
                  color: AppColors.black,
                ),
              ),
              Text(
                status,
                style: context.bold.copyWith(
                  fontSize: 15.textMultiplier,
                  color: statusColor,
                ),
              ),
            ],
          ),
          if (!isFree) ...[
            12.verticalSpace,
            Text(
              time ?? '',
              style: context.regular.copyWith(
                fontSize: 13.textMultiplier,
                color: Colors.grey[600],
              ),
            ),
            4.verticalSpace,
            Text(
              meeting ?? '',
              style: context.regular.copyWith(
                fontSize: 13.textMultiplier,
                color: Colors.grey[600],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildNowServingSection(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        24.widthMultiplier,
        24.widthMultiplier,
        24.widthMultiplier,
        0,
      ),
      decoration: BoxDecoration(
        color: AppColors.lightBeige.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(20.radiusMultipier),
      ),
      child: ListView(
        children: [
          Text(
            'Now Serving',
            style: context.bold.copyWith(
              fontSize: 24.textMultiplier,
              color: const Color(0xFF6B5D4F),
            ),
          ),
          15.verticalSpace,
          _buildCounterCard(
            context,
            counterName: 'Counter 1',
            tokenNumber: 'A-042',
            isVIP: false,
          ),
          10.verticalSpace,
          _buildCounterCard(
            context,
            counterName: 'Counter 2',
            tokenNumber: 'B-017',
            isVIP: false,
          ),
          10.verticalSpace,
          _buildCounterCard(
            context,
            counterName: 'Counter 3',
            tokenNumber: 'VIP-003',
            isVIP: true,
          ),
          10.verticalSpace,
          Text(
            'Waiting In Queue',
            style: context.bold.copyWith(
              fontSize: 20.textMultiplier,
              color: const Color(0xFF6B5D4F),
            ),
          ),
          10.verticalSpace,
          Row(
            children: [
              Expanded(
                child: _buildQueueCard(
                  context,
                  category: 'A',
                  count: '12',
                  isVIP: false,
                ),
              ),
              12.horizontalSpace,
              Expanded(
                child: _buildQueueCard(
                  context,
                  category: 'B',
                  count: '07',
                  isVIP: false,
                ),
              ),
              12.horizontalSpace,
              Expanded(
                child: _buildQueueCard(
                  context,
                  category: 'VIP',
                  count: '01',
                  isVIP: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCounterCard(
    BuildContext context, {
    required String counterName,
    required String tokenNumber,
    required bool isVIP,
  }) {
    return Container(
      padding: EdgeInsets.all(16.widthMultiplier),
      decoration: BoxDecoration(
        gradient: isVIP
            ? const LinearGradient(
                colors: [
                  Color(0xFFF4E4A6),
                  Color(0xFFF4F1E5),
                  Color(0xFFD4AF37),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        color: isVIP ? null : AppColors.white,
        borderRadius: BorderRadius.circular(16.radiusMultipier),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            counterName,
            style: context.semiBold.copyWith(
              fontSize: 16.textMultiplier,
              color: isVIP ? const Color(0xFF6B5D4F) : AppColors.black,
            ),
          ),
          Text(
            tokenNumber,
            style: context.bold.copyWith(
              fontSize: 18.textMultiplier,
              color: isVIP ? const Color(0xFF6B5D4F) : const Color(0xFF6B5D4F),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQueueCard(
    BuildContext context, {
    required String category,
    required String count,
    required bool isVIP,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: 4.heightMultiplier,
        horizontal: 12.widthMultiplier,
      ),
      decoration: BoxDecoration(
        gradient: isVIP
            ? const LinearGradient(
                colors: [
                  Color(0xFFD4AF37),
                  Color(0xFFF4F1E5),
                  Color(0xFFF4E4A6),
                ],
                begin: Alignment.centerRight,
                end: Alignment.centerLeft,
              )
            : null,
        color: isVIP ? null : AppColors.white,
        borderRadius: BorderRadius.circular(16.radiusMultipier),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            category,
            style: context.bold.copyWith(
              fontSize: 20.textMultiplier,
              color: isVIP ? const Color(0xFF6B5D4F) : AppColors.black,
            ),
          ),
          4.verticalSpace,
          Text(
            count,
            style: context.bold.copyWith(
              fontSize: 22.textMultiplier,
              color: isVIP ? const Color(0xFF6B5D4F) : AppColors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnnouncementsSection(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(24.widthMultiplier),
      decoration: BoxDecoration(
        color: AppColors.lightBeige.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(20.radiusMultipier),
      ),
      child: ListView(
        children: [
          Text(
            'Announcements',
            style: context.bold.copyWith(
              fontSize: 24.textMultiplier,
              color: const Color(0xFF6B5D4F),
            ),
          ),
          15.verticalSpace,
          _buildAnnouncementCard(
            context,
            title: 'Ramadan Working Hours',
            subtitle: '09:00 AM - 02:00PM',
          ),
          10.verticalSpace,
          _buildAnnouncementCard(
            context,
            title: 'Public Holiday',
            subtitle: 'Thursday, 21 March',
          ),
          10.verticalSpace,
          _buildAnnouncementCard(
            context,
            title: 'System Maintenance',
            subtitle: 'Friday, 6:00 PM',
          ),
        ],
      ),
    );
  }

  Widget _buildAnnouncementCard(
    BuildContext context, {
    required String title,
    required String subtitle,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.widthMultiplier),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16.radiusMultipier),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: context.semiBold.copyWith(
              fontSize: 16.textMultiplier,
              color: AppColors.black,
            ),
          ),
          2.verticalSpace,
          Text(
            subtitle,
            style: context.regular.copyWith(
              fontSize: 14.textMultiplier,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}
