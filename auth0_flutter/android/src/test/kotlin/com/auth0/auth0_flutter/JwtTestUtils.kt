package com.auth0.auth0_flutter

import com.auth0.jwt.JWT
import com.auth0.jwt.algorithms.Algorithm

class JwtTestUtils {
    companion object {
        fun createJwt(claims: Map<String, Any> = mapOf()): String {
            val alg = Algorithm.HMAC256("test")
            return JWT.create().withIssuer("test").sign(alg)
        }
    }
}
