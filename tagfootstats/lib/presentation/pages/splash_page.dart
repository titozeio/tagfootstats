import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tagfootstats/core/theme/app_colors.dart';
import 'package:tagfootstats/presentation/bloc/app/app_bloc.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.sports_football,
              size: 80,
              color: AppColors.nflGold,
            ),
            const SizedBox(height: 24),
            const Text(
              'TAG FOOT STATS',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 48),
            BlocBuilder<AppBloc, AppState>(
              builder: (context, state) {
                if (state is AppError) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      children: [
                        Text(
                          state.message,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: AppColors.accentRed,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'CONSEJO: Abre la consola del navegador (F12) y busca errores en rojo en la pestaña "Console".',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 10, color: Colors.grey),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton(
                              onPressed: () =>
                                  context.read<AppBloc>().add(InitializeApp()),
                              child: const Text('RETRY'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }
                return const CircularProgressIndicator();
              },
            ),
          ],
        ),
      ),
    );
  }
}
