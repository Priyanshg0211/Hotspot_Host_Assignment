import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hotspot_host/widgets/reusable_widget.dart';
import 'package:shimmer/shimmer.dart';
import 'dart:math' as math;
import '../bloc/experience/experience_bloc.dart';
import '../constants/app_constants.dart';
import '../constants/app_spacing.dart';
import '../widgets/experience_card.dart';
import '../utils/logger.dart';
import 'onboarding_question_screen.dart';

class ExperienceSelectionScreen extends StatefulWidget {
  const ExperienceSelectionScreen({super.key});

  @override
  State<ExperienceSelectionScreen> createState() =>
      _ExperienceSelectionScreenState();
}

class _ExperienceSelectionScreenState extends State<ExperienceSelectionScreen> {
  double progress = 0.3;
  final TextEditingController _textController = TextEditingController();
  final TextEditingController _step2TextController = TextEditingController();
  final FocusNode _step1FocusNode = FocusNode();
  final FocusNode _step2FocusNode = FocusNode();
  int currentStep = 1;
  final ScrollController _horizontalScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _textController.addListener(_onStep1TextChanged);
    _step2TextController.addListener(_onStep2TextChanged);
  }

  void _onStep1TextChanged() {
    if (currentStep == 1) {
      context.read<ExperienceBloc>().add(
        UpdateDescription(_textController.text),
      );
    }
  }

  void _onStep2TextChanged() {
    if (currentStep == 2) {
      context.read<ExperienceBloc>().add(
        UpdateDescription(_step2TextController.text),
      );
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    _step2TextController.dispose();
    _step1FocusNode.dispose();
    _step2FocusNode.dispose();
    _horizontalScrollController.dispose();
    super.dispose();
  }

  void _handleNext() {
    final state = context.read<ExperienceBloc>().state;
    if (state is ExperienceLoaded) {
      if (currentStep == 1) {
        AppLogger.info('Step 1 completed - Description: ${state.description}');

        setState(() {
          currentStep = 2;
          progress = 0.6;
          _step2TextController.text = state.description;
        });
      } else {
        AppLogger.info('Final submission', data: {
          'selectedIds': state.selectedIds.toList(),
          'selectedNames': state.experiences
              .where((e) => state.selectedIds.contains(e.id))
              .map((e) => e.name)
              .toList(),
          'description': state.description,
        });

        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                const OnboardingQuestionScreen(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              const begin = 0.0;
              const end = 1.0;
              const curve = Curves.easeInOut;

              var tween = Tween(
                begin: begin,
                end: end,
              ).chain(CurveTween(curve: curve));
              var fadeAnimation = animation.drive(tween);

              return FadeTransition(opacity: fadeAnimation, child: child);
            },
            transitionDuration: const Duration(milliseconds: 300),
          ),
        );
      }
    }
  }

  void _handleBack() {
    if (currentStep > 1) {
      setState(() {
        currentStep--;
        progress = 0.3;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: ScreenWrapper(
        child: Column(
          children: [
            CustomTopBar(
              progress: progress,
              onBack: currentStep > 1 ? _handleBack : null,
              onClose: () =>
                  Navigator.popUntil(context, (route) => route.isFirst),
            ),
            Expanded(
              child: BlocBuilder<ExperienceBloc, ExperienceState>(
                builder: (context, state) {
                  if (state is ExperienceLoading) {
                    return _buildShimmerLoading();
                  } else if (state is ExperienceError) {
                    return _buildErrorState(state);
                  } else if (state is ExperienceLoaded) {
                    return _buildContent(state);
                  }
                  return const SizedBox();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerLoading() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenHorizontal,
        vertical: AppSpacing.screenTop,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppSpacing.contentTopOffset),
          Shimmer.fromColors(
            baseColor: Colors.white.withOpacity(0.1),
            highlightColor: Colors.white.withOpacity(0.2),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40,
                  height: 16,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: AppSpacing.sectionVertical),
                Container(
                  width: double.infinity,
                  height: AppSpacing.textFieldHeight,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                const SizedBox(height: AppSpacing.sectionVertical),
                Container(
                  width: double.infinity,
                  height: AppSpacing.buttonHeight,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(ExperienceError state) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.screenHorizontal),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 64),
            const SizedBox(height: AppSpacing.elementVertical),
            Text(
              'Unable to load experiences',
              style: AppConstants.bodyBold.copyWith(color: Colors.white),
            ),
            const SizedBox(height: AppSpacing.elementSmall),
            Text(
              'Please check your internet connection and try again',
              style: AppConstants.smallRegular.copyWith(
                color: Colors.white.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sectionVertical),
            ElevatedButton(
              onPressed: () {
                context.read<ExperienceBloc>().add(LoadExperiences());
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF5B7FFF),
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(ExperienceLoaded state) {
    final mediaQuery = MediaQuery.of(context);
    final keyboardHeight = mediaQuery.viewInsets.bottom;
    final isKeyboardOpen = keyboardHeight > 0;
    final screenHeight = mediaQuery.size.height;
    final availableHeight =
        screenHeight - mediaQuery.padding.top - mediaQuery.padding.bottom;

    double topSpacing;
    if (isKeyboardOpen) {
      topSpacing = math.max(20, availableHeight * 0.03);
    } else {
      if (currentStep == 1) {
        topSpacing = math.max(60, availableHeight * 0.15);
      } else {
        topSpacing = math.max(40, availableHeight * 0.08);
      }
    }

    return Padding(
      padding: const EdgeInsets.only(
        left: AppSpacing.screenHorizontal,
        right: AppSpacing.screenHorizontal,
        top: AppSpacing.screenTop,
        bottom: AppSpacing.screenBottom,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: topSpacing),
          SectionTitle(
            stepNumber: currentStep == 1 ? '01' : '02',
            title: currentStep == 1
                ? 'What kind of hotspots do you want to host?'
                : 'What kind of experiences do you want to host?',
            isKeyboardOpen: isKeyboardOpen,
          ),
          const SizedBox(height: AppSpacing.sectionVertical),
          if (currentStep == 1)
            _buildStep1Content(isKeyboardOpen, availableHeight)
          else
            _buildStep2Content(state, isKeyboardOpen, availableHeight),
          const SizedBox(height: AppSpacing.sectionVertical),
          NextButton(
            onTap: _handleNext,
            isEnabled: currentStep == 1 || state.selectedIds.isNotEmpty,
          ),
        ],
      ),
    );
  }

  Widget _buildStep1Content(bool isKeyboardOpen, double availableHeight) {
    return ResponsiveTextField(
      controller: _textController,
      focusNode: _step1FocusNode,
      hintText: '/ Describe your perfect hotspot',
      maxLength: 250,
      isKeyboardOpen: isKeyboardOpen,
      availableHeight: availableHeight,
    );
  }

  Widget _buildStep2Content(
    ExperienceLoaded state,
    bool isKeyboardOpen,
    double availableHeight,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 100,
          child: ListView.separated(
            controller: _horizontalScrollController,
            scrollDirection: Axis.horizontal,
            itemCount: state.experiences.length,
            separatorBuilder: (context, index) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final experience = state.experiences[index];
              final isSelected = state.selectedIds.contains(experience.id);

              return AnimatedExperienceCard(
                key: ValueKey(experience.id),
                experience: experience,
                isSelected: isSelected,
                index: index,
                onTap: () {
                  context.read<ExperienceBloc>().add(
                    ToggleExperienceSelection(experience.id),
                  );

                  if (!isSelected) {
                    Future.delayed(const Duration(milliseconds: 150), () {
                      if (_horizontalScrollController.hasClients) {
                        _horizontalScrollController.animateTo(
                          0,
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.easeOutCubic,
                        );
                      }
                    });

                    Future.delayed(const Duration(milliseconds: 100), () {
                      context.read<ExperienceBloc>().add(
                        ReorderExperiences(experience.id),
                      );
                    });
                  }
                },
              );
            },
          ),
        ),
        const SizedBox(height: AppSpacing.sectionVertical),
        ResponsiveTextField(
          controller: _step2TextController,
          focusNode: _step2FocusNode,
          hintText: '/ Describe your perfect hotspot',
          maxLength: 250,
          isKeyboardOpen: isKeyboardOpen,
          availableHeight: availableHeight,
        ),
      ],
    );
  }
}

class AnimatedExperienceCard extends StatelessWidget {
  final dynamic experience;
  final bool isSelected;
  final int index;
  final VoidCallback onTap;

  const AnimatedExperienceCard({
    Key? key,
    required this.experience,
    required this.isSelected,
    required this.index,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedSlide(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutCubic,
      offset: Offset.zero,
      child: AnimatedScale(
        duration: const Duration(milliseconds: 300),
        scale: isSelected ? 1.0 : 1.0,
        curve: Curves.easeOutBack,
        child: SizedBox(
          width: 100,
          height: 100,
          child: ExperienceCard(
            experience: experience,
            isSelected: isSelected,
            onTap: onTap,
          ),
        ),
      ),
    );
  }
}


class ResponsiveTextField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final String hintText;
  final int maxLength;
  final bool isKeyboardOpen;
  final double availableHeight;

  const ResponsiveTextField({
    Key? key,
    required this.controller,
    required this.focusNode,
    required this.hintText,
    required this.maxLength,
    required this.isKeyboardOpen,
    required this.availableHeight,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double textFieldHeight;
    if (isKeyboardOpen) {
      textFieldHeight = math.max(100, availableHeight * 0.12);
    } else {
      textFieldHeight = math.max(160, availableHeight * 0.22);
    }

    final fontSize = isKeyboardOpen ? 14.0 : 16.0;
    final currentLength = controller.text.length;
    final isNearLimit = currentLength > maxLength * 0.8;
    final isAtLimit = currentLength >= maxLength;

    return Column(
      children: [
        Container(
          height: textFieldHeight,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(AppSpacing.cardRadiusSmall),
            border: Border.all(
              color: isAtLimit 
                  ? Colors.orange.withOpacity(0.5)
                  : Colors.white.withOpacity(0.1),
              width: 1,
            ),
          ),
          child: TextField(
            controller: controller,
            focusNode: focusNode,
            maxLines: null,
            maxLength: maxLength,
            textCapitalization: TextCapitalization.sentences,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) {
              FocusScope.of(context).unfocus();
            },
            style: AppConstants.smallRegular.copyWith(
              color: Colors.white,
              fontSize: fontSize,
            ),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: AppConstants.smallRegular.copyWith(
                color: Colors.white.withOpacity(0.3),
                fontSize: fontSize,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(20),
              counter: const SizedBox.shrink(),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.elementSmall),
        Align(
          alignment: Alignment.centerRight,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: isAtLimit
                  ? Colors.orange.withOpacity(0.2)
                  : isNearLimit
                      ? Colors.white.withOpacity(0.1)
                      : Colors.transparent,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              '$currentLength/$maxLength',
              style: AppConstants.lowercaseRegular.copyWith(
                color: isAtLimit
                    ? Colors.orange
                    : isNearLimit
                        ? Colors.white.withOpacity(0.9)
                        : Colors.white.withOpacity(0.5),
                fontSize: 12,
                fontWeight: isNearLimit ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ),
        ),
      ],
    );
  }
}