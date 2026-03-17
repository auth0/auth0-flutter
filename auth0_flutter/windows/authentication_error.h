/**
 * @file authentication_error.h
 * @brief Error class for Auth0 Authentication API errors
 *
 * Provides comprehensive error information for consistent cross-platform behavior
 */

#pragma once

#include <string>
#include <stdexcept>
#include <map>
#include <cpprest/json.h>

namespace auth0_flutter
{

    /**
     * @brief Error thrown when an Authentication API request fails
     *
     * Provides detailed error information to ensure consistent
     * error handling across platforms.
     */
    class AuthenticationError : public std::runtime_error
    {
    public:
        /**
         * @brief Construct from error code and description
         */
        AuthenticationError(
            const std::string &code,
            const std::string &description,
            int statusCode = 0)
            : std::runtime_error("An error occurred when trying to authenticate with the server."),
              code_(code),
              description_(description),
              statusCode_(statusCode)
        {
        }

        /**
         * @brief Construct from JSON error response
         *
         * Parses the error response from Auth0 API, supporting both:
         * - Modern format: { "error": "...", "error_description": "..." }
         * - Legacy format: { "code": "...", "description": "..." }
         */
        AuthenticationError(
            const web::json::value &errorJson,
            int statusCode)
            : std::runtime_error("An error occurred when trying to authenticate with the server."),
              statusCode_(statusCode)
        {
            // Try modern format first: "error" and "error_description"
            if (errorJson.has_field(U("error")))
            {
                code_ = GetJsonString(errorJson, U("error"));
            }
            else if (errorJson.has_field(U("code")))
            {
                // Fallback to legacy format
                code_ = GetJsonString(errorJson, U("code"));
            }
            else
            {
                code_ = "UNKNOWN_ERROR";
            }

            // Try "error_description" first, then "description"
            if (errorJson.has_field(U("error_description")))
            {
                description_ = GetJsonString(errorJson, U("error_description"));
            }
            else if (errorJson.has_field(U("description")))
            {
                description_ = GetJsonString(errorJson, U("description"));
            }
            else
            {
                description_ = "Failed with error code: " + code_;
            }

            // Store the full error JSON for additional fields (like mfa_token)
            errorJson_ = errorJson;
        }

        /**
         * @brief Get the error code
         *
         * Examples: "invalid_grant", "access_denied", "invalid_client", etc.
         */
        const std::string &GetCode() const { return code_; }

        /**
         * @brief Get the error description
         *
         * Important: Avoid displaying this to the user, it's for debugging only
         */
        const std::string &GetDescription() const { return description_; }

        /**
         * @brief Get the HTTP status code
         */
        int GetStatusCode() const { return statusCode_; }

        /**
         * @brief Get a value from the error JSON
         *
         * Used for additional fields like "mfa_token"
         */
        std::string GetValue(const std::string &key) const
        {
            utility::string_t wkey = utility::conversions::to_string_t(key);
            if (errorJson_.has_field(wkey))
            {
                return GetJsonString(errorJson_, wkey);
            }
            return std::string();
        }

        /**
         * @brief Check if this is an invalid credentials error
         *
         * Cross-platform helper: isInvalidCredentials
         */
        bool IsInvalidCredentials() const
        {
            return code_ == "invalid_user_password" ||
                   (code_ == "invalid_grant" && description_ == "Wrong email or password.") ||
                   (code_ == "invalid_grant" && description_ == "Wrong phone number or verification code.") ||
                   (code_ == "invalid_grant" && description_ == "Wrong email or verification code.");
        }

        /**
         * @brief Check if this is an access denied error
         *
         * Cross-platform helper: isAccessDenied
         */
        bool IsAccessDenied() const
        {
            return code_ == "access_denied";
        }

        /**
         * @brief Check if MFA is required
         *
         * Cross-platform helper: isMultifactorRequired
         */
        bool IsMultifactorRequired() const
        {
            return code_ == "mfa_required" || code_ == "a0.mfa_required";
        }

        /**
         * @brief Check if this is a network error
         *
         * Cross-platform helper: isNetworkError
         *
         * Only status code 0 qualifies: the HTTP request never completed
         * (no connection, DNS failure, timeout before any response, etc.).
         * A 5xx response means the server replied — the network was reachable,
         * so that is a server error, not a network error.
         */
        bool IsNetworkError() const
        {
            return statusCode_ == 0;
        }

