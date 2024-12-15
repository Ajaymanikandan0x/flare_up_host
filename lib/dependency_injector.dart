import 'package:dio/dio.dart';

import 'core/error/error_handler_service.dart';
import 'core/network/dio_interceptor.dart';
import 'core/network/network_service.dart';
import 'core/storage/secure_storage_service.dart';
import 'core/utils/cloudinary_service.dart';
import 'features/authentication/data/datasources/remote_data.dart';
import 'features/authentication/data/repositories/auth_repo_data.dart';
import 'features/authentication/domain/repositories/auth_repo_domain.dart';
import 'features/authentication/domain/usecases/login_usecase.dart';
import 'features/authentication/domain/usecases/logout_usecase.dart';
import 'features/authentication/domain/usecases/otp_send_usecase.dart';
import 'features/authentication/domain/usecases/resend_otp_usecase.dart';
import 'features/authentication/domain/usecases/signup_usecase.dart';
import 'features/authentication/domain/usecases/verify_reset_password_otp_usecase.dart';
import 'features/authentication/presentation/bloc/auth_bloc.dart';
import 'features/events/data/datasources/event_remote_datasource_impl.dart';
import 'features/events/data/repositories/event_repository_impl.dart';
import 'features/events/domain/repositories/event_repository.dart';
import 'features/events/domain/usecases/category_usecase.dart';
import 'features/events/domain/usecases/create_event_usecase.dart';
import 'features/events/domain/usecases/host_event_usecase.dart';
import 'features/events/domain/usecases/update_event_usecase.dart';
import 'features/events/domain/usecases/upload_event_media_usecase.dart';
import 'features/events/presentation/bloc/event_bloc.dart';
import 'features/profile/data/datasources/host_profile_remote_datasource.dart';
import 'features/profile/data/repositories/profile_image_repository_impl.dart';
import 'features/profile/data/repositories/host_profile_repository_impl.dart';
import 'features/profile/domain/repositories/host_profile_repository.dart';
import 'features/profile/domain/usecases/get_user_profile_usecase.dart';
import 'features/profile/domain/usecases/update_user_profile_usecase.dart';
import 'features/profile/domain/usecases/upload_profile_image_usecase.dart';
import 'features/profile/presentation/bloc/host_profile_bloc.dart';

class DependencyInjector {
  static final DependencyInjector _instance = DependencyInjector._internal();

  factory DependencyInjector() {
    return _instance;
  }

  DependencyInjector._internal();

  // Authentication dependencies
  late AuthRepositoryDomain _authRepository;
  late LoginUseCase _loginUseCase;
  late SendOtpUseCase _otpUseCase;
  late SignupUseCase _signupUseCase;
  late LogoutUseCase _logoutUseCase;
  late ResendOtpUseCase _resendOtpUseCase;
  late AuthBloc _authBloc;

  // Host profile dependencies
  late HostProfileRemoteDataSourceImpl _hostProfileRemoteDatasource;
  late HostProfileRepositoryDomain _hostProfileRepository;
  late GetHostProfileUseCase _getUserProfileUseCase;
  late UpdateHostProfileUseCase _updateUserProfileUseCase;
  late HostProfileBloc _hostProfileBloc;

  // Event dependencies
  late EventRemoteDataSourceImpl _eventRemoteDataSource;
  late EventRepositoryDomain _eventRepository;
  late CategoriesUseCase _categoriesUseCase;
  late CreateEventUseCase _createEventUseCase;
  late UpdateEventUseCase _updateEventUseCase;
  late GetHostEventsUseCase _getHostEventsUseCase;
  late UploadEventMediaUseCase _uploadEventMediaUseCase;
  late EventBloc _eventBloc;

  // Shared services
  late final SecureStorageService _storageService;
  late final Dio _dio;
  late final NetworkService _networkService;
  late final AppErrorHandlerService _errorHandlerService;
  late final CloudinaryService _mediaUploader;

