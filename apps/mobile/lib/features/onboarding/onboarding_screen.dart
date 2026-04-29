import 'package:flutter/material.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentStep = 0;

  final List<Widget> _pages = [
    const _IncomeStep(),
    const _DebtsStep(),
    const _GoalsStep(),
    const _HabitsStep(),
  ];

  void _nextPage() {
    if (_currentStep < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  void _completeOnboarding() {
    // TODO: Send data to API
    Navigator.of(context).pushReplacementNamed('/dashboard');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configura tu Perfil'),
        leading: _currentStep > 0
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => _pageController.previousPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                ),
              )
            : null,
      ),
      body: Column(
        children: [
          LinearProgressIndicator(
            value: (_currentStep + 1) / _pages.length,
          ),
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (index) => setState(() => _currentStep = index),
              physics: const NeverScrollableScrollPhysics(),
              children: _pages,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: _nextPage,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
              ),
              child: Text(_currentStep == _pages.length - 1 ? 'Finalizar' : 'Continuar'),
            ),
          ),
        ],
      ),
    );
  }
}

class _IncomeStep extends StatelessWidget {
  const _IncomeStep();
  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('¿Cuáles son tus ingresos mensuales?', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          SizedBox(height: 20),
          TextField(
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Monto mensual (USD)',
              prefixText: '\$ ',
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
    );
  }
}

class _DebtsStep extends StatelessWidget {
  const _DebtsStep();
  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Paso 2: Deudas (Próximamente)'));
  }
}

class _GoalsStep extends StatelessWidget {
  const _GoalsStep();
  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Paso 3: Metas (Próximamente)'));
  }
}

class _HabitsStep extends StatelessWidget {
  const _HabitsStep();
  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Paso 4: Hábitos (Próximamente)'));
  }
}
