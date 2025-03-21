import 'package:flare_up_host/features/events/presentation/bloc/location/location_event.dart';
import 'package:flare_up_host/features/events/presentation/bloc/location/location_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LocationBloc extends Bloc<LocationEvent, LocationState> {
  LocationBloc() : super(LocationInitial()) {
    on<UpdateLocation>(_onUpdateLocation);
  }

  Future<void> _onUpdateLocation(
    UpdateLocation event,
    Emitter<LocationState> emit,
  ) async {
    try {
      emit(LocationLoading());

      emit(LocationUpdated(
        latitude: event.latitude,
        longitude: event.longitude,
        address: event.address,
        city: event.city,
        state: event.state,
        country: event.country,
      ));
    } catch (e) {
      emit(LocationError(e.toString()));
    }
  }
}
