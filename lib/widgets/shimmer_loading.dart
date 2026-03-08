// Импортируем все виджеты Material Design из Flutter
import 'package:flutter/material.dart';

// Объявляем класс ShimmerLoading, который является StatefulWidget (имеет состояние)
// Этот виджет создает эффект мерцания (shimmer) для индикации загрузки
class ShimmerLoading extends StatefulWidget {
  // final - неизменяемые поля класса
  final Widget child;      // Дочерний виджет, который будет обернут в эффект
  final bool isLoading;    // Флаг загрузки (true - показываем эффект, false - показываем дочерний виджет)

  // Конструктор класса с обязательными параметрами
  const ShimmerLoading({
    super.key,              // Ключ для идентификации виджета
    required this.isLoading, // Обязательный параметр
    required this.child,     // Обязательный параметр
  });

  // Создает состояние для этого StatefulWidget
  @override
  State<ShimmerLoading> createState() => _ShimmerLoadingState();
}

// Приватный класс состояния для ShimmerLoading
// SingleTickerProviderStateMixin - миксин, который предоставляет Ticker для анимаций
class _ShimmerLoadingState extends State<ShimmerLoading>
    with SingleTickerProviderStateMixin {

  // late - переменная будет инициализирована позже (в initState)
  late AnimationController _controller;  // Контроллер анимации - управляет ходом анимации
  late Animation<double> _animation;     // Анимация - хранит текущее значение анимации

  // initState - вызывается один раз при создании состояния
  @override
  void initState() {
    super.initState();  // Обязательно вызываем родительский метод

    // Создаем контроллер анимации
    _controller = AnimationController(
      vsync: this,           // this предоставляет Ticker через миксин
      duration: const Duration(milliseconds: 1500), // Длительность одного цикла анимации (1.5 секунды)
    )..repeat();  // ..repeat() - запускаем анимацию по кругу (бесконечно)

    // Создаем анимацию с изменением значения от -2 до 2
    _animation = Tween<double>(begin: -2, end: 2).animate(
      // Применяем кривую анимации - плавное начало и конец
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  // dispose - вызывается при уничтожении виджета (освобождаем ресурсы)
  @override
  void dispose() {
    _controller.dispose();  // Обязательно освобождаем контроллер анимации
    super.dispose();        // Вызываем родительский метод
  }

  // build - строит UI виджета
  @override
  Widget build(BuildContext context) {
    // Если не в состоянии загрузки - просто возвращаем дочерний виджет без эффекта
    if (!widget.isLoading) {
      return widget.child;
    }

    // Если загрузка идет - применяем эффект мерцания
    // AnimatedBuilder - виджет, который перестраивается при каждом изменении анимации
    return AnimatedBuilder(
      animation: _animation,  // Анимация, за которой следим

      // builder - функция, которая вызывается при каждом изменении анимации
      builder: (context, child) {
        // ShaderMask - виджет, который применяет шейдер (градиент) к дочернему виджету
        return ShaderMask(
          // shaderCallback - функция, создающая шейдер для маски
          shaderCallback: (bounds) {
            // Создаем линейный градиент, который движется вместе с анимацией
            return LinearGradient(
              // Начальная точка градиента: (-значение, -значение)
              // При _animation.value = -2: (2, 2) - правый нижний угол
              // При _animation.value = 2: (-2, -2) - левый верхний угол
              begin: Alignment(-_animation.value, -_animation.value),

              // Конечная точка градиента: (значение, значение)
              // Противоположна начальной точке
              end: Alignment(_animation.value, _animation.value),

              // Цвета градиента: от серого к светло-серому и обратно к серому
              colors: [
                Colors.grey[300]!,  // Темно-серый (знак ! означает, что значение не null)
                Colors.grey[100]!,  // Светло-серый
                Colors.grey[300]!,  // Темно-серый
              ],

              // stops - позиции цветов в градиенте (0.0 - начало, 1.0 - конец)
              stops: const [0.1, 0.5, 0.9],
            ).createShader(bounds);  // Создаем шейдер из градиента
          },

          // blendMode - режим смешивания маски с дочерним виджетом
          // srcATop - исходное изображение накладывается поверх целевого
          blendMode: BlendMode.srcATop,

          // child - дочерний виджет (то, что мы хотим анимировать)
          child: widget.child,
        );
      },
    );
  }
}