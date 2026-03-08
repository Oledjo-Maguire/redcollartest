// Импортируем все виджеты Material Design из Flutter
import 'package:flutter/material.dart';

// Импортируем библиотеку flutter_bloc для работы с BLoC состоянием
import 'package:flutter_bloc/flutter_bloc.dart';

// Импортируем наш PhotoBloc из папки bloc
import '../bloc/photo_bloc.dart';

// Импортируем виджет PhotoGrid для отображения сетки фотографий
import '../widgets/photo_grid.dart';

// Импортируем экран камеры
import 'camera_screen.dart';

// Объявляем класс HomeScreen, который является StatelessWidget (не имеет состояния)
class HomeScreen extends StatelessWidget {
  // Конструктор класса с ключом super.key
  const HomeScreen({super.key});

  // Переопределяем метод build - основной метод, который строит UI
  @override
  Widget build(BuildContext context) {
    // Scaffold - базовая структура экрана с AppBar, body и floatingActionButton
    return Scaffold(
      // AppBar - верхняя панель навигации
      appBar: AppBar(
        // Заголовок AppBar с текстом
        title: const Text(
          'Мои фотографии',                    // Текст заголовка
          style: TextStyle(
            fontWeight: FontWeight.bold,          // Жирный шрифт
            letterSpacing: 1.2,                   // Межбуквенный интервал 1.2px
          ),
        ),
        centerTitle: false,
        backgroundColor: Colors.black,             // black фон
        foregroundColor: Colors.white,            // Белый цвет текста и иконок
        elevation: 4,                              // Высота тени 4px
      ),

      // body - основное содержимое экрана
      body: BlocBuilder<PhotoBloc, PhotoState>(
        // BlocBuilder - слушает изменения состояния PhotoBloc и перестраивает UI
        builder: (context, state) {
          // Проверяем состояние: если идет загрузка
          if (state is PhotoLoading) {
            // Центрируем содержимое
            return const Center(
              // Column - вертикальное расположение элементов
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center, // Центрируем по вертикали
                children: [
                  // CircularProgressIndicator - круговой индикатор загрузки
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.blue), // Синий цвет
                  ),
                  SizedBox(height: 16),          // Отступ 16px
                  Text(
                    'Загрузка фотографий...',         // Текст загрузки
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            );
          }
          // Если состояние PhotoLoaded (фото загружены)
          else if (state is PhotoLoaded) {
            // Проверяем, пуст ли список фото
            if (state.photos.isEmpty) {
              // Показываем экран "Нет фото"
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Container - контейнер для круга с иконкой

                    const SizedBox(height: 24),           // Отступ 24px
                    Text(
                      'Фотографий пока нет',                     // Заголовок
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 8),            // Отступ 8px
                    Text(
                      'Нажмите на кнопку камеры, чтобы сделать свой первый снимок', // Подсказка
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade500,
                      ),
                      textAlign: TextAlign.center,        // Центрируем текст
                    ),
                    const SizedBox(height: 32),           // Отступ 32px

                    // ElevatedButton.icon - кнопка с иконкой и текстом
                    IconButton(
                      onPressed: () async {                // Асинхронное действие
                        // Получаем текущий PhotoBloc
                        final photoBloc = context.read<PhotoBloc>();

                        // Переходим на экран камеры и ждем результат
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            // Передаем PhotoBloc в CameraScreen через BlocProvider.value
                            builder: (context) => BlocProvider<PhotoBloc>.value(
                              value: photoBloc,
                              child: const CameraScreen(),
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.add_a_photo_outlined),  // Иконка камеры
                      // Стилизация кнопки
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepOrangeAccent,       // black фон
                        foregroundColor: Colors.black,      // Белый текст
                        shape: const CircleBorder(),
                      ),
                    ),
                  ],
                ),
              );
            }
            // Если фото есть - показываем сетку фотографий
            return PhotoGrid(photos: state.photos);
          }
          // Если состояние PhotoError (ошибка)
          else if (state is PhotoError) {
            // Показываем экран ошибки
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),       // Отступы 24px со всех сторон
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Красный круг с иконкой ошибки
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,          // Светло-красный фон
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.error_outline,                 // Иконка ошибки
                        size: 60,
                        color: Colors.red,                   // Красный цвет
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Упс! Что-то не так',         // Заголовок ошибки
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Текст самой ошибки из состояния
                    Text(
                      state.message,
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    // Кнопка повторной попытки
                    ElevatedButton(
                      onPressed: () {
                        // Отправляем событие загрузки фото
                        context.read<PhotoBloc>().add(LoadPhotos());
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepOrangeAccent,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.all(16),
                        shape: const CircleBorder(),
                        minimumSize: const Size(56, 56),
                      ),
                      child: const Text('Повторите'),
                    ),
                  ],
                ),
              ),
            );
          }
          // Если состояние не определено - возвращаем пустой виджет
          return const SizedBox.shrink();
        },
      ),

      // floatingActionButton - плавающая кнопка действия (внизу справа)
      floatingActionButton: FloatingActionButton(
        // extended - кнопка с иконкой и текстом
        onPressed: () async {
          // Получаем текущий PhotoBloc
          final photoBloc = context.read<PhotoBloc>();

          // Переходим на экран камеры и ждем результат
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              // Передаем PhotoBloc в CameraScreen
              builder: (context) => BlocProvider<PhotoBloc>.value(
                value: photoBloc,
                child: const CameraScreen(),
              ),
            ),
          );

          // Если результат true (фото успешно сделано) и контекст еще существует
          if (result == true && context.mounted) {
            // Показываем зеленый SnackBar об успехе
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Фото сохранено!'),
                duration: Duration(seconds: 2),
                backgroundColor: Colors.green,
              ),
            );
          }
        },
        child: const Icon(Icons.add_a_photo_outlined),  // Иконка камеры
                // Стилизация кнопки
          backgroundColor: Colors.deepOrangeAccent,       // orange фон
          foregroundColor: Colors.black,      // black текст
          shape: const CircleBorder(),
      ),
    );
  }
}