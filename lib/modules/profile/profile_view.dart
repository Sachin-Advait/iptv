import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:oman_tv/common/utils/app_screen_util.dart';
import 'package:oman_tv/common/utils/focus_traversal.dart';
import 'package:oman_tv/configs/theme/app_colors.dart';
import 'package:oman_tv/configs/theme/app_theme.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  // User data
  String userName = 'Ahmed Ali';
  String userEmail = 'ahmed.ali@example.com';
  String phoneNumber = '+968 9123 4567';
  Color selectedAvatarColor = const Color(0xFF2FA4A9);

  final List<SettingsItem> settingsItems = [
    SettingsItem(
      icon: Icons.person_outline,
      title: 'Edit Profile',
      subtitle: 'Update your name and avatar',
    ),
    SettingsItem(
      icon: Icons.email_outlined,
      title: 'Email',
      subtitle: 'ahmed.ali@example.com',
    ),
    SettingsItem(
      icon: Icons.phone_outlined,
      title: 'Phone Number',
      subtitle: '+968 9123 4567',
    ),
    SettingsItem(
      icon: Icons.lock_outline,
      title: 'Change Password',
      subtitle: 'Update your password',
    ),
    SettingsItem(
      icon: Icons.notifications_outlined,
      title: 'Notifications',
      subtitle: 'Manage notification preferences',
    ),
    SettingsItem(
      icon: Icons.language_outlined,
      title: 'Language',
      subtitle: 'English',
    ),
    SettingsItem(
      icon: Icons.security_outlined,
      title: 'Privacy & Security',
      subtitle: 'Control your privacy settings',
    ),
    SettingsItem(
      icon: Icons.subscriptions_outlined,
      title: 'Subscription',
      subtitle: 'Premium Plan - Active',
    ),
    SettingsItem(
      icon: Icons.help_outline,
      title: 'Help & Support',
      subtitle: 'Get help and contact us',
    ),
    SettingsItem(
      icon: Icons.info_outline,
      title: 'About',
      subtitle: 'Version 2.1.0',
    ),
    SettingsItem(
      icon: Icons.logout,
      title: 'Sign Out',
      subtitle: 'Sign out from your account',
      isDestructive: true,
    ),
  ];

  void _onSettingTap(SettingsItem item) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${item.title} tapped'),
        backgroundColor: AppColors.primary,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Container(
            width: 400.widthMultiplier,
            decoration: BoxDecoration(
              color: AppColors.lightBeige.withValues(alpha: .4),
              border: Border(
                right: BorderSide(
                  color: AppColors.black.withValues(alpha: 0.1),
                  width: 1,
                ),
              ),
            ),
            child: Column(
              children: [
                Container(
                  width: 140.widthMultiplier,
                  height: 140.heightMultiplier,
                  decoration: BoxDecoration(
                    color: selectedAvatarColor,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      userName.split(' ').map((e) => e[0]).take(2).join(),
                      style: context.bold.copyWith(
                        fontSize: 48.textMultiplier,
                        color: AppColors.black,
                      ),
                    ),
                  ),
                ),
                Text(
                  userName,
                  style: context.semiBold.copyWith(
                    fontSize: 28.textMultiplier,
                    color: AppColors.black,
                  ),
                ),
                // User Email
                Text(
                  userEmail,
                  style: context.medium.copyWith(
                    fontSize: 16.textMultiplier,
                    color: AppColors.black.withValues(alpha: 0.6),
                  ),
                ),
                20.verticalSpace,
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 30.widthMultiplier),
                  padding: EdgeInsets.all(20.widthMultiplier),
                  decoration: BoxDecoration(
                    color: AppColors.black.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(12.radiusMultipier),
                  ),
                  child: Column(
                    children: [
                      _buildInfoRow('Location', 'Muscat Branch'),
                      16.verticalSpace,
                      _buildInfoRow('Floor', '2nd Floor'),
                      16.verticalSpace,
                      _buildInfoRow('Devices', '3 of 5'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    40.widthMultiplier,
                    20.heightMultiplier,
                    40.widthMultiplier,
                    0,
                  ),
                  child: Text(
                    'Settings',
                    style: context.bold.copyWith(
                      fontSize: 36.textMultiplier,
                      color: AppColors.black,
                    ),
                  ),
                ),
                // Settings List
                Expanded(
                  child: FocusTraversalGroup(
                    policy: const RecentFocusTraversalPolicy(
                      group: FocusGroup.listRow,
                    ),
                    child: ListView.builder(
                      padding: EdgeInsets.symmetric(
                        horizontal: 40.widthMultiplier,
                        vertical: 20.heightMultiplier,
                      ),
                      itemCount: settingsItems.length,
                      itemBuilder: (context, index) {
                        return SettingsTile(
                          rowId: index,
                          columnId: 0,
                          item: settingsItems[index],
                          onTap: () => _onSettingTap(settingsItems[index]),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: context.medium.copyWith(
            fontSize: 14.textMultiplier,
            color: AppColors.black.withValues(alpha: 0.5),
          ),
        ),
        Text(
          value,
          style: context.semiBold.copyWith(
            fontSize: 14.textMultiplier,
            color: AppColors.black,
          ),
        ),
      ],
    );
  }
}

class SettingsTile extends StatefulWidget {
  final int rowId;
  final int columnId;
  final SettingsItem item;
  final VoidCallback? onTap;

  const SettingsTile({
    super.key,
    required this.rowId,
    required this.columnId,
    required this.item,
    this.onTap,
  });

  @override
  State<SettingsTile> createState() => _SettingsTileState();
}

class _SettingsTileState extends State<SettingsTile> {
  final RecentFocusNode _focusNode = RecentFocusNode(group: FocusGroup.listRow);

  @override
  Widget build(BuildContext context) {
    _focusNode.row = widget.rowId;
    _focusNode.column = widget.columnId;

    return GestureDetector(
      onTap: () {
        RecentFocusTraversalPolicy.setFocus(_focusNode, true);
        widget.onTap?.call();
      },
      child: Focus(
        focusNode: _focusNode,
        autofocus: widget.rowId == 0 && widget.columnId == 0,
        child: Builder(
          builder: (context) {
            final isFocused = Focus.of(context).hasFocus;

            return AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: EdgeInsets.only(bottom: 12.heightMultiplier),
              decoration: BoxDecoration(
                color: isFocused
                    ? AppColors.black.withValues(alpha: 0.1)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(8.radiusMultipier),
                border: Border.all(
                  color: isFocused
                      ? AppColors.black.withValues(alpha: 0.3)
                      : Colors.transparent,
                  width: 2,
                ),
              ),
              child: Row(
                children: [
                  // Icon
                  Container(
                    width: 48.widthMultiplier,
                    height: 48.heightMultiplier,
                    decoration: BoxDecoration(
                      color: widget.item.isDestructive
                          ? Colors.red.withValues(alpha: 0.1)
                          : AppColors.black.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8.radiusMultipier),
                    ),
                    child: Icon(
                      widget.item.icon,
                      size: 24.widthMultiplier,
                      color: widget.item.isDestructive
                          ? Colors.red
                          : AppColors.black.withValues(alpha: 0.9),
                    ),
                  ),
                  20.horizontalSpace,
                  // Text Content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.item.title,
                          style: context.semiBold.copyWith(
                            fontSize: 18.textMultiplier,
                            color: widget.item.isDestructive
                                ? Colors.red
                                : AppColors.black,
                          ),
                        ),
                        4.verticalSpace,
                        Text(
                          widget.item.subtitle,
                          style: context.regular.copyWith(
                            fontSize: 14.textMultiplier,
                            color: widget.item.isDestructive
                                ? Colors.red.withValues(alpha: 0.7)
                                : AppColors.black.withValues(alpha: 0.5),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Arrow
                  Icon(
                    Icons.chevron_right,
                    size: 28.widthMultiplier,
                    color: AppColors.black.withValues(
                      alpha: isFocused ? 0.9 : 0.3,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        onKeyEvent: (_, event) {
          if (event is KeyUpEvent &&
              (event.logicalKey == LogicalKeyboardKey.enter ||
                  event.logicalKey == LogicalKeyboardKey.select)) {
            widget.onTap?.call();
            return KeyEventResult.handled;
          }
          return KeyEventResult.ignored;
        },
      ),
    );
  }
}

class SettingsItem {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isDestructive;

  SettingsItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.isDestructive = false,
  });
}
