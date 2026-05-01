import 'package:flutter/material.dart';
import 'package:qoucher/core/constants/app_colors.dart';
import 'package:qoucher/core/constants/app_texts.dart';
import 'package:qoucher/core/widgets/custom_button.dart';
import 'package:qoucher/router/app_router.dart';
import 'package:qoucher/router/route_names.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: Container(
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.92),
                  borderRadius: BorderRadius.circular(32),
                  border: Border.all(
                    color: AppColors.border,
                    width: 1.4,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryDark.withOpacity(0.08),
                      blurRadius: 34,
                      offset: const Offset(0, 18),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _topBadge(),
                    const SizedBox(height: 26),
                    _headline(),
                    const SizedBox(height: 14),
                    _subtitle(),
                    const SizedBox(height: 26),
                    _miniInfo(),
                    const SizedBox(height: 30),
                    _actionButtons(context),
                    const SizedBox(height: 18),
                    _footerSection(context),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _topBadge() {
    return Container(
      width: 90,
      height: 90,
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(28),
      ),
      child: const Icon(
        Icons.local_activity_rounded,
        size: 42,
        color: AppColors.primaryDark,
      ),
    );
  }

  Widget _headline() {
    return Column(
      children: const [
        Text(
          'Qoucher',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 38,
            fontWeight: FontWeight.w800,
            height: 1,
            letterSpacing: -1.0,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 10),
        Text(
          'Lokal. Smart. Direkt.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _subtitle() {
    return Text(
      'Entdecke lokale Deals, sammle Punkte oder Stempel und bleib mit deinen Lieblingsläden verbunden. Ohne App-Zwang. Ohne unnötigen Stress.',
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 15.5,
        height: 1.6,
        color: AppColors.textSecondary.withOpacity(0.95),
      ),
    );
  }

  Widget _miniInfo() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.primaryLight.withOpacity(0.45),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 1),
            child: Icon(
              Icons.auto_awesome_rounded,
              size: 18,
              color: AppColors.primaryDark,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Wähle deinen Weg: als Merchant einloggen, als Besucher einloggen oder einfach erst mal entspannt die Plattform erkunden.',
              style: TextStyle(
                fontSize: 13.8,
                height: 1.5,
                color: AppColors.textPrimary.withOpacity(0.9),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionButtons(BuildContext context) {
    return Column(
      children: [
        CustomButton(
          text: 'Merchant Login',
          icon: Icons.storefront_rounded,
          onPressed: () {
            AppRouter.pushNamed(
              context,
              RouteNames.login,
              arguments: {'role': 'merchant'},
            );
          },
        ),
        const SizedBox(height: 14),
        CustomButton(
          text: 'Besucher Login',
          icon: Icons.person_rounded,
          isOutlined: true,
          onPressed: () {
            AppRouter.pushNamed(
              context,
              RouteNames.login,
              arguments: {'role': 'customer'},
            );
          },
        ),
        const SizedBox(height: 14),
        TextButton.icon(
          onPressed: () {
            AppRouter.pushNamed(context, RouteNames.explorer);
          },
          icon: const Icon(
            Icons.travel_explore_rounded,
            size: 18,
          ),
          label: const Text(
            'Explorer öffnen',
            style: TextStyle(
              fontWeight: FontWeight.w800,
            ),
          ),
          style: TextButton.styleFrom(
            foregroundColor: AppColors.primaryDark,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ],
    );
  }

  Widget _footerSection(BuildContext context) {
    return Column(
      children: [
        Text(
          AppTexts.appTagline,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
            color: AppColors.textMuted,
          ),
        ),
        const SizedBox(height: 14),
        TextButton.icon(
          onPressed: () {
            AppRouter.pushNamed(context, '/admin');
          },
          icon: const Icon(
            Icons.admin_panel_settings_rounded,
            size: 16,
            color: AppColors.textMuted,
          ),
          label: const Text(
            'Admin',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.textMuted,
            ),
          ),
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
        ),
      ],
    );
  }
//button for admin of the app
// clicking on it open a page with password 1234 then a dashboard where I can see who requested a registerion and then register him as a merchant and set everything so he can login
// page going to be called admin.dart and everything is going to work inside in one page with pop us. Very simple as fuck and little differnet design
}