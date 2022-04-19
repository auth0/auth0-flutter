package com.auth0.auth0_flutter.utils

fun assertHasProperties(requiredProperties: List<String>, data: Map<*, *>) {
    var missingProperties =
        requiredProperties.filter {
            it.split('.')
                .fold(data) { acc: Any?, v: String -> (acc as Map<*, *>?)?.get(v) } == null
        };

    missingProperties.forEach { throw NullPointerException("Required property '$it' is not provided.") }
}
