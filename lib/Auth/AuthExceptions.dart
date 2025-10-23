// Login exception
class InvalidCredentialAuthException implements Exception {} //Invalid email or Password
class UserNotFoundAuthException implements Exception {}//User not found

class IllegalArgumentException implements Exception{} //Given String is empty or null

// Register exception
class InvalidEmailAuthException implements Exception{} //Enter a valid email
class WeakPasswordAuthException implements Exception{} //Password should be at least 6 characters
class EmailAlreadyInUseAuthException implements Exception{} //Email already in use

// EmailVerification exception
class FailedToSendEmailVerificationException implements Exception{}

// Generic exception
class GenericAuthException implements Exception{}

class UserNotLoggedInAuthException implements Exception{}

// twitter login exception
class TwitterSignInFailedAuthException implements Exception{}

// facebook login exception
class FacebookSignInFailedAuthException implements Exception{}

// google login exception
class GoogleLoginFailureException implements Exception{}
class CancelledByUserAuthException implements Exception{}
