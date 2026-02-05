import 'package:flutter/material.dart';
import 'package:oman_tv/common/utils/app_screen_util.dart';
import 'package:oman_tv/common/utils/focus_traversal.dart';
import 'package:oman_tv/configs/assets/app_channels.dart';
import 'package:oman_tv/configs/assets/app_images.dart';
import 'package:oman_tv/configs/theme/app_colors.dart';
import 'package:oman_tv/configs/theme/app_theme.dart';
import 'package:oman_tv/modules/radio/widget/radio_card.dart';
import 'package:oman_tv/modules/radio/widget/radio_player_service.dart';

class RadioView extends StatefulWidget {
  const RadioView({super.key});

  @override
  State<RadioView> createState() => _RadioViewState();
}

class _RadioViewState extends State<RadioView> implements FocusListener {
  final RadioPlayerService _player = RadioPlayerService();
  RadioStation? currentlyPlaying;

  @override
  void initState() {
    super.initState();
    FocusListener.add(this);
  }

  @override
  void onFocusChanged(FocusGroup group, int row, int column) {
    if (group == FocusGroup.header) {
      setState(() {});
    }
  }

  void _onStationSelected(RadioStation station) async {
    setState(() {
      currentlyPlaying = station;
    });

    await _player.play(station.streamUrl);
  }

  final List<RadioStation> radioStations = [
    RadioStation(
      name: 'Oman Quran Radio',
      imagePath: AppChannels.ubc,
      frequency: '',
      streamUrl:
          'https://n0e.radiojar.com/4wqre23fytzuv?rj-ttl=5&rj-tok=AAABm_pqdQ8Awie7CBzNbchVzA',
    ),
    RadioStation(
      name: 'Radio Oman',
      imagePath: AppChannels.omanAir,
      frequency: '107.1 FM',
      streamUrl:
          'https://n0e.radiojar.com/4wqre23fytzuv?rj-ttl=5&rj-tok=AAABm_pqdQ8Awie7CBzNbchVzA',
    ),
    RadioStation(
      name: 'Hi FM Oman',
      imagePath: AppChannels.hifm,
      frequency: '',
      streamUrl:
          'https://n0e.radiojar.com/4wqre23fytzuv?rj-ttl=5&rj-tok=AAABm_pqdQ8Awie7CBzNbchVzA',
    ),
    RadioStation(
      name: 'Merge FN Oman',
      imagePath: AppChannels.merge,
      frequency: '104.6',
      streamUrl:
          'https://n0e.radiojar.com/4wqre23fytzuv?rj-ttl=5&rj-tok=AAABm_pqdQ8Awie7CBzNbchVzA',
    ),
  ];

  @override
  void dispose() {
    _player.stop();
    FocusListener.remove(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Padding(
        padding: EdgeInsets.all(40.widthMultiplier),
        child: Row(
          children: [
            Container(
              width: 480.widthMultiplier,
              padding: EdgeInsets.symmetric(horizontal: 30.widthMultiplier),
              decoration: BoxDecoration(
                color: AppColors.lightBeige,
                borderRadius: BorderRadius.circular(24.radiusMultipier),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  16.verticalSpace,
                  Text(
                    'Radio Stations',
                    style: context.extraBold.copyWith(
                      fontSize: 28.textMultiplier,
                      color: AppColors.primary,
                    ),
                  ),
                  16.verticalSpace,
                  Expanded(
                    child: FocusTraversalGroup(
                      policy: const RecentFocusTraversalPolicy(
                        group: FocusGroup.listRow,
                      ),
                      child: ListView.separated(
                        padding: EdgeInsets.only(bottom: 20),
                        itemCount: radioStations.length,
                        separatorBuilder: (context, index) => 12.verticalSpace,
                        itemBuilder: (context, index) {
                          return RadioCard(
                            rowId: index,
                            columnId: 0,
                            station: radioStations[index],
                            isPlaying:
                                currentlyPlaying?.name ==
                                radioStations[index].name,
                            onTap: () =>
                                _onStationSelected(radioStations[index]),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            40.horizontalSpace,
            Expanded(
              child: Container(
                padding: EdgeInsets.all(0.widthMultiplier),
                decoration: BoxDecoration(
                  color: AppColors.lightBeige,
                  borderRadius: BorderRadius.circular(24.radiusMultipier),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Now Playing',
                      style: context.extraBold.copyWith(
                        fontSize: 32.textMultiplier,
                        color: AppColors.primary,
                      ),
                    ),
                    Image.asset(AppImages.fm, height: 200),
                    if (currentlyPlaying != null) ...[
                      Text(
                        currentlyPlaying!.name,
                        style: context.bold.copyWith(
                          fontSize: 26.textMultiplier,
                          color: AppColors.primary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      if (currentlyPlaying!.frequency.isNotEmpty) ...[
                        12.verticalSpace,
                        Text(
                          currentlyPlaying!.frequency,
                          style: context.semiBold.copyWith(
                            fontSize: 22.textMultiplier,
                            color: AppColors.primary.withValues(alpha: 0.8),
                          ),
                        ),
                      ],
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
