import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:oman_tv/common/utils/app_screen_util.dart';
import 'package:oman_tv/common/utils/focus_traversal.dart';
import 'package:oman_tv/configs/assets/app_images.dart';
import 'package:oman_tv/configs/theme/app_colors.dart';
import 'package:oman_tv/modules/dashboard/widgets/custom_tab.dart';

class Header extends StatelessWidget {
  final int currentIndex;

  const Header({super.key, required this.currentIndex});

  static const List<String> _tabLabels = [
    'Home',
    'Live TV',
    'VOD',
    'Catch-UP',
    'Radio',
    'Announcement',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60.heightMultiplier,
      color: AppColors.bg,
      padding: EdgeInsets.symmetric(
        horizontal: 24.widthMultiplier,
        vertical: 12.heightMultiplier,
      ),
      child: Row(
        children: [
          SvgPicture.asset(AppImages.logo, height: 25.heightMultiplier),

          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_tabLabels.length, (index) {
                return CustomTab(id: index, label: _tabLabels[index]);
              }),
            ),
          ),

          // ✅ USER IMAGE AS HEADER FOCUS NODE
          UserProfileButton(columnId: _tabLabels.length),
        ],
      ),
    );
  }
}

class UserProfileButton extends StatefulWidget {
  final int columnId;

  const UserProfileButton({super.key, required this.columnId});

  @override
  State<UserProfileButton> createState() => _UserProfileButtonState();
}

class _UserProfileButtonState extends State<UserProfileButton> {
  final RecentFocusNode _focusNode = RecentFocusNode(group: FocusGroup.header);

  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    _focusNode.row = 0;
    _focusNode.column = widget.columnId; // after last tab

    return Focus(
      focusNode: _focusNode,
      onFocusChange: (v) => setState(() => _isFocused = v),
      child: GestureDetector(
        onTap: () {
          RecentFocusTraversalPolicy.setFocus(_focusNode, true);
          debugPrint("USER PROFILE PRESSED");
        },
        child: Container(
          width: 45.widthMultiplier,
          height: 45.heightMultiplier,
          margin: EdgeInsets.only(left: 12.widthMultiplier),
          padding: EdgeInsets.all(6.widthMultiplier),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: _isFocused
                ? Border.all(color: AppColors.primary, width: 3)
                : null,
          ),
          child: ClipOval(
            child: Image.asset(AppImages.user, fit: BoxFit.cover),
          ),
        ),
      ),
      onKeyEvent: (_, event) {
        if (event is KeyUpEvent &&
            (event.logicalKey == LogicalKeyboardKey.enter ||
                event.logicalKey == LogicalKeyboardKey.select)) {
          debugPrint("USER PROFILE SELECT");
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      },
    );
  }
}
