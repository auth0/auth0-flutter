package com.auth0.auth0_flutter.utils

import org.hamcrest.CoreMatchers.equalTo
import org.hamcrest.MatcherAssert.assertThat
import org.junit.Assert.assertThrows
import org.junit.Test
import org.junit.runner.RunWith
import org.mockito.kotlin.*
import org.robolectric.RobolectricTestRunner

@RunWith(RobolectricTestRunner::class)
class AssertHasPropertiesTest {
    @Test
    fun `should not throw when all properties exactly equal`() {
        assertHasProperties(listOf("test", "test2"), mapOf("test" to "test", "test2" to "test2"));

        assertThat(true, equalTo(true));
    }

    @Test
    fun `should not throw when contains at least all properties`() {
        assertHasProperties(listOf("test", "test2"), mapOf("test" to "test", "test2" to "test2", "test3" to "test3"));

        assertThat(true, equalTo(true));
    }

    @Test
    fun `should not throw when nested property found`() {
        assertHasProperties(listOf("test", "test.prop"), mapOf("test" to mapOf("prop" to "value")));

        assertThat(true, equalTo(true));
    }

    @Test
    fun `should throw when nested property not found`() {
        val exception = assertThrows(IllegalArgumentException::class.java) {
            assertHasProperties(listOf("test", "test.prop"), mapOf("test2" to mapOf("prop" to "value")));
        }

        assertThat(exception.message, equalTo("Required property 'test' is not provided."));
    }

    @Test
    fun `should throw when nested sub property not found`() {
        val exception = assertThrows(IllegalArgumentException::class.java) {
            assertHasProperties(listOf("test", "test.prop"), mapOf("test" to mapOf("prop2" to "value")));
        }

        assertThat(exception.message, equalTo("Required property 'test.prop' is not provided."));
    }

    @Test
    fun `should throw when no properties found`() {
        val exception = assertThrows(IllegalArgumentException::class.java) {
            assertHasProperties(listOf("test", "test2"), mapOf("test3" to "test3", "test4" to "test4"));
        }

        assertThat(exception.message, equalTo("Required property 'test' is not provided."));
    }

    @Test
    fun `should throw when some properties not found`() {
        val exception = assertThrows(IllegalArgumentException::class.java) {
            assertHasProperties(listOf("test", "test2"), mapOf("test" to "test", "test3" to "test3"));
        }

        assertThat(exception.message, equalTo("Required property 'test2' is not provided."));
    }

}