        /**
         * @brief Check if refresh token is deleted
         *
         * Cross-platform helper: isRefreshTokenDeleted
         */
        bool IsRefreshTokenDeleted() const
        {
            return code_ == "invalid_grant" &&
                   statusCode_ == 403 &&
                   description_ == "The refresh_token was generated for a user who doesn't exist anymore.";
        }

        /**
         * @brief Check if refresh token is invalid
         *
         * Cross-platform helper: isInvalidRefreshToken
         */
        bool IsInvalidRefreshToken() const
        {
            return code_ == "invalid_grant" &&
                   description_ == "Unknown or invalid refresh token.";
        }

        /**
         * @brief Check if password is not strong enough
         *
         * Cross-platform helper: isPasswordNotStrongEnough
         */
        bool IsPasswordNotStrongEnough() const
        {
            return code_ == "invalid_password" &&
                   GetValue("name") == "PasswordStrengthError";
        }

        /**
         * @brief Check if password was already used
         *
         * Cross-platform helper: isPasswordAlreadyUsed
         */
        bool IsPasswordAlreadyUsed() const
        {
            return code_ == "invalid_password" &&
                   GetValue("name") == "PasswordHistoryError";
        }

        /**
         * @brief Check if password leaked
         *
         * Cross-platform helper: isPasswordLeaked
         */
        bool IsPasswordLeaked() const
        {
            return code_ == "password_leaked";
        }

        /**
         * @brief Check if too many login attempts
         *
         * Cross-platform helper: isTooManyAttempts
         */
        bool IsTooManyAttempts() const
        {
            return code_ == "too_many_attempts";
        }

        /**
         * @brief Check if login is required (prompt=none scenario)
         *
         * Cross-platform helper: isLoginRequired
         */
        bool IsLoginRequired() const
        {
            return code_ == "login_required";
        }

        /**
         * @brief Check if MFA enrollment is required
         *
         * Cross-platform helper: isMultifactorEnrollRequired
         */
        bool IsMultifactorEnrollRequired() const
        {
            return code_ == "a0.mfa_registration_required";
        }

        /**
         * @brief Check if the MFA code is invalid
         *
         * Cross-platform helper: isMultifactorCodeInvalid
         */
        bool IsMultifactorCodeInvalid() const
        {
            return code_ == "a0.mfa_invalid_code";
        }

        /**
         * @brief Check if the MFA token is invalid
         *
         * Cross-platform helper: isMultifactorTokenInvalid
         */
        bool IsMultifactorTokenInvalid() const
        {
            return (code_ == "expired_token" && description_ == "mfa_token is expired") ||
                   code_ == "invalid_grant";
        }

        /**
         * @brief Check if email/phone verification is required
         *
         * Cross-platform helper: isVerificationRequired
         */
        bool IsVerificationRequired() const
        {
            return code_ == "requires_verification";
        }

        /**
         * @brief Check if this is a rule error
         *
         * Cross-platform helper: isRuleError
         */
        bool IsRuleError() const
        {
            return code_ == "unauthorized";
        }

        /**
         * @brief Always false on Windows — browser app availability is not applicable
         *
         * Cross-platform helper: isBrowserAppNotAvailable
         */
        bool IsBrowserAppNotAvailable() const { return false; }

        /**
         * @brief Always false on Windows — PKCE availability check is not applicable
         *
         * Cross-platform helper: isPKCENotAvailable
         */
        bool IsPKCENotAvailable() const { return false; }

        /**
         * @brief Always false on Windows — authorize URL validation is not applicable
         *
         * Cross-platform helper: isInvalidAuthorizeURL
         */
        bool IsInvalidAuthorizeURL() const { return false; }

        /**
         * @brief Always false on Windows — configuration validation is not applicable
         *
         * Cross-platform helper: isInvalidConfiguration
         */
        bool IsInvalidConfiguration() const { return false; }

        /**
         * @brief Always false on Windows — cancellation is handled at the web auth layer, not here
         *
         * Cross-platform helper: isCanceled
         */
        bool IsCanceled() const { return false; }

    private:
        std::string code_;
        std::string description_;
        int statusCode_;
        web::json::value errorJson_;

        static std::string GetJsonString(
            const web::json::value &json,
            const utility::string_t &key)
        {
            if (json.has_field(key) && json.at(key).is_string())
            {
                return utility::conversions::to_utf8string(json.at(key).as_string());
            }
            return std::string();
        }
    };

} // namespace auth0_flutter
