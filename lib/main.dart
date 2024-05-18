import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_strategy/url_strategy.dart';

import 'presenter/storeinfo/store_info_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  setPathUrlStrategy();
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: _router,
    );
  }
}

final GoRouter _router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) {
        print("Navigating to HomePage, fullPath: ${state.fullPath}");
        return HomePage();
      },
    ),
    GoRoute(
      path: '/reservation/:storeCode',
      builder: (context, state) {
        print("Navigating to ReservationPage, fullPath: ${state.fullPath}");
        final storeCode = int.parse(state.pathParameters['storeCode']!);
        return StoreDetailInfoWidget(storeCode: storeCode);
      },
    ),
    GoRoute(
      path: '/reservation/:storeCode/:userPhoneNumber',
      builder: (context, state) {
        print(
            "Navigating to ReservationPage for Specific User, fullPath: ${state.fullPath}");
        final userPhoneNumber = state.pathParameters['userPhoneNumber']!;
        return StoreInfoScreen(storeCode: userPhoneNumber);
      },
    ),
  ],
  errorBuilder: (context, state) {
    print('Error: ${state.error}');
    return ErrorPage(state.error);
  },
);

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
      ),
      body: ElevatedButton(
        onPressed: () {
          context.go('/reservation/1');
        },
        child: Text('Go to ReservationPage'),
      ),
    );
  }
}

class ReservationPage extends StatelessWidget {
  const ReservationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Reservation'),
        ),
        body: Column(
          children: [
            ElevatedButton(
              onPressed: () {
                context.go('/reservation/1');
              },
              child: Text('Go to Store 1'),
            ),
            ElevatedButton(
              onPressed: () {
                context.go('/reservation/2');
              },
              child: Text('Go to Store 2'),
            ),
            ElevatedButton(
              onPressed: () {
                context.go('/reservation/3');
              },
              child: Text('Go to Store 3'),
            ),
          ],
        ));
  }
}

class StoreInfoScreen extends StatelessWidget {
  final String storeCode;

  const StoreInfoScreen({required this.storeCode});

  Future<String> fetchStoreDetails(String storeCode) async {
    // 여기에 실제로 데이터를 가져오는 로직을 구현
    await Future.delayed(Duration(seconds: 2)); // 예시로 2초 딜레이 추가
    return 'Store details for store code: $storeCode';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Reservation'),
      ),
      body: FutureBuilder<String>(
        future: fetchStoreDetails(storeCode),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            return Center(child: Text(snapshot.data ?? 'No details available'));
          }
        },
      ),
    );
  }
}

class ErrorPage extends StatelessWidget {
  final Exception? error;

  const ErrorPage(this.error);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Error'),
      ),
      body: Center(
        child: Text(error?.toString() ?? 'Unknown error'),
      ),
    );
  }
}
