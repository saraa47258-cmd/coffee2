import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ty_cafe/features/cart/data/repositories/cart_repository_impl.dart';
import 'package:ty_cafe/features/cart/presentation/bloc/cart_bloc.dart';
import 'package:ty_cafe/features/favorite/presentation/bloc/favorite_bloc.dart';
import 'package:ty_cafe/features/onboarding/presentation/pages/onboarding_page.dart';
import 'package:ty_cafe/features/profile/data/repositories/profile_repository.dart';
import 'package:ty_cafe/features/profile/presentation/bloc/profile_bloc.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();

  runApp(MyApp(prefs: prefs));
}

class MyApp extends StatelessWidget {
  final SharedPreferences prefs;
  final CartRepositoryImpl cartRepo;
  final ProfileRepositoryImpl profileRepo;

  MyApp({super.key, required this.prefs})
    : cartRepo = CartRepositoryImpl(),
      profileRepo = ProfileRepositoryImpl(prefs);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<CartBloc>(
          create: (_) => CartBloc(repository: cartRepo)..add(CartStarted()),
        ),
        BlocProvider<FavoriteBloc>(
          create: (_) => FavoriteBloc()..add(FavoriteLoadRequested()),
        ),
        BlocProvider<ProfileBloc>(
          create: (_) =>
              ProfileBloc(repository: profileRepo)..add(ProfileLoadRequested()),
        ),
      ],
      child: MaterialApp(
        title: 'Ty Cafe',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: false,
        ),
        home: const OnboardingPage(),
      ),
    );
  }
}
