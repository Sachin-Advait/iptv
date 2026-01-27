import 'package:flutter/material.dart';
import 'package:oman_tv/common/utils/focus_traversal.dart';
import 'package:oman_tv/common/utils/get_it.dart';
import 'package:oman_tv/modules/annoucement/annoucement_view.dart';
import 'package:oman_tv/modules/catch_up/catch_up_view.dart';
import 'package:oman_tv/modules/dashboard/cubit/dashboard_cubit.dart';
import 'package:oman_tv/modules/dashboard/widgets/header.dart';
import 'package:oman_tv/modules/dashboard/widgets/ticker_state.dart';
import 'package:oman_tv/modules/home/home_view.dart';
import 'package:oman_tv/modules/live_tv/live_tv_view.dart';
import 'package:oman_tv/modules/radio/radio_view.dart';
import 'package:oman_tv/modules/vod/vod_view.dart';

class DashboardView extends StatefulWidget {
  const DashboardView({super.key});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView>
    implements FocusListener {
  final _focusNode = RecentFocusNode(group: FocusGroup.root);

  List page = [
    const HomeView(),
    const LiveTVView(),
    const VodView(),
    const CatchUpView(),
    const RadioView(),
    const AnnouncementView(),
  ];

  int selectedTabIndex = 0;
  bool isUserSelected = false;
  final dashboardCubit = getIt<DashboardCubit>();

  @override
  void initState() {
    super.initState();
    dashboardCubit.fetchTickerData();
    FocusListener.add(this);
  }

  @override
  void dispose() {
    super.dispose();
    FocusListener.remove(this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Focus(
        focusNode: _focusNode,
        descendantsAreFocusable: true,
        child: Column(
          children: <Widget>[
            FocusTraversalGroup(
              policy: const RecentFocusTraversalPolicy(
                group: FocusGroup.header,
              ),
              child: Header(
                currentIndex: selectedTabIndex,
                userSelected: isUserSelected,
              ),
            ),
            Expanded(
              child: isUserSelected ? SizedBox() : page[selectedTabIndex],
            ),
            NewsTicker(dashboardCubit: dashboardCubit),
          ],
        ),
      ),
    );
  }

  @override
  void onFocusChanged(FocusGroup group, int row, int column) {
    if (group == FocusGroup.header) {
      setState(() {
        // if (column < page.length) {
        //   selectedTabIndex = column;
        //   isUserSelected = false;
        // } else {
        //   isUserSelected = true;
        // }
        selectedTabIndex = column;
      });
    }
  }
}
