#include "credentials.h"

#include "jwt_util.h"
#include "time_util.h"

// UserProfile Credentials::GetUser() const {

//   auto payloadJson = DecodeJwtPayload(idToken);
//   return UserProfile::FromJwtPayload(payloadJson);
// }

// flutter::EncodableMap Credentials::ToEncodableMap() const {
//   flutter::EncodableMap map;

//   map[flutter::EncodableValue("accessToken")] = flutter::EncodableValue(accessToken);
//   map[flutter::EncodableValue("idToken")] = flutter::EncodableValue(idToken);
//   map[flutter::EncodableValue("tokenType")] = flutter::EncodableValue(tokenType);

//   if (refreshToken.has_value()) {
//     map[flutter::EncodableValue("refreshToken")] = flutter::EncodableValue(*refreshToken);
//   }

//   // expiresIn (seconds)
//   if (expiresIn.has_value()) {
//     map[flutter::EncodableValue("expiresIn")] =
//         flutter::EncodableValue(static_cast<int64_t>(*expiresIn));
//   }

//   // expiresAt (ISO-8601 string, same as Android)
//   if (expiresAt.has_value()) {
//     map[flutter::EncodableValue("expiresAt")] =
//         flutter::EncodableValue(ToIso8601(*expiresAt));
//   }

//   // scope list
//   if (!scope.empty()) {
//     flutter::EncodableList scopes;
//     for (const auto& s : scope) {
//       scopes.emplace_back(s);
//     }
//     map[flutter::EncodableValue("scope")] = flutter::EncodableValue(scopes);
//   }

// //  ✅ Computed user property
//  map[flutter::EncodableValue("userProfile")] = flutter::EncodableValue(GetUser().ToEncodableMap());

//   return map;
// }