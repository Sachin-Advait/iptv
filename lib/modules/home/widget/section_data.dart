import 'package:flutter/material.dart';
import 'package:oman_tv/configs/assets/app_channels.dart';
import 'package:oman_tv/configs/assets/app_images.dart';
import 'package:oman_tv/modules/home/widget/group_card.dart';

class HomeSectionData {
  static List<Map<String, String>> get liveTVitems => [
    {'icon': AppImages.news, 'label': 'News'},
    {'icon': AppImages.government, 'label': 'Government'},
    {'icon': AppImages.sports, 'label': 'Sports'},
    {'icon': AppImages.internal, 'label': 'Internal'},
  ];

  static List<RadioItem> get _group1Items => [
    RadioItem(imagePath: AppChannels.bbc),
    RadioItem(imagePath: AppChannels.cnn),
    RadioItem(imagePath: AppChannels.cbs),
    RadioItem(imagePath: AppChannels.sky),
  ];

  static List<RadioItem> get _group2Items => [
    RadioItem(imagePath: AppChannels.omanAir),
    RadioItem(imagePath: AppChannels.channel1),
    RadioItem(imagePath: AppChannels.pngegg),
    RadioItem(imagePath: AppChannels.ubc2),
  ];

  static List<RadioItem> get _group3Items => [
    RadioItem(imagePath: AppChannels.bein),
    RadioItem(imagePath: AppChannels.fox),
    RadioItem(imagePath: AppChannels.star),
    RadioItem(imagePath: AppChannels.tenSports),
  ];

  static List<RadioItem> get _group4Items => [
    RadioItem(imagePath: AppChannels.channel1),
    RadioItem(imagePath: AppChannels.cbs),
    RadioItem(imagePath: AppChannels.star),
    RadioItem(imagePath: AppChannels.omanAir),
  ];

  static List<RadioItem> dynamicLiveTVItems(int categoryIndex) {
    switch (categoryIndex) {
      case 0:
        return _group1Items;
      case 1:
        return _group2Items;
      case 2:
        return _group3Items;
      default:
        return _group4Items;
    }
  }

  static List<Map<String, dynamic>> get announcements => [
    {
      'icon': AppImages.meetingRoom,
      'label': 'Meeting Room',
      'onTap': () => debugPrint("Meeting Room tapped"),
    },
    {
      'icon': AppImages.visitorManagement,
      'label': 'Visitor Management',
      'onTap': () => debugPrint("Visitor Management tapped"),
    },
    {
      'icon': AppImages.ramadan,
      'label': 'Ramadan',
      'onTap': () => debugPrint("Ramadan tapped"),
    },
  ];

  static List<RadioItem> get radioItems => [
    RadioItem(imagePath: AppChannels.ubc),
    RadioItem(imagePath: AppChannels.omanAir),
    RadioItem(imagePath: AppChannels.merge),
    RadioItem(imagePath: AppChannels.jld),
    RadioItem(imagePath: AppChannels.omanAir),
  ];
}
