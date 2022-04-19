package com.auth0.auth0_flutter.utils

fun tryGetByKey(data: Any?, key: String): Any? {
    if (data is Map<*, *>) {
        return data[key];
    }

    return null;
}

fun assertHasProperties(requiredProperties: List<String>, data: Map<*, *>) {
    var missingProperties =
        requiredProperties.filter {
            it.split('.')
                .fold(data) { acc: Any?, key: String -> tryGetByKey(acc, key) } == null
        };

    missingProperties.forEach { throw NullPointerException("Required property '$it' is not provided.") }
}
