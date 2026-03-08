import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/photo.dart';
import '../repositories/photo_repository.dart';

// Events
abstract class PhotoEvent {}

class LoadPhotos extends PhotoEvent {}

class AddPhoto extends PhotoEvent {
  final File imageFile;
  AddPhoto(this.imageFile);
}

class DeletePhoto extends PhotoEvent {
  final String id;
  DeletePhoto(this.id);
}

// States
abstract class PhotoState {}

class PhotoInitial extends PhotoState {}

class PhotoLoading extends PhotoState {}

class PhotoLoaded extends PhotoState {
  final List<Photo> photos;
  PhotoLoaded(this.photos);
}

class PhotoError extends PhotoState {
  final String message;
  PhotoError(this.message);
}

// BLoC
class PhotoBloc extends Bloc<PhotoEvent, PhotoState> {
  final PhotoRepository _repository;

  PhotoBloc({required PhotoRepository repository})
      : _repository = repository,
        super(PhotoInitial()) {
    on<LoadPhotos>(_onLoadPhotos);
    on<AddPhoto>(_onAddPhoto);
    on<DeletePhoto>(_onDeletePhoto);
  }

  Future<void> _onLoadPhotos(
      LoadPhotos event,
      Emitter<PhotoState> emit,
      ) async {
    emit(PhotoLoading());
    try {
      final photos = await _repository.getPhotos();
      emit(PhotoLoaded(photos));
    } catch (e) {
      emit(PhotoError(e.toString()));
    }
  }

  Future<void> _onAddPhoto(
      AddPhoto event,
      Emitter<PhotoState> emit,
      ) async {
    emit(PhotoLoading());
    try {
      await _repository.savePhoto(event.imageFile);
      final photos = await _repository.getPhotos();
      emit(PhotoLoaded(photos));
    } catch (e) {
      emit(PhotoError(e.toString()));
    }
  }

  Future<void> _onDeletePhoto(
      DeletePhoto event,
      Emitter<PhotoState> emit,
      ) async {
    emit(PhotoLoading());
    try {
      await _repository.deletePhoto(event.id);
      final photos = await _repository.getPhotos();
      emit(PhotoLoaded(photos));
    } catch (e) {
      emit(PhotoError(e.toString()));
    }
  }
}