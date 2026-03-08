// Импортируем библиотеку dart:io для работы с файлами (File)
import 'dart:io';

// Импортируем все виджеты Material Design из Flutter
import 'package:flutter/material.dart';

// Импортируем нашу модель Photo из соседней папки models
import '../models/photo.dart';

// Объявляем класс PhotoGrid, который является StatelessWidget (не имеет состояния)
class PhotoGrid extends StatelessWidget {
  // Объявляем обязательное поле photos - список фотографий, которые нужно отобразить
  final List<Photo> photos;

  // Конструктор класса с обязательным параметром photos и ключом super.key
  // const позволяет создавать константные экземпляры для оптимизации
  const PhotoGrid({super.key, required this.photos});

  // Переопределяем метод build - основной метод, который строит UI
  @override
  Widget build(BuildContext context) {
    // GridView.builder - виджет для создания сетки с динамическим количеством элементов
    return GridView.builder(
      // Внутренние отступы сетки со всех сторон по 12 пикселей
      padding: const EdgeInsets.all(12),

      // Настройки сетки: фиксированное количество столбцов
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 1,           // 2 колонки в сетке
        mainAxisSpacing: 12,          // Отступ между рядами 12px
        childAspectRatio: 1.7,        // Соотношение сторон ячейки (ширина/высота)
      ),

      // Количество элементов в сетке (равно количеству фотографий)
      itemCount: photos.length,

      // Функция, которая строит каждый элемент сетки по индексу
      itemBuilder: (context, index) {
        // Получаем фотографию по текущему индексу
        final photo = photos[index];

        // Hero - виджет для анимации перехода между экранами
        // tag должен быть уникальным для каждой фотографии
        return Hero(
          tag: 'photo_${photo.id}',   // Уникальный тег на основе ID фото

          // GestureDetector - обрабатывает жесты (нажатия)
          child: GestureDetector(
            onTap: () {               // При нажатии вызываем функцию
              _showPhotoDialog(context, photo);  // Показываем диалог с фото
            },

            // Card - карточка с тенью и скругленными углами
            child: Card(
              elevation: 4,            // Высота тени (4 пикселя)

              // Настройка формы карточки
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),  // Скругление углов 12px
              ),

              // ClipRRect - обрезает дочерний элемент по скругленным углам
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),  // Те же скругления 12px

                // Stack - позволяет накладывать виджеты друг на друга
                child: Stack(
                  fit: StackFit.expand,  // Растягивает все дочерние элементы на весь размер

                  // Список дочерних виджетов Stack
                  children: [
                    // Image.file - отображает изображение из файла
                    Image.file(
                      File(photo.path),   // Создаем File объект по пути к фото
                      fit: BoxFit.cover,   // Растягиваем изображение, сохраняя пропорции
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // Приватный метод для показа диалога с увеличенным фото
  void _showPhotoDialog(BuildContext context, Photo photo) {
    // showDialog - показывает модальное окно
    showDialog(
      context: context,
      builder: (context) => Dialog(           // Dialog - стандартное модальное окно
        insetPadding: const EdgeInsets.all(16), // Отступы от краев экрана 16px

        // Column - вертикальное расположение дочерних элементов
        child: Stack(
          children: [
            // Hero с тем же тегом для плавной анимации
            Hero(
              tag: 'photo_${photo.id}',

              // ClipRRect для скругления верхних углов
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                ),
                // Изображение во весь диалог
                child: Image.file(
                  File(photo.path),
                  fit: BoxFit.contain,          // Вписываем изображение, сохраняя пропорции
                  height: MediaQuery.of(context).size.height * 0.7, // 50% высоты экрана
                ),
              ),
            ),
          // Темная полоска со стрелкой
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                color: Colors.black.withOpacity(0.3),
                height: 56,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(
                      Icons.arrow_back_ios,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}