  void setup() {
    _setupSharedServices();
    _setupAuthenticationDependencies();
    _setupHostProfileDependencies();
    _setupEventDependencies();
  }

  void _setupSharedServices() {
    _storageService = SecureStorageService();
    _dio = Dio()..interceptors.add(AuthInterceptor(_storageService, Dio()));
    _networkService = NetworkService(_dio);
    _errorHandlerService = AppErrorHandlerService();
    _mediaUploader = CloudinaryService(_storageService);
  }

  void _setupAuthenticationDependencies() {
    final remoteDatasource = HostRemoteDatasource(_networkService);

    _authRepository = HostRepositoryImpl(remoteDatasource);
    _loginUseCase = LoginUseCase(_authRepository);
    _otpUseCase = SendOtpUseCase(_authRepository);
    _signupUseCase = SignupUseCase(_authRepository);
    _logoutUseCase = LogoutUseCase(_authRepository);
    _resendOtpUseCase = ResendOtpUseCase(_authRepository);

    final verifyResetPasswordOtpUseCase =
        VerifyResetPasswordOtpUseCase(_authRepository);

    _authBloc = AuthBloc(
      otpUsecase: _otpUseCase,
      loginUseCase: _loginUseCase,
      signupUseCase: _signupUseCase,
      resendOtpUseCase: _resendOtpUseCase,
      logoutUseCase: _logoutUseCase,
      authRepository: _authRepository,
      verifyResetPasswordOtpUseCase: verifyResetPasswordOtpUseCase,
      storageService: _storageService,
      errorHandler: _errorHandlerService,
    );
  }

  void _setupHostProfileDependencies() {
    final cloudinaryService = CloudinaryService(_storageService);
    final profileImageRepository =
        ProfileImageRepositoryImpl(cloudinaryService);
    final uploadProfileImageUseCase =
        UploadProfileImageUseCase(profileImageRepository);

    _hostProfileRemoteDatasource = HostProfileRemoteDataSourceImpl(
      storageService: _storageService,
      dio: _dio,
    );

    _hostProfileRepository =
        HostProfileRepositoryImpl(_hostProfileRemoteDatasource);
    _getUserProfileUseCase = GetHostProfileUseCase(_hostProfileRepository);
    _updateUserProfileUseCase =
        UpdateHostProfileUseCase(_hostProfileRepository);

    _hostProfileBloc = HostProfileBloc(
      getHostProfile: _getUserProfileUseCase,
      updateHostProfile: _updateUserProfileUseCase,
      uploadProfileImage: uploadProfileImageUseCase,
      storageService: _storageService,
    );
  }

  void _setupEventDependencies() {
    final eventMediaUploader = _mediaUploader as CloudinaryService;
    _eventRemoteDataSource = EventRemoteDataSourceImpl(
        _networkService, _storageService, eventMediaUploader);
    _eventRepository = EventRepositoryImpl(_eventRemoteDataSource);
    _categoriesUseCase = CategoriesUseCase(_eventRepository);
    _createEventUseCase = CreateEventUseCase(_eventRepository);
    _updateEventUseCase = UpdateEventUseCase(_eventRepository);
    _getHostEventsUseCase = GetHostEventsUseCase(_eventRepository);
    _uploadEventMediaUseCase = UploadEventMediaUseCase(_eventRepository);

    _eventBloc = EventBloc(
      createEventUseCase: _createEventUseCase,
      updateEventUseCase: _updateEventUseCase,
      getHostEventsUseCase: _getHostEventsUseCase,
      uploadEventMediaUseCase: _uploadEventMediaUseCase,
      storageService: _storageService,
      categoriesUseCase: _categoriesUseCase,
    );
  }

  // Getters
  AuthBloc get authBloc => _authBloc;
  HostProfileBloc get hostProfileBloc => _hostProfileBloc;
  EventBloc get eventBloc => _eventBloc;
}
