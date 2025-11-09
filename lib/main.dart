import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';
import 'bloc/experience/experience_bloc.dart';
import 'bloc/question/question_bloc.dart';
import 'data/repositories/experience_repository.dart';
import 'data/api/api_client.dart';
import 'screens/experience_selection_screen.dart';
import 'constants/app_constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Permission.microphone.request();
  await Permission.camera.request();
  await Permission.storage.request();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final apiClient = ApiClient();
    final experienceRepository = ExperienceRepository(apiClient: apiClient);

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => ExperienceBloc(repository: experienceRepository)
            ..add(LoadExperiences()),
        ),
        BlocProvider(
          create: (context) => QuestionBloc(),
        ),
      ],
      child: MaterialApp(
        title: 'Hotspot Host Onboarding',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: AppConstants.darkColorScheme,
          fontFamily: AppConstants.fontFamilyPrimary,
          scaffoldBackgroundColor: AppConstants.colorBase,
        ),
        home: const ExperienceSelectionScreen(),
      ),
    );
  }
}