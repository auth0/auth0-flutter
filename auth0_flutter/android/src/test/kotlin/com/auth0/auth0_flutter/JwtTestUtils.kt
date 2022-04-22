package com.auth0.auth0_flutter

import com.auth0.jwt.JWT
import com.auth0.jwt.algorithms.Algorithm

class JwtTestUtils {
    companion object {
        fun createJwt(
            subject: String = "test-subject",
            issuer: String = "test-issuer",
            claims: Map<String, String> = mapOf()
        ): String {
            val alg = Algorithm.HMAC256("test")
            val jwt = JWT.create().withIssuer(issuer).withSubject(subject)

            claims.entries.forEach { jwt.withClaim(it.key, it.value) }

            return jwt.sign(alg)
        }
    }
}
