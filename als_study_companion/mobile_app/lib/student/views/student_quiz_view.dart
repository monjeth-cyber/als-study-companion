import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/quiz_viewmodel.dart';

/// View for taking a quiz.
class StudentQuizView extends StatelessWidget {
  final String quizId;

  const StudentQuizView({super.key, required this.quizId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quiz')),
      body: Consumer<QuizViewModel>(
        builder: (context, vm, _) {
          if (vm.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (vm.isSubmitted) {
            return _QuizResultView(vm: vm);
          }

          if (vm.currentQuestion == null) {
            return const Center(child: Text('No questions available'));
          }

          final question = vm.currentQuestion!;
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Progress indicator
                LinearProgressIndicator(
                  value: (vm.currentQuestionIndex + 1) / vm.questions.length,
                ),
                const SizedBox(height: 8),
                Text(
                  'Question ${vm.currentQuestionIndex + 1} of ${vm.questions.length}',
                  style: TextStyle(color: Colors.grey[600]),
                ),
                const SizedBox(height: 24),

                // Question
                Text(
                  question.questionText,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 24),

                // Options
                Expanded(
                  child: ListView.builder(
                    itemCount: question.options.length,
                    itemBuilder: (context, index) {
                      final isSelected =
                          vm.selectedAnswers[vm.currentQuestionIndex] == index;
                      return Card(
                        color: isSelected
                            ? Theme.of(context).colorScheme.primaryContainer
                            : null,
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: isSelected
                                ? Theme.of(context).colorScheme.primary
                                : Colors.grey[300],
                            foregroundColor: isSelected
                                ? Colors.white
                                : Colors.black,
                            child: Text(String.fromCharCode(65 + index)),
                          ),
                          title: Text(question.options[index]),
                          onTap: () =>
                              vm.selectAnswer(vm.currentQuestionIndex, index),
                        ),
                      );
                    },
                  ),
                ),

                // Navigation buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (vm.currentQuestionIndex > 0)
                      OutlinedButton(
                        onPressed: vm.previousQuestion,
                        child: const Text('Previous'),
                      )
                    else
                      const SizedBox(),
                    vm.isLastQuestion
                        ? FilledButton(
                            onPressed: vm.answeredCount == vm.questions.length
                                ? vm.submitQuiz
                                : null,
                            child: const Text('Submit'),
                          )
                        : FilledButton(
                            onPressed: vm.nextQuestion,
                            child: const Text('Next'),
                          ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _QuizResultView extends StatelessWidget {
  final QuizViewModel vm;

  const _QuizResultView({required this.vm});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              vm.passed ? Icons.celebration : Icons.sentiment_dissatisfied,
              size: 80,
              color: vm.passed ? Colors.green : Colors.orange,
            ),
            const SizedBox(height: 16),
            Text(
              vm.passed ? 'Congratulations!' : 'Keep Trying!',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Score: ${vm.score} / ${vm.questions.length} (${vm.scorePercent.toStringAsFixed(0)}%)',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              vm.passed
                  ? 'You passed the quiz!'
                  : 'You need ${vm.currentQuiz?.passingScore}% to pass.',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Done'),
            ),
          ],
        ),
      ),
    );
  }
}
