import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../constants/app_constants.dart';

class ExperienceCard extends StatelessWidget {
  final dynamic experience;
  final bool isSelected;
  final VoidCallback onTap;

  const ExperienceCard({
    Key? key,
    required this.experience,
    required this.isSelected,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
        child: Transform.rotate(
          angle: -0.05,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Shimmer.fromColors(
                  baseColor: Colors.white.withOpacity(0.1),
                  highlightColor: Colors.white.withOpacity(0.2),
                  child: Container(color: Colors.white),
                ),
                ColorFiltered(
                  colorFilter: isSelected
                      ? const ColorFilter.mode(
                          Colors.transparent,
                          BlendMode.multiply,
                        )
                      : const ColorFilter.matrix([
                          0.2126, 0.7152, 0.0722, 0, 0, 
                          0.2126, 0.7152, 0.0722, 0, 0,
                          0.2126, 0.7152, 0.0722, 0, 0, 
                          0, 0, 0, 1, 0, 
                        ]),
                  child: Image.network(
                    experience.imageUrl ?? '',
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Shimmer.fromColors(
                        baseColor: Colors.white.withOpacity(0.1),
                        highlightColor: Colors.white.withOpacity(0.2),
                        child: Container(color: Colors.white),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[800],
                        child: Icon(
                          Icons.image_not_supported,
                          color: Colors.white.withOpacity(0.3),
                          size: 32,
                        ),
                      );
                    },
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.7),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  bottom: 8,
                  left: 8,
                  right: 8,
                  child: Text(
                    experience.name ?? 'Unknown',
                    style: AppConstants.smallRegular.copyWith(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
