import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class OnboardingPageContent extends StatelessWidget {
  final String title;
  final String description;
  final String imagePath;
  final bool isFirstPage;

  const OnboardingPageContent({
    super.key,
    required this.title,
    required this.description,
    required this.imagePath,
    this.isFirstPage = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (isFirstPage)
            RichText(
              textAlign: TextAlign.center,
              text: const TextSpan(
                style: TextStyle(fontSize: 38, fontWeight: FontWeight.bold, height: 1.3),
                children: [
                  TextSpan(text: 'Welcome To\n', style: TextStyle(color: AppColors.primaryNavy)),
                  TextSpan(text: 'Job', style: TextStyle(color: AppColors.primaryNavy)),
                  TextSpan(text: 'Able', style: TextStyle(color: AppColors.accentBlue)),
                ],
              ),
            )
          else
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryNavy,
                height: 1.3,
              ),
            ),
            
          if (description.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              description,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                color: AppColors.textGray,
                fontWeight: FontWeight.w500,
                height: 1.5,
              ),
            ),
          ],
          
          const SizedBox(height: 48),
          
          SizedBox(
            height: 280,
            child: Image.asset(
              imagePath,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 280,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(16)
                  ),
                  child: const Center(
                    child: Text('Illustration Placeholder\n(Add image here)', 
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
