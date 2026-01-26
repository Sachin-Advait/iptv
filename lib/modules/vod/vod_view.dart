import 'package:flutter/widgets.dart';
import 'package:oman_tv/configs/theme/app_colors.dart';

class VodView extends StatelessWidget {
  const VodView({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.bg,
      child: Center(
        child: Text(
          'VOD Content',
          style: TextStyle(
            fontSize: 24,
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
