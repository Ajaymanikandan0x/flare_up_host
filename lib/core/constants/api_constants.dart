class ApiEndpoints {
  static const baseUrl = 'http://10.0.2.2:8081/';
  static const signUp =
      'register/'; //(post) username, fullname, email, phone_number, role, password
  static const otpVerification = 'otp_verification/'; //(post) email, enteredOtp
  static const login = 'login/'; // (post)username, password
  static const resendOtp = 'resend_otp/'; //(post) email
  static const user = 'user/user_id/'; //(get) all user id
  static const refreshToken = 'token_refresh/'; //(post) refresh_token
  static const logout = 'logout/'; //(post)  just send a request
  static const updateUserProfile =
      'user/user_id/update_user_profile/'; //(patch) username, fullname, phone_number, email, profile_publicId  update user profile
  static const googleAuth =
      'GoogleAuth/'; //(post) registration gToken,role  login gToken
  static const updatePassword =
      'user/user_id/set_password/'; //{’new_password’: ‘’, ‘confirm_password’: ‘'
  static const forgotPassword = 'forgot-password/'; //(post) email
  static const verifyOtpForgotPassword =
      'verify-otp-forgot-password/'; //(post) email, enteredOtp
  static const setNewPassword =
      'set-new-password/'; //(post) new_password, confirm_password, email

  //Events
  static const eventBaseUrl = 'http://10.0.2.2:8082/';
  static const createEvent =
      'events/'; //(post)   'title', 'description', 'category', 'type', 'host_id', 'organization_id',
  //'latitude', 'longitude', 'address_line_1', 'city', 'state', 'country',
  //'payment_required', 'ticket_price', 'participant_capacity', 'banner_image',
  //'promo_video', 'start_date_time', 'end_date_time', 'registration_deadline',

  static const editEvent = 'events/event/event_id/'; //(put)
  static const hosterEvent =
      'events/events/hoster/hoster_id/'; //(get) To fetch all events of a particular hoster
//'id', 'title', 'description', 'category', 'type', 'host_id', 'organization_id',
//             'latitude', 'longitude', 'address_line_1', 'city', 'state', 'country',
//             'payment_required', 'ticket_price', 'participant_capacity', 'banner_image',
//             'promo_video', 'start_date_time', 'end_date_time', 'registration_deadline',
//             'created_at', 'updated_at', 'status', 'status_request', 'approval_status', 'approval_comments',
//             'approval_updated_at', 'key_participants'
  static const eventStatus =
      'events/event/event_id/update_event_status/'; //(post)  Key : event_status
  //Values : 'Active', 'Cancelled', 'Cancel status request’

  static const eventCategory = 'events/event-types-and-categories/'; //(get) []
}
