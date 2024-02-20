import 'package:anatomy/components/error_dialog.dart';
import 'package:anatomy/components/share_start_dialog.dart';
import 'package:anatomy/providers/providers.dart';
import 'package:anatomy/views/system_properties.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:anatomy/views/general.dart';
import 'package:anatomy/views/libwebrtc.dart';

import 'components/share_complete_dialog.dart';
import 'logics.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  runApp(const ProviderScope(child: MyApp()));
}

class TabData {
  const TabData({required this.tab, required this.w});
  final Tab tab;
  final Widget w;
}

class Home extends HookConsumerWidget {
  const Home({Key? key}) : super(key: key);

  static const tabs = [
    TabData(tab: Tab(text: 'General'), w: GeneralView()),
    TabData(tab: Tab(text: 'WebRTC'), w: WebrtcView()),
    TabData(tab: Tab(text: 'System Properties'), w: SystemPropertiesView()),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tabController = useTabController(
      initialLength: tabs.length,
      initialIndex: 0,
    );

    return DefaultTabController(
        length: tabs.length,
        child: Scaffold(
          // key: scaffoldKey,
          appBar: AppBar(
            title: const Text('Android Anatomy'),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(30),
              child: TabBar(
                isScrollable: true,
                tabs: tabs.map((e) => e.tab).toList(),
                controller: tabController,
              ),
            ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () async {
              showShareStartDialog(context, ref,
                  (BuildContext context, WidgetRef ref) async {
                Navigator.pop(context);

                try {
                  final isSignIn = await signInIfNeeded(ref);
                  debugPrint('isSignIn: $isSignIn');
                  if (!isSignIn) {
                    return;
                  }

                  // TODO: Show progress indicator

                  if (await checkAlreadyUploaded(ref)) {
                    showErrorDialog(context,
                        title: 'Already uploaded',
                        message: '''The data has already been updated.
Please upload again when you update this app or Android OS.''');
                    return;
                  }

                  final result = await upload(ref, context);
                  if (!context.mounted) {
                    return;
                  }

                  showShareCompleteDialog(context, result.id);
                } catch (e, s) {
                  debugPrint('$e\n$s');
                  final pb = ref.watch(pocketBaseProvider);
                  pb.authStore.clear();
                  if (!context.mounted) {
                    return;
                  }
                  showErrorDialog(context, message: '$e\n$s');
                }
              });
            },
            child: const Icon(Icons.upload),
          ),
          body: TabBarView(
            controller: tabController,
            children: tabs.map((e) => e.w).toList(),
          ),
        ));
  }
}

class MyApp extends HookConsumerWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: Colors.grey,
        ),
        useMaterial3: true,
      ),
      themeMode: ThemeMode.dark,
      home: const Home(),
    );
  }
}
