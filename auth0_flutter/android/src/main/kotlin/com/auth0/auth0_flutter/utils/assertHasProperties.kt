package com.auth0.auth0_flutter.utils

fun tryGetByKey(data: Any?, key: String): Any? {
    if (data is Map<*, *>) {
        return data[key]
    }

    return null
}

fun assertHasProperties(requiredProperties: List<String>, data: Map<*, *>, prefix: String? = null) {
    val missingProperties =
        requiredProperties.filter {
            it.split('.')
                .fold(data) { acc: Any?, key: String -> tryGetByKey(acc, key) } == null
        }

    missingProperties
        .map { if (prefix != null) "$prefix.$it" else it }
        .forEach { throw IllegalArgumentException("Required property '$it' is not provided.") }
}
