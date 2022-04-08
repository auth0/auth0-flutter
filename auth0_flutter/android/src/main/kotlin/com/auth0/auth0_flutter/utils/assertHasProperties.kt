package com.auth0.auth0_flutter.utils

fun assertHasProperties (requiredProperties: List<String>, data: Map<*, *>) {
    var missingProperties = requiredProperties.filter { data[it] == null };

    missingProperties.forEach { throw NullPointerException("Required property '$it' is not provided.") }
}
